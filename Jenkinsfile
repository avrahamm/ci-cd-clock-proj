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
                    env.PYTHONPATH = dockerEnvProps.PYTHONPATH
                    env.SELENIUM_HEADLESS_MODE_DISPLAY_PORT = dockerEnvProps.SELENIUM_HEADLESS_MODE_DISPLAY_PORT
                    env.CONTAINER_APP_PORT = dockerEnvProps.CONTAINER_APP_PORT
                    env.PUBLISHED_APP_PORT = dockerEnvProps.PUBLISHED_APP_PORT
                    env.IMAGE_NAME = dockerEnvProps.IMAGE_NAME
                    env.WORKDIR = dockerEnvProps.WORKDIR
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
                    docker --debug build --build-arg WORKDIR=${env.WORKDIR} . -t ${env.IMAGE_NAME}
                    docker run \
                            -d --name clock \
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
                    docker image push ${env.IMAGE_NAME}
                """
            }
        }

        stage('Cleaning') {
            steps {
                echo 'Cleaning....'
                sh """
                    docker stop clock || true
                    docker rm clock || true
                """
            }
        }
    }
}
