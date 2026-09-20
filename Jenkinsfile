pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build and Push Docker Image') {
            steps {
                withCredentials([
                    usernamePassword(
                        credentialsId: 'dockerhub-creds-global',
                        usernameVariable: 'DOCKER_USER',
                        passwordVariable: 'DOCKER_TOKEN'
                    )
                ]) {
                    sh '''
                        IMAGE_NAME="$DOCKER_USER/urban-fantasy-app"

                        echo "Building Docker image..."
                        docker build \
                          -t "$IMAGE_NAME:$BUILD_NUMBER" \
                          -t "$IMAGE_NAME:latest" .

                        echo "$DOCKER_TOKEN" | docker login \
                          -u "$DOCKER_USER" \
                          --password-stdin

                        docker push "$IMAGE_NAME:$BUILD_NUMBER"
                        docker push "$IMAGE_NAME:latest"

                        docker logout
                    '''
                }
            }
        }

        stage('Update GitOps Manifest') {
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
                        IMAGE_NAME="$DOCKER_USER/urban-fantasy-app"

                        git fetch origin main
                        git checkout -B main origin/main

                        sed -i -E \
                          "s#image: .*/urban-fantasy-app:[^[:space:]]+#image: $IMAGE_NAME:$BUILD_NUMBER#" \
                          k8s/deployment.yaml

                        git config user.name "Jenkins CI"
                        git config user.email "jenkins@urban-fantasy.local"

                        git add k8s/deployment.yaml

                        if git diff --cached --quiet; then
                            echo "No manifest change required."
                        else
                            git commit -m "[skip ci] Update image to build $BUILD_NUMBER"

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
            echo 'CI build, Docker push, and GitOps manifest update completed successfully.'
        }

        failure {
            echo 'Pipeline failed. Check the stage logs.'
        }
    }
}