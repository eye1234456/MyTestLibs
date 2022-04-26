参考：  
[统计Shell脚本执行时间](https://www.cnblogs.com/hencins/p/12273259.html)  
[xcodebuild命令简单使用](https://www.jianshu.com/p/88d9f2e57004)  
[一键打包完整Shell脚本xcodebuild archive](https://www.jianshu.com/p/36d2c6d65aa7)  
[How to create XCFramework?](https://medium.com/@er.mayursharma14/how-to-create-xcframework-855817f854cf)  
[找出 XCode 所有内置的环境变量 - SourceKim’s Blog
](https://www.uiimage.com/find-xcode-env-vars/)  
[Mac shell 输出日志到文件](https://blog.ihaiu.com/shell_%E8%BE%93%E5%87%BA%E6%97%A5%E5%BF%97%E5%88%B0%E6%96%87%E4%BB%B6/)  
[XCode执行脚本的三种方式](https://juejin.cn/post/6936365579070603301)  

设置可执行权限：`chmod +x xxx.sh`  
完整demo：https://github.com/eye1234456/MyTestLibs.git  

----

###一、使用archive的方式导出xcframework
完整参考例子：https://github.com/eye1234456/MyTestLibs/blob/main/HelloSDK/xcframework_archive_auto.sh  
  
```
#!/bin/bash
# set framework folder name
# 工程名称(Project的名字)
PROJECT_NAME="HelloSDK"
# scheme名称
# SCHEME_NAME="HelloSDK"
SCHEME_NAME="AAASDK"
Configuration="Debug"
# 项目所在的文件
PROJECT_DIR=`pwd`


XCWORKSPACE="${PROJECT_NAME}.xcworkspace"
FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_${SCHEME_NAME}_XCFramework"
TEMP_FRAMEWORK_DIR="${PROJECT_DIR}/${FRAMEWORK_FOLDER_NAME}"
# set framework name or read it from project by this variable

#xcframework path
# 生成的xcframework
EXPORT_FOLDER_PATH="${HOME}/Desktop/${FRAMEWORK_FOLDER_NAME}"
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
rm -rf "${EXPORT_FOLDER_PATH}"
echo "Deleted ${FRAMEWORK_FOLDER_NAME}"
mkdir "${FRAMEWORK_FOLDER_NAME}"
echo "Created ${FRAMEWORK_FOLDER_NAME}"
echo "Archiving ${SCHEME_NAME}"

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

```  
-----  
###二、在xcode里创建一个专门用于生成xcframework的target  
>这种方式可以使用build模拟器的方式就生成xcframework，主要使用在直接使用shell命令进行archive或build会失败，但是在xcode里能build成功的场景，优势是配置好后全程在xcode里操作，劣势是操作步骤比较多，需要三次点击build  

  

1、创建一个的target,`Other`->`Aggregate`，专门用于build，并在新target的`Build Phases`里新增一个`Run Script`，内容如下：  

```
#!/bin/bash
# set framework folder name
# 工程名称(Project的名字)
PROJECT_NAME="XXX"
# scheme名称
SCHEME_NAME="XXX"
Configuration="Debug"
# 编译文件的位置
Products_Path="${SYMROOT}"

FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_${SCHEME_NAME}_XCFramework"
# set framework name or read it from project by this variable

#xcframework path
# 生成的xcframework
EXPORT_FOLDER_PATH="${HOME}/Desktop/${FRAMEWORK_FOLDER_NAME}"
# 生成xcframework的路劲
EXPORT_XCFRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.xcframework"
# 生成真机、模拟器二和一的路劲
EXPORT_MIX_FRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.framework"
# set path for iOS simulator archive
# 删除之前生成的xcframework的文件夹
rm -rf "${EXPORT_FOLDER_PATH}"
echo "Deleted ${FRAMEWORK_FOLDER_NAME}"
mkdir "${FRAMEWORK_FOLDER_NAME}"
echo "Created ${FRAMEWORK_FOLDER_NAME}"

echo '==================start================'
total_startTime_s=`date +%s`


#Creating XCFramework
# 创建的模拟器库的地址
SIMULATOR_Framework_PATH="${Products_Path}/${Configuration}-iphonesimulator/${SCHEME_NAME}.framework"
# 创建的真机的库的地址
IPHONE_Framework_PATH="${Products_Path}/${Configuration}-iphoneos/${SCHEME_NAME}.framework"


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
```
2、对要导出的scheme的真机版本进行build  
3、对要导出的scheme的模拟器版本进行build  
4、对专门用于导出export的scheme进行build  

-----  
###三、使用build的方式导出xcframework  

```
#!/bin/bash
# set framework folder name
# 工程名称(Project的名字)
PROJECT_NAME="woxiu"
# scheme名称
SCHEME_NAME="WXSDK"
# 模式
Configuration="Debug"
Configuration="Release"
pwdPath=`pwd`


XCWORKSPACE="${PROJECT_NAME}.xcworkspace"
FRAMEWORK_FOLDER_NAME="${PROJECT_NAME}_${SCHEME_NAME}_XCFramework"
# 编译文件的位置
TEMP_Products_Path="${pwdPath}/${FRAMEWORK_FOLDER_NAME}"
# set framework name or read it from project by this variable

#xcframework path
# 生成的xcframework
EXPORT_FOLDER_PATH="${HOME}/Desktop/${FRAMEWORK_FOLDER_NAME}"
EXPORT_FRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.xcframework"
# 删除之前生成的buidle的文件夹
rm -rf "${TEMP_Products_Path}"
echo "Deleted ${TEMP_Products_Path}"
mkdir "${TEMP_Products_Path}"
# 删除之前生成的xcframework的文件夹
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


#echo '开始编译Pods'
#build_startTime_s=`date +%s`
#xcodebuild -project Pods/Pods.xcodeproj build
#build_endTime_s=`date +%s`
#echo '结束编译Pods'
#echo "Pod编译时长：$[$build_endTime_s - $build_startTime_s]"

xcodebuild build \
-workspace ${XCWORKSPACE} \
-scheme ${SCHEME_NAME} \
-configuration ${Configuration} \
-sdk iphonesimulator \
SYMROOT=${TEMP_Products_Path}

xcodebuild build \
-workspace ${XCWORKSPACE} \
-scheme ${SCHEME_NAME} \
-configuration ${Configuration} \
-sdk iphoneos \
SYMROOT=${TEMP_Products_Path}

#Creating XCFramework
# 创建的模拟器库的地址
SIMULATOR_Framework_PATH="${TEMP_Products_Path}/${Configuration}-iphonesimulator/${SCHEME_NAME}.framework"
# 创建的真机的库的地址
IPHONE_Framework_PATH="${TEMP_Products_Path}/${Configuration}-iphoneos/${SCHEME_NAME}.framework"

# 生成xcframework
xcodebuild -create-xcframework \
-framework ${SIMULATOR_Framework_PATH} \
-framework ${IPHONE_Framework_PATH} \
-output "${EXPORT_FRAMEWORK_PATH}"


rm -rf ${TEMP_Products_Path}
rmdir ${TEMP_Products_Path}
total_endTime_s=`date +%s`
echo '==================end================'
echo "总共时长：$[$total_endTime_s - $total_startTime_s]"

open "${EXPORT_FOLDER_PATH}"

```  
----  
###四、使用手动build，然后自动生成xcframework的方式  
1、在对应target的`Build Phases`里增加打印编译地址的`Run Script`

```  
# 将编译生成物的地址，写到项目文件地址上  
echo "${SYMROOT}" > "${SRCROOT}/SYMROOT_log.txt"
``` 
2、手动在xcode里对模拟器+真机执行build  
3、使用编译物生成xcframework 
 
```
#!/bin/bash
# set framework folder name
# scheme名称
SCHEME_NAME="xxx"
# 模式
Configuration="Debug"
# 编译文件的位置
Products_Path=`cat SYMROOT_log.txt`


FRAMEWORK_FOLDER_NAME="${SCHEME_NAME}_XCFramework"
# set framework name or read it from project by this variable

#xcframework path
# 生成的xcframework
EXPORT_FOLDER_PATH="${HOME}/Desktop/${FRAMEWORK_FOLDER_NAME}"
EXPORT_FRAMEWORK_PATH="${EXPORT_FOLDER_PATH}/${SCHEME_NAME}.xcframework"
# 删除之前生成的xcframework的文件夹
rm -rf "${EXPORT_FOLDER_PATH}"
echo '==================start================'
total_startTime_s=`date +%s`

#Creating XCFramework
# 创建的模拟器库的地址
SIMULATOR_Framework_PATH="${Products_Path}/${Configuration}-iphonesimulator/${SCHEME_NAME}.framework"
# 创建的真机的库的地址
IPHONE_Framework_PATH="${Products_Path}/${Configuration}-iphoneos/${SCHEME_NAME}.framework"

# 生成xcframework
xcodebuild -create-xcframework \
-framework ${SIMULATOR_Framework_PATH} \
-framework ${IPHONE_Framework_PATH} \
-output "${EXPORT_FRAMEWORK_PATH}"

total_endTime_s=`date +%s`
echo '==================end================'
echo "总共时长：$[$total_endTime_s - $total_startTime_s]"

open "${EXPORT_FOLDER_PATH}"

```  

