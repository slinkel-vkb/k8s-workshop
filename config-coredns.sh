#!/usr/bin/env bash

set -e

INGRESS_HOST=$(kubectl get service traefik --namespace kube-system --output jsonpath='{.status.loadBalancer.ingress[0].ip}')

kubectl apply -f - <<EOF
apiVersion: v1
kind: ConfigMap
metadata:
  name: coredns-custom
  namespace: kube-system
data:
  internal.server: |
    internal:53 {
      rewrite name regex .*\.internal internal
      hosts {
        ${INGRESS_HOST} internal
      }
    }
EOF

kubectl rollout restart -n kube-system deployment/coredns
