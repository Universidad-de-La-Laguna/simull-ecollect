cmake_minimum_required(VERSION 3.14)

project(ecollect VERSION 0.1 LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core Multimedia Quick REQUIRED)

set(PROJECT_SOURCES
    src/main.cpp
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

target_compile_definitions(ecollect
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(ecollect
  PRIVATE Qt::Core Qt::Multimedia Qt::Quick)

set_target_properties(ecollect PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER ecollect.simull.ull.edu.es
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
)

qt_import_qml_plugins(ecollect)
qt_finalize_executable(ecollect)
