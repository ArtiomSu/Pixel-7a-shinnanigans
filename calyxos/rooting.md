# Links

[Safety Net Module](https://github.com/Displax/safetynet-fix/releases)
[Pixel 7a calyx ota](https://calyxos.org/get/ota/)
[Pixel 7a calyx factory images](https://calyxos.org/install/devices/lynx/linux/)
[Magisk](https://github.com/topjohnwu/Magisk/releases)
[avbroot](https://github.com/chenxiaolong/avbroot)

no need to use their flashing tool. can simply use the flash-all.sh script

# Calyx OS flashing, rooting and locking bootloader

first time setup

```
mkdir calyx_rom_keys
cd calyx_rom_keys

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.key

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out ota.key

../../graphene_os/avbroot/external/avb/avbtool.py extract_public_key --key avb.key --output avb_pkmd.bin

openssl req -new -x509 -sha256 -key ota.key -out ota.crt -days 10000 -subj '/CN=Calyx/'

cd ..

python ../graphene_os/avbroot/avbroot.py patch --input ./lynx-ota_update-23409032.zip --privkey-avb ./calyx_rom_keys/avb.key --privkey-ota ./calyx_rom_keys/ota.key --cert-ota ./calyx_rom_keys/ota.crt --magisk ../rooting/Magisk-v26.1.apk --magisk-preinit-device persist

python ../graphene_os/avbroot/avbroot.py extract --input ./lynx-ota_update-23409032.zip.patched --directory extracted

mkdir flash_factory

cp lynx-factory-23409032.zip ./flash_factory

cd flash_factory

unzip lynx-factory-23409032.zip

mv ./lynx-tq2a.230505.002/* ./

rm -r lynx-tq2a.230505.002 lynx-factory-23409032.zip

mkdir image

mv image-lynx-tq2a.230505.002.zip image/

cd image

unzip image-lynx-tq2a.230505.002.zip

rm image-lynx-tq2a.230505.002.zip init_boot.img vbmeta.img vendor_boot.img

cp ../../extracted/* ./

zip -r patched_image.zip .

mv patched_image.zip ../

cd ..

rm -r image avb_custom_key.img

mv patched_image.zip image-lynx-tq2a.230505.002.zip

cp ../calyx_rom_keys/avb_pkmd.bin ./avb_custom_key.img

adb reboot bootloader

fastboot flashing unlock

./flash-all.sh

fastboot flashing lock

```













