#!/bin/bash

# display all files in the archives folder
#
# as all the archives are at the root of the archives folder
# we just display name of the file, not the path
find archives -type f -exec basename {} \;