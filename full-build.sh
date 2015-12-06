#!/bin/bash

# $1 = device codename
# $2 = release date

# Create the .config for B2G's build.sh script
CORE_COUNT=`grep processor /proc/cpuinfo | wc -l`
echo MAKE_FLAGS=-j$((CORE_COUNT + 2)) > .tmp-config
echo GECKO_OBJDIR=$PWD/objdir-gecko >> .tmp-config
echo DEVICE_NAME=$1-l >> .tmp-config
echo PRODUCT_NAME=$1 >> .tmp-config
mv .tmp-config .config

# Build an updateable B2G
. b2g-updates/export-me.sh && ./build.sh gecko-update-fota-fullimg

# Copy the month's images to a release zip
if [ ! -f "b2g-updates/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip" ]; then
    cp out/target/product/$1/recovery.img b2g-updates/$1/recovery_$1.img
    cp out/target/product/$1/fota/fullimg/update.zip b2g-updates/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip
fi;

# Prepare for the update.xml
export ANDROID_TOOLCHAIN="prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.8/bin/"
URL_TEMPLATE="https://github.com/fxpdev/b2g-updates/releases/download/$2/b2g-update-$2-$1.mar"
B2G_MILESTONE=`cat out/target/product/$1/system/b2g/platform.ini | grep Milestone | sed -e 's/Milestone=//' | tr -d '\n\r'`
MOZ_B2G_VERSION=`cat gecko/b2g/confvars.sh | grep MOZ_B2G_VERSION | sed -e 's/MOZ_B2G_VERSION=//' | tr -d '\n\r'`
B2G_BUILD_ID=`cat out/target/product/$1/system/b2g/platform.ini | grep BuildID | sed -e 's/BuildID=//' | tr -d '\n\r'`

# Locations to copy files
OTA_LOCATION="out/target/product/$1/fota-$1-update-fullimg.mar"
UPDATE_MAR="b2g-updates/$1/b2g-update-$2-$1.mar"
UPDATE_XML="b2g-updates/$1/update.xml"

if [ -f ${OTA_LOCATION} ]; then
    # Copy the update.mar to the git repo
    cp $OTA_LOCATION $UPDATE_MAR
    # Build the update.xml for the update.mar
    ./tools/update-tools/build-update-xml.py $UPDATE_MAR --url-template $URL_TEMPLATE --app-version $B2G_MILESTONE --platform-version $MOZ_B2G_VERSION --build-id $B2G_BUILD_ID --output $UPDATE_XML
else
    echo "ERROR: No update.mar built!"
fi
