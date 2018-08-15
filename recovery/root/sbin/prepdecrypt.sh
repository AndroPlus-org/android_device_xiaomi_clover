#!/sbin/sh

relink()
{
	fname=$(basename "$1")
	target="/sbin/$fname"
	sed 's@\x2F\x73\x79\x73\x74\x65\x6D\x2F\x62\x69\x6E\x2F\x6C\x69\x6E\x6B\x65\x72\x36\x34@\x2F\x73\x62\x69\x6E\x2F\x6C\x69\x6E\x6B\x65\x72\x36\x34\x00\x00\x00\x00\x00\x00@g' "$1" > "$target"
	chmod 755 $target
}

finish()
{
	umount /v
	umount /s
	rmdir /v
	rmdir /s
	setprop crypto.ready 1
	exit 0
}

venpath="/dev/block/bootdevice/by-name/vendor"
mkdir /v
mount -t ext4 -o ro "$venpath" /v
syspath="/dev/block/bootdevice/by-name/system"
mkdir /s
mount -t ext4 -o ro "$syspath" /s

is_fastboot_twrp=$(getprop ro.boot.fastboot)
if [ ! -z "$is_fastboot_twrp" ]; then
	osver=$(getprop ro.build.version.release_orig)
	patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	finish
fi

if [ -f /s/system/build.prop ]; then
	# TODO: It may be better to try to read these from the boot image than from /system
	osver=$(grep -i 'ro.build.version.release' /s/system/build.prop  | cut -f2 -d'=')
	patchlevel=$(grep -i 'ro.build.version.security_patch' /s/system/build.prop  | cut -f2 -d'=')
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	finish
else
	# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
	osver=$(getprop ro.build.version.release_orig)
	patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	finish
fi

finish
exit 0
