# Test of Dockerfile Maven plugin

Test of [Dockerfile Maven plugin](https://github.com/spotify/dockerfile-maven)

## Building

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