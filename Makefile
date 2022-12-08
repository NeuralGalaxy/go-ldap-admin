default: build

run:
	GIN_MODE=release go run main.go

build:
	go build -o go-ldap-admin main.go

build-linux:
	CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o go-ldap-admin main.go

build-linux-arm:
	CGO_ENABLED=0 GOARCH=arm64 GOOS=linux go build -o go-ldap-admin main.go

lint:
	env GOGC=25 golangci-lint run --fix -j 8 -v ./...

ng-image:
	@$(ng-image)

cri=cri-2bp27pwaqbe7w5t2
domain=ngiq-registry.cn-hangzhou.cr.aliyuncs.com
ns=public

define ng-image
	docker build . --tag ${domain}/${ns}/go-ldap-admin-server:$(shell git rev-parse --short HEAD) --tag ${domain}/${ns}/go-ldap-admin-server:latest
	aliyun cr GetAuthorizationToken --InstanceId ${cri} --force --version 2018-12-01 | jq -r .AuthorizationToken | docker login --username=cr_temp_user --password-stdin ${domain}
	docker push ${domain}/${ns}/go-ldap-admin-server:$(shell git rev-parse --short HEAD)
	docker push ${domain}/${ns}/go-ldap-admin-server:latest
endef
