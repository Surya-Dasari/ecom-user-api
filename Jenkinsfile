pipeline {
  agent { label 'maven' }

  environment {
    APP_NAME      = 'ecom-user-api'
    NEXUS_URL     = 'http://localhost:8081'
    NEXUS_REPO    = 'ecom-maven-releases'
    DOCKER_IMAGE  = 'suryadasari/ecom-user-api'
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Build & Unit Test') {
      steps {
        sh 'mvn clean verify'
      }
    }

    stage('Branch Classification') {
      steps {
        script {
          if (env.BRANCH_NAME == 'develop') {
            env.TARGET_ENV = 'dev'
          } else if (env.BRANCH_NAME.startsWith('release/')) {
            env.TARGET_ENV = 'qa'
          } else if (env.BRANCH_NAME == 'main') {
            env.TARGET_ENV = 'prod'
          } else {
            env.TARGET_ENV = 'none'
          }
          echo "Target environment: ${env.TARGET_ENV}"
        }
      }
    }

    /* =========================
       PUBLISH ARTIFACT TO NEXUS
       ========================= */
    stage('Publish Artifact to Nexus') {
      when {
        expression { env.TARGET_ENV != 'none' }
      }
      steps {
        withVault([vaultSecrets: [
          [path: 'secret/jenkins/nexus', secretValues: [
            [envVar: 'NEXUS_USER', vaultKey: 'username'],
            [envVar: 'NEXUS_PASS', vaultKey: 'password']
          ]]
        ]]) {
          sh """
            mvn deploy \
              -Dnexus.username=$NEXUS_USER \
              -Dnexus.password=$NEXUS_PASS
          """
        }
      }
    }

    /* ======================================
       DOCKER BUILD (ARTIFACT PULLED FROM NEXUS)
       ====================================== */
    stage('Docker Build from Nexus Artifact') {
      when {
        expression { env.TARGET_ENV != 'none' }
      }
      steps {
        script {
          env.IMAGE_TAG = "${env.TARGET_ENV}-${env.GIT_COMMIT.take(7)}"
        }

        withVault([vaultSecrets: [
          [path: 'secret/jenkins/nexus', secretValues: [
            [envVar: 'NEXUS_USER', vaultKey: 'username'],
            [envVar: 'NEXUS_PASS', vaultKey: 'password']
          ]]
        ]]) {
          sh """
            docker build \
              --build-arg NEXUS_URL=${NEXUS_URL} \
              --build-arg NEXUS_REPO=${NEXUS_REPO} \
              --build-arg NEXUS_USER=$NEXUS_USER \
              --build-arg NEXUS_PASS=$NEXUS_PASS \
              --build-arg APP_NAME=${APP_NAME} \
              -t ${DOCKER_IMAGE}:${IMAGE_TAG} .
          """
        }
      }
    }

    /* ======================
       PUSH IMAGE TO DOCKER HUB
       ====================== */
    stage('Push Image to Docker Hub') {
      when {
        expression { env.TARGET_ENV != 'none' }
      }
      steps {
        withVault([vaultSecrets: [
          [path: 'secret/jenkins/dockerhub', secretValues: [
            [envVar: 'DOCKER_USER', vaultKey: 'username'],
            [envVar: 'DOCKER_PASS', vaultKey: 'password']
          ]]
        ]]) {
          sh """
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
            docker push ${DOCKER_IMAGE}:${IMAGE_TAG}
          """
        }
      }
    }
  }

  post {
    success {
      echo "Pipeline SUCCESS for ${BRANCH_NAME}"
    }
    failure {
      echo "Pipeline FAILED for ${BRANCH_NAME}"
    }
  }
}

