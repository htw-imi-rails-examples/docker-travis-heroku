
if [ "$TRAVIS_TAG" ]; then
  echo $TRAVIS_TAG
  exit 0
fi
git log --pretty=format:'%h' -n 1
