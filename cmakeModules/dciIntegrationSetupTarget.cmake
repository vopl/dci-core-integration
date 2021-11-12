if(NOT COMMAND dciIntegrationSetupTarget)

    set(dciIntegrationSetupTarget_dir ${CMAKE_CURRENT_LIST_DIR})
    include(${dciIntegrationSetupTarget_dir}/dciIntegrationMeta.cmake)

    function(dciIntegrationSetupTargetMapSourceDirectory target from to)
#        target_compile_options(${target} PRIVATE -ffile-prefix-map=${from}=)
#        target_compile_options(${target} PRIVATE -fmacro-prefix-map=${from}=)
#        target_compile_options(${target} PRIVATE -fdebug-prefix-map=${from}=)

#        target_compile_options(${target} PRIVATE -ffile-prefix-map=${from}/=)
#        target_compile_options(${target} PRIVATE -fmacro-prefix-map=${from}/=)
#        target_compile_options(${target} PRIVATE -fdebug-prefix-map=${from}/=)
    endfunction()

    function(dciIntegrationSetupTarget target)

        set_target_properties(${target} PROPERTIES UNAME "${DCI_UNIT_NAME}")
        string(REGEX REPLACE "^module-" "" mname ${DCI_UNIT_NAME})

        #######################################################################
        set(options AUX BDEP TEST MODULE MODULE_SPARE)
        set(oneValueArgs)
        set(multiValueArgs)
        cmake_parse_arguments(A "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

        #######################################################################
        set(kind UNKNOWN)
        set(outputDirectoryApp)
        set(outputDirectoryLib)
        set(isDepForUnit No)
        if(A_AUX)
            set(kind AUX)
            set(outputDirectoryApp "${CMAKE_CURRENT_BINARY_DIR}")
            set(outputDirectoryLib "${CMAKE_CURRENT_BINARY_DIR}")
        elseif(A_TEST)
            set(kind TEST)
            set(outputDirectoryApp "${DCI_OUT_DIR}/test")
            set(outputDirectoryLib "${DCI_OUT_DIR}/test")
        elseif(A_MODULE)
            set(kind MODULE)
            set(outputDirectoryApp "${DCI_OUT_DIR}/module")
            set(outputDirectoryLib "${DCI_OUT_DIR}/module")
        elseif(A_MODULE_SPARE)
            set(kind MODULE_SPARE)
            set(outputDirectoryApp "${DCI_OUT_DIR}/module/${mname}")
            set(outputDirectoryLib "${DCI_OUT_DIR}/module/${mname}")
        elseif(A_BDEP)
            set(kind BDEP)
            set(outputDirectoryApp "${DCI_OUT_DIR}/bin")
            set(outputDirectoryLib "${DCI_OUT_DIR}/lib")
            set(isDepForUnit Yes)
        else()
            set(kind REGULAR)
            set(outputDirectoryApp "${DCI_OUT_DIR}/bin")
            set(outputDirectoryLib "${DCI_OUT_DIR}/lib")
            set(isDepForUnit Yes)
        endif()

        get_target_property(type ${target} TYPE)
        message(STATUS "unit '${DCI_UNIT_NAME}' target '${target}' type '${type}' kind '${kind}'")

        #######################################################################
        set(setupCxx Off)
        set(setupApiExports Off)
        set(setupLinker Off)
        set(linkIntegration Off)
        set(setupOutputDirectory)
        set(setupPrefix)
        set(setupRpath Off)
        set(setupDebug Off)
        set(setupReproducibleBuild Off)

        #######################################################################
        if("EXECUTABLE" STREQUAL ${type})
            set(setupCxx On)
            set(setupApiExports On)
            set(setupLinker On)
            set(linkIntegration On)
            set(setupOutputDirectory "${outputDirectoryApp}")
            set(setupPrefix dci-)
            set(setupRpath On)
            set(setupDebug On)
            set(setupReproducibleBuild  On)
        elseif("MODULE_LIBRARY" STREQUAL ${type})
            set(setupCxx On)
            set(setupApiExports On)
            set(setupLinker On)
            set(linkIntegration On)
            set(setupOutputDirectory "${outputDirectoryLib}")
            set(setupPrefix libdci-)
            set(setupRpath On)
            set(setupDebug On)
            set(setupReproducibleBuild  On)
        elseif("SHARED_LIBRARY" STREQUAL ${type})
            set(setupCxx On)
            set(setupApiExports On)
            set(setupLinker On)
            set(linkIntegration On)
            set(setupOutputDirectory "${outputDirectoryLib}")
            set(setupPrefix libdci-)
            set(setupRpath On)
            set(setupDebug On)
            set(setupReproducibleBuild  On)
        elseif("STATIC_LIBRARY" STREQUAL ${type})
            set(setupCxx On)
            set(setupApiExports On)
            set(setupLinker Off)
            set(linkIntegration Off)
            set(setupOutputDirectory "${outputDirectoryLib}")
            set(setupPrefix libdci-)
            set(setupRpath Off)
            set(setupDebug Off)
            set(setupReproducibleBuild On)
        elseif("OBJECT_LIBRARY" STREQUAL ${type})
            message(FATAL_ERROR "Usupported target type: [${target}] with type [${type}]")
        elseif("INTERFACE_LIBRARY" STREQUAL ${type})
            message(FATAL_ERROR "Usupported target type: [${target}] with type [${type}]")
        else()
            message(FATAL_ERROR "Unknown target type: [${target}] with type [${type}]")
        endif()

        #######################################################################
        dciIntegrationMeta(UNIT ${DCI_UNIT_NAME} TARGET ${target}
            TARGET_TYPE ${type}
            TARGET_KIND ${kind}
            TARGET_FILE $<TARGET_FILE:${target}>)

        #######################################################################
        if(setupCxx)
            set_target_properties(${target} PROPERTIES
                CXX_STANDARD 20
                CXX_STANDARD_REQUIRED TRUE
                POSITION_INDEPENDENT_CODE TRUE)

            target_compile_definitions(${target} PRIVATE "dciUnitName=\"${DCI_UNIT_NAME}\"")
            target_compile_definitions(${target} PRIVATE "dciUnitTargetName=\"${target}\"")
            target_compile_definitions(${target} PRIVATE "dciUnitTargetFile=\"$<TARGET_FILE_NAME:${target}>\"")

            target_compile_options(${target} PRIVATE "-fPIC")
        endif()

        #######################################################################
        if(setupApiExports)
            string(REPLACE "-" "_" def ${DCI_UNIT_NAME})
            string(TOUPPER ${def} def)

            set_target_properties(${target} PROPERTIES DEFINE_SYMBOL "")
            target_compile_definitions(${target} PRIVATE "DCI_${def}_EXPORTS")

            set_target_properties(${target} PROPERTIES
                C_VISIBILITY_PRESET hidden
                CXX_VISIBILITY_PRESET hidden
                VISIBILITY_INLINES_HIDDEN TRUE)
        endif()

        #######################################################################
        if(setupLinker)
            get_property(LINK_FLAGS TARGET ${target} PROPERTY LINK_FLAGS)
            set_target_properties(${target} PROPERTIES LINK_FLAGS "${LINK_FLAGS} -Wl,--no-undefined")
            dciIntegrationMeta(UNIT ${DCI_UNIT_NAME} TARGET ${target} FILE_FOR_TARGET_DEPS $<TARGET_FILE:${target}>)
        endif()

        #######################################################################
        if(linkIntegration AND NOT "${target}" STREQUAL "integration")
            #target_link_libraries(${target} PRIVATE integration)
        endif()

        #######################################################################
        if(setupOutputDirectory)
            set_target_properties(${target} PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY ${setupOutputDirectory}
                LIBRARY_OUTPUT_DIRECTORY ${setupOutputDirectory}
                ARCHIVE_OUTPUT_DIRECTORY ${setupOutputDirectory})
        endif()

        #######################################################################
        if(setupPrefix)
            set_target_properties(${target} PROPERTIES PREFIX "${setupPrefix}")
        endif()

        #######################################################################
        if(setupRpath)
            if(setupOutputDirectory)
                file(RELATIVE_PATH RPATH "${setupOutputDirectory}" "${DCI_OUT_DIR}/lib")
                if(RPATH)
                    set(RPATH "\$ORIGIN/${RPATH}")
                else()
                    set(RPATH "\$ORIGIN")
                endif()
            else()
                set(RPATH "\$ORIGIN/../lib")
            endif()

            set_target_properties(${target} PROPERTIES BUILD_WITH_INSTALL_RPATH TRUE)
            set_target_properties(${target} PROPERTIES INSTALL_RPATH "${RPATH}")
        endif()

        #######################################################################
        if(setupDebug)
            if(DCI_STRIP_DEBUG)
                add_custom_command(TARGET ${target}
                    POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E remove -f $<TARGET_FILE:${target}>.debug
                    COMMAND ${CMAKE_OBJCOPY} --strip-unneeded $<TARGET_FILE:${target}>
                    COMMENT "Stripping debug info for ${target}"
                )
            endif()

            if(DCI_SEPARATE_DEBUG)
                if(DCI_BE_DIR)
                    set(gdb_add_index ${DCI_BE_DIR}/bin/gdb-add-index)
                else()
                    set(gdb_add_index gdb-add-index)
                endif()

                add_custom_command(TARGET ${target}
                    POST_BUILD
                    COMMAND ${CMAKE_COMMAND} -E remove -f $<TARGET_FILE:${target}>.debug
                    COMMAND ${CMAKE_OBJCOPY} --only-keep-debug $<TARGET_FILE:${target}> $<TARGET_FILE:${target}>.debug
                    COMMAND ${gdb_add_index} $<TARGET_FILE:${target}>.debug
                    COMMAND ${CMAKE_OBJCOPY} --strip-all $<TARGET_FILE:${target}>
                    COMMAND ${CMAKE_OBJCOPY} --add-gnu-debuglink=$<TARGET_FILE:${target}>.debug $<TARGET_FILE:${target}>
                    COMMENT "Separating debug info for ${target}"
                )
                set_target_properties(${target} PROPERTIES ADDITIONAL_CLEAN_FILES $<TARGET_FILE:${target}>.debug)
            endif()
        endif()

        #######################################################################
        if(setupReproducibleBuild)
            if("STATIC_LIBRARY" STREQUAL ${type})
                add_custom_command(TARGET ${target}
                    POST_BUILD
                    COMMAND ${CMAKE_CXX_COMPILER_RANLIB} -D $<TARGET_FILE:${target}>
                    COMMENT "Striping nondeterminizm from for ${target}"
                )
                if(CMAKE_CXX_COMPILER_ID STREQUAL "GNU")
                    set_target_properties(${target} PROPERTIES STATIC_LIBRARY_OPTIONS "-Df")
                endif()

                if(CMAKE_CXX_COMPILER_ID STREQUAL "Clang")
                    set_target_properties(${target} PROPERTIES STATIC_LIBRARY_OPTIONS "-D")
                endif()

            else()
                target_link_options(${target} PRIVATE -Wl,--build-id=sha1)
                #target_link_options(${target} PRIVATE -Wl,--no-insert-timestamp)
            endif()

            foreach(iidir ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES} ${CMAKE_C_IMPLICIT_INCLUDE_DIRECTORIES})
                dciIntegrationSetupTargetMapSourceDirectory(${target} ${iidir} DCI_SYSINC)
            endforeach()

            dciIntegrationSetupTargetMapSourceDirectory(${target} ${DCI_SRC_DIR} DCI_SRC)
            dciIntegrationSetupTargetMapSourceDirectory(${target} ${DCI_OUT_DIR} DCI_OUT)
            dciIntegrationSetupTargetMapSourceDirectory(${target} ${CMAKE_CURRENT_BINARY_DIR} DCI_BLD)

            target_compile_options(${target} PRIVATE -Wdate-time)

            #SOURCE_DATE_EPOCH
        endif()

        #######################################################################
        target_include_directories(${target} BEFORE PRIVATE ${DCI_INCLUDE_DIRS})
        target_include_directories(${target} PRIVATE ${DCI_OUT_DIR}/include)

        #######################################################################
        if(DCI_BE_DIR)
            target_include_directories(${target} SYSTEM BEFORE PRIVATE ${DCI_BE_DIR}/include)
            target_link_options(${target} PRIVATE -L${DCI_BE_DIR}/lib)
        endif()

        #######################################################################
        # от таргета зависит юнит
        if(isDepForUnit)
            add_dependencies(unit-${UNAME} ${target})
        endif()

        # таргета зависит от всех юнитов, заявленных как зависимости для данного юнита
        get_property(udeps GLOBAL PROPERTY DCI_INTEGRATION_REGISTRY_${UNAME}_DEPENDS)
        foreach(udep ${udeps})
            add_dependencies(${target} unit-${udep})
        endforeach()

    endfunction()
endif()
