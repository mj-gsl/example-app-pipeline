## Terraform, ArgoCd und Example Application
Genutztes Repo https://github.com/Gitnicki/example-k8s-application
!Achtung: k ist ein Alias für kubectl und tf für terraform

## Git Repo Clonen (am besten Repo Forken und dann das eigene clonen)
git clone git@github.com:Gitnicki/example-k8s-application.git

## Dockernamen einfügen in der .github/workflows/build-and-push-image.yaml
## in Zeile 13 + 17 
## hier:             image: "docknicki/example-backend"

## Unter Repo Settings Secrets konfigurieren/erstellen
## DOCKER_USERNAME mit dem Username von Dockerhub
## DOCKER_TOKEN mit einem in Dockerhub erstellten Token

## mit AWS SSO einloggen
aws sso login

## terraform initiieren
tf init

## terraform planen
tf plan

## bei Problemen mit tf plan oder tf apply
## ggf. müssen der ingress-nginx und argocd manuell installiert werden
helm repo add argo https://argoproj.github.io/argo-helm
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
## können falls nötig so deleted werden und dann neu installiert werden
helm repo remove argo
helm repo remove ingress-nginx 
## habe in meinem Fall den Inhalt der ~/.kube/config komplett gelöscht

## terraform applyen
tf apply

## auf nodes und service überprüfen
k get nodes
k get svc -n ingress-nginx

## in der deployment/backend-deployment.yaml und der deployment/frontend-deployment.yaml
## muss jeweils in der Zeile 26 auch der Dockerhub-Name eingefügt werden
## hier:           image: docknicki/example-backend:v1.0.6 ## hinter dem : muss die aktuelle Versionsnr stehen

## in der svc findet man nun auch den hostlink
## dieser muss in der ingress/ingress.yaml auf zeile 10 eingefügt werden
## hier:     - host: ad34757af98b3407282e0e70e74519e9-1394244813.eu-central-1.elb.amazonaws.com

## diese Änderung muss jetzt applied werden
k apply -f ../ingress/ingress.yaml

## um die GithubAction-Pipeline loslaufen zu lassen
git tag -a v1.0.6 ## hier Versionsnummer eingeben
gps --tags ## gps ist ein Alias für git push

## nun den port-forward auf den port 4000 mappen
k port-forward svc/argocd-server -n argo-cd 4000:443

## das laufen lassen und in einer zweiten Gitbash weitermachen

## Um uns mit dem ArgoCD zu verbinden brauchen wir nun das Passwort für den admin
argocd admin initial-password -n argo-cd
## Ausgabe hier: bsppw1234

## nun bei argoCD einloggen
argocd login 127.0.0.1:4000 --insecure

## benutzername: admin
## passwort: bsppw1234

## nun auch auf http://localhost:4000 gehen und auch dort mit den selben daten einloggen

## application erstellen auf argocd (Achtung: Richtiges Repo eintragen)
argocd app create application --repo https://github.com/Gitnicki/example-k8s-application.git --path deployment --dest-server https://kubernetes.default.svc --server localhost:4000 --insecure

## application sync entweder über die argocd-seite auf dem localhost oder mit 
argocd app sync application

## application aufrufen unter dem Link von vorhin
k get svc -n ingress-nginx
## hier: http://ad34757af98b3407282e0e70e74519e9-1394244813.eu-central-1.elb.amazonaws.com

## ALLES wieder DESTROYEN
## alles in der main.tf, variables.tf und output.tf auskommentieren und dann
tf plan
tf apply 
## dadurch wird alles destroyed

## Änderungen müssen immer commited und gepushed werden
