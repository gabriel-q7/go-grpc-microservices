SHELL := /bin/bash
CLUSTER := dev
NS := micro

k3d-up:
	k3d cluster create $(CLUSTER) --servers 1 --agents 0 	--k3s-arg "--disable=traefik@server:0" 	--k3s-arg "--disable=servicelb@server:0"

k3d-down:
	k3d cluster delete $(CLUSTER)

build:
	docker build -t usersvc:dev -f services/usersvc/Dockerfile .
	docker build -t paymentsvc:dev -f services/paymentsvc/Dockerfile .
	docker build -t authsvc:dev -f services/authsvc/Dockerfile .

import:
	k3d image import usersvc:dev paymentsvc:dev authsvc:dev -c $(CLUSTER)

apply:
	kubectl apply -k deploy/kustomize/overlays/dev

restart:
	kubectl -n $(NS) rollout restart deploy/usersvc deploy/paymentsvc deploy/authsvc
