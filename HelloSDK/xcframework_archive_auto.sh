#!/bin/bash
# set framework folder name
# 工程名称(Project的名字)
PROJECT_NAME="HelloSDK"
# scheme名称
# SCHEME_NAME="HelloSDK"
SCHEME_NAME="AAASDK"
# Configuration="Debug"
Configuration="Release"
# 项目所在的文件
PROJECT_DIR=`pwd`


XCWORKSPACE="${PROJECT_NAME}.xcworkspace"
FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_${SCHEME_NAME}_XCFramework"
TEMP_FRAMEWORK_DIR="${PROJECT_DIR}/${FRAMEWORK_FOLDER_NAME}"
# set framework name or read it from project by this variable

#xcframework path
# 生成的xcframework
EXPORT_FOLDER_PATH="${HOME}/Desktop/${FRAMEWORK_FOLDER_NAME}/${Configuration}"
# 生成xcframework的路劲
EXPORT_XCFRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.xcframework"
# 生成真机、模拟器二和一的路劲
EXPORT_MIX_FRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.framework"
# set path for iOS simulator archive
# 生成的模拟器的库的文件
SIMULATOR_ARCHIVE_PATH="${TEMP_FRAMEWORK_DIR}/simulator.xcarchive"
# set path for iOS device archive
# 生成的真机的库的文件
IOS_DEVICE_ARCHIVE_PATH="${TEMP_FRAMEWORK_DIR}/iOS.xcarchive"
# 删除之前生成的xcframework的文件夹
# 创建临时文件
rm -rf "${TEMP_FRAMEWORK_DIR}"
mkdir "${TEMP_FRAMEWORK_DIR}"
# 创建导出文件地址
rm -rf "${EXPORT_FOLDER_PATH}"
mkdir "${EXPORT_FOLDER_PATH}"


echo '==================start================'
total_startTime_s=`date +%s`

#更新pod配置

echo '开始install Pod'
pod_startTime_s=`date +%s`
pod install
pod_endTime_s=`date +%s`
echo '结束install Pod'
echo "install pod 时长：$[$pod_endTime_s - $pod_startTime_s]"

echo '开始模拟器archive'
archive_simulator_startTime_s=`date +%s`
    
# 创建simulator的framework
xcodebuild archive \
-workspace ${XCWORKSPACE} \
-scheme ${SCHEME_NAME} \
-configuration ${Configuration} \
-destination="iOS Simulator" \
-archivePath "${SIMULATOR_ARCHIVE_PATH}" \
-sdk iphonesimulator clean build \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

archive_simulator_endTime_s=`date +%s`
echo "模拟器archive时长：$[$archive_simulator_endTime_s - $archive_simulator_startTime_s]"
echo '结束模拟器archive'

echo '开始真机archive'
archive_iphone_startTime_s=`date +%s`
# 创建iPhone的framework
xcodebuild archive \
-workspace ${XCWORKSPACE} \
-scheme ${SCHEME_NAME} \
-configuration ${Configuration} \
-destination="iOS" \
-archivePath "${IOS_DEVICE_ARCHIVE_PATH}" \
-sdk iphoneos clean build \
SKIP_INSTALL=NO \
BUILD_LIBRARIES_FOR_DISTRIBUTION=YES

archive_iphone_endTime_s=`date +%s`
echo "真机archive时长：$[$archive_iphone_endTime_s - $archive_iphone_startTime_s]"
echo '结束真机archive'

#Creating XCFramework
# 创建的模拟器库的地址
SIMULATOR_Framework_PATH="${SIMULATOR_ARCHIVE_PATH}/Products/Library/Frameworks/${SCHEME_NAME}.framework"
# 创建的真机的库的地址
IPHONE_Framework_PATH="${IOS_DEVICE_ARCHIVE_PATH}/Products/Library/Frameworks/${SCHEME_NAME}.framework"


# 生成xcframework
echo '开始合成xcframework'
create_xcframework_startTime_s=`date +%s`

xcodebuild -create-xcframework \
-framework ${SIMULATOR_Framework_PATH} \
-framework ${IPHONE_Framework_PATH} \
-output "${EXPORT_XCFRAMEWORK_PATH}"

create_xcframework_endTime_s=`date +%s`
echo "合成xcframework时长：$[$create_xcframework_endTime_s - $create_xcframework_startTime_s]"
echo '结束合成xcframework'

# 生成真机模拟器二合一framework
echo '开始合成framework'
create_mix_framework_startTime_s=`date +%s`

# 先复制一个真机的版本到目标
cp -rf ${IPHONE_Framework_PATH} ${EXPORT_MIX_FRAMEWORK_PATH}
# 将真机和模拟器合并成一个
lipo -create \
"${SIMULATOR_Framework_PATH}/${SCHEME_NAME}" \
"${IPHONE_Framework_PATH}/${SCHEME_NAME}" \
-output "${EXPORT_MIX_FRAMEWORK_PATH}/${SCHEME_NAME}"

create_mix_framework_endTime_s=`date +%s`
echo "合成framework时长：$[$create_mix_framework_endTime_s - $create_mix_framework_startTime_s]"
echo '结束合成framework'

rm -rf "${TEMP_FRAMEWORK_DIR}"
total_endTime_s=`date +%s`
echo '==================end================'
echo "总共时长：$[$total_endTime_s - $total_startTime_s]"

open "${EXPORT_FOLDER_PATH}"