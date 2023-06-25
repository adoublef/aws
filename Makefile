include .env

tfinit: infra/main.tf
	@cd infra && terraform init
tfmt: infra/main.tf
	@cd infra && terraform fmt -check && terraform validate
dkbuild: Dockerfile
	@docker build -t $(AWS_ECR_NAME) .
dkrun: dkbuild
	@docker run -p 0:8080 $(AWS_ECR_NAME)
dkpush: scripts/aws/push.py
	@./scripts/aws/push.py -u $(AWS_ACCOUNT_ID) -n $(AWS_ECR_NAME) .
dev: cmd/web/main.go
	@go run ./cmd/web/

.PHONY: tfinit tfmt dkbuild dkrun dkpush dev