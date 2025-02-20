function(add_qt_test file_path)
  get_filename_component(test_target ${file_path} NAME_WE)
  qt_add_executable(${test_target} ${file_path})
  add_test(NAME ${test_target} COMMAND ${test_target})
  target_link_libraries(${test_target} PRIVATE
    Qt::Gui
    Qt::Qml
    Qt::QuickTest
    Qt::Test
  )
  qt_add_qml_module(${test_target}
    URI tests
    SOURCES
      ${ARGN}
    DEPENDENCIES
      QtQuick
  )
endfunction()
