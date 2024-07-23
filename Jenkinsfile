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
                echo 'Load Jenkins Environment Variables'
                sh 'echo $JENKINS_ENV_FILE_PATH'
                script {
                    // Access the global environment variable
                    def envFilePath = JENKINS_ENV_FILE_PATH
                    // Load the environment variables from the file
                    def props = readFile(envFilePath)
                    def lines = props.split('\n')
                    for (line in lines) {
                        if (line.trim()) {
                            def (key, value) = line.split('=').collect { it.trim() }
                            env."${key}" = value
                        }
                    }
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

        stage('Copy Docker Environment Variables to .env file') {
            steps {
                sh 'whoami'
                sh 'pwd'
                sh 'echo $CLOCK_PROJ_DOCKER_ENV_FILE_PATH; cp $CLOCK_PROJ_DOCKER_ENV_FILE_PATH .env; chmod 644 .env '
                sh 'cat .env'
            }
        }

        stage('Export Docker Environment Variables') {
//             steps {
//                 script {
//                     def lines = readFile('.env').split('\n')
//                     for (line in lines) {
//                         if (line.trim() && !line.startsWith('#')) {
//                             def (key, value) = line.split('=').collect { it.trim() }
//                             env."${key}" = value
//                         }
//                     }
//                 }
//             }
               steps {
                   script {
                       def lines = readFile('.env').split('\n')
                       for (line in lines) {
                           if (line.trim() && !line.startsWith('#')) {
                               def (key, value) = line.split('=').collect { it.trim() }
                               sh "echo 'export ${key}=${value}' >> $WORKSPACE/env.sh"
                           }
                       }
                       sh """
                            chmod u+x $WORKSPACE/env.sh
                        """
                   }

               }
        }

        stage('Verify Environment Variables') {

            steps {
                sh """
                    . $WORKSPACE/env.sh
                    echo \$WORKDIR
                    echo \$IMAGE_NAME
                """
            }
        }

        stage('Build docker images, run container and test') {
            steps {
                echo 'Build docker images, run container and test'
                sh """
                    . $WORKSPACE/env.sh
                    docker --debug build --build-arg WORKDIR=\$WORKDIR . -t \$IMAGE_NAME
                """
            }
        }


//         stage('Verify Environment Variables') {
//             steps {
//                 sh """
//                     . $WORKSPACE/env.sh
//                     echo "WORKDIR: \$WORKDIR"
//                     echo "IMAGE_NAME: \$IMAGE_NAME"
//                 """
//             }
//         }
//
//
//         stage('Build docker images, run container and test') {
//             steps {
//                 echo 'Build docker images, run container and test'
//                 script {
//                     def workdir = sh(script: '. $WORKSPACE/env.sh && echo $WORKDIR', returnStdout: true).trim()
//                     def imageName = sh(script: '. $WORKSPACE/env.sh && echo $IMAGE_NAME', returnStdout: true).trim()
//
//                     sh """
//                         docker --debug build --build-arg WORKDIR=${workdir} . -t ${imageName}
//                     """
//                 }
//             }
//         }

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

        stage('Deploy') {
            steps {
                echo 'Deploying....'
                sh 'docker images | grep clock || true'
//                 sh 'docker compose push'
//                 sh 'echo "docker compose push"'
            }
        }

        stage('Cleaning') {
            steps {
                echo 'Cleaning....'
//                 sh 'docker compose down; pwd'
            }
        }
    }
}
