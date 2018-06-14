BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

DOCKER_BUILD_CMD = docker-compose build $(BUNDLE_FLAGS)


build:
	$(MAKE) stop
	$(DOCKER_BUILD_CMD)

serve:
	$(MAKE) build
	docker-compose up -d

lint:
	$(MAKE) build
	docker-compose run --rm app bundle exec govuk-lint-ruby

test:
	$(MAKE) serve
	docker-compose run --rm app rspec
	$(MAKE) stop

stop:
	docker-compose kill
	docker-compose rm -f

.PHONY: test serve stop lint
