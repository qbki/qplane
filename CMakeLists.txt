cmake_minimum_required(VERSION 3.27)

set(CMAKE_TOOLCHAIN_FILE
    "${CMAKE_CURRENT_SOURCE_DIR}/tools/vcpkg/scripts/buildsystems/vcpkg.cmake"
    CACHE STRING "Vcpkg toolchain file")

project(qplane VERSION 0.0.1)

set(CMAKE_AUTOMOC ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# find_package and target_link_libraries were taken from vcpkg's install log
find_package(Qt6Core CONFIG REQUIRED)
find_package(Qt6Gui CONFIG REQUIRED)

find_package(Qt6Qml CONFIG REQUIRED)
find_package(Qt6QmlBuiltins CONFIG REQUIRED)
find_package(Qt6QmlCompiler CONFIG REQUIRED)
find_package(Qt6QmlCore CONFIG REQUIRED)
find_package(Qt6QmlDebugPrivate CONFIG REQUIRED)
find_package(Qt6QmlDomPrivate CONFIG REQUIRED)
find_package(Qt6QmlIntegration CONFIG REQUIRED)
find_package(Qt6QmlLSPrivate CONFIG REQUIRED)
find_package(Qt6QmlLocalStorage CONFIG REQUIRED)
find_package(Qt6QmlModels CONFIG REQUIRED)
find_package(Qt6QmlNetwork CONFIG REQUIRED)
find_package(Qt6QmlToolingSettingsPrivate CONFIG REQUIRED)
find_package(Qt6QmlTypeRegistrarPrivate CONFIG REQUIRED)
find_package(Qt6QmlWorkerScript CONFIG REQUIRED)
find_package(Qt6QmlXmlListModel CONFIG REQUIRED)
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
find_package(Qt6QuickControlsTestUtilsPrivate CONFIG REQUIRED)
find_package(Qt6QuickDialogs2 CONFIG REQUIRED)
find_package(Qt6QuickDialogs2QuickImpl CONFIG REQUIRED)
find_package(Qt6QuickDialogs2Utils CONFIG REQUIRED)
find_package(Qt6QuickEffectsPrivate CONFIG REQUIRED)
find_package(Qt6QuickLayouts CONFIG REQUIRED)
find_package(Qt6QuickParticlesPrivate CONFIG REQUIRED)
find_package(Qt6QuickShapesPrivate CONFIG REQUIRED)
find_package(Qt6QuickTemplates2 CONFIG REQUIRED)
find_package(Qt6QuickTest CONFIG REQUIRED)
find_package(Qt6QuickTestUtilsPrivate CONFIG REQUIRED)
find_package(Qt6QuickWidgets CONFIG REQUIRED)

find_package(Qt6Quick3D CONFIG REQUIRED)
find_package(Qt6Quick3DAssetImport CONFIG REQUIRED)
find_package(Qt6Quick3DAssetUtils CONFIG REQUIRED)
find_package(Qt6Quick3DEffects CONFIG REQUIRED)
find_package(Qt6Quick3DGlslParserPrivate CONFIG REQUIRED)
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

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Core Qt6::Core Qt::CorePrivate Qt6::CorePrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Gui Qt6::Gui Qt::GuiPrivate Qt6::GuiPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::PacketProtocolPrivate Qt6::PacketProtocolPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Qml Qt6::Qml Qt::QmlPrivate Qt6::QmlPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlBuiltins Qt6::QmlBuiltins Qt::QmlBuiltinsPrivate Qt6::QmlBuiltinsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlCompiler Qt6::QmlCompiler Qt::QmlCompilerPrivate Qt6::QmlCompilerPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlCore Qt6::QmlCore Qt::QmlCorePrivate Qt6::QmlCorePrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlDebugPrivate Qt6::QmlDebugPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlDomPrivate Qt6::QmlDomPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlIntegration Qt6::QmlIntegration Qt::QmlIntegrationPrivate Qt6::QmlIntegrationPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlLSPrivate Qt6::QmlLSPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlLocalStorage Qt6::QmlLocalStorage Qt::QmlLocalStoragePrivate Qt6::QmlLocalStoragePrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlModels Qt6::QmlModels Qt::QmlModelsPrivate Qt6::QmlModelsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlNetwork Qt6::QmlNetwork Qt::QmlNetworkPrivate Qt6::QmlNetworkPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlToolingSettingsPrivate Qt6::QmlToolingSettingsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlTypeRegistrarPrivate Qt6::QmlTypeRegistrarPrivate Qt6::QmlTypeRegistrarPrivate_resources_1)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlWorkerScript Qt6::QmlWorkerScript Qt::QmlWorkerScriptPrivate Qt6::QmlWorkerScriptPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QmlXmlListModel Qt6::QmlXmlListModel Qt::QmlXmlListModelPrivate Qt6::QmlXmlListModelPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick Qt6::Quick Qt::QuickPrivate Qt6::QuickPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2 Qt6::QuickControls2 Qt::QuickControls2Private Qt6::QuickControls2Private)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Basic Qt6::QuickControls2Basic Qt::QuickControls2BasicPrivate Qt6::QuickControls2BasicPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2BasicStyleImpl Qt6::QuickControls2BasicStyleImpl Qt::QuickControls2BasicStyleImplPrivate Qt6::QuickControls2BasicStyleImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Fusion Qt6::QuickControls2Fusion Qt::QuickControls2FusionPrivate Qt6::QuickControls2FusionPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2FusionStyleImpl Qt6::QuickControls2FusionStyleImpl Qt::QuickControls2FusionStyleImplPrivate Qt6::QuickControls2FusionStyleImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Imagine Qt6::QuickControls2Imagine Qt::QuickControls2ImaginePrivate Qt6::QuickControls2ImaginePrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2ImagineStyleImpl Qt6::QuickControls2ImagineStyleImpl Qt::QuickControls2ImagineStyleImplPrivate Qt6::QuickControls2ImagineStyleImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Impl Qt6::QuickControls2Impl Qt::QuickControls2ImplPrivate Qt6::QuickControls2ImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Material Qt6::QuickControls2Material Qt::QuickControls2MaterialPrivate Qt6::QuickControls2MaterialPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2MaterialStyleImpl Qt6::QuickControls2MaterialStyleImpl Qt::QuickControls2MaterialStyleImplPrivate Qt6::QuickControls2MaterialStyleImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2Universal Qt6::QuickControls2Universal Qt::QuickControls2UniversalPrivate Qt6::QuickControls2UniversalPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControls2UniversalStyleImpl Qt6::QuickControls2UniversalStyleImpl Qt::QuickControls2UniversalStyleImplPrivate Qt6::QuickControls2UniversalStyleImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickControlsTestUtilsPrivate Qt6::QuickControlsTestUtilsPrivate Qt6::QuickControlsTestUtilsPrivate_resources_1)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2 Qt6::QuickDialogs2 Qt::QuickDialogs2Private Qt6::QuickDialogs2Private)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2QuickImpl Qt6::QuickDialogs2QuickImpl Qt::QuickDialogs2QuickImplPrivate Qt6::QuickDialogs2QuickImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickDialogs2Utils Qt6::QuickDialogs2Utils Qt::QuickDialogs2UtilsPrivate Qt6::QuickDialogs2UtilsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickEffectsPrivate Qt6::QuickEffectsPrivate Qt6::QuickEffectsPrivate_resources_1 Qt6::QuickEffectsPrivate_resources_2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickLayouts Qt6::QuickLayouts Qt::QuickLayoutsPrivate Qt6::QuickLayoutsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickParticlesPrivate Qt6::QuickParticlesPrivate Qt6::QuickParticlesPrivate_resources_1 Qt6::QuickParticlesPrivate_resources_2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickShapesPrivate Qt6::QuickShapesPrivate Qt6::QuickShapesPrivate_resources_1 Qt6::QuickShapesPrivate_resources_2)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickTemplates2 Qt6::QuickTemplates2 Qt::QuickTemplates2Private Qt6::QuickTemplates2Private)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickTest Qt6::QuickTest Qt::QuickTestPrivate Qt6::QuickTestPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickTestUtilsPrivate Qt6::QuickTestUtilsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::QuickWidgets Qt6::QuickWidgets Qt::QuickWidgetsPrivate Qt6::QuickWidgetsPrivate)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3D Qt6::Quick3D Qt::Quick3DPrivate Qt6::Quick3DPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DAssetImport Qt6::Quick3DAssetImport Qt::Quick3DAssetImportPrivate Qt6::Quick3DAssetImportPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DAssetUtils Qt6::Quick3DAssetUtils Qt::Quick3DAssetUtilsPrivate Qt6::Quick3DAssetUtilsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DEffects Qt6::Quick3DEffects Qt::Quick3DEffectsPrivate Qt6::Quick3DEffectsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DGlslParserPrivate Qt6::Quick3DGlslParserPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DHelpers Qt6::Quick3DHelpers Qt::Quick3DHelpersPrivate Qt6::Quick3DHelpersPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DHelpersImpl Qt6::Quick3DHelpersImpl Qt::Quick3DHelpersImplPrivate Qt6::Quick3DHelpersImplPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DParticleEffects Qt6::Quick3DParticleEffects Qt::Quick3DParticleEffectsPrivate Qt6::Quick3DParticleEffectsPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DParticles Qt6::Quick3DParticles Qt::Quick3DParticlesPrivate Qt6::Quick3DParticlesPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DRuntimeRender Qt6::Quick3DRuntimeRender Qt::Quick3DRuntimeRenderPrivate Qt6::Quick3DRuntimeRenderPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Quick3DUtils Qt6::Quick3DUtils Qt::Quick3DUtilsPrivate Qt6::Quick3DUtilsPrivate)

target_link_libraries(${PROJECT_NAME} PRIVATE Qt::Svg Qt6::Svg Qt::SvgPrivate Qt6::SvgPrivate)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt::SvgWidgets Qt6::SvgWidgets Qt::SvgWidgetsPrivate Qt6::SvgWidgetsPrivate)

include_directories(
  ${CMAKE_SOURCE_DIR}
  # <> Without it Qt can't find classes tagged with QML_ELEMENT or QT_GADGET
  ${CMAKE_SOURCE_DIR}/src/components
  ${CMAKE_SOURCE_DIR}/src/components/form
  ${CMAKE_SOURCE_DIR}/src/components/icons
  ${CMAKE_SOURCE_DIR}/src/components/rosters
  ${CMAKE_SOURCE_DIR}/src/components/windows
  ${CMAKE_SOURCE_DIR}/src/models
  ${CMAKE_SOURCE_DIR}/src/models/actionmanager
  ${CMAKE_SOURCE_DIR}/src/types
  # </>
)

qt_add_qml_module(${PROJECT_NAME}
  URI app
  QML_FILES
    src/components/EntityModelItem.qml
    src/components/HeightControl.qml
    src/components/Highlight.qml
    src/components/IconButton.qml
    src/components/LevelSettings.qml
    src/components/MainMenuItem.qml
    src/components/OpacityHover.qml
    src/components/PropertiesControl.qml
    src/components/SceneGhost.qml
    src/components/SceneItem.qml
    src/components/SceneListEntry.qml
    src/components/form/BlockableTextInput.qml
    src/components/form/FormAcceptButtonsGroup.qml
    src/components/form/FormCheckBoxInput.qml
    src/components/form/FormColorInput.qml
    src/components/form/FormComboBoxInput.qml
    src/components/form/FormFilesComboBoxInput.qml
    src/components/form/FormTextInput.qml
    src/components/form/FormVector3DInput.qml
    src/components/icons/BaseIconShape.qml
    src/components/icons/DownIcon.qml
    src/components/icons/UpIcon.qml
    src/components/rosters/RosterEntityActors.qml
    src/components/rosters/RosterEntityDirectionalLights.qml
    src/components/rosters/RosterEntityModels.qml
    src/components/rosters/RosterEntityParticles.qml
    src/components/rosters/RosterEntityWeapons.qml
    src/components/rosters/RosterLabel.qml
    src/components/windows/EditWindowBase.qml
    src/components/windows/EntityActorEditWindow.qml
    src/components/windows/EntityDirectionalLightEditWindow.qml
    src/components/windows/EntityModelEditWindow.qml
    src/components/windows/EntityParticlesEditWindow.qml
    src/components/windows/EntityWeaponEditWindow.qml
    src/components/windows/LazyEditWindow.qml
    src/components/windows/LazyWindow.qml
    src/components/windows/LevelSettingsWindow.qml
    src/components/windows/LevelsEditWindow.qml
    src/components/windows/ThemeEditWindow.qml
    src/mainwindow/MainWindow.qml
  QML_FILES
    src/jsutils/utils.mjs
  SOURCES
    src/consts.h
    src/models/actionmanager/actionmanager.h src/models/actionmanager/actionmanager.cpp
    src/models/actionmanager/actionmanageritem.h src/models/actionmanager/actionmanageritem.cpp
    src/models/appstate.h src/models/appstate.cpp
    src/models/baselist.h
    src/models/fileio.h src/models/fileio.cpp
    src/models/gadgetlistmodel.h src/models/gadgetlistmodel.cpp
    src/models/recursivedirectorylistmodel.h src/models/recursivedirectorylistmodel.cpp
    src/models/theme.h src/models/theme.cpp
    src/models/transformmodel.h src/models/transformmodel.cpp
    src/types/entityactor.h src/types/entityactor.cpp
    src/types/entitycamera.h src/types/entitycamera.cpp
    src/types/entitydirectionallight.h src/types/entitydirectionallight.cpp
    src/types/entitymodel.h src/types/entitymodel.cpp
    src/types/entityparticles.h src/types/entityparticles.cpp
    src/types/entityweapon.h src/types/entityweapon.cpp
    src/types/positionstrategymany.h src/types/positionstrategymany.cpp
    src/types/positionstrategyvoid.h src/types/positionstrategyvoid.cpp
    src/utils/json.h src/utils/json.cpp
    src/utils/jsonvalidator.h src/utils/jsonvalidator.cpp
)
