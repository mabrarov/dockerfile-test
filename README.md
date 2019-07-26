# Test of Dockerfile Maven plugin

[![Release](https://img.shields.io/github/release/mabrarov/dockerfile-test)](https://github.com/mabrarov/dockerfile-test/releases/latest) [![License](https://img.shields.io/github/license/mabrarov/dockerfile-test.svg)](https://github.com/mabrarov/dockerfile-test/tree/master/LICENSE)

Branch | Linux
-------|-------
[master](https://github.com/mabrarov/dockerfile-test/tree/master) | [![Travis CI build status](https://travis-ci.org/mabrarov/dockerfile-test.svg?branch=master)](https://travis-ci.org/mabrarov/dockerfile-test)
[develop](https://github.com/mabrarov/dockerfile-test/tree/develop) | [![Travis CI build status](https://travis-ci.org/mabrarov/dockerfile-test.svg?branch=develop)](https://travis-ci.org/mabrarov/dockerfile-test)

Test of [Dockerfile Maven plugin](https://github.com/spotify/dockerfile-maven), which

* solves [The backlash of chmod/chown/mv in your Dockerfile](https://medium.com/@lmakarov/the-backlash-of-chmod-chown-mv-in-your-dockerfile-f12fe08c0b55) 
  issue by using Maven Assembly plugin and TAR format, i.e. works correctly and uniformly when building 
  on Linux and on Windows (using remote Docker Engine)
* uses [Red Hat JBoss EAP 6.4 Docker image](https://access.redhat.com/containers/#/registry.access.redhat.com/jboss-eap-6/eap64-openshift)
  and controls deployment of application, i.e. ensures that application is deployed successfully or stops 
  Docker container with non zero exit code otherwise
* utilizes [j2cli](https://github.com/kolypto/j2cli) for filling configuration templates and for generating 
  configuration files - both JBoss EAP configuration files and application configuration files are generated
* performs custom escaping of values inserted into generated [.properties files](https://en.wikipedia.org/wiki/.properties)

## Docker image hierarchy

```text
registry.redhat.io/jboss-eap-6/eap64-openshift (Red Hat OpenJDK 1.8 + Red Hat JBoss EAP 6.4 + Python 2.7)
│
└─── abrarov/dockerfile-test-base (+ pip + j2cli)
     │
     └─── abrarov/dockerfile-test-hollow (+ configuration + scripts)
          │
          └─── abrarov/dockerfile-test (+ application)
```

## Building

Requires authentication in registry.redhat.io Docker Registry with [Red Hat account](https://www.redhat.com/wapps/ugc/register.html) 
to pull 
[jboss-eap-6/eap64-openshift](https://access.redhat.com/containers/#/registry.access.redhat.com/jboss-eap-6/eap64-openshift) 
Red Hat Docker image during build:

```bash
docker login registry.redhat.io
```

Command for building:

```bash
mvn clean package
```

## Running

```bash
docker run --rm -it -p 8080:8080 abrarov/dockerfile-test
```

or 

```bash
docker run -e GREETING="$(date)" --rm -it -p 8080:8080 abrarov/dockerfile-test
```

## Testing

```bash
wget -q -O - http://${DOCKER_HOST}:8080
```

where `${DOCKER_HOST}` is Docker host address

expected output looks like:

```html
<html>
<head>
    <title>Dockerfile Maven plugin test</title>
</head>
<body>

Sat Jul  6 15:42:38 MSK 2019
</body>
</html>
``` 