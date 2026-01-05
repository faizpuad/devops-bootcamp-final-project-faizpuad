.PHONY: all destroy plan

all:
	terraform init
	terraform apply -auto-approve

destroy:
	terraform destroy

plan:
	terraform plan