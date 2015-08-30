#!/bin/bash

# Create the .config for B2G's build.sh script
CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1-l >> .tmp-config
echo PRODUCT_NAME=$1 >> .tmp-config 
mv .tmp-config .config

# Build an updateable B2G
export VARIANT=userdebug &&
export B2G_UPDATER=1 &&
export B2G_SYSTEM_APPS=1 &&
export B2G_UPDATE_CHANNEL=default &&
export MOZ_TELEMETRY_REPORTING=1 &&
export MOZ_CRASHREPORTER_NO_REPORT=1 &&
# Gaia & Spark
export GAIA_DISTRIBUTION_DIR=distros/spark &&
export GAIA_OPTIMIZE=1 &&
# Extra Locales
export LOCALE_BASEDIR=$PWD/gaia/locales &&
export LOCALES_FILE=$PWD/gaia/locales/languages_all.json &&
export GAIA_DEFAULT_LOCALE=en-GB &&
# Firefox OS Branding
export MOZILLA_OFFICIAL=1 &&
export ENABLE_DEFAULT_BOOTANIMATION=true &&
./build.sh

# Copy the month's images to a release zip
if [ ! -f "b2g-updates/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip" ]; then
    pushd out/target/product/$1/
    zip -1 ../../../../b2g-updates/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip system.img boot.img recovery.img userdata.img
    popd
fi;

# Choose which type of OTA build
case "$2" in
    "full")
        # Build a full FOTA Gonk/Gecko/Gaia update.mar
        OTA_TYPE="gecko-update-fota-full"
        OTA_LOCATION="out/target/product/$1/fota-$1-update-full.mar"
        ;;
    *)
        # Build a full OTA Gecko/Gaia update.mar
        OTA_TYPE="gecko-update-full"
        OTA_LOCATION="objdir-gecko/dist/b2g-update/b2g-$1-gecko-update.mar"
        ;;
esac

# Build the chosen type of update
echo "Type of OTA: $OTA_TYPE"
./build.sh "$OTA_TYPE"

# Prepare the data for the update.xml
export ANDROID_TOOLCHAIN="prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.8/bin/"
B2G_BUILD_ID=`cat out/target/product/$1/system/b2g/platform.ini | grep BuildID | sed -e 's/BuildID=//' | tr -d '\n\r'`
B2G_MILESTONE=`cat out/target/product/$1/system/b2g/platform.ini | grep Milestone | sed -e 's/Milestone=//' | tr -d '\n\r'`
URL_TEMPLATE="https://github.com/fxpdev/b2g-updates/releases/download/$(date +"%Y%m%d")/b2g-update-$(date +"%Y%m%d")-$1.mar"

# Locations to copy files
UPDATE_MAR="b2g-updates/$1/b2g-update-$(date +"%Y%m%d")-$1.mar"
UPDATE_XML="b2g-updates/$1/update.xml"

if [ -f ${OTA_LOCATION} ]; then
    # Copy the update.mar to the git repo
    cp $OTA_LOCATION $UPDATE_MAR
    # Build the update.xml for the update.mar
    ./tools/update-tools/build-update-xml.py $UPDATE_MAR --url-template $URL_TEMPLATE --app-version $B2G_MILESTONE --platform-version $B2G_MILESTONE --build-id $B2G_BUILD_ID --output $UPDATE_XML
else
    echo "ERROR: No update.mar built!"
fi
