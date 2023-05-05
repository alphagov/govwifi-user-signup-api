BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

DOCKER_COMPOSE += -f docker-compose.development.yml

DOCKER_BUILD_CMD = $(DOCKER_COMPOSE) build $(BUNDLE_FLAGS)

build: stop
	$(DOCKER_BUILD_CMD)

prebuild:
	$(DOCKER_BUILD_CMD)
	$(DOCKER_COMPOSE) up --no-start

serve:
	$(MAKE) build
	$(DOCKER_COMPOSE) run --rm app bundle exec rake db:migrate
	$(DOCKER_COMPOSE) up -d

lint:
	$(MAKE) build
	$(DOCKER_COMPOSE) run --no-deps --rm app bundle exec rubocop

test:
	$(MAKE) serve
	$(DOCKER_COMPOSE) run --rm app bundle exec rspec
	$(MAKE) stop

shell: serve
	$(DOCKER_COMPOSE) run --rm app ash

stop:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

.PHONY: test serve stop lint
