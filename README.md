- The clock app
There is a simple python web app shows current time,
at http://host:port/myclock.html

- Module tests and E2E tests.
There are simple pytest and selenium e2e tests
in tests/ folder 

- Jenkins server setup
Jenkins server runs locally in docker DIND setup as described in
https://www.yuval.guide/jenkins/setup/jenkins-all-in-docker-1/
https://www.yuval.guide/jenkins/setup/jenkins-all-in-docker-2/
Then installed several Jenkins plugins 
to expand Jenkinsfile capabilities.
Take a look at 
https://github.com/avrahamm/jenkins-utils](https://github.com/avrahamm/jenkins-utils/blob/main/install-plugins/plugins-list.txt
there is a list of plugins installed on jenkins server.

- Environment variables on Jenkins server.
I run it on Jenkins server by Pipeline Job runs Jenkinsfile.
To avoid storing sensitive info in Github repository,
Jenkins server global environment variable JENKINS_ENV_FILE_PATH is used.
It points to jenkins.env.properties file, 
in directory on Jenkis server contains 4 files,
you can see respective files with '.example' suffix.

- jenkins.env.properties - contains clock project global variables,
- docker.env.properties - clock project docker env variables,
- aws.env.properties - clock project aws env variables and aws credentials id,
- clock_persistent_vars_file - contains variables like TR workspace of successful build,
  probably to destroy the ec2 server after next successful deployment.
  
- Credentials
Credentials plugin is used to store credentials on Jenkins server.
Also need to add Github,Docker hub and AWS credentials on Jenkins server,
and mannually add its id to jenkins.env.properties file,
see .example files mentioned above for reference.
Also, I installed and configured aws-cli, terraform and some other tools
directly on Jenkins server.

I run Pipeline job runs Jenkinsfile mannualy from 'clock-pipeline' job when developing.
Certainly, Github will notify Jenkins server with web hook
when completed developing.

- Dockerfile
There is a multi step docker file.
Main targets are tester and production generate respective images.
I tried to use environment variables as much as possible
to avoid using hardcoded variable values in Dockerfile.

- Jenkinsfile
At the beginning images were stored in Docker hub.
Yet later I switched to AWS ECR, becasue its higher rate of 'docker login' operation
from automatic scripts.
There are several Jenkinsfile items correspond to clock project developing stages.
I will probably split it to git branches in the future.
Currently, there are dedicated folders contain respective Jenkinsfile. 

- 1 Docker Ubuntu host deployment.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-host-deploy/Jenkinsfile

Images were tested, built and pushed to Docker hub on Jenkins DIND main node.
Deployed to ubuntu host from Jenkins docker DIND server,
using ssh connection with dedicated user and rsa keys.

- 2 Docker AWS ec2 deployment on static test and production servers.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-aws-ec2-deploy/Jenkinsfile

Initially test and production aws ec2 servers were prepared and their ip adresses
set in environment file as environemtn variables.
Jenkinsfile ran testing, created and pushed images to Docker hub on test server.
Then production image was run on production server.
  
3 Docker AWS ec2 deployment on dynamic ec2 production server.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-aws-tr-ec2-deploy/install-on-ec2.sh

No static ec2 servers are prepared.
Jenkinsfile ran testing, created and pushed images to AWS ECR hub
locally on Jenkins server main node.
Then terrafrom provisions production ec2 instance.
Then production image was run on production server.
Route53 clock.avrahammlabs.net record is set to new ec2 production ip.
http://clock.avrahammlabs.net/
Currently, unused ec2 instances continue to function - need to terminate manually.




