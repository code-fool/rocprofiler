################################################################################
# Copyright (c) 2018 Advanced Micro Devices, Inc. All rights reserved.
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
################################################################################

cmake_minimum_required ( VERSION 2.8.12 )

## Verbose output.
set ( CMAKE_VERBOSE_MAKEFILE TRUE CACHE BOOL "Verbose Output" FORCE )

## Set module name and project name.
set ( ROCPROFILER_NAME "rocprofiler" )
set ( ROCPROFILER_TARGET "${ROCPROFILER_NAME}64" )
set ( ROCPROFILER_LIBRARY "lib${ROCPROFILER_TARGET}" )
project ( ${ROCPROFILER_NAME} )

# Set default libdir to be "lib" for ROCm
set(CMAKE_INSTALL_LIBDIR "lib" CACHE STRING "Library install directory")
include(GNUInstallDirs)
## Adding default path cmake modules
list ( APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake_modules" )
## Include common cmake modules
include ( utils )
## Set build environment
include ( env )

## Setup the package version.
get_version ( "1.0.0" )
message ( "-- LIB-VERSION: ${VERSION_MAJOR}.${VERSION_MINOR}.${VERSION_PATCH}" )

set ( BUILD_VERSION_MAJOR ${VERSION_MAJOR} )
set ( BUILD_VERSION_MINOR ${VERSION_MINOR} )
set ( BUILD_VERSION_PATCH ${VERSION_PATCH} )
if ( DEFINED VERSION_BUILD AND NOT ${VERSION_BUILD} STREQUAL "" )
  message ( "VERSION BUILD DEFINED ${VERSION_BUILD}" )
  set ( BUILD_VERSION_PATCH "${BUILD_VERSION_PATCH}-${VERSION_BUILD}" )
endif ()
set ( BUILD_VERSION_STRING "${BUILD_VERSION_MAJOR}.${BUILD_VERSION_MINOR}.${BUILD_VERSION_PATCH}" )

set ( LIB_VERSION_MAJOR ${VERSION_MAJOR} )
set ( LIB_VERSION_MINOR ${VERSION_MINOR} )
if ( ${ROCM_PATCH_VERSION} )
    set ( LIB_VERSION_PATCH ${ROCM_PATCH_VERSION} )
else()
    set ( LIB_VERSION_PATCH ${VERSION_PATCH} )
endif()
set ( LIB_VERSION_STRING "${LIB_VERSION_MAJOR}.${LIB_VERSION_MINOR}.${LIB_VERSION_PATCH}" )
message ( "-- LIB-VERSION STRING: ${LIB_VERSION_STRING}" )

## Set target and root/lib/test directory
set ( TARGET_NAME "${ROCPROFILER_TARGET}" )
set ( ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}" )
set ( LIB_DIR "${ROOT_DIR}/src" )
set ( TEST_DIR "${ROOT_DIR}/test" )

## Enable tracing API
if (NOT USE_PROF_API)
  set(USE_PROF_API 1)
endif()

# Protocol header lookup
set(PROF_API_HEADER_NAME prof_protocol.h)
if(USE_PROF_API EQUAL 1)
  find_path(PROF_API_HEADER_DIR ${PROF_API_HEADER_NAME}
        HINTS
          ${PROF_API_HEADER_PATH}
        PATHS
            /opt/rocm/include
        PATH_SUFFIXES
            roctracer/ext
    )
    if(NOT PROF_API_HEADER_DIR)
        MESSAGE(FATAL_ERROR "Profiling API header not found. Tracer integration disabled. Use -DPROF_API_HEADER_PATH=<path to ${PROF_API_HEADER_NAME} header>")
    else()
        add_definitions(-DUSE_PROF_API=1)
        include_directories(${PROF_API_HEADER_DIR})
        MESSAGE(STATUS "Profiling API: ${PROF_API_HEADER_DIR}/${PROF_API_HEADER_NAME}")
    endif()
endif()

## Build library
include ( ${LIB_DIR}/CMakeLists.txt )

## Set the VERSION and SOVERSION values
set_property ( TARGET ${TARGET_NAME} PROPERTY VERSION "${LIB_VERSION_STRING}" )
set_property ( TARGET ${TARGET_NAME} PROPERTY SOVERSION "${LIB_VERSION_MAJOR}" )

## If the library is a release, strip the target library
if ( "${CMAKE_BUILD_TYPE}" STREQUAL release )
  add_custom_command ( TARGET ${ROCPROFILER_TARGET} POST_BUILD COMMAND ${CMAKE_STRIP} *.so )
endif ()

## Build tests
add_subdirectory ( ${TEST_DIR} ${PROJECT_BINARY_DIR}/test )

## Installation and packaging
set ( DEST_NAME ${ROCPROFILER_NAME} )
if ( DEFINED CMAKE_INSTALL_PREFIX )
  get_filename_component ( prefix_name ${CMAKE_INSTALL_PREFIX} NAME )
  get_filename_component ( prefix_dir ${CMAKE_INSTALL_PREFIX} DIRECTORY )
  if ( prefix_name STREQUAL ${DEST_NAME} )
    set ( CMAKE_INSTALL_PREFIX ${prefix_dir} )
  endif ()
endif ()
if ( DEFINED CPACK_PACKAGING_INSTALL_PREFIX )
  get_filename_component ( prefix_name ${CPACK_PACKAGING_INSTALL_PREFIX} NAME )
  get_filename_component ( prefix_dir ${CPACK_PACKAGING_INSTALL_PREFIX} DIRECTORY )
  if ( prefix_name STREQUAL ${DEST_NAME} )
    set ( CPACK_PACKAGING_INSTALL_PREFIX ${prefix_dir} )
  endif ()
else ()
  set ( CPACK_PACKAGING_INSTALL_PREFIX ${CMAKE_INSTALL_PREFIX} )
endif ()
message ( "CMake-install-prefix: ${CMAKE_INSTALL_PREFIX}" )
message ( "CPack-install-prefix: ${CPACK_PACKAGING_INSTALL_PREFIX}" )
message ( "-----------Dest-name: ${DEST_NAME}" )

# Install header and library
install ( TARGETS ${ROCPROFILER_TARGET} LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR} )
install ( FILES
          ${CMAKE_CURRENT_SOURCE_DIR}/inc/rocprofiler.h
          ${CMAKE_CURRENT_SOURCE_DIR}/src/core/activity.h
          DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/${DEST_NAME} )
# rpl_run.sh tblextr.py txt2xml.sh
install ( FILES
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/rpl_run.sh
          DESTINATION ${CMAKE_INSTALL_BINDIR}
          PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE
          RENAME rocprof )

install ( FILES
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/txt2xml.sh
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/merge_traces.sh
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/txt2params.py
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/tblextr.py
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/dform.py
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/mem_manager.py
          ${CMAKE_CURRENT_SOURCE_DIR}/bin/sqlitedb.py
          DESTINATION ${CMAKE_INSTALL_LIBEXECDIR}/${DEST_NAME}
          PERMISSIONS OWNER_READ OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE )
# gfx_metrics.xml metrics.xml
install ( FILES
          ${CMAKE_CURRENT_SOURCE_DIR}/test/tool/metrics.xml
          ${CMAKE_CURRENT_SOURCE_DIR}/test/tool/gfx_metrics.xml
          DESTINATION ${CMAKE_INSTALL_LIBDIR}/${DEST_NAME} )
# librocprof-tool.so
install ( FILES ${PROJECT_BINARY_DIR}/test/librocprof-tool.so DESTINATION ${CMAKE_INSTALL_LIBDIR}/${DEST_NAME} )
install ( FILES ${PROJECT_BINARY_DIR}/test/rocprof-ctrl DESTINATION ${CMAKE_INSTALL_LIBDIR}/${DEST_NAME}
          PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE )

# File reorg Backward compatibility
option(FILE_REORG_BACKWARD_COMPATIBILITY "Enable File Reorg with backward compatibility" ON)
if(FILE_REORG_BACKWARD_COMPATIBILITY)
  include (rocprofiler-backward-compat.cmake)
endif()

## Packaging directives
set ( CPACK_GENERATOR "DEB" "RPM" "TGZ" CACHE STRING "CPACK GENERATOR e.g. DEB;RPM" )
set ( ENABLE_LDCONFIG ON CACHE BOOL "Set library links and caches using ldconfig.")
set ( CPACK_PACKAGE_NAME "${ROCPROFILER_NAME}-dev" )
set ( CPACK_PACKAGE_VENDOR "Advanced Micro Devices, Inc." )
set ( CPACK_PACKAGE_VERSION_MAJOR ${BUILD_VERSION_MAJOR} )
set ( CPACK_PACKAGE_VERSION_MINOR ${BUILD_VERSION_MINOR} )
set ( CPACK_PACKAGE_VERSION_PATCH ${BUILD_VERSION_PATCH} )
set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION_MAJOR}.${CPACK_PACKAGE_VERSION_MINOR}.${CPACK_PACKAGE_VERSION_PATCH}" )
set ( CPACK_PACKAGE_CONTACT "ROCm Profiler Support <dl.ROCm-Profiler.support@amd.com>" )
set ( CPACK_PACKAGE_DESCRIPTION_SUMMARY "ROCPROFILER library for AMD HSA runtime API extension support" )
set ( CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_SOURCE_DIR}/LICENSE" )

# Install license file
install(FILES ${CPACK_RESOURCE_FILE_LICENSE} DESTINATION ${CMAKE_INSTALL_DOCDIR})

if ( DEFINED ENV{ROCM_LIBPATCH_VERSION} )
  set ( CPACK_PACKAGE_VERSION "${CPACK_PACKAGE_VERSION}.$ENV{ROCM_LIBPATCH_VERSION}" )
  message ( "Using CPACK_PACKAGE_VERSION ${CPACK_PACKAGE_VERSION}" )
endif()

## Debian package specific variables
if ( DEFINED ENV{CPACK_DEBIAN_PACKAGE_RELEASE} )
  set ( CPACK_DEBIAN_PACKAGE_RELEASE $ENV{CPACK_DEBIAN_PACKAGE_RELEASE} )
else()
  set ( CPACK_DEBIAN_PACKAGE_RELEASE "local" )
endif()
message ( "Using CPACK_DEBIAN_PACKAGE_RELEASE ${CPACK_DEBIAN_PACKAGE_RELEASE}" )
set ( CPACK_DEBIAN_FILE_NAME "DEB-DEFAULT" )
set ( CPACK_DEBIAN_PACKAGE_DEPENDS "hsa-rocr-dev, rocm-core" )
## Process the Debian install/remove scripts to update the CPACK variables
configure_file ( ${CMAKE_CURRENT_SOURCE_DIR}/DEBIAN/postinst.in DEBIAN/postinst @ONLY )
configure_file ( ${CMAKE_CURRENT_SOURCE_DIR}/DEBIAN/prerm.in DEBIAN/prerm @ONLY )
set ( CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA "DEBIAN/postinst;DEBIAN/prerm" )

## RPM package specific variables
if ( DEFINED ENV{CPACK_RPM_PACKAGE_RELEASE} )
  set ( CPACK_RPM_PACKAGE_RELEASE $ENV{CPACK_RPM_PACKAGE_RELEASE} )
else()
  set ( CPACK_RPM_PACKAGE_RELEASE "local" )
endif()
message ( "Using CPACK_RPM_PACKAGE_RELEASE ${CPACK_RPM_PACKAGE_RELEASE}" )

set( CPACK_RPM_PACKAGE_LICENSE "MIT" )

## 'dist' breaks manual builds on debian systems due to empty Provides
execute_process( COMMAND rpm --eval %{?dist}
                 RESULT_VARIABLE PROC_RESULT
                 OUTPUT_VARIABLE EVAL_RESULT
                 OUTPUT_STRIP_TRAILING_WHITESPACE )
message("RESULT_VARIABLE ${PROC_RESULT} OUTPUT_VARIABLE: ${EVAL_RESULT}")

if ( PROC_RESULT EQUAL "0" AND NOT EVAL_RESULT STREQUAL "" )
  string ( APPEND CPACK_RPM_PACKAGE_RELEASE "%{?dist}" )
endif()
set ( CPACK_RPM_FILE_NAME "RPM-DEFAULT" )
set ( CPACK_RPM_PACKAGE_REQUIRES "hsa-rocr-dev, rocm-core" )
## Process the Rpm install/remove scripts to update the CPACK variables
configure_file ( "${CMAKE_CURRENT_SOURCE_DIR}/RPM/post.in" RPM/post @ONLY )
configure_file ( "${CMAKE_CURRENT_SOURCE_DIR}/RPM/postun.in" RPM/postun @ONLY )

set ( CPACK_RPM_POST_INSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/RPM/post" )
set ( CPACK_RPM_POST_UNINSTALL_SCRIPT_FILE "${CMAKE_CURRENT_BINARY_DIR}/RPM/postun" )
# Remove dependency on rocm-core if -DROCM_DEP_ROCMCORE=ON not given to cmake
if(NOT ROCM_DEP_ROCMCORE)
    string(REGEX REPLACE ",? ?rocm-core" "" CPACK_RPM_PACKAGE_REQUIRES ${CPACK_RPM_PACKAGE_REQUIRES})
    string(REGEX REPLACE ",? ?rocm-core" "" CPACK_DEBIAN_PACKAGE_DEPENDS ${CPACK_DEBIAN_PACKAGE_DEPENDS})
endif()

include ( CPack )
