# Links

[Safety Net Module](https://github.com/Displax/safetynet-fix/releases)

[Magisk](https://github.com/topjohnwu/Magisk/releases)

[avbroot](https://github.com/chenxiaolong/avbroot)

# Grapheneos rooting and locking bootloader

first time setup


```
cd graphene_os

mkdir rooting_stock_grapheneos

cd rooting_stock_grapheneos

mkdir stock_graphene_keys
cd stock_graphene_keys

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.key

openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out ota.key

../../../graphene_os/avbroot/external/avb/avbtool.py extract_public_key --key avb.key --output avb_pkmd.bin

openssl req -new -x509 -sha256 -key ota.key -out ota.crt -days 10000 -subj '/CN=Grapheneos/'

cd ..

python ../avbroot/avbroot.py patch --input ./lynx-ota_update-2023051600.zip --privkey-avb ./stock_graphene_keys/avb.key --privkey-ota ./stock_graphene_keys/ota.key --cert-ota ./stock_graphene_keys/ota.crt --magisk ../../rooting/Magisk-v26.1.apk --magisk-preinit-device persist

python ../avbroot/avbroot.py extract --input ./lynx-ota_update-2023051600.zip.patched --directory extracted

mkdir flash_graphene

cp lynx-factory-2023051600.zip ./flash_graphene

cd flash_graphene

unzip lynx-factory-2023051600.zip

mv ./lynx-factory-2023051600/* ./

rm -r lynx-factory-2023051600 lynx-factory-2023051600.zip

mkdir image

mv image-lynx-2023051600.zip image/

cd image

unzip image-lynx-2023051600.zip

rm image-lynx-2023051600.zip init_boot.img vbmeta.img vendor_boot.img

cp ../../extracted/* ./

zip -r patched_image.zip .

mv patched_image.zip ../

cd ..

rm -r image 

mv patched_image.zip image-lynx-2023051600.zip

rm avb_pkmd.bin

cp ../stock_graphene_keys/avb_pkmd.bin ./

fastboot flashing unlock

fastboot getvar current-slot

./flash-all.sh

fastboot flashing lock

```













