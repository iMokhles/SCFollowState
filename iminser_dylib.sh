
BASEDIR=$(dirname "$0")
cd "$BASEDIR"

IPA_FILE="$BASEDIR/files/snapchat.ipa"

DYLIB_NAME="SCFollowState.dylib"
DYLIB_PATH="@executable_path/$DYLIB_NAME"

OUTPUT_DIR="$BASEDIR/files_out"

logit() {

    echo "FastCodesign: [`date`] - ${*}"

}

WORKING_PATH="$OUTPUT_DIR/WorkingPath"
EXTRACTED_IPA_PATH="$WORKING_PATH/EXTRACTED_IPA"
TEMP_PATH="$OUTPUT_DIR/temp"

CURRENT_TIME_EPOCH=$(date +"%s")

createWantedDirs() {

logit "Create Directories"

rm -Rf "$WORKING_PATH"

if [ -d "$TEMP_PATH" ];then
    logit "Removing Dir: $TEMP_PATH"
    rm -Rf "$TEMP_PATH"
fi
    logit "Creating Dir: $TEMP_PATH"
    mkdir -p "$TEMP_PATH" || true

if [ -d "$EXTRACTED_IPA_PATH" ];then
    logit "Removing Dir: $EXTRACTED_IPA_PATH"
    rm -Rf "$EXTRACTED_IPA_PATH"
fi
    logit "Creating Dir: $EXTRACTED_IPA_PATH"
    mkdir -p "$EXTRACTED_IPA_PATH" || true

}

# $1 password
# $2 path
# usage = unlockKeychain password path.keychain

unlockKeychain() {
    security unlock-keychain -p "$1" "$2"
}

# $1 = ipa file
# $2 = extracted ipa path
unzipIPAFile() {
    logit "Unzipping IPA File: $1"
    logit "Unzipping Output Dir: $2"
    unzip -oqq "$1" -d "$2"
}

setupVariables() {

    AppPath=$(set -- "$EXTRACTED_IPA_PATH/Payload/"*.app; echo "$1")

    val=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName"  "$AppPath/Info.plist" 2>/dev/null)
    exitCode=$?

if (( exitCode == 0 )); then
    HOOKED_APP_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleDisplayName"  "$AppPath/Info.plist")

else
    /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string" "$AppPath/Info.plist"
    HOOKED_APP_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleName"  "$AppPath/Info.plist")
fi

    HOOKED_APP_BUNDLE_NAME=$(/usr/libexec/PlistBuddy -c "Print CFBundleName"  "$AppPath/Info.plist")
    HOOKED_EXECUTABLE=$(/usr/libexec/PlistBuddy -c "Print CFBundleExecutable"  "$AppPath/Info.plist")
    HOOKED_EXE_PATH="$AppPath/$HOOKED_EXECUTABLE"

    filename=$(basename "$HOOKED_EXE_PATH")
    extension="${filename##*.}"
    filename="${filename%.*}"

    HOOKED_APP_BUNDLE_NAME="$HOOKED_APP_BUNDLE_NAME"
    HOOKED_APP_BUNDLE_NAME=${HOOKED_APP_BUNDLE_NAME// /_}

    HOOKED_APP_NAME="$HOOKED_APP_NAME"
    HOOKED_APP_NAME=${HOOKED_APP_NAME// /_}


}

makeBinaryExecutable() {
    logit "Make App Binary Executable"
    chmod +x "$1"
}


# $1 = dylib
# $2 = app executable
addNewEntries() {

    AppPath=$(set -- "$EXTRACTED_IPA_PATH/Payload/"*.app; echo "$1")

    $BASEDIR/optool install -c load -p "$1" -t "$2"

    cp "$BASEDIR/$DYLIB_NAME" "$AppPath"
}

# $1 = app name
archiveAppAgainToIPA() {

    logit "archiveAppAgainToIPA: $1"
    cd "$EXTRACTED_IPA_PATH"
    zip -qry "$1.ipa" Payload/ >/dev/null 2>&1
    cd ../../
    cp "$EXTRACTED_IPA_PATH/$1.ipa" "$OUTPUT_DIR/"

    logit "done"
}

    createWantedDirs

    unzipIPAFile "$IPA_FILE" "$EXTRACTED_IPA_PATH"

    setupVariables

    makeBinaryExecutable "$HOOKED_EXE_PATH"

    addNewEntries "$DYLIB_PATH" "$HOOKED_EXE_PATH"

    archiveAppAgainToIPA "$HOOKED_APP_NAME"

    rm -rf "$WORKING_PATH" || true
    rm -rf "$TEMP_PATH" || true
