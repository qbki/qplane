function(add_ts_resource resource_target_name ts_file)
  set(js_file "")
  string(REGEX REPLACE "mts$" "mjs" js_file ${ts_file})
  set(js_src ${CMAKE_CURRENT_SOURCE_DIR}/${ts_file})
  set(js_out ${CMAKE_CURRENT_BINARY_DIR}/generated/js/${js_file})
  add_custom_target(${resource_target_name}
    ALL
    BYPRODUCTS ${js_out}
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    COMMAND npx rollup -c ${CMAKE_CURRENT_SOURCE_DIR}/rollup.config.js -o ${js_out} -i ${js_src}
    COMMENT "JS transpilation: ${ts_file}"
    VERBATIM
  )
  qt_add_resources(
    ${PROJECT_NAME} ${resource_target_name}
    PREFIX "/"
    BASE ${CMAKE_CURRENT_BINARY_DIR}/generated/js/src/
    FILES ${js_out}
  )
  add_dependencies(${PROJECT_NAME} ${resource_target_name})
endfunction()
