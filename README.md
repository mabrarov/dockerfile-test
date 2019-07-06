# Test of Dockerfile Maven plugin

Test of [Dockerfile Maven plugin](https://github.com/spotify/dockerfile-maven)

Utilizes [j2cli](https://github.com/kolypto/j2cli) for filling configuration templates

## Docker image hierarchy

```text
registry.redhat.io/jboss-eap-6/eap64-openshift (Red Hat OpenJDK 1.8 + Red Hat JBoss EAP 6.4 + Python 2.7)
│
└─── abrarov/dockerfile-test/base-image (+ pip + j2cli)
     │
     └─── abrarov/dockerfile-test/hollow-image (+ configuration + scripts)
          │
          └─── abrarov/dockerfile-test/app-image (+ application)
```

## Building

Requires authentication in registry.redhat.io Docker Registry with Red Hat account to pull 
registry.redhat.io/jboss-eap-6/eap64-openshift Docker image during build:

```bash
docker login registry.redhat.io
```

Command for building:

```bash
mvn clean package
```

## Running

```bash
docker run --rm -it -p 8080:8080 abrarov/dockerfile-test/app-image
```

or 

```bash
docker run -e GREETING="$(date)" --rm -it -p 8080:8080 abrarov/dockerfile-test/app-image
```

## Testing

```bash
wget -q -O - http://localhost:8080
```

where `localhost` is Docker host address 