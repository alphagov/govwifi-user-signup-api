BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --jobs 20 --retry 5'

ifdef DEPLOYMENT
	BUNDLE_FLAGS = --build-arg BUNDLE_INSTALL_CMD='bundle install --without test'
endif

DOCKER_BUILD_CMD = docker-compose build $(BUNDLE_FLAGS)
DOCKER_COMPOSE = docker-compose -f docker-compose.yml

ifndef JENKINS_URL
  DOCKER_COMPOSE += -f docker-compose.development.yml
endif

build:
	$(MAKE) stop
	$(DOCKER_BUILD_CMD)

serve:
	$(MAKE) build
	$(DOCKER_COMPOSE) up -d db
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) up -d user_db
	./mysql_user/bin/wait_for_mysql
	$(DOCKER_COMPOSE) up -d

lint:
	$(MAKE) build
	$(DOCKER_COMPOSE) run --rm app bundle exec govuk-lint-ruby

test:
	$(MAKE) serve
	./mysql/bin/wait_for_mysql
	$(DOCKER_COMPOSE) run --rm app rspec
	$(MAKE) stop

stop:
	$(DOCKER_COMPOSE) kill
	$(DOCKER_COMPOSE) rm -f

.PHONY: test serve stop lint
