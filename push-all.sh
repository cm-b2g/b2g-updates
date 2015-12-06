#!/bin/bash

# $1 = type of push

RELEASE_DATE=$(date +'%Y%m')

# List of devices to push releases for.
RELEASE_DEVICES="
    flamingo
    eagle
    seagull
    tianchi
    amami
    honami
    scorpion
    sirius
    aries
    leo
    "

# Upload the new full release.
#
# $1 = list of devices
# $2 = release date
push_full_release()
{
    for NAME in $1
    do
        # Upload the release to GitHub.
        if [ -f $NAME/B2G_MASTER-$2_$NAME.zip ]; then
            echo "Uploading full release for $NAME"
            ./github-release upload --user fxpdev --repo b2g-updates --tag "nightly" --name "B2G_MASTER-$2_$NAME.zip" --file $NAME/B2G_MASTER-$2_$NAME.zip
        fi
    done

    echo "Uploading Complete!"
}

# Upload the new recovery release.
#
# $1 = list of devices
push_recovery_release()
{
    for NAME in $1
    do
        # Upload the release to GitHub.
        if [ -f $NAME/recovery_$NAME.img ]; then
            echo "Uploading recovery for $NAME"
            ./github-release upload --user fxpdev --repo b2g-updates --tag "recovery" --name "recovery_$NAME.img" --file $NAME/recovery_$NAME.img
        fi
    done

    echo "Uploading Complete!"
}

read -p "Delete the old release in the '$1' tag, then press [Enter] to continue..."

pushd b2g-updates/ > /dev/null

# Push the new release
case "$1" in
    "full")
        push_full_release "$RELEASE_DEVICES" "$RELEASE_DATE"
        ;;

    "recovery")
        push_recovery_release "$RELEASE_DEVICES"
        ;;

    *)
        echo "What are you trying to push? full or recovery?"
        popd > /dev/null
        exit -1
        ;;
esac

popd > /dev/null


