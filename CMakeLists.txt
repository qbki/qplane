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

find_package(Qt6QmlCompiler CONFIG REQUIRED)
find_package(Qt6QmlIntegration CONFIG REQUIRED)
find_package(Qt6QmlModels CONFIG REQUIRED)
find_package(Qt6Quick CONFIG REQUIRED)
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

qt_standard_project_setup(REQUIRES 6.8.1)
qt_add_executable(${PROJECT_NAME} src/main.cpp)

target_link_libraries(${PROJECT_NAME} PRIVATE
  Qt::Gui
  Qt::Qml

  Qt::QmlCompiler
  Qt::QmlIntegration
  Qt::QmlModels
  Qt::Quick
  Qt::QuickWidgets

  Qt::Quick3D
  Qt::Quick3DAssetImport
  Qt::Quick3DAssetUtils
  Qt::Quick3DEffects
  Qt::Quick3DHelpers
  Qt::Quick3DHelpersImpl
  Qt::Quick3DParticleEffects
  Qt::Quick3DParticles
  Qt::Quick3DRuntimeRender
  Qt::Quick3DUtils
)

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
