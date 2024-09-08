MAIN_PACKAGE_PATH := ./main.go
BINARY_NAME := sqlite_sync


## tidy: format code and tidy modfile
.PHONY: tidy
tidy:
	go fmt ./...
	go mod tidy -v



## build: build the application
.PHONY: build
build:
    # Include additional build steps, like TypeScript, SCSS or Tailwind compilation here...
	go build -o=/tmp/bin/${BINARY_NAME} ${MAIN_PACKAGE_PATH}


## remove old database
.PHONY: rmd
rmd:
	rm database/databases/master && rm database/databases/Diff && sqlite3 database/databases/master < database/clientSchema.sql&& sqlite3 database/databases/Diff < database/diffSchema.sql

## remove old script
.PHONY: rms
rms:
	cd script && rm *.sql && cd ./..
