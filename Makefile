SRC_MAKEFILE=src/Makefile
BOOTSTRAP=src/bootstrap

# AWS_PROFILE=localstack
AWS_PROFILE=default

# TF=tflocal
TF=terraform

all: tf_apply

tf_apply: $(BOOTSTRAP)
	$(TF) -chdir=terra apply

tf_apply_frontend: $(BOOTSTRAP)
	$(TF) -chdir=terra apply -target=module.frontend

tf_apply_backend: $(BOOTSTRAP)
	$(TF) -chdir=terra apply -target=module.backend

tf_apply_domains: $(BOOTSTRAP)
	$(TF) -chdir=terra apply -target=module.domains

tf_destroy_frontend:
	$(TF) -chdir=terra destroy -target=module.frontend

tf_destroy_backend:
	$(TF) -chdir=terra destroy -target=module.backend

tf_destroy_domains:
	$(TF) -chdir=terra destroy -target=module.domains

tf_plan:
	$(TF) -chdir=terra plan

tf_plan_frontend:
	$(TF) -chdir=terra plan -target=module.frontend

tf_plan_backend:
	$(TF) -chdir=terra plan -target=module.backend

tf_plan_domains:
	$(TF) -chdir=terra plan -target=module.domains

$(BOOTSTRAP): $(SRC_MAKEFILE)
	cd src && $(MAKE)


lb_ls:
	aws lambda list-functions --profile $(AWS_PROFILE)

lb_create:
	aws lambda create-function --function-name test_lambda --runtime provided.al2 --handler main.handler --architectures arm64 --role arn:aws:iam::000000000000:role/go_lambda_role --zip-file fileb://src/test_ok.zip --profile $(AWS_PROFILE)

lb_delete:
	aws lambda delete-function --function-name test_lambda --profile $(AWS_PROFILE)

lb_invoke:
	aws lambda invoke --function-name test_lambda outputfile.txt --profile $(AWS_PROFILE)

clean:
	$(TF) -chdir=terra destroy
	cd src && $(MAKE) clean

.PHONY: all tf_apply tf_apply_frontend tf_apply_backend tf_apply_domains \
        tf_destroy_frontend tf_destroy_backend tf_destroy_domains \
        tf_plan tf_plan_frontend tf_plan_backend tf_plan_domains \
        lb_ls lb_create lb_delete lb_invoke clean