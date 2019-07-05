# Test of Dockerfile Maven plugin

Test of [Dockerfile Maven plugin](https://github.com/spotify/dockerfile-maven)

## Building

```bash
mvn clean package
```

## Running

```bash
docker run --rm -it abrarov/dockerfile-test
```

or 

```bash
docker run --rm -it -e GREETING_NAME=user abrarov/dockerfile-test
```