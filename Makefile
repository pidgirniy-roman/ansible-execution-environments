# [ supported, minimal ]
BASE_VERSION ?= minimal
CONTAINER_NAME ?= routeros-ee-$(BASE_VERSION)
CONTAINER_TAG ?= 1.0.0

.PHONY: lint
lint: # Lint the repository with yaml-lint
	yaml-lint .

.PHONY: build
build: # Build the execution environment image
	ansible-builder build \
		--build-arg EE_BASE_IMAGE=registry.redhat.io/ansible-automation-platform-21/ee-$(BASE_VERSION)-rhel8 \
		--tag $(CONTAINER_NAME):$(CONTAINER_TAG) \
		--container-runtime podman

.PHONY: run
run: # Run the example playbook in the execution environment
	ansible-runner run \
		--container-image localhost/$(CONTAINER_NAME):$(CONTAINER_TAG) \
		--process-isolation \
		-p mikrotik.yml .

.PHONY: list
list: # List all of the installed collections
	podman container run -it --rm \
		localhost/$(CONTAINER_NAME):$(CONTAINER_TAG) \
		ansible-galaxy collection list

.PHONY: shell
shell: # Run an interactive shell in the execution environment
	podman run -it --rm \
		localhost/$(CONTAINER_NAME):$(CONTAINER_TAG) \
		/bin/bash