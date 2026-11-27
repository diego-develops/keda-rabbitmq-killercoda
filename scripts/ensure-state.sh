#!/bin/bash
# Idempotent setup so any step can be opened directly.
# Metrics Server (step 3) and KEDA (step 4) are installed by the step text itself.
# Usage: ensure-state.sh <step number>
STEP="${1:-1}"
REPO=/root/keda-rabbitmq-killercoda

for i in $(seq 1 60); do [ -d "$REPO/kubernetes" ] && break; sleep 2; done
cd "$REPO" || exit 1
for i in $(seq 1 60); do kubectl get nodes >/dev/null 2>&1 && break; sleep 2; done

# Step 1 deploys the base app itself.
[ "$STEP" -le 1 ] && exit 0

# RabbitMQ + worker are required by steps 2-4.
kubectl apply -f kubernetes/base/ >/dev/null
kubectl rollout status deployment/rabbitmq --timeout=180s
kubectl rollout status deployment/worker --timeout=180s

# Remove autoscalers that would compete with the experiment of this step.
if [ "$STEP" != "3" ]; then
  kubectl delete -f kubernetes/hpa/worker-hpa.yaml --ignore-not-found >/dev/null 2>&1 || true
fi
if [ "$STEP" != "4" ]; then
  kubectl delete -f kubernetes/keda/scaledobject.yaml --ignore-not-found >/dev/null 2>&1 || true
fi
exit 0
