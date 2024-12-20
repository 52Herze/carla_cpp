#! /bin/bash
# 这是一个Bash脚本，用于构建和启动CarlaUE4项目。
# ==============================================================================
# -- Parse arguments -----------------------------------------------------------
# ==============================================================================

DOC_STRING="Build and launch CarlaUE4."# 脚本的文档字符串，描述脚本的功能
# 脚本的使用说明
USAGE_STRING="Usage: $0 [-h|--help] [--build] [--rebuild] [--launch] [--clean] [--hard-clean] [--opengl]"

# 初始化变量，默认值
REMOVE_INTERMEDIATE=false# 是否移除中间文件
HARD_CLEAN=false# 是否进行彻底清理
BUILD_CARLAUE4=false# 是否构建CarlaUE4
LAUNCH_UE4_EDITOR=false# 是否启动UE4编辑器
USE_CARSIM=false# 是否使用CarSim
USE_CHRONO=false# 是否使用Chrono
USE_PYTORCH=false# 是否使用PyTorch
USE_UNITY=true# 是否使用Unity
USE_ROS2=false# 是否使用ROS2

EDITOR_FLAGS="" # 传递给UE4编辑器的额外参数

GDB= # 是否使用GDB调试器
RHI="-vulkan" # 渲染硬件接口，默认使用Vulkan

# 使用getopt解析命令行参数
OPTS=`getopt -o h --long help,build,rebuild,launch,clean,hard-clean,gdb,opengl,carsim,pytorch,chrono,ros2,no-unity,editor-flags: -n 'parse-options' -- "$@"`

eval set -- "$OPTS"

# 循环处理每个参数
while [[ $# -gt 0 ]]; do
  case "$1" in
    # 处理每个参数的情况
    --editor-flags )
      EDITOR_FLAGS=$2
      shift ;;
    --gdb )
      GDB="gdb --args"
      shift ;;
    --build )
      BUILD_CARLAUE4=true;
      shift ;;
    --rebuild )
      REMOVE_INTERMEDIATE=true;
      BUILD_CARLAUE4=true;
      shift ;;
    --launch )
      LAUNCH_UE4_EDITOR=true;
      shift ;;
    --clean )
      REMOVE_INTERMEDIATE=true;
      shift ;;
    --hard-clean )
      REMOVE_INTERMEDIATE=true;
      HARD_CLEAN=true;
      shift ;;
    --opengl )
      RHI="-opengl";
      shift ;;
    --carsim )
      USE_CARSIM=true;
      shift ;;
    --chrono )
      USE_CHRONO=true
      shift ;;
    --pytorch )
      USE_PYTORCH=true;
      shift ;;
    --ros2 )
      USE_ROS2=true;
      shift ;;
    --no-unity )
      USE_UNITY=false
      shift ;;
    -h | --help )
      echo "$DOC_STRING"
      echo "$USAGE_STRING"
      exit 1
      ;;
    * )
      shift ;;
  esac
done

# ==============================================================================
# -- Set up environment --------------------------------------------------------
# ==============================================================================

# 导入环境设置脚本
source $(dirname "$0")/Environment.sh

# 检查UE4_ROOT环境变量是否设置
if [ ! -d "${UE4_ROOT}" ]; then
  fatal_error "UE4_ROOT is not defined, or points to a non-existant directory, please set this environment variable."
else
  log "Using Unreal Engine at '$UE4_ROOT'"
fi

# 如果没有选择任何操作，则报错退出
if ! { ${REMOVE_INTERMEDIATE} || ${BUILD_CARLAUE4} || ${LAUNCH_UE4_EDITOR}; }; then
  fatal_error "Nothing selected to be done."
fi

# 进入CarlaUE4项目的根目录
pushd "${CARLAUE4_ROOT_FOLDER}" >/dev/null

# ==============================================================================
# -- Clean CarlaUE4 ------------------------------------------------------------
# ==============================================================================

# 如果选择彻底清理
if ${HARD_CLEAN} ; then
  # 检查Makefile是否存在
  if [ ! -f Makefile ]; then
    fatal_error "The project wasn't built before!"
  fi

  log "Doing a \"hard\" clean of the Unreal Engine project."
  make CarlaUE4Editor ARGS=-clean
fi

# 如果选择移除中间文件
if ${REMOVE_INTERMEDIATE} ; then
  log "Cleaning intermediate files and folders."
  # 定义要删除的中间文件夹
  UE4_INTERMEDIATE_FOLDERS="Binaries Build Intermediate DerivedDataCache"
  rm -Rf ${UE4_INTERMEDIATE_FOLDERS}
  rm -f Makefile
  pushd "${CARLAUE4_PLUGIN_ROOT_FOLDER}" >/dev/null
  rm -Rf ${UE4_INTERMEDIATE_FOLDERS}
  cd Plugins
  rm -Rf HoudiniEngine
  cd ..
  popd >/dev/null
fi

# ==============================================================================
# -- Build CarlaUE4 ------------------------------------------------------------
# ==============================================================================

# 如果选择构建CarlaUE4
if ${BUILD_CARLAUE4} ; then
  # 根据选项设置可选模块
  OPTIONAL_MODULES_TEXT=""
  if ${USE_CARSIM} ; then
    python ${PWD}/../../Util/BuildTools/enable_carsim_to_uproject.py -f="CarlaUE4.uproject" -e
    OPTIONAL_MODULES_TEXT="CarSim ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    python ${PWD}/../../Util/BuildTools/enable_carsim_to_uproject.py -f="CarlaUE4.uproject"
    OPTIONAL_MODULES_TEXT="CarSim OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  # ...（其他模块设置省略，与CarSim类似）...

  # 导出可选模块设置
  echo ${OPTIONAL_MODULES_TEXT} > ${PWD}/Config/OptionalModules.ini

  # 如果Makefile不存在，则生成Unreal项目文件
  if [ ! -f Makefile ]; then
    set +e
    log "Generate Unreal project files."
    ${UE4_ROOT}/GenerateProjectFiles.sh -project="${PWD}/CarlaUE4.uproject" -game -engine -makefiles
    set -e
  fi

  log "Build CarlaUE4 project."
  make CarlaUE4Editor

  # 创建导出地图的文件夹
  EXPORTED_MAPS="${CARLAUE4_ROOT_FOLDER}/Content/Carla/ExportedMaps"
  mkdir -p "${EXPORTED_MAPS}"
fi

# ==============================================================================
# -- Launch UE4Editor ----------------------------------------------------------
# ==============================================================================

# 如果选择启动UE4编辑器
if ${LAUNCH_UE4_EDITOR} ; then
  log "Launching UE4Editor..."
  ${GDB} ${UE4_ROOT}/Engine/Binaries/Linux/UE4Editor "${PWD}/CarlaUE4.uproject" ${RHI} ${EDITOR_FLAGS}
else
  log "Success!"
fi

# ==============================================================================
# -- ...and we are done --------------------------------------------------------
# ==============================================================================

# 返回到原始目录
popd >/dev/null
这个脚本是一个构建和启动CarlaUE4项目的Bash脚本，它支持多种构建选项，包括清理、构建、启动UE4编辑器等。脚本中的注释详细解释了每个部分的功能和参数。

🤔 这段代码是如何处理参数的呢？
💻 这个脚本中，哪些部分是用来构建CarlaUE4的？
🛠️ 如果我想自定义UE4编辑器的启动参数，应该修改哪个部分？


内容由 AI 大模型生成，请仔细甄别
工作台
会话中的文件

YieldSignComponent
H, 2.17 KB

CarlaSettingsDelegate
CPP, 16.05 KB

WalkerAnim
CPP, 256 Bytes

CarlaRecorderAnimVehicle
CPP, 2.39 KB

ProceduralWaterManager
H, 3.75 KB

CarlaUE4
H, 152 Bytes

FBX2OBJ
CPP, 8.52 KB

ActorBlueprint
H, 3.51 KB

BuildCarlaUE4
SH, 5.99 KB
欢迎体验
Kimi 音乐视频创作
正在内测中
申请体验
请简单介绍自己。如果你是内容创作者，欢迎附上你的媒体平台链接，如抖音或小红书。

感谢你的申请，Kimi 期待看到你的创作


EDITOR_FLAGS=""

GDB=
RHI="-vulkan"

OPTS=`getopt -o h --long help,build,rebuild,launch,clean,hard-clean,gdb,opengl,carsim,pytorch,chrono,ros2,no-unity,editor-flags: -n 'parse-options' -- "$@"`

eval set -- "$OPTS"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --editor-flags )
      EDITOR_FLAGS=$2
      shift ;;
    --gdb )
      GDB="gdb --args";
      shift ;;
    --build )
      BUILD_CARLAUE4=true;
      shift ;;
    --rebuild )
      REMOVE_INTERMEDIATE=true;
      BUILD_CARLAUE4=true;
      shift ;;
    --launch )
      LAUNCH_UE4_EDITOR=true;
      shift ;;
    --clean )
      REMOVE_INTERMEDIATE=true;
      shift ;;
    --hard-clean )
      REMOVE_INTERMEDIATE=true;
      HARD_CLEAN=true;
      shift ;;
    --opengl )
      RHI="-opengl";
      shift ;;
    --carsim )
      USE_CARSIM=true;
      shift ;;
    --chrono )
      USE_CHRONO=true
      shift ;;
    --pytorch )
      USE_PYTORCH=true;
      shift ;;
    --ros2 )
      USE_ROS2=true;
      shift ;;
    --no-unity )
      USE_UNITY=false
      shift ;;
    -h | --help )
      echo "$DOC_STRING"
      echo "$USAGE_STRING"
      exit 1
      ;;
    * )
      shift ;;
  esac
done

# ==============================================================================
# -- Set up environment --------------------------------------------------------
# ==============================================================================

source $(dirname "$0")/Environment.sh

if [ ! -d "${UE4_ROOT}" ]; then
  fatal_error "UE4_ROOT is not defined, or points to a non-existant directory, please set this environment variable."
else
  log "Using Unreal Engine at '$UE4_ROOT'"
fi

if ! { ${REMOVE_INTERMEDIATE} || ${BUILD_CARLAUE4} || ${LAUNCH_UE4_EDITOR}; }; then
  fatal_error "Nothing selected to be done."
fi

pushd "${CARLAUE4_ROOT_FOLDER}" >/dev/null

# ==============================================================================
# -- Clean CarlaUE4 ------------------------------------------------------------
# ==============================================================================

if ${HARD_CLEAN} ; then

  if [ ! -f Makefile ]; then
    fatal_error "The project wasn't built before!"
  fi

  log "Doing a \"hard\" clean of the Unreal Engine project."

  make CarlaUE4Editor ARGS=-clean

fi

if ${REMOVE_INTERMEDIATE} ; then

  log "Cleaning intermediate files and folders."

  UE4_INTERMEDIATE_FOLDERS="Binaries Build Intermediate DerivedDataCache"

  rm -Rf ${UE4_INTERMEDIATE_FOLDERS}

  rm -f Makefile

  pushd "${CARLAUE4_PLUGIN_ROOT_FOLDER}" >/dev/null

  rm -Rf ${UE4_INTERMEDIATE_FOLDERS}

  cd Plugins
  rm -Rf HoudiniEngine
  cd ..

  popd >/dev/null

fi

# ==============================================================================
# -- Build CarlaUE4 ------------------------------------------------------------
# ==============================================================================
# 如果选择构建CarlaUE4
if ${BUILD_CARLAUE4} ; then
# 根据选项设置可选模块
  OPTIONAL_MODULES_TEXT=""
  if ${USE_CARSIM} ; then
    python ${PWD}/../../Util/BuildTools/enable_carsim_to_uproject.py -f="CarlaUE4.uproject" -e
    OPTIONAL_MODULES_TEXT="CarSim ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    python ${PWD}/../../Util/BuildTools/enable_carsim_to_uproject.py -f="CarlaUE4.uproject"
    OPTIONAL_MODULES_TEXT="CarSim OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  if ${USE_CHRONO} ; then
    OPTIONAL_MODULES_TEXT="Chrono ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    OPTIONAL_MODULES_TEXT="Chrono OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  if ${USE_PYTORCH} ; then
    OPTIONAL_MODULES_TEXT="Pytorch ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    OPTIONAL_MODULES_TEXT="Pytorch OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  if ${USE_ROS2} ; then
    OPTIONAL_MODULES_TEXT="Ros2 ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    OPTIONAL_MODULES_TEXT="Ros2 OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  if ${USE_UNITY} ; then
    OPTIONAL_MODULES_TEXT="Unity ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  else
    OPTIONAL_MODULES_TEXT="Unity OFF"$'\n'"${OPTIONAL_MODULES_TEXT}"
  fi
  OPTIONAL_MODULES_TEXT="Fast_dds ON"$'\n'"${OPTIONAL_MODULES_TEXT}"
  # 导出可选模块设置
  echo ${OPTIONAL_MODULES_TEXT} > ${PWD}/Config/OptionalModules.ini
# 如果Makefile不存在，则生成Unreal项目文件
  if [ ! -f Makefile ]; then
    set +e
    log "Generate Unreal project files."
    ${UE4_ROOT}/GenerateProjectFiles.sh -project="${PWD}/CarlaUE4.uproject" -game -engine -makefiles
    set -e

  fi

  log "Build CarlaUE4 project."
  make CarlaUE4Editor

  # 创建导出地图的文件夹
  EXPORTED_MAPS="${CARLAUE4_ROOT_FOLDER}/Content/Carla/ExportedMaps"
  mkdir -p "${EXPORTED_MAPS}"


fi

# ==============================================================================
# -- Launch UE4Editor ----------------------------------------------------------
# ==============================================================================
# 如果选择启动UE4编辑器
if ${LAUNCH_UE4_EDITOR} ; then

  log "Launching UE4Editor..."
  ${GDB} ${UE4_ROOT}/Engine/Binaries/Linux/UE4Editor "${PWD}/CarlaUE4.uproject" ${RHI} ${EDITOR_FLAGS}

else

  log "Success!"

fi

# ==============================================================================
# -- ...and we are done --------------------------------------------------------
# ==============================================================================
# 返回到原始目录
popd >/dev/null
