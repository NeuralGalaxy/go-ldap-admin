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
	@$(ng-aliyun-image)

ng-debug:
	@$(ng-debug)


# for common
tag=$(shell git rev-parse --short HEAD)
# for aws
cri=$(shell aws ecr describe-repositories --repository-names go-ldap-admin-server | jq -r ".repositories[].repositoryUri")
# for aliyun
instanceId=$(shell aliyun cr ListInstance | jq -r '.Instances[0].InstanceId')
domain=ngiq-registry.cn-hangzhou.cr.aliyuncs.com
ns=public

define ng-aws-image
	docker build . --tag ${cri}:${tag} --tag ${cri}:latest
	aws ecr get-login-password | docker login --username AWS --password-stdin ${cri}
	docker push ${cri}:${tag}
	docker push ${cri}:latest
endef

define ng-aliyun-image
	docker build . --tag ${domain}/${ns}/go-ldap-admin-server:$(shell git rev-parse --short HEAD) --tag ${domain}/${ns}/go-ldap-admin-server:latest
	aliyun cr GetAuthorizationToken --InstanceId ${instanceId} --force --version 2018-12-01 | jq -r .AuthorizationToken | docker login --username=cr_temp_user --password-stdin ${domain}
	docker push ${domain}/${ns}/go-ldap-admin-server:${tag}
	docker push ${domain}/${ns}/go-ldap-admin-server:latest
endef

define ng-debug
	docker build . --tag localhost/go-ldap-admin-server:latest
	cd ./docs/docker-compose/ && docker-compose up -d && docker-compose stop go-ldap-admin-server && docker-compose rm go-ldap-admin-server -f && docker-compose up -d go-ldap-admin-server
	docker image prune -f
	docker logs -f go-ldap-admin-server
endef
