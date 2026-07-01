#!/usr/bin/env bash
set -euo pipefail

if [[ -t 1 ]] && command -v tput >/dev/null 2>&1 && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then
  C_GREEN="$(tput setaf 2)"
  C_YELLOW="$(tput setaf 3)"
  C_RED="$(tput setaf 1)"
  C_BLUE="$(tput setaf 4)"
  C_RESET="$(tput sgr0)"
else
  C_GREEN=""; C_YELLOW=""; C_RED=""; C_BLUE=""; C_RESET=""
fi

step() { printf "\n${C_BLUE}[%s]${C_RESET} %s\n" "$1" "$2"; }
ok()   { printf "${C_GREEN}✔${C_RESET} %s\n" "$1"; }
warn() { printf "${C_YELLOW}⚠${C_RESET} %s\n" "$1"; }
die()  { printf "${C_RED}✘ %s${C_RESET}\n" "$1" >&2; exit 1; }

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$PROJECT_ROOT/terraform/option-b-ecs"

step "1/6" "Pre-flight checks"
for bin in terraform aws docker; do
  command -v "$bin" >/dev/null 2>&1 || die "Falta '$bin' en el PATH."
done
ok "CLIs disponibles"

docker info >/dev/null 2>&1 || die "Docker no está corriendo. Iniciá Docker Desktop."
ok "Docker activo"

step "2/6" "Terraform init + apply (auto-aprobado)"
pushd "$TF_DIR" >/dev/null
terraform init -input=false
terraform apply -auto-approve -input=false
popd >/dev/null
ok "Infraestructura AWS aprovisionada"

step "3/6" "Extrayendo outputs de Terraform"
pushd "$TF_DIR" >/dev/null
URL_MEMBERS="$(terraform output -raw ecr_members_repository_url)"
URL_BILLING="$(terraform output -raw ecr_billing_repository_url)"
URL_ACCESS="$(terraform output -raw ecr_access_control_repository_url)"
ALB_DNS="$(terraform output -raw alb_dns_name)"
CLUSTER="$(terraform output -raw cluster_name)"
popd >/dev/null

REGISTRY="${URL_MEMBERS%/*}"
REGION="$(echo "$REGISTRY" | awk -F'.' '{print $4}')"

ok "ALB DNS: $ALB_DNS"

step "4/6" "Login a ECR"
aws ecr get-login-password --region "$REGION" | docker login --username AWS --password-stdin "$REGISTRY" >/dev/null
ok "Docker autenticado en ECR"

step "5/6" "Build y push de imágenes Docker"
cd "$PROJECT_ROOT"

echo "→ Construyendo y subiendo members..."
docker build --platform linux/amd64 -f apps/members/Dockerfile -t "$URL_MEMBERS:latest" .
docker push "$URL_MEMBERS:latest"

echo "→ Construyendo y subiendo billing..."
docker build --platform linux/amd64 -f apps/billing/Dockerfile -t "$URL_BILLING:latest" .
docker push "$URL_BILLING:latest"

echo "→ Construyendo y subiendo access-control..."
docker build --platform linux/amd64 -f apps/access-control/Dockerfile -t "$URL_ACCESS:latest" .
docker push "$URL_ACCESS:latest"
ok "Las 3 imágenes están en AWS"

step "6/6" "Forzando redeploy en ECS"
aws ecs update-service --cluster "$CLUSTER" --service members --force-new-deployment --region "$REGION" >/dev/null
aws ecs update-service --cluster "$CLUSTER" --service billing --force-new-deployment --region "$REGION" >/dev/null
aws ecs update-service --cluster "$CLUSTER" --service access-control --force-new-deployment --region "$REGION" >/dev/null

echo "Esperando a que los servicios queden estables (puede tardar 2-5 min)..."
if aws ecs wait services-stable --cluster "$CLUSTER" --services members billing access-control --region "$REGION"; then
  ok "Servicios estables y listos"
else
  warn "Timeout esperando. Revisa la consola de ECS."
fi

cat <<EOF

${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}
${C_GREEN} ¡DESPLIEGUE COMPLETADO CON ÉXITO!${C_RESET}
${C_GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${C_RESET}

URL pública del Gimnasio (API):
  http://${ALB_DNS}/members

Para destruir toda la infraestructura:
  make destroy

EOF