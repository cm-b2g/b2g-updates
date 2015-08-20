#!/bin/bash

# export GITHUB_TOKEN=
TAG_DATE=$(date +'%Y%m%d')

# Build all of the releases
./full-build.sh sirius
./full-build.sh tianchi

pushd b2g-updates/

# commit the update.xml files
git add sirius/update.xml
git add tianchi/update.xml
git commit -m "Update the update.xml files for release $TAG_DATE"
git push

# Create the tag for the release
git tag $TAG_DATE && git push --tags

# Create the release from the tag
./github-release release --user fxpdev --repo b2g-updates --tag $TAG_DATE --name "b2g-gecko-update-$TAG_DATE"

# Upload the release binaries
echo "Uploading Sirius"
./github-release upload --user fxpdev --repo b2g-updates --tag $TAG_DATE --name "b2g-sirius-gecko-update.mar" --file sirius/b2g-sirius-gecko-update.mar
echo "Uploading Tianchi"
./github-release upload --user fxpdev --repo b2g-updates --tag $TAG_DATE --name "b2g-tianchi-gecko-update.mar" --file tianchi/b2g-tianchi-gecko-update.mar
echo "Uploading Complete!"

popd
