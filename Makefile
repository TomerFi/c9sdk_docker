default: help

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

ARCH = $(strip $(shell dpkg --print-architecture))

ifneq ($(filter $(ARCH),$(amd64 armhf)),)
$(error This image is made for amd64 and armhf, you're running $(ARCH).)
endif

IMAGE_NAME = tomerfi/c9sdk_docker

GIT_COMMIT = $(strip $(shell git rev-parse --short HEAD))

CURRENT_DATE = $(strip $(shell date -u +"%Y-%m-%dT%H:%M:%SZ"))

CODE_VERSION = $(strip $(shell cat VERSION))

ifndef CODE_VERSION
$(error You need to create a VERSION file to build the image.)
endif

FULL_IMAGE_NAME = $(strip $(IMAGE_NAME):$(CODE_VERSION)-$(ARCH)-linux)
TESTING_IMAGE_NAME = $(strip $(IMAGE_NAME):testing-$(ARCH)-linux)

docker-build: ## build image from Dockerfile.
	docker build \
	--build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg BUILD_DATE=$(CURRENT_DATE) \
  --build-arg VERSION=$(CODE_VERSION) \
  -t $(FULL_IMAGE_NAME) \
  -f $(ARCH)/Dockerfile .

docker-build-testing-image: ## build image from Dockerfile using a testing tag.
	docker build \
	--build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg BUILD_DATE=$(CURRENT_DATE) \
  --build-arg VERSION=testing \
  -t $(TESTING_IMAGE_NAME) \
  -f $(ARCH)/Dockerfile .

docker-remove-testing-image: ## remove the testing image (must be build first).
	docker image rm $(TESTING_IMAGE_NAME)

docker-build-no-cache: ## build image from Dockerfile with no caching.
	docker build --no-cache \
	--build-arg VCS_REF=$(GIT_COMMIT) \
  --build-arg BUILD_DATE=$(CURRENT_DATE) \
  --build-arg VERSION=$(CODE_VERSION) \
  -t $(FULL_IMAGE_NAME) \
  -f $(ARCH)/Dockerfile .

structure-test: ## run the container-structure-test tool against the built testing image (must be build first) using the relative container_structure.yml file
	bash shellscripts/container-structure-test-verify.sh container_structure.yml $(TESTING_IMAGE_NAME)

docker-build-structure-test: ## build the image and test the container structure
docker-build-structure-test: docker-build structure-test

docker-build-no-cache-structure-test: ## build the image and test the container structure
docker-build-no-cache-structure-test: docker-build-no-cache structure-test

docker-full-structure-testing: ## build the image with the testing tag and remove after structure test
docker-full-structure-testing: docker-build-testing-image structure-test docker-remove-testing-image

push-description: ## push the relative README.md file as full description to docker hub, requires username and password arguments
	bash shellscripts/push-docker-description.sh $(strip $(username)) $(strip $(password)) $(strip $(IMAGE_NAME))
