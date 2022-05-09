.PHONY: clean critic security lint test build run

APP_NAME = fibergo
BUILD_DIR = $(PWD)/build
MIGRATIONS_FOLDER = $(PWD)/platform/migrations
DATABASE_URL = postgres://postgres:securedb@localhost:5432/postgres?sslmode=disable

clean:
	rm -rf ./build

critic:
	gocritic check -enableAll ./...

security:
	gosec ./...

lint:
	golangci-lint run ./...

test: clean critic security lint
	go test -v -timeout 30s -coverprofile=cover.out -cover ./...
	go tool cover -func=cover.out

build: test
	CGO_ENABLED=0 go build -ldflags="-w -s" -o $(BUILD_DIR)/$(APP_NAME) main.go

run: swag build
	$(BUILD_DIR)/$(APP_NAME)

migrate.up:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" up

migrate.down:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" down

migrate.force:
	migrate -path $(MIGRATIONS_FOLDER) -database "$(DATABASE_URL)" force $(version)

docker.run: docker.network docker.postgres swag docker.fiber docker.redis migrate.up

docker.network:
	docker network inspect intranet >/dev/null 2>&1 || \
	docker network create -d bridge intranet

docker.fiber.build:
	docker build -t $(APP_NAME) .

docker.fiber: docker.fiber.build
	docker run --rm -d \
		--name $(APP_NAME) \
		--network intranet \
		-p 3030:3030 \
		$(APP_NAME)

# FIXME: mount data to localdata
# -v $(PWD)/localdata/pgsql:/var/lib/postgresql/data
docker.postgres:
	docker run --rm -d \
		--name $(APP_NAME)-db \
		--network intranet \
		-e POSTGRES_USER=postgres \
		-e POSTGRES_PASSWORD=securedb \
		-e POSTGRES_DB=postgres \
		-p 5432:5432 \
		postgres:14-alpine

docker.redis:
	docker run --rm -d \
		--name $(APP_NAME)-redis \
		--network intranet \
		-p 6379:6379 \
		redis:7-alpine

docker.stop: docker.stop.fiber docker.stop.postgres docker.stop.redis

docker.restart: docker.stop docker.run

docker.stop.fiber:
	docker stop $(APP_NAME)

docker.stop.postgres:
	docker stop $(APP_NAME)-db

docker.stop.redis:
	docker stop $(APP_NAME)-redis

swag:
	swag init
