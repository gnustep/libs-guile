#!/bin/sh

obj="obj/${GNUSTEP_HOST_CPU}/${GNUSTEP_HOST_OS}/${LIBRARY_COMBO}"

if test -x "$obj/test_skit"; then
  cd $obj
  LD_LIBRARY_PATH=.:${LD_LIBRARY_PATH}
  export LD_LIBRARY_PATH
  ./test_skit
fi

