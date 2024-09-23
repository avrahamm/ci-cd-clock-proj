- The clock app
There is a simple python web app shows current time,
at http://clock.avrahammlabs.net/

- Module tests and E2E tests.
There are simple pytest and selenium e2e tests
in tests/ folder 

- Jenkins server setup
Jenkins server runs locally in docker DIND setup as described in <br/>
https://www.yuval.guide/jenkins/setup/jenkins-all-in-docker-1/ <br/>
and
https://www.yuval.guide/jenkins/setup/jenkins-all-in-docker-2/ <br/>
Then installed several Jenkins plugins 
to expand Jenkinsfile capabilities.
Take a look at <br/>
https://github.com/avrahamm/jenkins-utils](https://github.com/avrahamm/jenkins-utils/blob/main/install-plugins/plugins-list.txt <br/>
there is a list of plugins installed on jenkins server.

- Environment variables on Jenkins server.
I run it on Jenkins server by Pipeline Job runs Jenkinsfile. <br/>
To avoid storing sensitive info in Github repository, <br/>
Jenkins server global environment variable JENKINS_ENV_FILE_PATH is used. <br/>
It points to jenkins.env.properties file, <br/>
in directory on Jenkis server contains 4 files, <br/>
you can see respective files with '.example' suffix. <br/>

- jenkins.env.properties - contains clock project global variables,<br/>
- docker.env.properties - clock project docker env variables,<br/>
- aws.env.properties - clock project aws env variables and aws credentials id,<br/>
- clock_persistent_vars_file - contains variables like TR workspace of successful build,<br/>
  probably to destroy the ec2 server after next successful deployment.
  
- Credentials
Credentials plugin is used to store credentials on Jenkins server. <br/>
Also need to add Github,Docker hub and AWS credentials on Jenkins server, <br/>
and mannually add its id to jenkins.env.properties file,<br/>
see .example files mentioned above for reference. <br/>
Also, I installed and configured aws-cli, terraform and some other tools <br/>
directly on Jenkins server. <br/>

I run Pipeline job runs Jenkinsfile mannualy from 'clock-pipeline' job when developing. <br/>
Certainly, Github will notify Jenkins server with web hook <br/>
when completed developing. <br/>

- Dockerfile
There is a multi step docker file. <br/>
Main targets are tester and production generate respective images. <br/>
I tried to use environment variables as much as possible <br/>
to avoid using hardcoded variable values in Dockerfile. <br/>

- Jenkinsfile
At the beginning images were stored in Docker hub. <br/>
Yet later I switched to AWS ECR, becasue its higher rate of 'docker login' operation <br/>
from automatic scripts. <br/>
There are several Jenkinsfile items correspond to clock project developing stages. <br/>
I will probably split it to git branches in the future. <br/>
Currently, there are dedicated folders contain respective Jenkinsfile. <br/>

- 1 Docker Ubuntu host deployment.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-host-deploy/Jenkinsfile <br/>

Images were tested, built and pushed to Docker hub on Jenkins DIND main node. <br/>
Deployed to ubuntu host from Jenkins docker DIND server, <br/>
using ssh connection with dedicated user and rsa keys. <br/>

- 2 Docker AWS ec2 deployment on static test and production servers.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-aws-ec2-deploy/Jenkinsfile <br/>

Initially test and production aws ec2 servers were prepared and their ip adresses <br/>
set in environment file as environemtn variables. <br/>
Jenkinsfile ran testing, created and pushed images to Docker hub on test server. <br/>
Then production image was run on production server. <br/>
  
3 Docker AWS ec2 deployment on dynamic ec2 production server.

https://github.com/avrahamm/ci-cd-clock-proj/blob/main/docker-aws-tr-ec2-deploy/install-on-ec2.sh <br/>

No static ec2 servers are prepared.
Jenkinsfile ran testing, created and pushed images to AWS ECR hub <br/>
locally on Jenkins server main node. <br/>
Then terrafrom provisions production ec2 instance. <br/>
Then production image was run on production server. <br/>
Route53 clock.avrahammlabs.net record is set to new ec2 production ip. <br/>
http://clock.avrahammlabs.net/ <br/>
Currently, unused ec2 instances continue to function - need to terminate manually.

CI part of CI/CD.
You may run with a multibranch pipeline job for git flow scenario 
with feature, staging and production branches.
There are conditions for branches for CI part of CI/CD.
Feature branch runs Unit tests (pytest) only.
While staging and production run both Unit, 2E tests and deploy.



