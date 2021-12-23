cmake_minimum_required(VERSION 3.14)

project(ecollect VERSION 0.1 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 23)  # /std:c++latest - unlocks non stable MSVC C++20 features (like ranges) for new 16.11 versions
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#set(CMAKE_VERBOSE_BUILD ON)

find_package(Qt6 COMPONENTS Core Multimedia Quick REQUIRED)
find_package(AWSSDK CONFIG COMPONENTS transfer REQUIRED)

set(PROJECT_SOURCES
    src/main.cpp
    src/utils.cpp
    src/utils.h
    src/qml/qml.qrc
    src/uploader/awsconfig.h
    src/uploader/uploader.cpp
    src/uploader/uploader.h
    src/uploader/uploadererror.h
    src/uploader/uploadererror.cpp
    src/uploader/uploaderimplabstract.h
    src/uploader/uploaderawss3impl.cpp
    src/uploader/uploaderawss3impl.h
    res/resources.qrc
)

set(QML_IMPORT_PATH
    "${CMAKE_SOURCE_DIR}/src/qml/imports"
    CACHE STRING "Qt Creator extra qml import paths"
    FORCE
)

qt_add_executable(ecollect
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
)

target_compile_definitions(ecollect
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_include_directories(ecollect
    PRIVATE ${AWSSDK_INCLUDE_DIRS})
target_link_libraries(ecollect
    PRIVATE Qt::Core Qt::Multimedia Qt::Quick)
target_link_libraries(ecollect
    PRIVATE ${AWSSDK_LIBRARIES})

set_target_properties(ecollect PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER ecollect.simull.ull.edu.es
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(ecollect)
qt_finalize_executable(ecollect)
