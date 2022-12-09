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

ng-debug:
	@$(ng-debug)


cri=$(shell aws ecr describe-repositories --repository-names go-ldap-admin-server | jq -r ".repositories[].repositoryUri")
tag=$(shell git rev-parse --short HEAD)

define ng-image
	docker build . --tag ${cri}:${tag} --tag ${cri}:latest
	aws ecr get-login-password | docker login --username AWS --password-stdin ${cri}
	docker push ${cri}:${tag}
	docker push ${cri}:latest
endef

define ng-debug
	docker build . --tag localhost/go-ldap-admin-server:latest
	cd ./docs/docker-compose/ && docker-compose up -d && docker-compose stop go-ldap-admin-server && docker-compose rm go-ldap-admin-server -f && docker-compose up -d go-ldap-admin-server
	docker image prune -f
	docker logs -f go-ldap-admin-server
endef
