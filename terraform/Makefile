.PHONY: all destroy plan init validate

all:
	terraform init --upgrade
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

plan:
	terraform plan

init:
	terraform init

validate:
	terraform validate