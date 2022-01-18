cmake_minimum_required(VERSION 3.21.1)

project(ecollect VERSION 0.1 LANGUAGES CXX)

option(ECOLLECT_DISABLE_FULLSCREEN "Disable open the main window in fullscreen" ON)
option(STATIC_BUILD "Enable build a static linked executable" OFF)

set(AWS_ACCESS_KEY_ID "<access-key-id>" CACHE STRING "AWS access key id")
set(AWS_SECRET_ACCESS_KEY "/base64+encrypted+secret+access+key/" CACHE STRING "Encrypted AWS secret key")
set(AWS_CRYPTO_KEY "0" CACHE STRING "Key to decrypt the AWS secret key")
set(AWS_S3_BUCKET_NAME "<bucket-name>" CACHE STRING "AWS S3 bucket name")
set(AWS_LOGGING_LOGLEVEL 0 CACHE STRING "AWS logging log level. See 'common/logging.h'")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 23)  # /std:c++latest - unlocks non stable MSVC C++20 features (like ranges) for new 16.11 versions
set(CMAKE_CXX_STANDARD_REQUIRED ON)

if (STATIC_BUILD)
    set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>")
endif()

find_package(Qt6 COMPONENTS Core CoreTools Multimedia Quick REQUIRED)
find_package(AWSSDK COMPONENTS transfer REQUIRED)

# Get paths to QMAKE and the Qt translations directory
if (NOT QT_QMAKE_EXECUTABLE)
    get_target_property(QT_QMAKE_EXECUTABLE Qt6::qmake IMPORTED_LOCATION_RELEASE)
endif()
execute_process(
    COMMAND ${QT_QMAKE_EXECUTABLE} -query QT_INSTALL_TRANSLATIONS
    OUTPUT_VARIABLE QT_INSTALL_TRANSLATIONS
    OUTPUT_STRIP_TRAILING_WHITESPACE
)

set(QML_IMPORT_PATH
    "${CMAKE_SOURCE_DIR}/src/qml/imports"
    CACHE STRING "Qt Creator extra qml import paths"
    FORCE
)

set(PROJECT_SOURCES
    src/main.cpp
    src/filelog.cpp
    src/filelog.h
    src/messagehandler.cpp
    src/messagehandler.h
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
    src/thirdparty/base64.h
    src/thirdparty/simplecrypt/simplecrypt.h
    src/thirdparty/simplecrypt/simplecrypt.cpp
    res/resources.qrc
)

qt_add_big_resources(PROJECT_SOURCES
    res/videos.qrc
)

qt_add_executable(ecollect
    WIN32
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
)

qt_add_resources(ecollect "i18n"
    PREFIX /i18n
    BASE ${QT_INSTALL_TRANSLATIONS}
    FILES ${QT_INSTALL_TRANSLATIONS}/qtbase_es.qm
       ${QT_INSTALL_TRANSLATIONS}/qtdeclarative_es.qm
       ${QT_INSTALL_TRANSLATIONS}/qtmultimedia_es.qm
)

target_compile_definitions(ecollect
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>
            Qt6_COMPILE_OPTIONS_LIST
            AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
            AWS_CRYPTO_KEY=${AWS_CRYPTO_KEY}
            AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}
            AWS_LOGGING_LOGLEVEL=${AWS_LOGGING_LOGLEVEL}
            ECOLLECT_DISABLE_FULLSCREEN=$<$<BOOL:${ECOLLECT_DISABLE_FULLSCREEN}>:"1">
)

target_include_directories(ecollect PRIVATE src/thirdparty)
target_link_libraries(ecollect
    PRIVATE Qt6::Core
            Qt6::Multimedia
            Qt6::Quick
            ${AWSSDK_LIBRARIES}
)

set_target_properties(ecollect PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER ecollect.simull.ull.edu.es
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(ecollect)
qt_finalize_target(ecollect)

if (NOT STATIC_BUILD)
    add_subdirectory(tools/awskeygen)
endif()
