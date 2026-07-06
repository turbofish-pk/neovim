# This is not meant to be included by the top-level.
cmake_minimum_required(VERSION 4.2)
project(NVIM_DEPS C)

if(POLICY CMP0135)
    cmake_policy(SET CMP0135 NEW)
endif()

# Point CMake at any custom modules we may ship
list(APPEND CMAKE_MODULE_PATH "${PROJECT_SOURCE_DIR}/cmake" "${PROJECT_SOURCE_DIR}/../cmake")

include(CheckCCompilerFlag)
include(ExternalProject)
include(FindPackageHandleStandardArgs)

include(Deps)
include(Find)
include(Util)

#-------------------------------------------------------------------------------
# User settings
#-------------------------------------------------------------------------------

if(NOT DEPS_IGNORE_SHA)
    set(DEPS_IGNORE_SHA FALSE)
endif()

# Options
option(USE_BUNDLED "Use bundled dependencies." ON)

option(USE_BUNDLED_LIBUV "Use the bundled libuv." ${USE_BUNDLED})
option(USE_BUNDLED_LPEG "Use the bundled lpeg." ${USE_BUNDLED})
# PUC Lua is only used for tests, unless explicitly requested.
option(USE_BUNDLED_LUA "Use the bundled version of lua." OFF)
option(USE_BUNDLED_LUAJIT "Use the bundled version of luajit." ${USE_BUNDLED})
option(USE_BUNDLED_LUV "Use the bundled version of luv." ${USE_BUNDLED})
option(USE_BUNDLED_TS "Use the bundled treesitter runtime." ${USE_BUNDLED})
option(USE_BUNDLED_TS_PARSERS "Use the bundled treesitter parsers." ${USE_BUNDLED})
option(USE_BUNDLED_UNIBILIUM "Use the bundled unibilium." ${USE_BUNDLED})
option(USE_BUNDLED_UTF8PROC "Use the bundled utf8proc library." ${USE_BUNDLED})

option(USE_BUNDLED_GETTEXT "Use the bundled version of gettext." OFF)
option(USE_BUNDLED_LIBICONV "Use the bundled version of libiconv." OFF)

option(USE_EXISTING_SRC_DIR "Skip download of deps sources in case of existing source directory." OFF)

set_default_buildtype(Release)
get_property(isMultiConfig GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)

if (NOT DEFINED DEPS_CMAKE_ARGS)
    set(DEPS_CMAKE_ARGS)
endif()

if(NOT isMultiConfig)
    list(APPEND DEPS_CMAKE_ARGS -D CMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE})
endif()

set(DEFAULT_MAKE_CFLAGS CFLAGS+=-g)

check_c_compiler_flag(-Og HAS_OG_FLAG)
if(HAS_OG_FLAG)
    set(DEFAULT_MAKE_CFLAGS CFLAGS+=-Og ${DEFAULT_MAKE_CFLAGS})
endif()

# Always pass the toolchain if it exists
if(CMAKE_TOOLCHAIN_FILE)
    list(APPEND DEPS_CMAKE_ARGS
    -D CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE}
  )
endif()

set(DEPS_INCLUDE_FLAGS "-I\"${DEPS_INSTALL_DIR}/include\" -I\"${DEPS_INSTALL_DIR}/include/luajit-2.1\"")

if(USE_BUNDLED_LUAJIT)
    set(LUA_ENGINE LuaJit)
else()
    find_package(Luajit)
    if(LUAJIT_FOUND)
        set(LUA_ENGINE LuaJit)
        string(APPEND DEPS_INCLUDE_FLAGS " -I\"${LUAJIT_INCLUDE_DIR}\"")
    else()
        message(FATAL_ERROR "Could not find system lua or luajit")
    endif()
endif()

if(USE_BUNDLED_UNIBILIUM)
    include(BuildUnibilium)
endif()

if(USE_BUNDLED_LIBUV)
    include(BuildLibuv)
endif()

if(USE_BUNDLED_LUAJIT)
    include(BuildLuajit)
endif()

if(USE_BUNDLED_LUV)
    include(BuildLuv)
endif()

if(USE_BUNDLED_LPEG)
    include(BuildLpeg)
endif()

if(USE_BUNDLED_GETTEXT)
    include(BuildGettext)
endif()

if(USE_BUNDLED_LIBICONV)
    include(BuildLibiconv)
endif()

if(USE_BUNDLED_TS_PARSERS)
    include(BuildTreesitterParsers)
endif()

if(USE_BUNDLED_TS)
    include(BuildTreesitter)
endif()

if(USE_BUNDLED_UTF8PROC)
    include(BuildUTF8proc)
endif()
