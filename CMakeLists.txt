cmake_minimum_required(VERSION 3.14)

project(ecollect VERSION 0.1 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

#set(CMAKE_VERBOSE_BUILD ON)

include(ExternalProject)

set(GOOGLEQT_PREFIX googleqt)
set(GOOGLEQT_SOURCE_DIR ${GOOGLEQT_PREFIX}-source)
set(GOOGLEQT_BUILD_DIR ${GOOGLEQT_PREFIX}-build)
set(GOOGLEQT_BUILD_BYPRODUCTS ${GOOGLEQT_BUILD_DIR}/${CMAKE_STATIC_MODULE_PREFIX}googleQt${CMAKE_STATIC_LIBRARY_SUFFIX})
ExternalProject_Add(googleqt
    GIT_REPOSITORY https://github.com/Universidad-de-La-Laguna/simull-google-qt.git
    GIT_TAG master
    GIT_SHALLOW true
    PREFIX ${GOOGLEQT_PREFIX}
    SOURCE_DIR ${GOOGLEQT_SOURCE_DIR}
    BINARY_DIR ${GOOGLEQT_BUILD_DIR}
    CMAKE_ARGS -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}
    BUILD_BYPRODUCTS ${GOOGLEQT_BUILD_BYPRODUCTS}
    INSTALL_COMMAND ""
)

set(GOOGLEQT_INCLUDE_DIR ${CMAKE_BINARY_DIR}/${GOOGLEQT_SOURCE_DIR}/src)
set(GOOGLEQT_LIBS ${CMAKE_BINARY_DIR}/${GOOGLEQT_BUILD_BYPRODUCTS})

find_package(Qt6 COMPONENTS Core Multimedia Quick REQUIRED)

set(PROJECT_SOURCES
    src/main.cpp
    src/uploader.cpp
    src/uploader.h
    src/utils.cpp
    src/utils.h
    src/qml/qml.qrc
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

add_dependencies(ecollect googleqt)

target_compile_definitions(ecollect
    PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_include_directories(ecollect
    PRIVATE ${GOOGLEQT_INCLUDE_DIR})
target_link_libraries(ecollect
    PRIVATE Qt::Core Qt::Multimedia Qt::Quick)
target_link_libraries(ecollect
    PRIVATE ${GOOGLEQT_LIBS})

set_target_properties(ecollect PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER ecollect.simull.ull.edu.es
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(ecollect)
qt_finalize_executable(ecollect)
