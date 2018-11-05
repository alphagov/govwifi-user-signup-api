class Globals {
  static boolean userInput = true
  static boolean didTimeout = false
}

pipeline {
  agent any
  stages {
    stage('Linting') {
      steps {
        sh 'make lint'
      }
    }

    stage('Test') {
      steps {
        sh 'make test'
      }
    }

    stage('Publish stable tag') {
      when{
        branch 'master'
      }

      steps {
        publishStableTag()
      }
    }

    stage('Deploy to staging') {
      when{
        branch 'master'
      }

      steps {
        deploy_staging()
      }
    }

    stage('Deploy to production') {
      when{
        branch 'master'
      }

      steps {
        deploy_production()
      }
    }
  }

  post {
    failure {
      script {
        if(deployCancelled()) {
          setBuildStatus("Build successful", "SUCCESS");
          return
        }
      }
      setBuildStatus("Build failed", "FAILURE");
    }

    success {
      setBuildStatus("Build successful", "SUCCESS");
    }

    cleanup {
      sh 'make stop'
    }
  }
}

void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/govwifi-user-signup-api"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

def deploy_staging() {
  deploy('staging')
}

def deploy_production() {
  if(deployCancelled()) {
    setBuildStatus("Build successful", "SUCCESS");
    return
  }

  try {
    timeout(time: 5, unit: 'MINUTES') {
      input "Do you want to deploy to production?"
      deploy('production')
    }
  } catch(err) { // timeout reached or input false
    def user = err.getCauses()[0].getUser()

    if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
      Globals.didTimeout = true
      echo "Release window timed out, to deploy please re-run"
    } else {
      Globals.userInput = false
      echo "Aborted by: [${user}]"
    }
  }
}

def deploy(deploy_environment) {
  echo "Deploying to ${deploy_environment}"
  sh('git fetch')
  sh('git checkout stable')

  withAWS(credentials: 'jenkins-read-wordlist-credentials') {
    s3Download(
      file: 'tmp/wordlist',
      bucket: 'govwifi-wordlist',
      path: 'wordlist-short',
      force: true
    )
  }

  docker.withRegistry(env.AWS_ECS_API_REGISTRY) {
    sh("eval \$(aws ecr get-login --no-include-email)")
    def appImage = docker.build(
      "govwifi/user-signup-api:${deploy_environment}",
      "--build-arg BUNDLE_INSTALL_CMD='bundle install --without test' ."
    )
    appImage.push()
  }

  if(deploy_environment == 'production') { deploy_environment = 'wifi' }

  cluster_name = "${deploy_environment}-api-cluster"
  service_name = "user-signup-api-service-${deploy_environment}"

  sh("aws ecs update-service --force-new-deployment --cluster ${cluster_name} --service ${service_name} --region eu-west-2")
}

def publishStableTag() {
  sshagent(credentials: ['govwifi-jenkins']) {
    sh('export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"')
    sh("git tag -f stable HEAD")
    sh("git push git@github.com:alphagov/govwifi-user-signup-api.git --force --tags")
  }
}

def deployCancelled() {
  if(Globals.didTimeout || Globals.userInput == false) {
    return true
  }
}
