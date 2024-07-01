cmake_minimum_required(VERSION 3.27)

set(CMAKE_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/tools/vcpkg/scripts/buildsystems/vcpkg.cmake"
    CACHE STRING "Vcpkg toolchain file")

project(qplane VERSION 0.0.1)

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)

find_package(Qt6Core CONFIG REQUIRED)
find_package(Qt6Gui CONFIG REQUIRED)
find_package(Qt6OpenGL CONFIG REQUIRED)
find_package(Qt6OpenGLWidgets CONFIG REQUIRED)
find_package(Qt6Widgets CONFIG REQUIRED)

qt_standard_project_setup()
file(GLOB_RECURSE SOURCES src/*)
qt_add_executable(${PROJECT_NAME} ${SOURCES})

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Core Qt6::Core Qt::CorePrivate Qt6::CorePrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Gui Qt6::Gui Qt::GuiPrivate Qt6::GuiPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::OpenGL Qt6::OpenGL Qt::OpenGLPrivate Qt6::OpenGLPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::OpenGLWidgets Qt6::OpenGLWidgets Qt::OpenGLWidgetsPrivate Qt6::OpenGLWidgetsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Widgets Qt6::Widgets Qt::WidgetsPrivate Qt6::WidgetsPrivate)
