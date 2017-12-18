# Travis-Heroku-Docker: This is a Demo App for Heroku Deployment of a Rails app via Travis in a docker container.

[![Build Status](https://travis-ci.org/htw-imi-rails-examples/docker-travis-heroku.svg?branch=master)](https://travis-ci.org/htw-imi-rails-examples/docker-travis-heroku)

App on heroku:
[https://docker-travis-heroku.herokuapp.com/](https://docker-travis-heroku.herokuapp.com/)

## Setting up docker, Database Config for dev, test, prd

* include the pg gem in Gemfile (&remove sqlite)
* adapt config/database.yml:
    * dev+test connect to postgres on host db in the docker network,
    * prd: don't provide configuration for prd - this will be provided by the DATABASE_URL env variable on heroku
* create Dockerfile and docker-compose.yml
* create separate Dockerfile.production - at least for asset precompilation:

### Set up a production docker image - Dockerfile.production

To run rails in production mode, a couple of changes need to be applied:

- Database need to be set to postgres
- RAILS_ENV needs to be set to production to run rails in production mode
- assets should be precompiled and included in the docker image.
- the image should be build by travis after an successful test run and uploaded to heroku - thus a script is created that builds the image with an appropriate tag. see travis/docker-upload.sh

### some notes on local testing

To test docker image locally:

start the database, build and start the web app:

    travis/docker-upload.sh
    docker-compose up db
    export SECRET_KEY_BASE=$(rake secret)
    docker run -e SECRET_KEY_BASE=$SECRET_KEY_BASE \
               -p 3002:3000 \
               --name web \
               notes/notes:293ef60

execute bash in container:
    docker exec -ti web bash

## Heroku Preparation

On Heroku, only the rails app will run in a docker container. The Database will run as a heroku add-on.

To prepare the Heroku app:

    heroku login
    heroku create
    heroku rename <app-name>
e.g.
    heroku rename docker-travis-heroku

Configuration for the Rails App is done by setting Environment variables, see [https://devcenter.heroku.com/articles/config-vars](https://devcenter.heroku.com/articles/config-vars) and [https://12factor.net/config](https://12factor.net/config)

### secret key base for production
configure SECRET_KEY_BASE:

    heroku config:set SECRET_KEY_BASE=$(rake secret)

### Database for production on Heroku

Tell Heroku to use the postgres add-on:

    heroku addons:create heroku-postgresql:hobby-dev

After that, the database is available and the configuration is set in an environment variable, you can check it with

    heroku config:get DATABASE_URL

Nothing needs to be done in the config/database.yml.

Create the database:

    heroku run bundle exec rails db:create

(TBD: is this step necessary or is the migration run by travis sufficient?)

Documentation: [https://devcenter.heroku.com/articles/heroku-postgresql](https://devcenter.heroku.com/articles/heroku-postgresql)

## Pushing the image to Heroku

###Documentation:

* Heroku side: [Container Registry & Runtime (Docker Deploys)](https://devcenter.heroku.com/articles/container-registry-and-runtime)
* Travis side: [Pushing a Docker Image to a Registry](https://docs.travis-ci.com/user/docker/#Pushing-a-Docker-Image-to-a-Registry)

### Making the Heroku API key known to Travis CI

In order to access heroku, the Heroku API key must be set as HEROKU_TOKEN
environment variable in the travis repository.

One way to do that is to obtain the API key and set is via the Travis web
interface under "settings". Be sure to switch "Show in log" to off, otherwise
your key will be included in the log and be public to everyone enabling everyone
to access your Heroku account.

(note: it should also be possible to set the HEROKU_TOKEN via .travis.yml
  add HEROKU_TOKEN to .travis.yml
  travis encrypt HEROKU_TOKEN=$(heroku auth:token) --add env.global
)
### add deploy steps to travis.yml:

to get the heroku token into a env variable:

set the env variable on travis (switch "show it in the log" to off!)

add these steps to travis.yml:(can also be tested locally)

- docker login -u _ -p "$HEROKU_TOKEN"  registry.heroku.com
- docker build -t registry.heroku.com/notes/web -f Dockerfile.production .
- docker push registry.heroku.com/notes/web
    docker login -u _ -p $HEROKU_TOKEN registry.heroku.com
- heroku run bundle exec rails db:migrate


https://devcenter.heroku.com/articles/local-development-with-docker-compose
