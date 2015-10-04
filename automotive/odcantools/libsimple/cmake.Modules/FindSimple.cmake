# Simple - CAN data mapping generated by CANDataStructureGenerator.
###########################################################################
# Try to find Simple library.
# The user can specify an additional search path using the CMake variable
# SIMPLE_DIR
# First, search at the specific user path setting.
IF(NOT ("${SIMPLE_DIR}" STREQUAL ""))
    FIND_PATH(SIMPLE_INCLUDE_DIR simple/GeneratedHeaders_Simple.h
                 NAMES simple
                 PATHS ${SIMPLE_DIR}/include
                 NO_DEFAULT_PATH)
    FIND_LIBRARY(SIMPLE_LIBRARY
                 NAMES simple simple-static
                 PATHS ${SIMPLE_DIR}/lib
                 NO_DEFAULT_PATH)
ENDIF()
IF(   ("${SIMPLE_INCLUDE_DIR}" STREQUAL "SIMPLE_INCLUDE_DIR-NOTFOUND")
   OR ("${SIMPLE_DIR}" STREQUAL "") )
    MESSAGE(STATUS "Trying to find Simple in default paths.")
    # If not found, use the system's search paths.
    FIND_PATH(SIMPLE_INCLUDE_DIR simple/GeneratedHeaders_Simple.h
                 NAMES simple
                 PATHS /usr/include
                       /usr/local/include)
    FIND_LIBRARY(SIMPLE_LIBRARY
                 NAMES simple simple-static
                 PATHS /usr/lib
                       /usr/lib64
                       /usr/local/lib
                       /usr/local/lib64)
ENDIF()
IF("${SIMPLE_INCLUDE_DIR}" STREQUAL "")
    MESSAGE(FATAL_ERROR "Could not find Simple library.")
ENDIF()
###########################################################################
# Set linking libraries.
SET(SIMPLE_LIBRARIES ${SIMPLE_LIBRARY})
SET(SIMPLE_INCLUDE_DIRS ${SIMPLE_INCLUDE_DIR})
###########################################################################
INCLUDE(FindPackageHandleStandardArgs)
FIND_PACKAGE_HANDLE_STANDARD_ARGS(LibSimple DEFAULT_MSG
                                  SIMPLE_LIBRARY SIMPLE_INCLUDE_DIR)
MARK_AS_ADVANCED(SIMPLE_INCLUDE_DIR SIMPLE_LIBRARY)
