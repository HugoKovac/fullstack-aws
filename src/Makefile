all: test_lambda.zip

bootstrap: main.go
	GOOS=linux GOARCH=arm64 CGO_ENABLED=0 go build -tags lambda.norpc -o bootstrap main.go

test_lambda.zip: bootstrap
	zip test_lambda.zip bootstrap

clean:
	rm -f test_lambda.zip bootstrap

.PHONY: clean