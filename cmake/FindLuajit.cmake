find_path2(LUAJIT_INCLUDE_DIR luajit.h
          PATH_SUFFIXES luajit-2.1)

list(APPEND LUAJIT_NAMES luajit-5.1)

find_library2(LUAJIT_LIBRARY NAMES ${LUAJIT_NAMES})

find_package_handle_standard_args(Luajit DEFAULT_MSG
                                  LUAJIT_LIBRARY LUAJIT_INCLUDE_DIR)

mark_as_advanced(LUAJIT_INCLUDE_DIR LUAJIT_LIBRARY)
