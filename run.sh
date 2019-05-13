#!/usr/bin/env bash

# You need to specify some environment variables for this to work
# Name - Description
# AWS_ACCESS_KEY_ID - AWS access key
# AWS_SECRET_ACCESS_KEY - AWS secret access key
# AWS_DEFAULT_REGION - OPTIONAL default region for AWS commands if not specified will be used North Virginia
# KEYSTORE - Path to keystore
# STOREALIAS - Alias of the keystore
# STOREPASS - Password of the keystore
# GPLAYKEY - Path to the P12 Key for the access to upload your APK

# First you need to go to the path of the source
cd ./source

# Deployment notification example
aws lambda invoke --function-name Deployment-notifier --log-type Tail --payload "{ \"success\":\"working\" }" outputfile.txt

# A run example, this files upload 

# PreBuild Clean space
bash -c 'WORKING_DIR="./app/build"; if [ -d "$WORKING_DIR" ]; then rm -Rf $WORKING_DIR; fi'

# Build
./gradlew clean build

./gradlew assembleRelease --stacktrace

# Signing of the APK
jarsigner -verbose -sigalg SHA1withRSA -digestalg SHA1 -keystore $KEYSTORE -storepass "$STOREPASS" ./app/build/outputs/apk/release/app-release-unsigned.apk $STOREALIAS

# ZipAlign of the APK
zipalign -f -v 4 ./app/build/outputs/apk/release/app-release-unsigned.apk ./app/build/outputs/apk/release/app-release.apk

python basic_upload_apks_service_account.py nextline.com.nextline_android ./app/build/outputs/apk/release/app-release.apk $GPLAYKEY

# Deployment notification
aws lambda invoke --function-name Deployment-notifier --log-type Tail --payload "{ \"success\":\"succeded\" }" outputfile.txt
