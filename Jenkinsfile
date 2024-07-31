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
                    env.PUBLISHED_APP_PORT = dockerEnvProps.PUBLISHED_APP_PORT
                    env.IMAGE_NAME = dockerEnvProps.IMAGE_NAME
                    env.WORKDIR = dockerEnvProps.WORKDIR

                    env.UPDATE_CLOCK_TIME_INTERVAL = dockerEnvProps.UPDATE_CLOCK_TIME_INTERVAL
                    env.CLOCK_APP_URL = dockerEnvProps.CLOCK_APP_URL
                    env.REFRESH_INTERVAL = dockerEnvProps.REFRESH_INTERVAL
                    env.TIME_FORMAT = dockerEnvProps.TIME_FORMAT
                    env.OUTPUT_FILE_PATH = dockerEnvProps.OUTPUT_FILE_PATH
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

        stage('Build docker images, run container and test') {
            steps {
                echo 'Build docker images, run container and test'
                sh """
                    docker --debug build -t ${env.IMAGE_NAME} .
                    docker run \
                        -d --name clock \
                        -e WORKDIR=${env.WORKDIR} \
                        -e CONTAINER_APP_PORT=${env.CONTAINER_APP_PORT} \
                        -e CHROME_DRIVER_VERSION=${env.CHROME_DRIVER_VERSION} \
                        -e OUTPUT_FILE_PATH=${env.OUTPUT_FILE_PATH} \
                        -p ${env.PUBLISHED_APP_PORT}:${env.CONTAINER_APP_PORT}  \
                        ${env.IMAGE_NAME}
                """
            }
        }

        stage('Push docker images') {
            steps {
                echo 'Push docker images'
                sh """
                    docker images | grep clock || true
                    # docker image push ${env.IMAGE_NAME}
                """
            }
        }

        stage('Cleaning') {
            steps {
                echo 'Cleaning....'
                sh """
                   # docker stop clock || true
                   # docker rm clock || true
                """
            }
        }
    }
}
