.PHONY: all destroy plan init

all:
	terraform init
	terraform apply -auto-approve

destroy:
	terraform destroy -auto-approve

plan:
	terraform plan

init:
	terraform init