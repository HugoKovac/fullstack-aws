FUNCTIONS := $(shell find ports/inbound -maxdepth 1 -mindepth 1 -type d)

all: build

build:
	@for dir in $(FUNCTIONS); do \
		echo "Building function $$dir"; \
		GOOS=linux GOARCH=arm64 CGO_ENABLED=0 \
		go build -tags lambda.norpc -o $$dir/bootstrap $$dir/main.go; \
	done

clean:
	rm -f ports/inbound/*/bootstrap

local_api:
	sam local start-api

local_invoke:
	sam local invoke HelloFunction

.PHONY: build clean local_api