# dockerhero-php-7.3-fpm

https://github.com/johanvanhelden/dockerhero

## Available tags
- `latest`

## Building and publishing

Ensure you are logged in locally to hub.docker.com using `docker login` and have access to the hub repository.
(note: your username is used, not your email address).

```
$ docker build ./ --tag johanvanhelden/dockerhero-workspace:TAG
$ docker push johanvanhelden/dockerhero-workspace:TAG
```
Replace `TAG` with the tag you are working on.
Only tag and push this one once you know there are no issues with the current build!

## Testing the image locally

```
$ docker-compose up --build
$ docker exec -it dockerhero-php-7.3-fpm-testing bash
```
