NodeJS build agent for Teamcity
===============================

* Based on [jetbrains/teamcity-minimal-agent](https://hub.docker.com/r/jetbrains/teamcity-minimal-agent/)
* Contains NodeJS, eslint, istanbul, and mocha for running tests
* Docker for building images
* AWS CLI for image/task deployments to AWS
* Can be deployed with a [tf_teamcity terraform module](https://github.com/snatalenko/tf_teamcity)

In case you want to add your deployment SSH key, you can extend the teamcity-nodejs-agent image in the following way:

```Dockerfile
FROM snatalenko/teamcity-nodejs-agent:latest

COPY ./etc/buildagent.key /root/.ssh/
RUN chmod 600 /root/.ssh/buildagent.key && \
    echo "IdentityFile ~/.ssh/buildagent.key" > /root/.ssh/config
```
