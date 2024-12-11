cmake_minimum_required(VERSION 3.27)

set(CMAKE_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/tools/vcpkg/scripts/buildsystems/vcpkg.cmake"
    CACHE STRING "Vcpkg toolchain file")

project(qplane VERSION 0.0.1)

set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6Gui CONFIG REQUIRED)

find_package(Qt6Qml CONFIG REQUIRED)
find_package(Qt6QmlBuiltins CONFIG REQUIRED)
find_package(Qt6QmlCompiler CONFIG REQUIRED)
find_package(Qt6QmlCore CONFIG REQUIRED)
find_package(Qt6QmlIntegration CONFIG REQUIRED)
find_package(Qt6QmlLocalStorage CONFIG REQUIRED)
find_package(Qt6QmlModels CONFIG REQUIRED)
find_package(Qt6QmlWorkerScript CONFIG REQUIRED)
find_package(Qt6Quick CONFIG REQUIRED)
find_package(Qt6QuickControls2 CONFIG REQUIRED)
find_package(Qt6QuickControls2Basic CONFIG REQUIRED)
find_package(Qt6QuickControls2BasicStyleImpl CONFIG REQUIRED)
find_package(Qt6QuickControls2Fusion CONFIG REQUIRED)
find_package(Qt6QuickControls2FusionStyleImpl CONFIG REQUIRED)
find_package(Qt6QuickControls2Imagine CONFIG REQUIRED)
find_package(Qt6QuickControls2ImagineStyleImpl CONFIG REQUIRED)
find_package(Qt6QuickControls2Impl CONFIG REQUIRED)
find_package(Qt6QuickControls2Material CONFIG REQUIRED)
find_package(Qt6QuickControls2MaterialStyleImpl CONFIG REQUIRED)
find_package(Qt6QuickControls2Universal CONFIG REQUIRED)
find_package(Qt6QuickControls2UniversalStyleImpl CONFIG REQUIRED)
find_package(Qt6QuickDialogs2 CONFIG REQUIRED)
find_package(Qt6QuickDialogs2QuickImpl CONFIG REQUIRED)
find_package(Qt6QuickDialogs2Utils CONFIG REQUIRED)
find_package(Qt6QuickLayouts CONFIG REQUIRED)
find_package(Qt6QuickTemplates2 CONFIG REQUIRED)
find_package(Qt6QuickTest CONFIG REQUIRED)
find_package(Qt6QuickWidgets CONFIG REQUIRED)

find_package(Qt6Quick3D CONFIG REQUIRED)
find_package(Qt6Quick3DAssetImport CONFIG REQUIRED)
find_package(Qt6Quick3DAssetUtils CONFIG REQUIRED)
find_package(Qt6Quick3DEffects CONFIG REQUIRED)
find_package(Qt6Quick3DHelpers CONFIG REQUIRED)
find_package(Qt6Quick3DHelpersImpl CONFIG REQUIRED)
find_package(Qt6Quick3DParticleEffects CONFIG REQUIRED)
find_package(Qt6Quick3DParticles CONFIG REQUIRED)
find_package(Qt6Quick3DRuntimeRender CONFIG REQUIRED)
find_package(Qt6Quick3DUtils CONFIG REQUIRED)

find_package(Qt6Svg CONFIG REQUIRED)
find_package(Qt6SvgWidgets CONFIG REQUIRED)

qt_standard_project_setup(REQUIRES 6.7)
qt_add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Gui)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Qml)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlBuiltins)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlCompiler)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlCore)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlIntegration)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlLocalStorage)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlModels)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlWorkerScript)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Basic)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2BasicStyleImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Fusion)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2FusionStyleImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Imagine)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2ImagineStyleImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Impl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Material)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2MaterialStyleImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Universal)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2UniversalStyleImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2QuickImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2Utils)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickLayouts)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickTemplates2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickTest)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickWidgets)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3D)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DAssetImport)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DAssetUtils)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DEffects)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DHelpers)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DHelpersImpl)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DParticleEffects)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DParticles)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DRuntimeRender)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DUtils)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Svg)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::SvgWidgets)

include_directories(
  ${CMAKE_SOURCE_DIR}
  # <> Without it Qt can't find classes tagged with QML_ELEMENT or QT_GADGET
  ${CMAKE_SOURCE_DIR}/src/qmlutils
  ${CMAKE_SOURCE_DIR}/src/models
  ${CMAKE_SOURCE_DIR}/src/models/actionmanager
  ${CMAKE_SOURCE_DIR}/src/types
  ${CMAKE_SOURCE_DIR}/src/mainwindow
  ${CMAKE_SOURCE_DIR}/src/components
  ${CMAKE_SOURCE_DIR}/src/components/form
  ${CMAKE_SOURCE_DIR}/src/components/icons
  ${CMAKE_SOURCE_DIR}/src/components/rosters
  ${CMAKE_SOURCE_DIR}/src/components/scene
  ${CMAKE_SOURCE_DIR}/src/components/windows
  # </>
)

set_source_files_properties(
  src/qmlutils/QmlUtils.qml
  PROPERTIES QT_QML_SINGLETON_TYPE TRUE
)

qt_add_qml_module(${PROJECT_NAME}
  URI app
  QML_FILES
    src/components/CameraController.qml
    src/components/EntityModelItem.qml
    src/components/HeightControl.qml
    src/components/Highlight.qml
    src/components/IconButton.qml
    src/components/LevelSettings.qml
    src/components/MainMenuItem.qml
    src/components/OpacityHover.qml
    src/components/PropertiesControl.qml
    src/components/SceneGhost.qml
    src/components/TextTexture.qml
    src/components/form/BlockableTextInput.qml
    src/components/form/FormAcceptButtonsGroup.qml
    src/components/form/FormCheckBoxInput.qml
    src/components/form/FormColorInput.qml
    src/components/form/FormComboBoxInput.qml
    src/components/form/FormFilesComboBoxInput.qml
    src/components/form/FormInfoLabel.qml
    src/components/form/FormNullableTextInput.qml
    src/components/form/FormTextInput.qml
    src/components/form/FormVector3DInput.qml
    src/components/form/FormVelocityInput.qml
    src/components/icons/BaseIconShape.qml
    src/components/icons/DownIcon.qml
    src/components/icons/UpIcon.qml
    src/components/rosters/RosterBase.qml
    src/components/rosters/RosterContextMenu.qml
    src/components/rosters/RosterEntityActors.qml
    src/components/rosters/RosterEntityDirectionalLights.qml
    src/components/rosters/RosterEntityModels.qml
    src/components/rosters/RosterEntityParticles.qml
    src/components/rosters/RosterEntityTexts.qml
    src/components/rosters/RosterEntityWeapons.qml
    src/components/rosters/RosterLabel.qml
    src/components/rosters/RosterTitle.qml
    src/components/scene/SceneItem.qml
    src/components/scene/SceneItemsInstanceList.qml
    src/components/scene/SceneListEntry.qml
    src/components/scene/SceneTextItem.qml
    src/components/windows/EditWindowBase.qml
    src/components/windows/EntityActorEditWindow.qml
    src/components/windows/EntityDirectionalLightEditWindow.qml
    src/components/windows/EntityModelEditWindow.qml
    src/components/windows/EntityParticlesEditWindow.qml
    src/components/windows/EntityTextEditWindow.qml
    src/components/windows/EntityWeaponEditWindow.qml
    src/components/windows/LazyEditWindow.qml
    src/components/windows/LazyWindow.qml
    src/components/windows/LevelSettingsWindow.qml
    src/components/windows/LevelsEditWindow.qml
    src/components/windows/ThemeEditWindow.qml
    src/mainwindow/MainWindow.qml
    src/qmlutils/QmlUtils.qml
  QML_FILES
    src/jsutils/utils.mjs
  SOURCES
    src/consts.h
    src/models/actionmanager/actionmanager.h src/models/actionmanager/actionmanager.cpp
    src/models/actionmanager/actionmanageritem.h src/models/actionmanager/actionmanageritem.cpp
    src/models/appstate.h src/models/appstate.cpp
    src/models/baselist.h
    src/models/clipboard.h src/models/clipboard.cpp
    src/models/fileio.h src/models/fileio.cpp
    src/models/gadgetlistmodel.h src/models/gadgetlistmodel.cpp
    src/models/recursivedirectorylistmodel.h src/models/recursivedirectorylistmodel.cpp
    src/models/theme.h src/models/theme.cpp
    src/models/transformmodel.h src/models/transformmodel.cpp
    src/models/translations.h src/models/translations.cpp
    src/models/uuidgenerator.h src/models/uuidgenerator.cpp
    src/types/entityactor.h src/types/entityactor.cpp
    src/types/entitybase.h src/types/entitybase.cpp
    src/types/entityboundaries.h src/types/entityboundaries.cpp
    src/types/entitycamera.h src/types/entitycamera.cpp
    src/types/entitydirectionallight.h src/types/entitydirectionallight.cpp
    src/types/entitymodel.h src/types/entitymodel.cpp
    src/types/entityparticles.h src/types/entityparticles.cpp
    src/types/entitypropvelocity.h src/types/entitypropvelocity.cpp
    src/types/entitytext.h src/types/entitytext.cpp
    src/types/entityweapon.h src/types/entityweapon.cpp
    src/types/levelmeta.h src/types/levelmeta.cpp
    src/types/positionstrategymany.h src/types/positionstrategymany.cpp
    src/types/positionstrategysingle.h src/types/positionstrategysingle.cpp
    src/types/positionstrategyvoid.h src/types/positionstrategyvoid.cpp
    src/utils/json.h src/utils/json.cpp
    src/utils/jsonvalidator.h src/utils/jsonvalidator.cpp
    src/utils/utils.h
)
