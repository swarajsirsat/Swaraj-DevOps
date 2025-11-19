@Library('Shared') _
pipeline {
    agent { label 'Swaraj' }

    environment {
        REGISTRY_CREDENTIALS = credentials('dockerhub-creds')
        DOCKERHUB_USER = "${REGISTRY_CREDENTIALS_USR}"
        DOCKERHUB_PASS = "${REGISTRY_CREDENTIALS_PSW}"

        IMAGE_NAME = "${DOCKERHUB_USER}/next-notes-app"
        IMAGE_TAG  = "v1"
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
                git url: "https://github.com/swarajsirsat/Swaraj-DevOps.git", branch: "main"
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
