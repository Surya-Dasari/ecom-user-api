pipeline {
  agent {
    docker {
      image 'maven:3.9.6-eclipse-temurin-17'
      args '-v /var/run/docker.sock:/var/run/docker.sock'
    }
  }

  stages {
    stage('Build') {
      steps {
        sh 'mvn clean package'
      }
    }

    stage('Branch Info') {
      steps {
        sh 'echo "Building branch: ${BRANCH_NAME}"'
      }
    }
  }
}
