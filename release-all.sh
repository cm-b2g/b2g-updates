#!/bin/bash

# export GITHUB_TOKEN=

# List of devices to build releases for.
RELEASE_DEVICES="
    leo
    aries
    scorpion
    sirius
    tianchi
    flamingo
    "

# Before we do anything, make sure our release repo is up-to-date.
pushd b2g-updates/
    git pull
popd

# Build full releases for a list of devices.
#
# $1 = list of devices
# $2 = type of build
full_build()
{
    for NAME in $1
    do
        ./full-build.sh $NAME $2
    done
}
full_build "$RELEASE_DEVICES"

# Go to /B2G/b2g-updates to publish the releases.
pushd b2g-updates/

# Add all the update.xml files from the builds
# then commit and push them to GitHub.
#
# $1 = list of devices
# $2 = timestamp for tag
add_update_xml()
{
    # Add update.xml files for commit
    for NAME in $1
    do
        echo "Adding $NAME/update.xml"
        git add $NAME/update.xml
    done

    # Commit and push the update.xml files.
    git commit -m "Update the update.xml files for release $2"
    git push
}
add_update_xml "$RELEASE_DEVICES" "$(date +'%Y%m%d')"

# Create the tag and release on GitHub
# then upload the updates to the release.
#
# $1 = list of devices
# $2 = timestamp for tag
github_release()
{
    # Create the tag for the release.
    git tag $2 && git push --tags

    # Create the release from the tag.
    ./github-release release --user fxpdev --repo b2g-updates --tag $2 --name "b2g-gecko-update-$2"

    # Upload the releases to GitHub if it exists.
    for NAME in $1
    do
        if [ -f $NAME/b2g-update-$2-$NAME.mar ]; then
            echo "Uploading $NAME"
            ./github-release upload --user fxpdev --repo b2g-updates --tag $2 --name "b2g-update-$2-$NAME.mar" --file $NAME/b2g-update-$2-$NAME.mar
        fi
    done

    echo "Uploading Complete!"
}
github_release "$RELEASE_DEVICES" "$(date +'%Y%m%d')"

# Return back to /B2G
popd
