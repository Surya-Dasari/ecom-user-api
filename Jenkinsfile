pipeline {
    agent { label 'maven' }

    environment {
        APP_NAME   = "ecom-user-api"
        IMAGE_NAME = "suryadasari/ecom-user-api"
        IMAGE_TAG  = "${BRANCH_NAME}-${GIT_COMMIT.take(7)}"

        NEXUS_URL  = "http://localhost:8081"
        NEXUS_REPO = "ecom-maven-releases"
        GROUP_ID   = "com.ecom.user"
        VERSION    = "1.0.0"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build & Test') {
            steps {
                sh 'mvn clean test package'
            }
        }

        stage('Publish Artifact to Nexus') {
            when { branch 'develop' }
            steps {
                withVault([vaultSecrets: [[
                    path: 'secret/jenkins/nexus',
                    secretValues: [
                        [envVar: 'NEXUS_USER', vaultKey: 'username'],
                        [envVar: 'NEXUS_PASS', vaultKey: 'password']
                    ]
                ]]]) {
                    sh '''
cat > settings.xml <<EOF
<settings>
  <servers>
    <server>
      <id>nexus-releases</id>
      <username>${NEXUS_USER}</username>
      <password>${NEXUS_PASS}</password>
    </server>
  </servers>
</settings>
EOF

mvn deploy -s settings.xml
'''
                }
            }
        }

        stage('Docker Build (from Nexus)') {
            when { branch 'develop' }
            steps {
                withVault([vaultSecrets: [[
                    path: 'secret/jenkins/nexus',
                    secretValues: [
                        [envVar: 'NEXUS_USER', vaultKey: 'username'],
                        [envVar: 'NEXUS_PASS', vaultKey: 'password']
                    ]
                ]]]) {
                    sh '''
docker build \
  --build-arg NEXUS_URL=${NEXUS_URL} \
  --build-arg NEXUS_REPO=${NEXUS_REPO} \
  --build-arg NEXUS_USER=${NEXUS_USER} \
  --build-arg NEXUS_PASS=${NEXUS_PASS} \
  --build-arg GROUP_ID=${GROUP_ID} \
  --build-arg ARTIFACT_ID=${APP_NAME} \
  --build-arg VERSION=${VERSION} \
  -t ${IMAGE_NAME}:${IMAGE_TAG} .
'''
                }
            }
        }

        stage('Push Image to Docker Hub') {
            when { branch 'develop' }
            steps {
                withVault([vaultSecrets: [[
                    path: 'secret/jenkins/dockerhub',
                    secretValues: [
                        [envVar: 'DOCKER_USER', vaultKey: 'username'],
                        [envVar: 'DOCKER_PASS', vaultKey: 'password']
                    ]
                ]]]) {
                    sh '''
echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
docker push ${IMAGE_NAME}:${IMAGE_TAG}
'''
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
