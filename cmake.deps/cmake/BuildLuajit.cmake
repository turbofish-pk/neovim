function(BuildLuajit)
  cmake_parse_arguments(_luajit
    ""
    ""
    "CONFIGURE_COMMAND;BUILD_COMMAND;INSTALL_COMMAND;DEPENDS"
    ${ARGN})

  get_externalproject_options(luajit ${DEPS_IGNORE_SHA})
  ExternalProject_Add(luajit
    DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/luajit
    CONFIGURE_COMMAND "${_luajit_CONFIGURE_COMMAND}"
    BUILD_IN_SOURCE 1
    BUILD_COMMAND "${_luajit_BUILD_COMMAND}"
    INSTALL_COMMAND "${_luajit_INSTALL_COMMAND}"
    DEPENDS "${_luajit_DEPENDS}"
    ${EXTERNALPROJECT_OPTIONS})
endfunction()

check_c_compiler_flag(-fno-stack-check HAS_NO_STACK_CHECK)

set(NO_STACK_CHECK "")

set(AMD64_ABI "")

set(BUILDCMD_UNIX ${MAKE_PRG} -j CFLAGS=-fPIC
                              CFLAGS+=-DLUA_USE_APICHECK
                              CFLAGS+=-funwind-tables
                              ${NO_STACK_CHECK}
                              ${AMD64_ABI}
                              CCDEBUG+=-g
                              Q=)


BuildLuajit(INSTALL_COMMAND ${BUILDCMD_UNIX}
    CC=${DEPS_C_COMPILER} PREFIX=${DEPS_INSTALL_DIR}
    ${DEPLOYMENT_TARGET} install)
