B2G OTA Updates from FXP
=======================

This repo hosts the update.xml files that our builds of B2G use to check for OTA
updates. We also take advantage of [GitHub releases](https://help.github.com/articles/creating-releases/)
to host the actual updates.

* Building the update for a particular device is scripted by `full-build.sh`.
* Building all devices and uploading to GitHub is scripted by `release-all.sh`.
* The actual upload is managed by `github-release` v0.6.2 which comes from [github.com/aktau](https://github.com/aktau/github-release).

Be sure to grab the right manifest when cloning B2G:
`export GITREPO="git://github.com/AdFad666/b2g-manifest --reference /home/repo/"`

After you've done an initial `config.sh` sync you should clone `b2g-updates` inside
the B2G folder, then symlink `release-all.sh` and `full-build.sh` to the B2G folder. 

After that it's enough to run `release-all.sh`, then grab a coffee as all of your
releases are automatically built and uploaded.

(Just remember to have your [GitHub access token](https://help.github.com/articles/creating-an-access-token-for-command-line-use/)
defined as `GITHUB_TOKEN=XXXXXXXXX` in `release-all.sh`!)

How often will there be updates?
--------------------------------

The current plan is to provide weekly Gecko/Gaia OTA updates, and full updates when
necessary, probalby once a month (a full update includes kernel and blobs).
These will be run at the weekend when Mozillians are not as active.

Why should I care about B2G?
----------------------------

Typically each new version of Android runs slower on the same hardware, so eventually
a future version of Android will be too much for current devices.

B2G drops the java bloat entirely, and is actually much faster than Android on the
same hardware because of this.

But Sony devices are supported in AOSP!
---------------------------------------

Yes, for now.

Android iterates very quickly, and older versions are quickly abandoned. The same
is true for the actual devices. Your Android phone that is two years old is effectively
guaranteed to be abandoned by the manufacturer, and riddled with security holes.

Custom Android ROMs aren't much help either. CyanogenMod also abandons older versions
and routinely drops devices that are not considered good enough for the latest release.

If your device is not compatible with Android 4.4 KitKat or greater, good luck finding
a custom ROM that has the latest security patches.

Why do this now? Just wait until the device is obsolete!
--------------------------------------------------------

Do you want to work on an obsolete device?

Mozilla has shown a willingness to keep compatibility with older devices.

We're doing the hard work now, so that *in the future* we have a solution for when
Android is too bloated. At that point in time we'll also be working on the latest
and greatest devices. We won't have the time to start porting an old device to an
entirely new OS.

We hope this work will extend the life of Xperia devices even further into the future.

