pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Images') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds-global',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        FRONTEND_IMAGE="$DOCKER_USER/urban-fantasy-app"
                        API_IMAGE="$DOCKER_USER/urban-fantasy-status-api"

                        echo "Building frontend image..."
                        docker build \
                          -t "$FRONTEND_IMAGE:$BUILD_NUMBER" \
                          -t "$FRONTEND_IMAGE:latest" .

                        echo "Building status API image..."
                        docker build \
                          -t "$API_IMAGE:$BUILD_NUMBER" \
                          -t "$API_IMAGE:latest" ./status-api

                        echo "$DOCKER_TOKEN" | docker login \
                          -u "$DOCKER_USER" \
                          --password-stdin

                        docker push "$FRONTEND_IMAGE:$BUILD_NUMBER"
                        docker push "$FRONTEND_IMAGE:latest"

                        docker push "$API_IMAGE:$BUILD_NUMBER"
                        docker push "$API_IMAGE:latest"

                        docker logout
                    '''
                }
            }
        }

        stage('Update GitOps Manifests') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds-global',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    ),
                    usernamePassword(
                        credentialsId: 'github-gitops-creds',
                        usernameVariable: 'GITHUB_USER',
                        passwordVariable: 'GITHUB_TOKEN'
                    )
                ]) {
                    sh '''
                        FRONTEND_IMAGE="$DOCKER_USER/urban-fantasy-app"
                        API_IMAGE="$DOCKER_USER/urban-fantasy-status-api"

                        git fetch origin main
                        git checkout -B main origin/main

                        sed -i -E \
                          "s#image: .*/urban-fantasy-app:[^[:space:]]+#image: $FRONTEND_IMAGE:$BUILD_NUMBER#" \
                          k8s/deployment.yaml

                        sed -i -E \
                          "s#image: .*/urban-fantasy-status-api:[^[:space:]]+#image: $API_IMAGE:$BUILD_NUMBER#" \
                          k8s/status-api-deployment.yaml

                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@urban-fantasy.local"

                        git add k8s/deployment.yaml k8s/status-api-deployment.yaml

                        if git diff --cached --quiet; then
                            echo "No manifest change required."
                        else
                            git commit -m "[skip ci] Update application images to build $BUILD_NUMBER"

                            set +x
                            git push "https://$GITHUB_USER:$GITHUB_TOKEN@github.com/pahanattx/urban-fantasy-app.git" main
                            set -x
                        fi
                    '''
                }
            }
        }
    }

    post {
        success {
            echo 'Frontend and status API images built, pushed, and GitOps manifests updated successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}