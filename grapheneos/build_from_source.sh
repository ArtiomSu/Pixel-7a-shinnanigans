# Links
[Build instructions](https://grapheneos.org/build)
[Guide to root and lock bootloader](https://forum.xda-developers.com/t/guide-to-lock-bootloader-while-using-rooted-grapheneos-magisk-root.4510295/)

# Building The OS
## dependancies
I chose `community/signify` but might need `python-signify`

## branches
### Development branch (we won't use this one)
```bash
mkdir grapheneos-13-lynx
repo init -u https://github.com/GrapheneOS/platform_manifest.git -b 13-lynx --depth=1
repo sync -c -j16

```

### Pixel 7a stable release
Its using the tags/branches from [here](https://github.com/GrapheneOS/platform_manifest)
Pixel 7a tags aren't in here yet. So we will use the development branch lol.
```bash
mkdir grapheneos-TQ2B.230505.005.A1.2023051600
repo init -u https://github.com/GrapheneOS/platform_manifest.git -b refs/tags/TQ2B.230505.005.A1.2023051600 --depth=1

curl https://grapheneos.org/allowed_signers > ~/.ssh/grapheneos_allowed_signers
cd .repo/manifests
git config gpg.ssh.allowedSignersFile ~/.ssh/grapheneos_allowed_signers
git verify-tag $(git describe)
cd ../..

repo sync -c -j16
```

## Vendor Files
```bash
cd grapheneos-13-lynx
yarn install --cwd vendor/adevtool/
```
change to bash shell before sourcing env.

```
source script/envsetup.sh
m aapt2
```

get the build id from here https://developers.google.com/android/ota. My one seems to be `13.0.0 (TQ2B.230505.005.A1, May 2023)`
Copy and paste these commands into the terminal
for the chown part I had to do $(logname):users cause I don't have a group with the same name as my user name
```
DEVICE=lynx
BUILD_ID=TQ2B.230505.005.A1
vendor/adevtool/bin/run download vendor/adevtool/dl/ -d $DEVICE -b $BUILD_ID -t factory ota
sudo vendor/adevtool/bin/run generate-all vendor/adevtool/config/$DEVICE.yml -c vendor/state/$DEVICE.json -s vendor/adevtool/dl/$DEVICE-${BUILD_ID,,}-*.zip
sudo chown -R $(logname):users vendor/{google_devices,adevtool}
vendor/adevtool/bin/run ota-firmware vendor/adevtool/config/$DEVICE.yml -f vendor/adevtool/dl/$DEVICE-ota-${BUILD_ID,,}-*.zip
```

## Acutally building

During build it failed because of a new ncurses so install this package here `ncurses5-compat-libs`

Again use bash for this
```
source script/envsetup.sh
export OFFICIAL_BUILD=false
choosecombo release lynx user
export OFFICIAL_BUILD=false
```

Try this here if the build fails
```
export CPU_SSE42=false
```

```
rm -r out
m vendorbootimage vendorkernelbootimage target-files-package

```

## Generating release keys

Make sure the password for all of these is the same otherwise the scripts won't work.

if you used decrypt_keys.sh you technically have no password now lol. so just press enter when using the encrypt_keys.sh


```
mkdir -p keys/lynx
cd keys/lynx
CN=GrapheneOS
../../development/tools/make_key releasekey "/CN=$CN/"
../../development/tools/make_key platform "/CN=$CN/"
../../development/tools/make_key shared "/CN=$CN/"
../../development/tools/make_key media "/CN=$CN/"
../../development/tools/make_key networkstack "/CN=$CN/"
../../development/tools/make_key sdk_sandbox "/CN=$CN/"
../../development/tools/make_key bluetooth "/CN=$CN/"
openssl genrsa 4096 | openssl pkcs8 -topk8 -scrypt -out avb.pem
../../external/avb/avbtool extract_public_key --key avb.pem --output avb_pkmd.bin
cd ../..

signify -G -p keys/lynx/factory.pub -s keys/lynx/factory.sec

script/encrypt_keys.sh keys/lynx

m otatools-package

script/release.sh lynx

```

Now best to build the kernel and copy it over. only takes like 10 minutes anyway

# Applying the magisk boot

while in the main os folder. we can decrypt the keys we made

```
./script/decrypt_keys.sh keys/lynx

cd keys/lynx

openssl rsa -outform der -in avb.pem -out avb.key

cp avb.key ota.key

../../external/avb/avbtool extract_public_key --key avb.key --output avb_pkmd.bin

openssl req -new -x509 -sha256 -key ota.key -out ota.crt -days 10000 -subj "/CN=$CN/"




```

```
git clone --recursive https://github.com/chenxiaolong/avbroot.git

cd avbroot

git submodule update --init --recursive

# we also need to get the fucking --magisk-preinit-device name so lets do this now

python avbroot.py extract --input /build/Pixel_7a/graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/out/release-lynx-2023051700/lynx-ota_update-2023051700.zip --directory . --boot-only


python avbroot.py patch --input /build/Pixel_7a/graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/out/release-lynx-2023051700/lynx-ota_update-2023051700.zip --privkey-avb /build/Pixel_7a/graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/keys/lynx/avb.key --privkey-ota /build/Pixel_7a/graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/keys/lynx/ota.key --cert-ota /build/Pixel_7a/graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/keys/lynx/ota.crt --magisk /build/Pixel_7a/rooting/Magisk-v26.1.apk --magisk-preinit-device persist

cd /build/Pixel_7a/graphene_os

mv grapheneos-TQ2B.230505.005.A1.2023051600/out/release-lynx-2023051700/lynx-ota_update-2023051700.zip.patched ./complete_builds/

python ./avbroot/avbroot.py extract --input ./complete_builds/lynx-ota_update-2023051700.zip.patched --directory ./complete_builds/extracted/patched

cp grapheneos-TQ2B.230505.005.A1.2023051600/out/release-lynx-2023051700/lynx-factory-2023051700.zip ./complete_builds/

cd ./complete_builds

mkdir extracted/factory

mv lynx-factory-2023051700.zip ./extracted/factory/

cd extracted/factory

unzip lynx-factory-2023051700.zip

cd lynx-factory-2023051700

mkdir extracted_image

cp image-lynx-2023051700.zip ./extracted_image/

cd extracted_image

unzip image-lynx-2023051700.zip

rm image-lynx-2023051700.zip init_boot.img vbmeta.img vendor_boot.img

cp ../../../patched/* ./

zip -r patched_image.zip .

mv patched_image.zip ../

rm -rf extracted_image image-lynx-2023051700.zip avb_pkmd.bin

mv patched_image.zip image-lynx-2023051700.zip

cp ../../../../grapheneos-TQ2B.230505.005.A1.2023051600/keys/lynx/avb_pkmd.bin ./

mkdir /build/Pixel_7a/graphene_os/complete_builds/flash

cd .. && mv lynx-factory-2023051700 ../../flash/ && cd ../../flash/lynx-factory-2023051700

```

now can flash the whole fuking thing with

```
adb reboot bootloader

./flash-all.sh

fastboot flashing lock
```



# Building the Kernel


```
mkdir -p android/kernel/lynx
cd android/kernel/lynx
repo init -u https://github.com/GrapheneOS/kernel_manifest-lynx.git -b 13-lynx --depth=1
repo sync -c -j16
```

compiling it
```
LTO=full BUILD_AOSP_KERNEL=1 ./build_lynx.sh
```

Lastly Replace the files in the OS source tree at device/google/lynx-kernel/ with your build in out/mixed/dist/.

cp ./out/mixed/dist/* ../../../grapheneos-TQ2B.230505.005.A1.2023051600/device/google/lynx-kernel/

# Building the browser and webview

I won't build this now, cause the feking patches don't apply. fuck sake.

## setup
need to setup some stuff from [here](https://chromium.googlesource.com/chromium/src/+/refs/heads/main/docs/android_build_instructions.md)
```
mkdir -p browser/build_tools
cd browser/build_tools
git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git --depth=1


```
add this to the .bashrc path 
`export PATH="$PATH:/build/Pixel_7a/graphene_os/browser/build_tools/depot_tools"`


## build

```
mkdir -p browser
cd browser
#git clone https://github.com/GrapheneOS/Vanadium.git --depth 1
git clone https://github.com/GrapheneOS/Vanadium.git
cd Vanadium
git checkout 113.0.5672.132.0

# if initial build do this
keytool -genkey -v -keystore vanadium.keystore -storetype pkcs12 -alias vanadium -keyalg RSA -keysize 4096 -sigalg SHA512withRSA -validity 10000 -dname "cn=GrapheneOS"

fetch --nohooks --no-history android

cd src
git am --whitespace=nowarn --keep-non-patch ../patches/*.patch
gclient sync -D --with_branch_heads --with_tags --jobs 32


```
gn args out/Default

copy from
cat ../args.gn

edit trichrome_certdigest to be the output of
keytool -export-cert -alias vanadium -keystore vanadium.keystore | sha256sum

#### build the browser
```
chrt -b 0 ninja -C out/Default/ trichrome_webview_64_32_apk trichrome_chrome_64_32_apk trichrome_library_64_32_apk
../generate-release.sh out
```

cp ./out/Default/apks/release/*.apk ../graphene_os/grapheneos-TQ2B.230505.005.A1.2023051600/external/vanadium/prebuilt/arm64/





















