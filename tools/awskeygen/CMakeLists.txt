cmake_minimum_required(VERSION 3.14)

project(awskeygen LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 COMPONENTS Core REQUIRED)

add_executable(awskeygen
  main.cpp
  ${CMAKE_SOURCE_DIR}/src/thirdparty/simplecrypt/simplecrypt.h
  ${CMAKE_SOURCE_DIR}/src/thirdparty/simplecrypt/simplecrypt.cpp
)

target_compile_definitions(awskeygen
    PRIVATE AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
            AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
            AWS_CRYPTO_KEY=${AWS_CRYPTO_KEY}
            AWS_S3_BUCKET_NAME=${AWS_S3_BUCKET_NAME}
)
target_include_directories(awskeygen PRIVATE ${CMAKE_SOURCE_DIR}/src/thirdparty)
target_link_libraries(awskeygen Qt::Core)
