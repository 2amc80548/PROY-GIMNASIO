#!/usr/bin/env bash
# scripts/bootstrap-backend.sh
# Crea (si no existen) el bucket S3 y la tabla DynamoDB para el state remoto
# de Terraform. Se corre UNA sola vez por entorno.
set -euo pipefail

: "${TF_STATE_BUCKET:?Definí TF_STATE_BUCKET, ej: export TF_STATE_BUCKET=gimnasio-tfstate-tony123}"
: "${AWS_REGION:=us-east-1}"
TF_LOCK_TABLE="${TF_LOCK_TABLE:-gimnasio-tflock}"

echo "→ Bucket:  $TF_STATE_BUCKET"
echo "→ Tabla:   $TF_LOCK_TABLE"
echo "→ Región:  $AWS_REGION"

if ! aws s3api head-bucket --bucket "$TF_STATE_BUCKET" 2>/dev/null; then
  echo "Creando bucket..."
  if [[ "$AWS_REGION" == "us-east-1" ]]; then
    aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_REGION"
  else
    aws s3api create-bucket --bucket "$TF_STATE_BUCKET" --region "$AWS_REGION" \
      --create-bucket-configuration LocationConstraint="$AWS_REGION"
  fi
  aws s3api put-bucket-versioning --bucket "$TF_STATE_BUCKET" \
    --versioning-configuration Status=Enabled
  aws s3api put-bucket-encryption --bucket "$TF_STATE_BUCKET" \
    --server-side-encryption-configuration '{"Rules":[{"ApplyServerSideEncryptionByDefault":{"SSEAlgorithm":"AES256"}}]}'
  aws s3api put-public-access-block --bucket "$TF_STATE_BUCKET" \
    --public-access-block-configuration 'BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true'
  echo " Bucket creado"
else
  echo " Bucket ya existe"
fi

if ! aws dynamodb describe-table --table-name "$TF_LOCK_TABLE" --region "$AWS_REGION" >/dev/null 2>&1; then
  echo "Creando tabla de lock..."
  aws dynamodb create-table \
    --table-name "$TF_LOCK_TABLE" \
    --attribute-definitions AttributeName=LockID,AttributeType=S \
    --key-schema AttributeName=LockID,KeyType=HASH \
    --billing-mode PAY_PER_REQUEST \
    --region "$AWS_REGION" >/dev/null
  aws dynamodb wait table-exists --table-name "$TF_LOCK_TABLE" --region "$AWS_REGION"
  echo " Tabla creada"
else
  echo " Tabla ya existe"
fi

echo ""
