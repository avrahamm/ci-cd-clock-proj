There is a simple python web app shows current time,
at http://host:port/myclock.html

I run it on Jenkins server by Pipeline Job runs Jenkinsfile.
To avoid storing sensitive info i Github repository,
Jenkins server global environment variable JENKINS_ENV_FILE_PATH is used.
It points to directory on Jenkis server contains 4 files,
jenkins.env.properties, aws.env.properties, clock_persistent_vars_file, docker.env.properties
There are respective example files with same variables.
Also need to add Github and Docker hub credentials on Jenkins server,
and mannually add its id to jenkins.env.properties file,
like that:
DOCKER_HUB_CREDENTIALS_ID=bb23149f-b50b-4777-9249-cefa08f0cd5e
GIT_CREDENTIALS_ID=bb23149f-b50b-4777-9249-cefa08f0cd5e

I run Pipeline job runs Jenkinsfile mannualy when developing.
Certainly, Github will notify Jenkins server with web hook
when completed developing.
