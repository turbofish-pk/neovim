get_externalproject_options(treesitter ${DEPS_IGNORE_SHA})
ExternalProject_Add(treesitter
  DOWNLOAD_DIR ${DEPS_DOWNLOAD_DIR}/treesitter
  CMAKE_ARGS ${DEPS_CMAKE_ARGS} ${TREESITTER_ARGS}
  ${EXTERNALPROJECT_OPTIONS})
