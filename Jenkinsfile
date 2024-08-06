pipeline {
    agent any
    environment {
        // Set from the global environment variable
        // to extract environment variables.
        JENKINS_ENV_FILE_PATH = "${env.JENKINS_ENV_FILE_PATH}"
    }

    stages {
        stage('Load Jenkins Environment Variables') {
            steps {
                script {
                    def envFilePath = env.JENKINS_ENV_FILE_PATH
                    def props = readProperties file: envFilePath
                    env.DOCKER_HUB_CREDENTIALS_ID = props.DOCKER_HUB_CREDENTIALS_ID
                    env.CLOCK_PROJ_GIT_REPO_URL = props.CLOCK_PROJ_GIT_REPO_URL
                    env.CLOCK_PROJ_DOCKER_ENV_FILE_PATH = props.CLOCK_PROJ_DOCKER_ENV_FILE_PATH
                    env.GIT_CREDENTIALS_ID = props.GIT_CREDENTIALS_ID
                }
            }
        }

        stage('Load Docker Environment Variables') {
            steps {
                script {
                    def dockerEnvProps = readProperties file: env.CLOCK_PROJ_DOCKER_ENV_FILE_PATH
                    env.CHROME_VERSION = dockerEnvProps.CHROME_VERSION
                    env.CHROME_DRIVER_VERSION = dockerEnvProps.CHROME_DRIVER_VERSION
                    env.CHROME_DRIVER_PATH = dockerEnvProps.CHROME_DRIVER_PATH
                    env.PYTHONPATH = dockerEnvProps.PYTHONPATH
                    env.SELENIUM_HEADLESS_MODE_DISPLAY_PORT = dockerEnvProps.SELENIUM_HEADLESS_MODE_DISPLAY_PORT
                    env.CONTAINER_APP_PORT = dockerEnvProps.CONTAINER_APP_PORT
                    env.PUBLISHED_TEST_APP_PORT = dockerEnvProps.PUBLISHED_TEST_APP_PORT
                    env.PUBLISHED_PROD_APP_PORT = dockerEnvProps.PUBLISHED_PROD_APP_PORT
                    env.IMAGE_NAME = dockerEnvProps.IMAGE_NAME
                    env.WORKDIR = dockerEnvProps.WORKDIR

                    env.UPDATE_CLOCK_TIME_INTERVAL = dockerEnvProps.UPDATE_CLOCK_TIME_INTERVAL
                    env.CLOCK_APP_URL = dockerEnvProps.CLOCK_APP_URL
                    env.REFRESH_INTERVAL = dockerEnvProps.REFRESH_INTERVAL
                    env.TIME_FORMAT = dockerEnvProps.TIME_FORMAT
                    env.TEST_OUTPUT_FILE_PATH = dockerEnvProps.TEST_OUTPUT_FILE_PATH
                    env.PROD_OUTPUT_FILE_PATH = dockerEnvProps.PROD_OUTPUT_FILE_PATH
                    env.TEST_CONTAINER_NAME = dockerEnvProps.TEST_CONTAINER_NAME
                    env.PROD_CONTAINER_NAME = dockerEnvProps.PROD_CONTAINER_NAME
                }
            }
        }

        stage('Git Clone Repo') {
            steps {
                echo 'Git Clone Repo'
                git branch: 'main',
                    url: "${env.CLOCK_PROJ_GIT_REPO_URL}",
                    credentialsId: "${env.GIT_CREDENTIALS_ID}"
            }
        }

        stage('Set Git Commit Hash') {
            steps {
                script {
                    env.GIT_COMMIT_SHORT = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
                    echo "Short commit hash: ${env.GIT_COMMIT_SHORT}"
                }
            }
        }

        stage('Login to Docker Hub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: env.DOCKER_HUB_CREDENTIALS_ID,
                    usernameVariable: 'DOCKER_USERNAME',
                    passwordVariable: 'DOCKER_PASSWORD'
                  )]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u $DOCKER_USERNAME --password-stdin'
                }
            }
        }

        stage('Tester stage') {
            steps {
                echo 'Build docker images, run container and test'
                sh """
                    docker --debug build --target tester \
                           -t ${env.IMAGE_NAME}:test-${env.GIT_COMMIT_SHORT} .
                    docker run --rm \
                        -d --name ${env.TEST_CONTAINER_NAME} \
                        -e WORKDIR=${env.WORKDIR} \
                        -e CONTAINER_APP_PORT=${env.CONTAINER_APP_PORT} \
                        -e CHROME_DRIVER_VERSION=${env.CHROME_DRIVER_VERSION} \
                        -e OUTPUT_FILE_PATH=${env.TEST_OUTPUT_FILE_PATH} \
                        -p ${env.PUBLISHED_TEST_APP_PORT}:${env.CONTAINER_APP_PORT}  \
                        ${env.IMAGE_NAME}:test-${env.GIT_COMMIT_SHORT}
                """
            }
        }

        stage('Production stage') {
            steps {
                echo 'Tests passed. Production stage - build docker images and run container'
                sh """
                    docker --debug build --target production \
                           -t ${env.IMAGE_NAME}:production-${env.GIT_COMMIT_SHORT} .
                    docker run --rm \
                        -d --name ${env.PROD_CONTAINER_NAME} \
                        -e WORKDIR=${env.WORKDIR} \
                        -e CONTAINER_APP_PORT=${env.CONTAINER_APP_PORT} \
                        -e CHROME_DRIVER_VERSION=${env.CHROME_DRIVER_VERSION} \
                        -e OUTPUT_FILE_PATH=${env.PROD_OUTPUT_FILE_PATH} \
                        -p ${env.PUBLISHED_PROD_APP_PORT}:${env.CONTAINER_APP_PORT}  \
                        ${env.IMAGE_NAME}:production-${env.GIT_COMMIT_SHORT}
                   """
                // Optional: Add a small delay to ensure everything is running
                sleep 5
            }
        }


        stage('Push test and production docker images') {
            steps {
                echo 'Push test and production docker images'
                sh """
                    docker images | grep clock || true
                    docker image push ${env.IMAGE_NAME}:test-${env.GIT_COMMIT_SHORT}
                    docker image push ${env.IMAGE_NAME}:production-${env.GIT_COMMIT_SHORT}
                """
            }
        }

        stage('Cleaning') {
            steps {
                echo 'Cleaning....'
                sh """
                   docker stop ${env.TEST_CONTAINER_NAME}
                   docker stop ${env.PROD_CONTAINER_NAME}
                   docker rmi ${env.IMAGE_NAME}:test-${env.GIT_COMMIT_SHORT} || true
                   docker rmi ${env.IMAGE_NAME}:production-${env.GIT_COMMIT_SHORT} || true
                   # Prune any dangling images
                   docker image prune -f
                """
            }
        }
    }
}
