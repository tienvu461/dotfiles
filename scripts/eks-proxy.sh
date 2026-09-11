#!/usr/bin/env bash
# eks-proxy.sh — SSM port-forward tunnel to EKS via a bastion, with kubectl context setup
#
# SETUP
#   1. Install dependencies:
#        brew install --cask session-manager-plugin
#        pip3 install pyyaml          # or: pip3 install --user pyyaml
#
#   2. Place this script somewhere on $PATH, e.g.:
#        ln -s ~/workspace/00_dotfiles/dotfiles/scripts/eks-proxy.sh ~/.local/bin/eks-proxy
#
#   3. Create config file at ~/.config/eks-proxy.yaml — example:
#        clusters:
#          mycluster:
#            aws_profile:  your-aws-profile
#            cluster_name: your-cluster-name
#            region:       eu-west-1
#            kube_context: mycluster
#            bastion:      i-xxxxxxxxxxxxxxxxx
#            local_port:   8443          # optional, default 8443
#            role_arn:     arn:aws:iam::123456789012:role/custom-role  # optional
#
# HOW IT WORKS
#   - Opens an SSM port-forward from localhost:<local_port> -> EKS API (port 443) via bastion
#   - Updates the kubeconfig context to point kubectl at localhost:<local_port>
#   - Injects --role-arn into the kubeconfig exec credential so kubectl assumes
#     the EKS admin role only for token generation (AWS ops use aws_profile as-is)
#   - auto-resolves role to eks-cluster-admin-role-{nonprod|prod} if role_arn omitted
#
# USAGE
#   eks-proxy <cluster-key> [-b <bastion-id>] [-R <role-arn>] [-l <local-port>]
#   eks-proxy              # lists available cluster keys from config

set -euo pipefail

CONFIG_FILE="${HOME}/.config/eks-proxy.yaml"

usage() {
  echo "Usage: $0 <cluster-key> [-b <bastion-id>] [-R <role-arn>] [-l <local-port>]"
  echo ""
  echo "  <cluster-key>  key from ${CONFIG_FILE}"
  echo "  -b             override bastion instance ID"
  echo "  -R             override IAM role ARN for EKS auth"
  echo "  -l             override local port"
  echo ""
  echo "Available clusters:"
  python3 - <<'EOF'
import yaml, os, sys
cfg = yaml.safe_load(open(os.path.expanduser("~/.config/eks-proxy.yaml")))
for k in cfg.get("clusters", {}):
    c = cfg["clusters"][k]
    print(f"  {k:20s}  {c.get('cluster_name','')}  ({c.get('region','')})")
EOF
  exit 1
}

[[ $# -eq 0 ]] && usage

CLUSTER_KEY="$1"
shift

OVERRIDE_BASTION=""
OVERRIDE_ROLE_ARN=""
OVERRIDE_PORT=""

while getopts "b:R:l:h" opt; do
  case $opt in
    b) OVERRIDE_BASTION="$OPTARG" ;;
    R) OVERRIDE_ROLE_ARN="$OPTARG" ;;
    l) OVERRIDE_PORT="$OPTARG" ;;
    h) usage ;;
    *) usage ;;
  esac
done

# load config values via python3
read -r AWS_PROFILE CLUSTER_NAME AWS_REGION KUBE_CONTEXT BASTION_INSTANCE LOCAL_PORT ROLE_ARN < <(python3 - <<EOF
import yaml, os, sys

cfg = yaml.safe_load(open(os.path.expanduser("~/.config/eks-proxy.yaml")))
clusters = cfg.get("clusters", {})
key = "$CLUSTER_KEY"

if key not in clusters:
    print(f"ERROR: cluster key '{key}' not found in config", file=sys.stderr)
    known = ", ".join(clusters.keys())
    print(f"Known keys: {known}", file=sys.stderr)
    sys.exit(1)

c = clusters[key]
required = ["aws_profile", "cluster_name", "region", "kube_context", "bastion"]
for r in required:
    if r not in c:
        print(f"ERROR: missing '{r}' for cluster '{key}'", file=sys.stderr)
        sys.exit(1)

print(
    c["aws_profile"],
    c["cluster_name"],
    c["region"],
    c["kube_context"],
    c["bastion"],
    str(c.get("local_port", 8443)),
    c.get("role_arn", ""),
)
EOF
)

# apply CLI overrides
[[ -n "$OVERRIDE_BASTION" ]] && BASTION_INSTANCE="$OVERRIDE_BASTION"
[[ -n "$OVERRIDE_PORT" ]]    && LOCAL_PORT="$OVERRIDE_PORT"
[[ -n "$OVERRIDE_ROLE_ARN" ]] && ROLE_ARN="$OVERRIDE_ROLE_ARN"

export AWS_PROFILE

# auto-resolve role ARN if not set
if [[ -z "$ROLE_ARN" ]]; then
  echo "==> Resolving account ID..."
  ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
  if [[ "$CLUSTER_NAME" == *"prod"* && "$CLUSTER_NAME" != *"nonprod"* ]]; then
    ENV_SUFFIX="prod"
  else
    ENV_SUFFIX="nonprod"
  fi
  ROLE_ARN="arn:aws:iam::${ACCOUNT_ID}:role/eks-cluster-admin-role-${ENV_SUFFIX}"
  echo "    Role: $ROLE_ARN"
fi

echo "==> Fetching EKS endpoint for cluster: $CLUSTER_NAME"
EKS_ENDPOINT=$(aws eks describe-cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --query 'cluster.endpoint' \
  --output text)

EKS_HOST="${EKS_ENDPOINT#https://}"
echo "    Endpoint: $EKS_HOST"

echo "==> Updating kubeconfig for context: $KUBE_CONTEXT"
aws eks update-kubeconfig \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --alias "$KUBE_CONTEXT" \
  --role-arn "$ROLE_ARN"

CLUSTER_ENTRY=$(kubectl config view -o jsonpath="{.contexts[?(@.name==\"$KUBE_CONTEXT\")].context.cluster}")

kubectl config set-cluster "$CLUSTER_ENTRY" \
  --server="https://localhost:$LOCAL_PORT" \
  --tls-server-name="$EKS_HOST"

echo "==> Starting SSM tunnel: $BASTION_INSTANCE -> $EKS_HOST:443 (local: $LOCAL_PORT)"
echo "    kubectl context '$KUBE_CONTEXT' ready — keep this terminal open"
echo ""

aws ssm start-session \
  --target "$BASTION_INSTANCE" \
  --region "$AWS_REGION" \
  --document-name AWS-StartPortForwardingSessionToRemoteHost \
  --parameters "{\"host\":[\"$EKS_HOST\"],\"portNumber\":[\"443\"],\"localPortNumber\":[\"$LOCAL_PORT\"]}"
