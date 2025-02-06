# QPlane

QPlane is a level editor for [Plane Game
Engine](https://github.com/qbki/plane).

It uses JSON schemas described in [Plane Game Engine Data
Structures](https://github.com/qbki/planeds).

## Introduction

QPlane works with an assets directory. It can create:

* The _entities.json_ file that contains all entities of the game
* A level file (_*.level.json_)
* A level configuration (camera position, light, boundaries)
* A theme file (theme.json that contains font paths, UI colors, etc.)

## Documentation

For detailed information on how to use and configure the project, please refer
to [the full documentation](https://qbki.github.io/planedoc/qplane.html).

## Troubleshooting

### syncqt

Wrong path in vcpkg. Should be:

```CMake
set(_qt_imported_build_location "${CMAKE_CURRENT_LIST_DIR}/../../tools/Qt6/bin/syncqt")
set(_qt_imported_install_location "${CMAKE_CURRENT_LIST_DIR}/../../tools/Qt6/bin/syncqt")
```

## License

QPlane is [MIT licensed](./LICENSE).
