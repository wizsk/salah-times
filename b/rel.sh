#!/usr/bin/env bash

# Check if flutter exists
if ! command -v flutter &>/dev/null; then
    echo "Error: flutter not found in PATH" >&2
    exit 1
fi

# Get flutter version
FLUTTER_VERSION=$(flutter --version 2>/dev/null | awk 'NR==1 {print $2}')

# if [[ "$FLUTTER_VERSION" != "$REQUIRED_FLUTTER_VERSION" ]]; then
#     echo "Error: required Flutter $REQUIRED_FLUTTER_VERSION but found Flutter $FLUTTER_VERSION" >&2
#     exit 1
# fi

echo "Flutter $FLUTTER_VERSION found"

source ./b/common.sh
source ./b/confirm.sh "$@"

version=$ver

echo "Version: $version"

set -x

export SOURCE_DATE_EPOCH=$(git log -1 --format=%ct)

# 1
flutter build apk \
    --release \
    --split-per-abi \
    --dart-define="APP_VERSION=$version" \
    --dart-define=GIT_COMMIT="$gc"
    # --target-platform="android-arm" \

cp build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk \
   "$bd/$n-v$version-armeabi-v7a.apk"


cp build/app/outputs/flutter-apk/app-arm64-v8a-release.apk \
   "$bd/$n-v$version-arm64-v8a.apk"

cp build/app/outputs/flutter-apk/app-x86_64-release.apk \
   "$bd/$n-v$version-x86_64.apk"

flutter build apk --release \
  --dart-define=APP_VERSION="$ver" \
  --dart-define=GIT_COMMIT="$gc"

cp 'build/app/outputs/flutter-apk/app-release.apk' \
    "$bd/$n-v$version-universal.apk"

echo "Done: APKs copied"
