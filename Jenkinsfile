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
