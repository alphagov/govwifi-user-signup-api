#!/bin/bash

set -v -e -u -o pipefail

source ci/tasks/scripts/deploy-tools/aws-helpers.sh

function migrate() {
  local migration_command="bundle exec rake db:migrate"
  local docker_service_name="${CONTAINER_NAME}"
  local cluster_name service_name task_definition docker_service_name deploy_stage

  deploy_stage="$(stage_name)"
  cluster_name="${deploy_stage}-${CLUSTER_NAME}"
  service_name="${SERVICE_NAME}-${deploy_stage}"
  task_definition="${TASK_NAME}-task-${deploy_stage}"

  echo "deploy_stage: " $deploy_stage
  echo "cluster_name: " $cluster_name
  echo "service_name: " $service_name
  echo "task_definition: " $task_definition

  run_task_with_command \
    "${cluster_name}" \
    "${service_name}" \
    "${task_definition}" \
    "${docker_service_name}" \
    "${migration_command}"
}

migrate
