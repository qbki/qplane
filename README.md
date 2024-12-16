# Troubleshooting

## syncqt

Wrong path in vcpkg. Should be:

```CMake
set(_qt_imported_build_location "${CMAKE_CURRENT_LIST_DIR}/../../tools/Qt6/bin/syncqt")
set(_qt_imported_install_location "${CMAKE_CURRENT_LIST_DIR}/../../tools/Qt6/bin/syncqt")
```
