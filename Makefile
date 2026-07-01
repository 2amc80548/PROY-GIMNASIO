# Makefile — atajos para Gimnasio (dev local, prod local, ECS en AWS).
.ONESHELL:
ifeq ($(OS),Windows_NT)
    SHELL := C:/PROGRA~1/Git/bin/bash.exe
else
    SHELL := /bin/bash
endif
.SHELLFLAGS := -euo pipefail -c

TF_DIR     := terraform/option-b-ecs
AWS_REGION ?= us-east-1
IMAGE_TAG  ?= latest

.PHONY: help up down prod-up prod-down init plan apply outputs login build push redeploy deploy verify services logs-members logs-billing logs-access-control logs-nats destroy nuke clean

help:  ## Lista los targets disponibles
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	  | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

up:  ## Levanta NATS + MySQL local
	docker compose up -d

down:  ## Baja NATS + MySQL local
	docker compose down

init:  ## terraform init en el módulo ECS
	cd $(TF_DIR) && terraform init

plan:  ## terraform plan
	cd $(TF_DIR) && terraform plan

apply:  ## terraform apply
	cd $(TF_DIR) && terraform apply

outputs:  ## Imprime los outputs de Terraform
	cd $(TF_DIR) && terraform output

login:  ## Login de Docker contra ECR
	cd $(TF_DIR)
	ECR_URL=$$(terraform output -raw ecr_members_repository_url)
	ECR_REGISTRY=$${ECR_URL%/*}
	aws ecr get-login-password --region $(AWS_REGION) \
	  | docker login --username AWS --password-stdin "$$ECR_REGISTRY"

build:  ## Build de las 3 imágenes
	cd $(TF_DIR)
	URL_MEMBERS=$$(terraform output -raw ecr_members_repository_url)
	URL_BILLING=$$(terraform output -raw ecr_billing_repository_url)
	URL_ACCESS=$$(terraform output -raw ecr_access_control_repository_url)
	cd $(CURDIR)
	docker build --platform linux/amd64 -f apps/members/Dockerfile -t "$$URL_MEMBERS:$(IMAGE_TAG)" .
	docker build --platform linux/amd64 -f apps/billing/Dockerfile -t "$$URL_BILLING:$(IMAGE_TAG)" .
	docker build --platform linux/amd64 -f apps/access-control/Dockerfile -t "$$URL_ACCESS:$(IMAGE_TAG)" .

push: login build  ## Push de las 3 imágenes a ECR
	cd $(TF_DIR)
	URL_MEMBERS=$$(terraform output -raw ecr_members_repository_url)
	URL_BILLING=$$(terraform output -raw ecr_billing_repository_url)
	URL_ACCESS=$$(terraform output -raw ecr_access_control_repository_url)
	docker push "$$URL_MEMBERS:$(IMAGE_TAG)"
	docker push "$$URL_BILLING:$(IMAGE_TAG)"
	docker push "$$URL_ACCESS:$(IMAGE_TAG)"

redeploy:  ## force-new-deployment en ECS para los 3 servicios
	cd $(TF_DIR)
	CLUSTER=$$(terraform output -raw cluster_name)
	aws ecs update-service --cluster "$$CLUSTER" --service members --force-new-deployment --region $(AWS_REGION) >/dev/null
	aws ecs update-service --cluster "$$CLUSTER" --service billing --force-new-deployment --region $(AWS_REGION) >/dev/null
	aws ecs update-service --cluster "$$CLUSTER" --service access-control --force-new-deployment --region $(AWS_REGION) >/dev/null
	echo "Redeploy lanzado para los 3 servicios"

deploy:  ## Pipeline completo (Corre deploy.sh)
	bash ./deploy.sh

verify:  ## Testea el endpoint de members en el ALB
	cd $(TF_DIR)
	ALB_DNS=$$(terraform output -raw alb_dns_name)
	echo "GET http://$$ALB_DNS/members"
	curl -sS "http://$$ALB_DNS/members" && echo

services:  ## Estado de los servicios ECS
	cd $(TF_DIR)
	CLUSTER=$$(terraform output -raw cluster_name)
	aws ecs describe-services --cluster "$$CLUSTER" --services members billing access-control --region $(AWS_REGION) --query 'services[].{name:serviceName,running:runningCount,desired:desiredCount,status:status}' --output table

destroy:  ## Corre destroy.sh
	bash ./destroy.sh