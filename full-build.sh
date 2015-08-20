#!/bin/bash

# Grab the right manifest and download repos
export GITREPO="git://github.com/AdFad666/b2g-manifest --reference /home/repo/"
./config.sh $1-l

# Build an updateable B2G
export VARIANT=userdebug &&
export B2G_UPDATER=1 &&
export B2G_SYSTEM_APPS=1 &&
export B2G_UPDATE_CHANNEL=default &&
export MOZ_TELEMETRY_REPORTING=1 &&
export MOZ_CRASHREPORTER_NO_REPORT=1 &&
export GAIA_DISTRIBUTION_DIR=distros/spark &&
export GAIA_OPTIMIZE=1 &&
export MOZILLA_OFFICIAL=1 &&
export ENABLE_DEFAULT_BOOTANIMATION=true &&
./build.sh

# Copy the month's images to a release zip
if [ ! -f "../b2g-fota/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip" ]; then
    zip -1 ../b2g-fota/$1/B2G_MASTER-$(date +'%Y%m')_$1.zip out/target/product/$1/system.img out/target/product/$1/boot.img out/target/product/$1/userdata.img
fi;

# Build a full Gecko/Gaia update.mar
./build.sh gecko-update-full

# Prepare the data for the update.xml
export ANDROID_TOOLCHAIN="prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.8/bin/"
B2G_BUILD_ID=`cat out/target/product/$1/system/b2g/platform.ini | grep BuildID | sed -e 's/BuildID=//' | tr -d '\n\r'`
B2G_MILESTONE=`cat out/target/product/$1/system/b2g/platform.ini | grep Milestone | sed -e 's/Milestone=//' | tr -d '\n\r'`
URL_TEMPLATE="https://github.com/fxpdev/b2g-updates/releases/download/$(date +"%Y%m%d")/b2g-$1-gecko-update.mar"

# Locations to copy files
UPDATE_MAR="b2g-updates/$1/b2g-$1-gecko-update.mar"
UPDATE_XML="b2g-updates/$1/update.xml"

# Copy the update.mar to the git repo
cp objdir-gecko/dist/b2g-update/b2g-$1-gecko-update.mar $UPDATE_MAR

# Build the update.xml for the update.mar
./tools/update-tools/build-update-xml.py $UPDATE_MAR --url-template $URL_TEMPLATE --app-version $B2G_MILESTONE --platform-version $B2G_MILESTONE --build-id $B2G_BUILD_ID --output $UPDATE_XML

