# Test of Dockerfile Maven plugin

Test of [Dockerfile Maven plugin](https://github.com/spotify/dockerfile-maven)

## Building

```bash
mvn clean package
```

## Running

```bash
docker run --rm -it -p 8080:8080 abrarov/dockerfile-test
```

or 

```bash
docker run -e GREETING='Hello, User!' --rm -it -p 8080:8080 abrarov/dockerfile-test
```