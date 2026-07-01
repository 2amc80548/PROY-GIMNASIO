#!/usr/bin/env bash
set -euo pipefail

ASSUME_YES=0
KEEP_LOCAL=0
for arg in "$@"; do
  case "$arg" in
    --yes|-y)     ASSUME_YES=1 ;;
    --keep-local) KEEP_LOCAL=1 ;;
    -h|--help)
      echo "Uso: ./destroy.sh [--yes] [--keep-local]"
      exit 0
      ;;
    *) echo "Argumento desconocido: $arg" >&2; exit 2 ;;
  esac
done

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
ok()   { printf "${C_GREEN}OK${C_RESET} %s\n" "$1"; }
warn() { printf "${C_YELLOW}!!${C_RESET} %s\n" "$1"; }
die()  { printf "${C_RED}ERROR: %s${C_RESET}\n" "$1" >&2; exit 1; }

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TF_DIR="$PROJECT_ROOT/terraform/option-b-ecs"

step "1/4" "Pre-flight checks"
for bin in terraform aws; do
  command -v "$bin" >/dev/null 2>&1 || die "Falta '$bin' en el PATH."
done
ok "CLIs disponibles"

ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"
AWS_REGION="$(aws configure get region || echo us-east-1)"
ok "Cuenta AWS autenticada: $ACCOUNT_ID ($AWS_REGION)"

if [[ $ASSUME_YES -eq 0 ]]; then
  echo
  printf "${C_YELLOW}Esta operación borra TODA la infraestructura en AWS.${C_RESET}\n"
  read -r -p "Escribe 'destroy' para confirmar: " REPLY
  [[ "$REPLY" == "destroy" ]] || die "Cancelado."
fi

step "2/4" "Vaciando repositorios ECR (Gimnasio)"

empty_ecr_repo() {
  local repo="$1"
  if ! aws ecr describe-repositories --repository-names "$repo" --region "$AWS_REGION" >/dev/null 2>&1; then
    warn "Repo '$repo' no existe, salteando."
    return 0
  fi

  local image_ids
  image_ids="$(aws ecr list-images --repository-name "$repo" --region "$AWS_REGION" --query 'imageIds[*]' --output json)"

  if [[ "$image_ids" == "[]" || -z "$image_ids" ]]; then
    ok "Repo '$repo' ya está vacío"
    return 0
  fi

  aws ecr batch-delete-image --repository-name "$repo" --region "$AWS_REGION" --image-ids "$image_ids" >/dev/null
  ok "Repo '$repo' vaciado exitosamente"
}

# Vaciamos los 3 repositorios de nuestro Gimnasio
empty_ecr_repo "gestion-gimnasio/members"
empty_ecr_repo "gestion-gimnasio/billing"
empty_ecr_repo "gestion-gimnasio/access-control"

step "3/4" "Terraform destroy"
pushd "$TF_DIR" >/dev/null
terraform init -input=false >/dev/null
terraform destroy -auto-approve -input=false
popd >/dev/null
ok "Recursos AWS destruidos"

step "4/4" "Limpieza local de imágenes Docker"
if [[ $KEEP_LOCAL -eq 1 ]]; then
  warn "Se omite la limpieza de imágenes Docker locales"
else
  if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
    ECR_REGISTRY="${ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    LOCAL_IMAGES="$(docker images --format '{{.Repository}}:{{.Tag}}' | grep -E "(^${ECR_REGISTRY}/gestion_gimnasio/(members|billing|access-control))" || true)"
    if [[ -n "$LOCAL_IMAGES" ]]; then
      echo "$LOCAL_IMAGES" | xargs -r docker rmi -f >/dev/null 2>&1 || true
      ok "Imágenes Docker locales borradas"
    else
      ok "No hay imágenes Docker locales para borrar"
    fi
  fi
fi

cat <<EOF

${C_GREEN}========================================${C_RESET}
${C_GREEN} Infraestructura destruida al 100%${C_RESET}
${C_GREEN}========================================${C_RESET}
EOF