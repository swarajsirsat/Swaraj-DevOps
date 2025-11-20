@Library('Shared') _
pipeline {
    agent { label 'Swaraj' }

    tools {
        SonarQubeScanner 'sonar-scanner'
    }

    environment {
        // Docker Hub Credentials
        REGISTRY_CREDENTIALS = credentials('dockerhub-creds')
        DOCKERHUB_USER       = "${REGISTRY_CREDENTIALS_USR}"
        DOCKERHUB_PASS       = "${REGISTRY_CREDENTIALS_PSW}"

        IMAGE_NAME           = "${DOCKERHUB_USER}/next-notes-app"
        IMAGE_TAG            = "v1"

        // SonarQube Credential
        SONAR_TOKEN = credentials('sqa_579d64dda56488e425281b2f3a3da40acfcfcba4')
    }

    stages {

        stage("Test") {
            steps {
                hello()
            }
        }

        stage("Code Checkout") {
            steps {
                echo "Initiating SCM checkout for Next.js workload"
                code_checkout(
                    "https://github.com/swarajsirsat/Swaraj-DevOps.git",
                    "main"
                )
            }
        }

        stage('SonarQube Scan') {
            steps {
                echo "Executing static analysis via SonarQube"
                withSonarQubeEnv('sonar') {
                    sh """
                        sonar-scanner \
                          -Dsonar.projectKey=SwarajDevOps \
                          -Dsonar.projectName=Swaraj-DevOps-NextJS \
                          -Dsonar.sources=src \
                          -Dsonar.host.url=http://172.179.245.83:9000 \
                          -Dsonar.login=$SONAR_TOKEN \
                          -Dsonar.exclusions=node_modules/**,.next/**,coverage/**,**/*.test.ts,**/*.test.tsx
                    """
                }
            }
        }

        stage('Quality Gate') {
            steps {
                script {
                    echo "Enforcing SonarQube Quality Gate compliance"
                    timeout(time: 2, unit: 'MINUTES') {
                        waitForQualityGate abortPipeline: true
                    }
                }
            }
        }

        stage("Docker Build") {
            steps {
                echo "Executing Next.js container build"
                sh """
                    docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .
                """
            }
        }

        stage("Docker Hub Authentication") {
            steps {
                echo "Authenticating with Docker Hub"
                sh """
                    echo "${DOCKERHUB_PASS}" | docker login -u "${DOCKERHUB_USER}" --password-stdin
                """
            }
        }

        stage("Tag & Push Image") {
            steps {
                echo "Tagging and pushing image to registry"
                sh """
                    docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${IMAGE_NAME}:latest
                    docker push ${IMAGE_NAME}:${IMAGE_TAG}
                    docker push ${IMAGE_NAME}:latest
                """
            }
        }

        stage("Deploy via Docker Compose") {
            steps {
                echo "Initiating rolling deployment via Compose"
                sh """
                    docker compose pull || true
                    docker compose down --remove-orphans
                    docker compose up -d --force-recreate
                """
            }
        }
    }

    post {
        always {
            echo "Executing cleanup lifecycle"
            sh """
                docker image prune -f
                docker logout
            """
        }
    }
}
