#!/bin/bash
#
# =================================
#
# RELEASE VERSION 1.1
#
# GCC ARM64 UEFI Bootloader Mac Cleanup Script
#
# by KNNSpeed
#
# =================================
#

set +v

#
# set +v disables displaying all of the code you see here in the command line
#

echo
echo "Running cleanup procedures; press CTRL+C to exit now. Otherwise..."
read -n1 -r -p "Press any key to continue..."

#
# Move into the Backend folder, where all the magic happens
#

CurDir=$PWD

cd ../Backend

#
# Delete generated files
#

rm BOOTAA64.EFI
rm output.map
rm objects.list

while read f; do
  rm ${f%.*}.o
  rm ${f%.*}.d
done < $CurDir/c_files_mac.txt

#
# Move into startup folder
#

cd $CurDir/startup

#
# Delete compiled object files
#

rm *.o
rm *.d

#
# Move into user source directory
#

cd $CurDir/src

#
# Delete compiled object files
#

rm *.o
rm *.d

#
# Return to folder started from
#

cd $CurDir

#
# Display completion message and exit
#

echo
echo "Done! All clean."
echo
