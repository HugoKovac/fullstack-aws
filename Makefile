SRC_MAKEFILE=src/Makefile
BOOTSTRAP=src/bootstrap

all: tf_apply

tf_apply: $(BOOTSTRAP)
	tflocal -chdir=terra apply

$(BOOTSTRAP): $(SRC_MAKEFILE)
	cd src && $(MAKE)


lb_ls:
	aws lambda list-functions --profile localstack

lb_create:
	aws lambda create-function --function-name test_lambda --runtime provided.al2 --handler main.handler --architectures arm64 --role arn:aws:iam::000000000000:role/go_lambda_role --zip-file fileb://src/test_ok.zip --profile localstack

lb_delete:
	aws lambda delete-function --function-name test_lambda --profile localstack

lb_invoke:
	aws lambda invoke --function-name test_lambda outputfile.txt --profile localstack

clean:
	tflocal -chdir=terra destroy
	cd src && $(MAKE) clean

.PHONY: all tf_apply lb_ls lb_create lb_delete lb_invoke