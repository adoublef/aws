include .env

tfinit: infra/main.tf
	@cd infra && terraform init
tfmt: infra/main.tf
	@cd infra && terraform fmt -check && terraform validate
dkbuild: Dockerfile
	@docker build -t $(AWS_ECR_NAME) .
dkrun: dkbuild
	@docker run -d -p 0:8080 $(AWS_ECR_NAME)
dev: cmd/web/main.go
	@go run ./cmd/web/

.PHONY: tfinit tfmt dkbuild dkrun dev