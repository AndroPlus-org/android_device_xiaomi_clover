#!/sbin/sh

relink()
{
	fname=$(basename "$1")
	target="/sbin/$fname"
	sed 's|/system/bin/linker64|///////sbin/linker64|' "$1" > "$target"
	chmod 755 $target
}

finish()
{
	umount /v
	umount /s
	umount /fw
	rmdir /v
	rmdir /s
	rmdir /fw
	setprop crypto.ready 1
	exit 0
}

venpath="/dev/block/bootdevice/by-name/vendor"
mkdir /v
mount -t ext4 -o ro "$venpath" /v
syspath="/dev/block/bootdevice/by-name/system"
mkdir /s
mount -t ext4 -o ro "$syspath" /s
fwpath="/dev/block/bootdevice/by-name/modem"
mkdir /fw
mount -t vfat -o ro "$fwpath" /fw

is_fastboot_twrp=$(getprop ro.boot.fastboot)
if [ ! -z "$is_fastboot_twrp" ]; then
	osver=$(getprop ro.build.version.release_orig)
	patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
fi

if [ -f /s/build.prop ]; then
	# TODO: It may be better to try to read these from the boot image than from /system
	osver=$(grep -i 'ro.build.version.release' /s/build.prop  | cut -f2 -d'=')
	patchlevel=$(grep -i 'ro.build.version.security_patch' /s/build.prop  | cut -f2 -d'=')
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
else
	# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
	osver=$(getprop ro.build.version.release_orig)
	patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
fi

###### NOTE: The below is no longer used but I'm keeping it here in case it is needed again at some point!
mkdir -p /vendor/lib64/hw/
mkdir -p /firmware/image/

cp /s/lib64/android.hidl.base@1.0.so /sbin/
cp /s/lib64/vndk-sp/libhidlbase.so /sbin/
cp /s/lib64/libicuuc.so /sbin/
cp /s/lib64/libxml2.so /sbin/
cp /s/lib64/libkeymaster1.so /sbin/
cp /s/lib64/libkeymaster_messages.so /sbin/

relink /v/bin/qseecomd

cp /s/lib64/android.hidl.base@1.0.so /vendor/lib64/
cp /s/lib64/vndk-sp/libhidlbase.so /vendor/lib64/
cp /v/lib64/libdiag.so /vendor/lib64/
cp /v/lib64/libdrmfs.so /vendor/lib64/
cp /v/lib64/libdrmtime.so /vendor/lib64/
cp /v/lib64/libGPreqcancel.so /vendor/lib64/
cp /v/lib64/libGPreqcancel_svc.so /vendor/lib64/
cp /v/lib64/libqdutils.so /vendor/lib64/
cp /v/lib64/libqisl.so /vendor/lib64/
cp /v/lib64/libqservice.so /vendor/lib64/
cp /v/lib64/libQSEEComAPI.so /vendor/lib64/
cp /v/lib64/librecovery_updater_msm.so /vendor/lib64/
cp /v/lib64/librpmb.so /vendor/lib64/
cp /v/lib64/libsecureui.so /vendor/lib64/
cp /v/lib64/libSecureUILib.so /vendor/lib64/
cp /v/lib64/libsecureui_svcsock.so /vendor/lib64/
cp /v/lib64/libspcom.so /vendor/lib64/
cp /v/lib64/libspl.so /vendor/lib64/
cp /v/lib64/libssd.so /vendor/lib64/
cp /v/lib64/libStDrvInt.so /vendor/lib64/
cp /v/lib64/libtime_genoff.so /vendor/lib64/
cp /v/lib64/libkeymasterdeviceutils.so /vendor/lib64/
cp /v/lib64/libkeymasterprovision.so /vendor/lib64/
cp /v/lib64/libkeymasterutils.so /vendor/lib64/
cp /v/lib64/hw/bootctrl.sdm660.so /vendor/lib64/hw/
cp /v/lib64/hw/gatekeeper.sdm660.so /vendor/lib64/hw/
cp /v/lib64/hw/keystore.sdm660.so /vendor/lib64/hw/
cp /v/lib64/hw/android.hardware.boot@1.0-impl.so /vendor/lib64/hw/
cp /v/lib64/hw/android.hardware.gatekeeper@1.0-impl.so /vendor/lib64/hw/
cp /v/lib64/hw/android.hardware.keymaster@3.0-impl.so /vendor/lib64/hw/

cp /v/manifest.xml /vendor/
cp /v/compatibility_matrix.xml /vendor/

relink  /v/bin/hw/android.hardware.boot@1.0-service
relink  /v/bin/hw/android.hardware.keymaster@3.0-service
relink  /v/bin/hw/android.hardware.gatekeeper@1.0-service

cp /fw/image/keymaste.mdt /firmware/image/keymaster.mdt
cp /fw/image/keymaste.b00 /firmware/image/keymaster.b00
cp /fw/image/keymaste.b01 /firmware/image/keymaster.b01
cp /fw/image/keymaste.b02 /firmware/image/keymaster.b02
cp /fw/image/keymaste.b03 /firmware/image/keymaster.b03
cp /fw/image/keymaste.b04 /firmware/image/keymaster.b04
cp /fw/image/keymaste.b05 /firmware/image/keymaster.b05
cp /fw/image/keymaste.b06 /firmware/image/keymaster.b06
cp /fw/image/keymaste.b07 /firmware/image/keymaster.b07

finish
exit 0
