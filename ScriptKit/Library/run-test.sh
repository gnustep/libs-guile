#!/bin/sh

shared_obj="shared_obj/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"
shared_debug_obj="shared_debug_obj/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"

static_debug_obj="static_debug_obj/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"
static_obj="static_obj/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"

if test -x "$shared_obj/test_skit"; then
  cd $shared_obj
  LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
  ./test_skit
elif test -x "$shared_debug_obj/test_skit"; then
  cd $shared_debug_obj
  LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
  ./test_skit
elif test -x "$static_debug_obj/test_skit"; then
  cd $static_debug_obj
  ./test_skit
elif test -x "$static_obj/test_skit"; then
  cd $static_obj
  ./test_skit
fi

