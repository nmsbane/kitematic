#!/bin/bash
set -e # Auto exit on error

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/colors.sh
source $DIR/versions.sh

BASE=$DIR/..

pushd $BASE

if [ ! -d bundle ]; then
  cecho "No bundle, run script/bundle.sh first." $red
  exit 1
fi

rm -rf dist/osx/Kitematic.app
rm -rf dist/osx/Kitematic.zip
mkdir -p dist/osx/

cecho "-----> Creating Kitematic.app..." $blue
find cache/node-webkit -name "debug\.log" -print0 | xargs -0 rm -rf
cp -R cache/node-webkit/node-webkit.app dist/osx/
mv dist/osx/node-webkit.app dist/osx/Kitematic.app
mkdir -p dist/osx/Kitematic.app/Contents/Resources/app.nw

cecho "-----> Copying meteor bundle into Kitematic.app..." $blue
cp -R bundle dist/osx/Kitematic.app/Contents/Resources/app.nw/

cecho "-----> Copying node-webkit app into Kitematic.app..." $blue
cp index.html dist/osx/Kitematic.app/Contents/Resources/app.nw/
cp index.js dist/osx/Kitematic.app/Contents/Resources/app.nw/
cp package.json dist/osx/Kitematic.app/Contents/Resources/app.nw/
cp -R node_modules dist/osx/Kitematic.app/Contents/Resources/app.nw/

$DIR/setup.sh

cecho "-----> Copying binary files to Kitematic.app" $blue
mkdir -p dist/osx/Kitematic.app/Contents/Resources/app.nw/resources
cp -v resources/* dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/ || :

chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/$BOOT2DOCKER_CLI_FILE
chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/$COCOASUDO_FILE
chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/install
chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/terminal
chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/unison
chmod +x dist/osx/Kitematic.app/Contents/Resources/app.nw/resources/node

if [ -f $DIR/sign.sh ]; then
  cecho "-----> Signing app file...." $blue
  $DIR/sign.sh $BASE/dist/osx/Kitematic.app
fi

pushd dist/osx
  cecho "-----> Creating disributable zip file...." $blue
  ditto -c -k --sequesterRsrc --keepParent Kitematic.app Kitematic.zip
popd

cecho "Done." $green
cecho "Kitematic app available at dist/osx/Kitematic.app" $green
cecho "Kitematic zip distribution available at dist/osx/Kitematic.zip" $green

popd
