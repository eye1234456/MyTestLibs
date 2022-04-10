FRAMEWORK_NAME='HelloSDK'
CURRENTPATH=`pwd`
WORK_DIR=${CURRENTPATH}'/Build'
echo '=============='
echo $CURRENTPATH
echo $WORK_DIR
echo '=============='
#release环境下，generic ios device编译出的framework。这个framework只能供真机运行。
DEVICE_DIR=${WORK_DIR}/'Release-iphoneos'/${FRAMEWORK_NAME}'.framework'
#release环境下，simulator编译出的framework。这个framework只能供模拟器运行。
SIMULATOR_DIR=${WORK_DIR}/'Release-iphonesimulator'/${FRAMEWORK_NAME}'.framework'
#framework的输出目录
SRCROOT=$CURRENTPATH
DSTROOT=$CURRENTPATH
OUTPUT_DIR=${SRCROOT}/'Products'/${FRAMEWORK_NAME}'.framework'

##xcodebuild打包
# xcodebuild -target ${FRAMEWORK_NAME}
# ONLY_ACTIVE_ARCH=NO
# -configuration 'Release'
# -sdk iphoneos clean build

# xcodebuild -target ${FRAMEWORK_NAME} 
# ONLY_ACTIVE_ARCH=NO 
# -configuration 'Release' 
# -sdk iphonesimulator clean build

# xcodebuild clean build

# xcodebuild -workspace ${FRAMEWORK_NAME}.xcworkspace \
# -scheme ${FRAMEWORK_NAME}  \
# SYMROOT=$SRCROOT \
# DSTROOT=$SRCROOT \
# -configuration 'Release'  \
# -sdk iphoneos
# -sdk iphoneos clean build

# xcodebuild -workspace ${FRAMEWORK_NAME}.xcworkspace \
# -scheme ${FRAMEWORK_NAME}  \
# DSTROOT=$SRCROOT \
# -configuration 'Release'  \
# -sdk iphonesimulator clean build
# -sdk iphonesimulator

xcodebuild archive \
-project ${FRAMEWORK_NAME}.xcodeproj \ 
# -workspace ${FRAMEWORK_NAME}.xcworkspace \
-scheme $FRAMEWORK_NAME \
-configuration 'Release' \ 
-destination 'generic/platform=iOS Simulator' \
-archivePath '../archives/'+$FRAMEWORK_NAME+'.framework-iphonesimulator.xcarchive' \ 
SKIP_INSTALL=NO

#如果输出目录存在，即移除该目录，再创建该目录。目的是为了清空输出目录。
# if [ -d ${OUTPUT_DIR} ]; then
# rm -rf ${OUTPUT_DIR}
# fi
# mkdir -p ${OUTPUT_DIR}

#复制release-simulator下的framework到输出目录
# cp -r ${DEVICE_DIR}/ ${OUTPUT_DIR}/

#lipo命令合并两种framework，将SVProgressHUD.framework/SVProgressHUD，覆盖输出到输出目录。
# lipo -create ${DEVICE_DIR}/${FRAMEWORK_NAME} ${SIMULATOR_DIR}/${FRAMEWORK_NAME} -output ${OUTPUT_DIR}/${FRAMEWORK_NAME}

# rm -r ${WORK_DIR}
# #打开输出目录
# open ${OUTPUT_DIR}