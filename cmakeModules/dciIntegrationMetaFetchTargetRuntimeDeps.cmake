include(GetPrerequisites)
get_prerequisites("${f}" deps 0 1 "" "")

set(adeps)
foreach(dep ${deps})
    get_filename_component(adep ${dep} ABSOLUTE)
    list(APPEND adeps ${adep})
endforeach()

execute_process(COMMAND ${CMAKE_COMMAND} -E echo "UNIT[${u}] TARGET[${t}] TARGET_DEPS[${adeps}]")
