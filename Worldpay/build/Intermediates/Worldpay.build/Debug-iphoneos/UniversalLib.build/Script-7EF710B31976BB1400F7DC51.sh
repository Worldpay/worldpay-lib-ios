#!/bin/sh
# define output folder environment variable
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal

# Step 1. Build Device and Simulator versions
xcodebuild -target Worldpay ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
xcodebuild -target Worldpay -configuration ${CONFIGURATION} -sdk iphonesimulator -arch i386 BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"

rm -rf "${UNIVERSAL_OUTPUTFOLDER}"

# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"

# Step 2. Create universal binary file using lipo
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${PROJECT_NAME}.a"

# Last touch. copy the header files. Just for convenience
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include/Worldpay" "${UNIVERSAL_OUTPUTFOLDER}/"

rm -rf "./output"

mkdir -p "./output/Worldpay/Include"

cp "${UNIVERSAL_OUTPUTFOLDER}/libWorldpay.a" "./output/Worldpay"
cp -R ${UNIVERSAL_OUTPUTFOLDER}/Worldpay/ "./output/Worldpay/Include"


