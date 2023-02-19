if(NOT COMMAND dciIntegration)

    ############################################################################
    include(${CMAKE_CURRENT_LIST_DIR}/dciIntegrationUnit.cmake)
    include(${CMAKE_CURRENT_LIST_DIR}/dciIntegrationMeta.cmake)

    ############################################################################
    function(dciIntegration_includeWithScope fname)
        include(${fname})
    endfunction()

    ############################################################################
    function(dciIntegration)

        set(options)
        set(oneValueArgs
            SRC_DIR
            OUT_DIR
            BE_DIR
            SRC_BRANCH
            SRC_REVISION
            SRC_MOMENT
            PLATFORM_OS
            PLATFORM_ARCH
            COMPILER
            COMPILER_VERSION
            COMPILER_OPTIMIZATION
            REPRODUCIBLE_BUILD
            PROVIDER
            AUP_SIGNERKEY
            BUILD_TESTS
            STRIP_DEBUG
            SEPARATE_DEBUG)
        set(multiValueArgs UNIT_SCRIPTS)
        cmake_parse_arguments(DCI "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})

        foreach(VAR ${oneValueArgs})
            if(NOT DCI_${VAR} AND DEFINED ENV{DCI_${VAR}})
                set(DCI_${VAR} $ENV{DCI_${VAR}})
            endif()
        endforeach()

        #####################
        if(NOT DCI_SRC_DIR)
            set(DCI_SRC_DIR ${CMAKE_SOURCE_DIR})
        endif()

        #####################
        if(NOT DCI_OUT_DIR)
            set(DCI_OUT_DIR ${CMAKE_CURRENT_BINARY_DIR}/out)
        endif()

        #####################
        if(NOT DCI_SRC_BRANCH)
            find_package(Git)
            if(Git_FOUND)
                execute_process(
                    COMMAND ${GIT_EXECUTABLE} rev-parse --abbrev-ref HEAD
                    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    OUTPUT_VARIABLE DCI_SRC_BRANCH
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            else()
                set(DCI_SRC_BRANCH "")
            endif()
        endif()

        #####################
        if(NOT DCI_SRC_REVISION)
            find_package(Git)
            if(Git_FOUND)
                execute_process(
                    COMMAND ${GIT_EXECUTABLE} rev-parse HEAD
                    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    OUTPUT_VARIABLE DCI_SRC_REVISION
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            else()
                set(DCI_SRC_REVISION "0000000000000000000000000000000000000000")
            endif()
        endif()

        #####################
        if(NOT DCI_SRC_MOMENT)
            find_package(Git)
            if(Git_FOUND)
                execute_process(
                    COMMAND ${GIT_EXECUTABLE} show -s --format=%at ${DCI_SRC_REVISION}
                    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
                    OUTPUT_VARIABLE DCI_SRC_MOMENT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
            else()
                set(DCI_SRC_MOMENT 0)
            endif()
        endif()

        #####################
        if(NOT DCI_PLATFORM_OS)
            set(DCI_PLATFORM_OS ${CMAKE_SYSTEM_NAME})
        endif()

        #####################
        if(NOT DCI_PLATFORM_ARCH)
            set(DCI_PLATFORM_ARCH ${CMAKE_SYSTEM_PROCESSOR})
        endif()

        #####################
        if(NOT DCI_COMPILER)
            set(DCI_COMPILER ${CMAKE_CXX_COMPILER_ID})
        endif()

        #####################
        if(NOT DCI_COMPILER_VERSION)
            set(DCI_COMPILER_VERSION ${CMAKE_CXX_COMPILER_VERSION})
        endif()

        #####################
        if(NOT DCI_COMPILER_OPTIMIZATION)
            string(TOUPPER "CMAKE_CXX_FLAGS_${CMAKE_BUILD_TYPE}" tmp)
            set(DCI_COMPILER_OPTIMIZATION "-O ${CMAKE_CXX_FLAGS} ${${tmp}}")
            string(REGEX REPLACE ".*-O([^ ]*).*" "\\1" DCI_COMPILER_OPTIMIZATION "${DCI_COMPILER_OPTIMIZATION}")
        endif()

        #####################
        if(NOT DCI_AUP_SIGNERKEY)
            set(DCI_AUP_SIGNERKEY 0000000000000000000000000000000000000000000000000000000000000000)
        endif()

        #####################
        if(NOT DEFINED DCI_BUILD_TESTS)
            set(DCI_BUILD_TESTS On)
        endif()

        #####################
        if(NOT DEFINED DCI_STRIP_DEBUG)
            set(DCI_STRIP_DEBUG Off)
        endif()

        #####################
        if(NOT DEFINED DCI_SEPARATE_DEBUG)
            if("Debug" STREQUAL CMAKE_BUILD_TYPE)
                set(DCI_SEPARATE_DEBUG Off)
            else()
                set(DCI_SEPARATE_DEBUG On)
            endif()
        endif()

        foreach(VAR ${oneValueArgs})
            message(STATUS "use DCI_${VAR}=${DCI_${VAR}}")
        endforeach()

        set(DCI_SRC_DIR                 ${DCI_SRC_DIR}                  CACHE PATH   "root sources directory" FORCE)
        set(DCI_OUT_DIR                 ${DCI_OUT_DIR}                  CACHE PATH   "directory for build artifacts" FORCE)
        set(DCI_BE_DIR                  ${DCI_BE_DIR}                   CACHE PATH   "build envitonment directory" FORCE)
        set(DCI_SRC_BRANCH              ${DCI_SRC_BRANCH}               CACHE STRING "sources VCS branch" FORCE)
        set(DCI_SRC_REVISION            ${DCI_SRC_REVISION}             CACHE STRING "sources VCS revision" FORCE)
        set(DCI_SRC_MOMENT              ${DCI_SRC_MOMENT}               CACHE STRING "sources VCS commit moment" FORCE)
        set(DCI_PLATFORM_OS             ${DCI_PLATFORM_OS}              CACHE STRING "platform OS" FORCE)
        set(DCI_PLATFORM_ARCH           ${DCI_PLATFORM_ARCH}            CACHE STRING "platform arch" FORCE)
        set(DCI_COMPILER                ${DCI_COMPILER}                 CACHE STRING "compiler name" FORCE)
        set(DCI_COMPILER_VERSION        ${DCI_COMPILER_VERSION}         CACHE STRING "compiler version" FORCE)
        set(DCI_COMPILER_OPTIMIZATION   ${DCI_COMPILER_OPTIMIZATION}    CACHE STRING "compiler optimization level" FORCE)
        set(DCI_PROVIDER                ${DCI_PROVIDER}                 CACHE STRING "build provider" FORCE)
        set(DCI_AUP_SIGNERKEY           ${DCI_AUP_SIGNERKEY}            CACHE STRING "aup signer private key" FORCE)
        set(DCI_BUILD_TESTS             ${DCI_BUILD_TESTS}              CACHE BOOL   "build tests" FORCE)
        set(DCI_STRIP_DEBUG             ${DCI_STRIP_DEBUG}              CACHE BOOL   "strip debug info" FORCE)
        set(DCI_SEPARATE_DEBUG          ${DCI_SEPARATE_DEBUG}           CACHE BOOL   "separate debug info" FORCE)

        #####################
        dciIntegrationMeta(DIR_MAPPING ${DCI_SRC_DIR} "")
        dciIntegrationMeta(DIR_MAPPING ${DCI_OUT_DIR} "")

        if(WIN32)
            find_program(cygpath_program cygpath)
            if(cygpath_program)
                execute_process(COMMAND sh -c "${cygpath_program} -m -W | xargs -L1 echo -n" OUTPUT_VARIABLE libdirWin)
                dciIntegrationMeta(SYSLIB_IGNORE ${libdirWin}/**)
                execute_process(COMMAND sh -c "${cygpath_program} -m -S | xargs -L1 echo -n" OUTPUT_VARIABLE libdirWin)
                dciIntegrationMeta(SYSLIB_IGNORE ${libdirWin}/**)

                execute_process(COMMAND sh -c "${cygpath_program} -m / | xargs -L1 echo -n" OUTPUT_VARIABLE cygrootWin)

                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}bin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}sbin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}lib/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}libexec/*.dll lib)

                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw32/bin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw32/sbin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw32/lib/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw32/libexec/*.dll lib)

                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw64/bin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw64/sbin/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw64/lib/*.dll lib)
                dciIntegrationMeta(SYSLIB_MAPTO ${cygrootWin}mingw64/libexec/*.dll lib)
            else()
                dciIntegrationMeta(SYSLIB_IGNORE C:/Windows/**)
            endif()

            dciIntegrationMeta(SYSLIB_MAPTO ${DCI_OUT_DIR}/lib/*.dll lib)
            if(DCI_BE_DIR)
                dciIntegrationMeta(SYSLIB_MAPTO ${DCI_BE_DIR}/lib/*.dll lib)
            endif()
        else()
            dciIntegrationMeta(SYSLIB_IGNORE
                /lib*/**
                /usr/lib*/**
                /usr/local/lib*/**)

            dciIntegrationMeta(SYSLIB_MAPTO ${DCI_OUT_DIR}/lib/lib*.so* lib)
            if(DCI_BE_DIR)
                dciIntegrationMeta(SYSLIB_MAPTO ${DCI_BE_DIR}/lib/lib*.so* lib)
            endif()
        endif()

        ############# собрать перечень всех юнитов с зависимостями
        set(dciIntegrationStage1 On)
        set(dciIntegrationStage2 Off)
        set(dciIntegrationStage3 Off)
        foreach(unitScript ${DCI_UNIT_SCRIPTS})
            dciIntegration_includeWithScope(${unitScript})
        endforeach()

        ############# упорядочить по зависимостям
        get_property(unorderedUnits GLOBAL PROPERTY DCI_INTEGRATION_REGISTRY_UNITS)
        set(orderedUnits)

        while(unorderedUnits)
            set(processed)
            set(missingDeps)
            foreach(candidate ${unorderedUnits})
                set(allDepsPresent On)
                get_property(candidateDeps GLOBAL PROPERTY DCI_INTEGRATION_REGISTRY_${candidate}_DEPENDS)
                foreach(candidateDep ${candidateDeps})
                    if(NOT candidateDep IN_LIST orderedUnits)
                        list(APPEND missingDeps ${candidateDep})
                        set(allDepsPresent Off)
                    endif()
                endforeach()

                if(allDepsPresent)
                    list(APPEND processed ${candidate})
                endif()
            endforeach()

            if(NOT processed)
                message(FATAL_ERROR "Unsatisfied dependencies: [${missingDeps}] for next units: [${unorderedUnits}]. Successfully processed units: [${orderedUnits}]")
            endif()
            list(REMOVE_ITEM unorderedUnits ${processed})
            list(APPEND orderedUnits ${processed})
        endwhile()

        ############# подключать упорядоченные
        set(dciIntegrationStage1 Off)
        set(dciIntegrationStage2 On)
        set(dciIntegrationStage3 Off)
        foreach(unit ${orderedUnits})
            message(STATUS "unit '${unit}'")
            get_property(dir GLOBAL PROPERTY DCI_INTEGRATION_REGISTRY_${unit}_SRC_DIR)
            add_subdirectory(${dir})
        endforeach()

        ############# пост процессинг
        set(dciIntegrationStage1 Off)
        set(dciIntegrationStage2 Off)
        set(dciIntegrationStage3 On)
        foreach(unit ${orderedUnits})
            get_property(script GLOBAL PROPERTY DCI_INTEGRATION_REGISTRY_${unit}_CMAKE_SCRIPT)
            dciIntegration_includeWithScope(${script})
        endforeach()

    endfunction()
endif()
