export HEROKU_TOKEN=$(heroku auth:token)

docker login -u _ -p "$HEROKU_TOKEN"  registry.heroku.com
docker push registry.heroku.com/notes/web
