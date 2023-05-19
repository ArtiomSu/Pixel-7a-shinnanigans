# Links

[Guide for Pixel 7](https://www.xda-developers.com/how-to-unlock-bootloader-root-magisk-google-pixel-7-pro/)

[Safety Net Module](https://github.com/Displax/safetynet-fix/releases)

[Pixel 7a stock ota](https://developers.google.com/android/ota)
[Pixel 7a stock factory images](https://developers.google.com/android/images)

[Magisk](https://github.com/topjohnwu/Magisk/releases)

[Payload Dumper](https://github.com/vm03/payload_dumper)

[avbroot](https://github.com/chenxiaolong/avbroot)

# Stock rom rooting and locking bootloader

first time setup

```
mkdir stock_rom_keys
cd stock_rom_keys

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.key

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out ota.key

../../graphene_os/avbroot/external/avb/avbtool.py extract_public_key --key avb.key --output avb_pkmd.bin

openssl req -new -x509 -sha256 -key ota.key -out ota.crt -days 10000 -subj '/CN=PixelSevenA/'

cd ..

python ../graphene_os/avbroot/avbroot.py patch --input ./lynx-ota-TQ2B.230505.005.A1.zip --privkey-avb ./stock_rom_keys/avb.key --privkey-ota ./stock_rom_keys/ota.key --cert-ota ./stock_rom_keys/ota.crt --magisk ./Magisk-v26.1.apk --magisk-preinit-device persist

python ../graphene_os/avbroot/avbroot.py extract --input ./lynx-ota-TQ2B.230505.005.A1.zip.patched --directory extracted

mkdir flash_factory

cp lynx-tq2b.230505.005.a1-factory-1b694930.zip ./flash_factory

cd flash_factory

unzip lynx-tq2b.230505.005.a1-factory-1b694930.zip

mv ./lynx-tq2b.230505.005.a1/* ./

rm -r lynx-tq2b.230505.005.a1 lynx-tq2b.230505.005.a1-factory-1b694930.zip

mkdir image

mv image-lynx-tq2b.230505.005.a1.zip image/

cd image

unzip image-lynx-tq2b.230505.005.a1.zip

rm image-lynx-tq2b.230505.005.a1.zip init_boot.img vbmeta.img vendor_boot.img

cp ../../extracted/* ./

zip -r patched_image.zip .

mv patched_image.zip ../

cd ..

rm -r image 

mv patched_image.zip image-lynx-tq2b.230505.005.a1.zip

./flash-all.sh

fastboot getvar current-slot

fastboot set_active a

./flash-all.sh

fastboot erase avb_custom_key

fastboot flash avb_custom_key ../stock_rom_keys/avb_pkmd.bin

fastboot flashing lock

```













