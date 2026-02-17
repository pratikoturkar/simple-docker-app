pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "pratikoturkar/blue-green-demo"
        DOCKER_CREDENTIALS_ID = "dockerhub-creds"
        KUBE_NAMESPACE = "default"
        APP_NAME = "my-app"
    }

    triggers {
        githubPush()
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    env.BUILD_TAG_VERSION = "${BUILD_NUMBER}"
                }
                sh """
                docker build \
                --build-arg VERSION=${BUILD_NUMBER} \
                -t $DOCKER_IMAGE:${BUILD_TAG_VERSION} .
                """
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "${DOCKER_CREDENTIALS_ID}",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {

                    sh """
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_IMAGE:${BUILD_TAG_VERSION}
                    docker logout
                    """
                }
            }
        }

        stage('Blue-Green Deploy') {
            steps {
                script {

                    // Detect current live color
                    def currentColor = sh(
                        script: "kubectl get svc ${APP_NAME}-service -o jsonpath='{.spec.selector.version}' || echo blue",
                        returnStdout: true
                    ).trim()

                    def newColor = (currentColor == "blue") ? "green" : "blue"

                    echo "Current live: ${currentColor}"
                    echo "Deploying new version as: ${newColor}"

                    // Deploy new version
                    sh """
                    sed -e 's|{{IMAGE}}|$DOCKER_IMAGE:${BUILD_TAG_VERSION}|g' \
                        -e 's|{{COLOR}}|${newColor}|g' \
                        k8s/deployment-template.yaml | kubectl apply -f -
                    """

                    // Wait for rollout
                    sh """
                    kubectl rollout status deployment/${APP_NAME}-${newColor}
                    """

                    // Switch service to new version
                    sh """
                    kubectl patch service ${APP_NAME}-service \
                    -p '{"spec":{"selector":{"app":"${APP_NAME}","version":"${newColor}"}}}'
                    """

                    echo "Switched traffic to ${newColor}"
                }
            }
        }
    }

    post {

        success {
            emailext(
                subject: "SUCCESS: Job ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
                Build Success!

                Job Name: ${JOB_NAME}
                Build Number: ${BUILD_NUMBER}
                Docker Image: ${DOCKER_IMAGE}:${BUILD_NUMBER}

                Blue-Green Deployment Completed Successfully.
                """,
                to: "your-email@example.com"
            )
        }

        failure {
            emailext(
                subject: "FAILED: Job ${JOB_NAME} #${BUILD_NUMBER}",
                body: """
                Build Failed!

                Check Jenkins Console Output:
                ${BUILD_URL}

                """,
                to: "your-email@example.com"
            )
        }
    }
}
