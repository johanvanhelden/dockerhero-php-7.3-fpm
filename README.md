# dockerhero-php-7.3-fpm

https://github.com/johanvanhelden/dockerhero

## Available tags
- `latest`
- `develop` -> used for development purposes and testing before merging to the master branch

## Building and releasing the docker image

Automated builds are turned on for the `develop` and `master` branch.
A push to the `develop` branch will build to a `develop` tag for development and testing purposes and the `master`
branch will build to the `latest` tag, used in production.

## Publishing custom tags

Ensure you are logged in locally to hub.docker.com using `docker login` and have access to the hub repository.
(note: your username is used, not your email address).

```
$ docker build ./ --tag johanvanhelden/dockerhero-php-7.3-fpm:TAG
$ docker push johanvanhelden/dockerhero-php-7.3-fpm:TAG
```
Replace `TAG` with either develop or latest.

Please note, that latest is used in production.
So only tag and push this one once you know there are no issues with the current build!

## Testing the image locally

```
$ docker-compose up --build
$ docker exec -it dockerhero-php-7.3-fpm-testing bash
```
