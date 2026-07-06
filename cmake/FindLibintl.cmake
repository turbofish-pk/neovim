include(CheckCSourceCompiles)
include(CheckVariableExists)

find_path(LIBINTL_INCLUDE_DIR
    NAMES libintl.h
    PATH_SUFFIXES gettext
)

find_library(LIBINTL_LIBRARY
    NAMES intl libintl
)

if (LIBINTL_INCLUDE_DIR)
  list(APPEND CMAKE_REQUIRED_INCLUDES "${LIBINTL_INCLUDE_DIR}")
endif()
# On some systems (linux+glibc) libintl is passively available.
# So only specify the library if one was found.
if (LIBINTL_LIBRARY)
  list(APPEND CMAKE_REQUIRED_LIBRARIES "${LIBINTL_LIBRARY}")
endif()

get_filename_component(LibIntl_EXT "${LIBINTL_LIBRARY}" EXT)

check_c_source_compiles("
#include <libintl.h>

int main(int argc, char** argv) {
  gettext(\"foo\");
  ngettext(\"foo\", \"bar\", 1);
  bindtextdomain(\"foo\", \"bar\");
  bind_textdomain_codeset(\"foo\", \"bar\");
  textdomain(\"foo\");
}" HAVE_WORKING_LIBINTL)

if (LibIntl_STATIC)
  list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES  "${ICONV_LIBRARY}" "${CoreFoundation_FRAMEWORK}")
endif()
if (LIBINTL_INCLUDE_DIR)
  list(REMOVE_ITEM CMAKE_REQUIRED_INCLUDES "${LIBINTL_INCLUDE_DIR}")
endif()
if (LIBINTL_LIBRARY)
  list(REMOVE_ITEM CMAKE_REQUIRED_LIBRARIES "${LIBINTL_LIBRARY}")
endif()

set(REQUIRED_VARIABLES LIBINTL_LIBRARY LIBINTL_INCLUDE_DIR)
if (HAVE_WORKING_LIBINTL)
  # On some systems (linux+glibc) libintl is passively available.
  # If HAVE_WORKING_LIBINTL then we consider the requirement satisfied.
  unset(REQUIRED_VARIABLES)

  check_variable_exists(_nl_msg_cat_cntr HAVE_NL_MSG_CAT_CNTR)
endif()

find_package_handle_standard_args(Libintl DEFAULT_MSG
  ${REQUIRED_VARIABLES})
mark_as_advanced(LIBINTL_LIBRARY LIBINTL_INCLUDE_DIR)

add_library(libintl INTERFACE)
target_include_directories(libintl SYSTEM BEFORE INTERFACE ${LIBINTL_INCLUDE_DIR})
if (LIBINTL_LIBRARY)
  target_link_libraries(libintl INTERFACE ${LIBINTL_LIBRARY})
endif()
