#For getting the Argo Pass:
kubectl get secret argocd-initial-admin-secret -n argo-cd -o jsonpath="{.data.password}" | base64 --decode; echo

