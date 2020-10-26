BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

DOCKER_COMPOSE = docker-compose -f docker-compose.yml

ifdef ON_CONCOURSE
  DOCKER_COMPOSE += -f docker-compose.concourse.yml
endif

ifndef ON_CONCOURSE
	DOCKER_COMPOSE += -f docker-compose.development.yml
endif

DOCKER_BUILD_CMD = $(DOCKER_COMPOSE) build $(BUNDLE_FLAGS)

build: stop
ifndef ON_CONCOURSE
	$(DOCKER_BUILD_CMD)
endif

prebuild:
	$(DOCKER_BUILD_CMD)
	$(DOCKER_COMPOSE) up --no-start

serve:
	$(MAKE) build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) run --rm app bundle exec rake db:migrate
	$(DOCKER_COMPOSE) up -d

lint:
	$(MAKE) build
	$(DOCKER_COMPOSE) run --rm app bundle exec rubocop

test:
	$(MAKE) serve
	$(DOCKER_COMPOSE) run --rm app rspec
	$(MAKE) stop

shell: serve
	$(DOCKER_COMPOSE) run --rm app ash

stop:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

.PHONY: test serve stop lint
