include .env

tfinit: infra/main.tf
	@cd infra && terraform init
tfmt: infra/main.tf
	@cd infra && terraform fmt -check && terraform validate
dkbuild:
	@docker build -t $(AWS_ECR_NAME) .
dkrun:
	@docker run -p 0:8080 $(AWS_ECR_NAME)

.PHONY: tfinit tfmt dkbuild dkrun