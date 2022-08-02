kubectl := kubectl apply -f
database_path := app/microservices/database
system_path := app/microservices/system
portal_path := app/microservices/portal

all: cluster database system portal ingress

cluster:
	kind create cluster --config app/cluster/cluster-config.yaml

database: 
	${kubectl} ${database_path}/db-configmap.yaml
	${kubectl} ${database_path}/dp-news-db.yaml
	${kubectl} ${database_path}/svc-news-db.yaml

system: 
	${kubectl} ${system_path}/system-configmap.yaml
	${kubectl} ${system_path}/pvc/pvc-image.yaml
	${kubectl} ${system_path}/pvc/pvc-session.yaml
	${kubectl} ${system_path}/ss-news-system.yaml
	${kubectl} ${system_path}/svc-news-system.yaml

portal: 
	${kubectl} ${portal_path}/dp-news-portal.yaml
	${kubectl} ${portal_path}/svc-news-portal.yaml

ingress: 
	${kubectl} https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
	kubectl wait --namespace ingress-nginx \
				 --for=condition=ready pod \
				 --selector=app.kubernetes.io/component=controller \
				 --timeout=180s
	${kubectl} app/ingress/ingress-config.yaml

clean:
	kind delete cluster --name app-cluster