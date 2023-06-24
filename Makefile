tfinit: infra/main.tf
	@cd infra && terraform init
tfmt: infra/main.tf
	@cd infra && terraform fmt -check && terraform validate

.PHONY: tfinit tfmt