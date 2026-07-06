if(CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm64|ARM64|aarch64)$")
  set(CMAKE_SYSTEM_PROCESSOR arm64)
endif()

set(CPACK_PACKAGE_NAME "Neovim")
set(CPACK_PACKAGE_VENDOR "neovim.io")
set(CPACK_PACKAGE_FILE_NAME "nvim")
set(CPACK_PACKAGE_DIRECTORY ${PROJECT_BINARY_DIR})

# From the GitHub About section
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Vim-fork focused on extensibility and usability.")

set(CPACK_PACKAGE_INSTALL_DIRECTORY ${CPACK_PACKAGE_NAME})

# Pull the versions defined with the top level CMakeLists.txt
set(CPACK_PACKAGE_VERSION_MAJOR ${NVIM_VERSION_MAJOR})
set(CPACK_PACKAGE_VERSION_MINOR ${NVIM_VERSION_MINOR})
set(CPACK_PACKAGE_VERSION_PATCH ${NVIM_VERSION_PATCH})

# CPACK_VERBATIM_VARIABLES ensures that the variables prefixed with *CPACK_*
# are correctly passed to the cpack program.
# This should always be set to true.
set(CPACK_VERBATIM_VARIABLES TRUE)

set(CPACK_RESOURCE_FILE_LICENSE "${PROJECT_SOURCE_DIR}/LICENSE.txt")
set(CPACK_RESOURCE_FILE_README ${PROJECT_SOURCE_DIR}/README.md)

set(CPACK_PACKAGE_FILE_NAME "nvim-linux-${CMAKE_SYSTEM_PROCESSOR}")
set(CPACK_GENERATOR TGZ DEB)
set(CPACK_DEBIAN_PACKAGE_NAME "Neovim") # required
set(CPACK_DEBIAN_PACKAGE_MAINTAINER "Neovim.io") # required

# Automatically compute required shared lib dependencies.
# Unfortunately, you "just need to know" that this has a hidden
# dependency on dpkg-shlibdeps whilst using a debian based host.
set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS TRUE)

# Include postinst and prerm scripts for update-alternatives
set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
    "${CMAKE_CURRENT_LIST_DIR}/postinst"
    "${CMAKE_CURRENT_LIST_DIR}/prerm")

# CPack variables are loaded in on the call to include(CPack). If you set
# variables *after* the inclusion, they don't get updated within the CPack
# config. Note that some CPack commands should still be run after it, such
# as cpack_add_component().
include(CPack)
