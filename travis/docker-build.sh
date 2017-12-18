export DEPLOYMENT_TAG=$(travis/tag.sh)
echo "set deployment tag to $DEPLOYMENT_TAG"
echo "building image notes/notes:$DEPLOYMENT_TAG"
docker build -f Dockerfile.production -t notes/notes:$DEPLOYMENT_TAG .
