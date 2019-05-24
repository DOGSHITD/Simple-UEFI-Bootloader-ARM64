# Simple UEFI Bootloader ARM64
A UEFI bootloader for bare-metal ARM64 applications. Looking for the x86-64 version? Get it here: https://github.com/KNNSpeed/Simple-UEFI-Bootloader  

**Version 2.2**

This bootloader is like a much simpler version of GRUB/Elilo/Windows Boot Manager, but mainly meant for writing your own operating system-less ARM64 programs, kernels, or full operating systems. It supports Windows, Linux, and Mac executable binaries (PE32+, 64-bit ELF, and 64-bit Mach-O formats). It also supports... Well, I'll let you figure that one out yourself. ;)

***See the "Releases" tab for usage information and downloads, and please post any bugs, feature requests, etc. in "Issues."***  

A minimal, cross-platform development environment for making your own programs, kernels, and/or operating systems that use this bootloader can be found here (demo binary programs are also there): https://github.com/KNNSpeed/Simple-Kernel-ARM64  

## Bootloader Features  

- UEFI 2.x support
- Loads and executes kernels compiled as Aarch64-native Windows PE32+, Linux 64-bit ELF, and Mac OS 64-bit Mach-O files ***(1)***
- Passes load options from a user-generated text file directly to kernel files
- Multiple bootloader instances can coexist on one system to load separate kernel files, complete with their own load options, all using the system's native UEFI boot manager to select between them
- Multi-GPU framebuffer support ***(2)***
- ACPI support
- The ability to get the full system memory map to do whatever you want with it
- Fits on a floppy diskette, and some systems can actually boot it from a floppy
- Minimal UEFI development environment tuned for Windows, Mac, and Linux included in repository ***(3)***

***(1)*** *See the Simple-Kernel-ARM64 repository for proper compilation options for each operating system.*  
***(2)*** *This typically only works with one monitor per GPU due to how most GPU firmwares are implemented.*  
***(3)*** *See the below "How to Build from Source" section for complete compilation instructions for each platform, and then all you need to do is put your code in "src" and "inc" in place of mine. Once compiled, your program can be run in the same way as described in "Releases" using an ARM64-based, UEFI-supporting VM or on actual hardware.*  

## Target System Requirements  

- ARM64 architecture with UEFI support ***(1)***  
- Secure Boot must be disabled (or unimplemented)  
- More than 4GB RAM (though it seems to work OK with less, e.g. Raspberry Pi 3B+ with only 1GB)  
- A graphics card (Intel, AMD, NVidia, Broadcom, etc.) **with UEFI GOP support**  
- A keyboard  

The earliest GPUs with UEFI GOP support were released around the Radeon HD 7xxx series (~2011). Anything that age or newer should have UEFI GOP support, though older models, like early 7970s, required owners to contact GPU vendors to get UEFI-compatible firmware. On Windows, you can check if your graphics card(s) have UEFI GOP support by downloading TechPowerUp's GPU-Z utility and seeing whether or not the UEFI checkbox is checked. If it is, you're all set! Generally an ARM64 board with UEFI has a built-in GPU with GOP support, so you'd really only need Windows to check PCI-Express devices.   

*NOTE: You need to check each graphics card if there is a mix, as you will only be able to use the ones with UEFI GOP support. Per the system requirements above, you need at least one compliant device.*  

***(1)*** *ARM64 is also called Aarch64, or sometimes armv8.x-a, where 'x' is the revision. For example, the CPUs used in the Raspberry Pi 3 family (and newer) or the NVidia Tegra family. Raspberry Pis need this UEFI package to get UEFI support, which has ready-to-go binaries in "Binary/prebuilt": https://github.com/andreiw/RaspberryPiPkg (NOTE: be sure to disable the emulated video modes in the firmware menu--I've found they tend to cause more problems than they solve for this application. If the screen has EDID issues with the Raspi, please just use another screen.)*  

## License and Crediting  

Please see the LICENSE file for information on all licenses covering code created for and used in this project.  

***TL;DR:***  

If you don't give credit to this project, per the license you aren't allowed to do anything with any of its source code that isn't already covered by an existing license (in other words, my license covers most of the code I wrote). That's pretty much it, and why it's "almost" PD, or "PD with Credit" if I have to give it a nickname: there's no restriction on what it gets used for as long as the license is satisfied. If you have any issues, feature requests, etc. please post in "Issues" so it can be attended to/fixed.  

Note that each of these files already has appropriate crediting at the top, so you could just leave what's already there to satisfy the terms. You really should see the license file for complete information, though (it's short!!).  

## Usage

### How to Use

1. **[External Drive, ignore step 2]** On an external FAT or FAT32 drive (USB, floppy, whatever), make an "EFI" folder, and inside that make a "BOOT" folder. Put the desired bootloader binary in the BOOT folder, and name the binary BOOTAA64.EFI. This is just standard booting procedure: a FAT32 volume containing \\EFI\\BOOT\\BOOTAA64.EFI is defined by specification to be the default UEFI boot file for that drive on ARM64.

2. **[Internal Drive, ignore step 1]** Put this program anywhere you want on the EFI System Partition and add it to your UEFI firmware as a boot option. The default bootable file that UEFI firmware looks for is BOOTAA64.EFI in the directory \\EFI\\BOOT\\, so you could just rename the bootloader file accordingly and put it at that location to boot it automatically.  

3. Put the bare metal program or kernel somewhere on the same FAT32 drive or EFI System Partition.

4. Make a file called **Kernel64.txt**--this should be stored **in the same folder as the bootloader itself.** See the next section for how to properly format this file.

5. Boot your machine, and enter the boot device menu. This is commonly achieved by pressing a key like F10 or F12 at the boot logo. Select the option **UEFI ... [your drive or boot entry containing the bootloader and kernel]** -- the name varies depending on the type of drive used and the motherboard model.

    NOTE: You should be sure your system supports booting from external media if you are using a USB drive, and ensure that the system is not configured to boot in Legacy or BIOS mode (i.e. it has UEFI booting enabled). Also, spaces in file/folder names are not allowed.

That's it! If your kernel file's entry point function is something like **main_function(LOADER_PARAMS * LP)**, it should load after you select how you want your graphics output device(s) configured. See https://github.com/KNNSpeed/Simple-Kernel-ARM64 for an example, including proper compilation options.

### Kernel64.txt Format and Contents

Kernel64.txt should be stored in UTF-16 format in the same directory as the boot loader on the EFI system partition. Windows Notepad and Wordpad can save text files in this format (select "Unicode Text Document" or "UTF-16 LE" as the encoding format in the "Save As" dialog). Linux users can use gedit or xed, saving as a .txt file with UTF-16 encoding. Also, it does not matter if the file uses Windows (CRLF) or Unix (LF) line endings, but the file does need a 2-byte identification Byte Order Mark (BOM). Don't worry too much about the BOM; it gets added automatically by all of the aforementioned editors when saving with the correct encoding.  

The contents of the text file are simple: only three lines are needed. The first line should be the filename and location of the kernel to be booted relative to the root of the EFI system partition, e.g. \\EFI\\Kernel1\\MyKernel.64 or \\Socks\\Bubbles.ReallyLongFileExtension (do not use spaces or special characters in file/folder names), and the second line is the string of load options to be passed to the kernel, e.g. "root=/dev/nvme0n1p5 initrd=\\\EFI\\\ubuntu\\\initrd.img ro rootfstype=ext4 debug ignore_loglevel libata.force=dump_id crashkernel=384M-:128M quiet splash acpi_rev_override=1 acpi_osi=Linux" (without quotes! -- note this example is just a random string of Linux arguments). The third line should be blank--and make sure there is a third line, as this program expects a line break to denote the end of the kernel arguments.**  

That's it!  

 ** Technically you could use the remainder of the text file to contain an actual text document. You could put this info in there if you wanted, or your favorite song lyrics, though the smaller the text file the faster it is to load.  

### Booting Multiple Kernels

A copy of the bootloader and a kernel64.txt file is required for every kernel in a multi-use situation. Recommended practice for booting multiple kernels is to make a folder for each kernel, and each folder should contain its own bootloader, kernel64.txt, and kernel file. The method to boot multiple kernel files varies by machine: generally there is a firmware boot menu accessed by F10, F11, F12, etc. at power-on, and entries can be added to this menu in the UEFI firmware setup (accessed by F2, DEL, etc. at power-on). Some machines may need boot entries added by the Linux program efibootmgr, and some might only work with one UEFI application stored in the folder \\EFI\\BOOT\\ with the filename BOOTAA64.EFI. In more inconvenient cases like these, it is probably easier to just boot from FAT32-formatted USB drives using the same \\EFI\\BOOT\\BOOTAA64.EFI convention. If the UEFI firmware allows booting from them, CDs/DVDs and FAT/FAT16-formatted drives (like floppies) can be used with the same file/folder naming scheme, too.

## How to Build from Source  

Requires GCC 7.1.0 or later and Binutils 2.29.1 or later. I cannot make any guarantees whatsoever for earlier versions, especially with the number of compilation and linking flags used. I'd personally recommend using the same version as used for Simple-Kernel-ARM64, as these two projects are designed to share the same compiler folder.  

***Windows:***  
1. Download and extract or clone this repository into a dedicated folder, preferably somewhere easy like C:\BareMetalAA64

2. Decide whether you want to use the Windows Subsystem for Linux (use step 2a) or just plain Windows (use step 2b). If you are using Windows on ARM64, use step 2c.

    2a. If you want to use the Windows Subsystem for Linux, follow the Linux instructions below and make sure you *untar the GCC archive into a case-sensitive folder* per here (NOTE: you'll need Windows 10 1809 or later and you can just make Backend case-sensitive): https://devblogs.microsoft.com/commandline/improved-per-directory-case-sensitivity-support-in-wsl/

    2b. If you want to use plain Windows, download MinGW-w64 "llvm-mingw-[build date]-x86_64" from https://github.com/mstorsjo/llvm-mingw/releases and continue following these Windows instructions.

    2c. If you are using Windows on ARM64, download MinGW-w64 "llvm-mingw-[build date]-aarch64" from https://github.com/mstorsjo/llvm-mingw/releases and continue following these Windows instructions.

3. Extract the "llvm-mingw" folder from the archive into the "Backend" folder. As a check, "Backend/llvm-mingw/bin" will exist if done correctly. If instead you see a folder that's named something like "llvm-mingw-20190124-x86_64," check inside of it for the "llvm-mingw" folder and fish it out, otherwise you'll have to modify Compile.bat's "GCC_FOLDER_NAME" parameter to point to it relative to the Backend folder.

4. Open Windows PowerShell or the Command Prompt in the "Simple-UEFI-Bootloader-ARM64" folder and type ".\Compile.bat"

    *That's it! It should compile and a binary called "BOOTAA64.EFI" will be output into the "Backend" folder.*

***Mac:***
1. Download and extract or clone this repository into a dedicated folder, preferably somewhere easy like ~/BareMetalAA64

2. Install the latest MacPorts: https://www.macports.org/

3. In Terminal, get the cmake package via "sudo port install cmake"

4. After cmake is installed, clone the repository https://github.com/mstorsjo/llvm-mingw somewhere and "cd" into it. Run "./build-all.sh llvm-mingw-mac" (without quotes). If you get an error about ucnv_err.h "file not found" (at around 9%), follow step 3a. Otherwise, it should build.

    3a. In Finder, navigate to llvm-mingw/llvm/lib/WindowsManifest/ and open CMakeLists.txt. At the top of the file, add, without quotes, "include_directories(/opt/local/include)" and save the file. You will also need to modify the CMakeLists.txt file at llvm-mingw/llvm/tools/clang/tools/c-index-test/ in the same way, or else you'll get the same error at 100% of the llvm build stage. Re-run ./build-all.sh [output directory] as per before, and it will compile now.

5. Once that's done building, copy the newly created "llvm-mingw-mac" directory (it'll be inside "llvm-mingw") into Backend. Its OK to delete the "llvm-mingw" folder after this; it'll be several GBs at this point.

6. Finally, open Terminal in the "Simple-UEFI-Bootloader-ARM64" folder and run "./Compile-Mac.sh"

    *That's it! It should compile and a binary called "BOOTAA64.EFI" will be output into the "Backend" folder.*

***Linux:***  
1. Download and extract or clone this repository into a dedicated folder, preferably somewhere easy like ~/BareMetalAA64

2. If you are compiling from an x86_64 machine, download GCC for ARM-A devices from here, under the "x86_64 hosted cross compilers" section -- *not the i686 section!!*: https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads (Use "AArch64 GNU/Linux target (aarch64-linux-gnu)" or "AArch64 ELF bare-metal target (aarch64-elf)" -- they both work.)

    2a. If instead you are compiling from an ARM64 machine, don't use these instructions and follow the directions for Linux here: https://github.com/KNNSpeed/Simple-UEFI-Bootloader (with the following 3 differences: 1). Use *./Compile-ARM64.sh* instead of ./Compile.sh. 2). The output binary will be *"BOOTAA64.EFI"* instead of "BOOTX64.EFI." 3). If you can't use steps 2a, b, & c, you'll need to use *"./configure -v --build=aarch64-linux-gnu --host=aarch64-linux-gnu --target=aarch64-linux-gnu --enable-fix-cortex-a53-835769 --enable-fix-cortex-a53-843419 --prefix=$PWD/../gcc-linux-arm64 --enable-checking=release --enable-languages=c --disable-multilib"* for the ./configure line. You can also use --target=aarch64-elf in the configure line instead of --target=aarch64-linux-gnu if you want; they'll both work. Note that the GCC folder will be called *"gcc-linux-arm64"* instead of "gcc-8" in this case).

3. Extract the downloaded archive into "Backend." If you copy the downloaded archive into Backend and run the command "tar -xf [archive name]" while Terminal is in the Backend folder, it will come out right. As a check, "Backend/[archive name]/bin" will exist if done correctly.

4. Open Compile.sh in an editor of your choice (nano, gedit, vim, etc.) and set the GCC_FOLDER_NAME variable at the top to be the name of the folder inside Backend you just made (e.g. "gcc-arm-8.3-2019.03-x86_64-aarch64-linux-gnu" or "gcc-arm-8.3-2019.03-x86_64-aarch64-elf" -- with no slashes or quotes).

5. Still in Compile.sh, set the GCC_PREFIX variable at the top (it's right under GCC_FOLDER_NAME) to "aarch64-elf" or "aarch64-linux-gnu" (no quotes), depending on which one you are using.

6. Now set the terminal to the Simple-UEFI-Bootloader-ARM64 folder and run "./Compile.sh"

    *That's it! It should compile and a binary called "BOOTAA64.EFI" will be output into the "Backend" folder.*

## Change Log

V2.2 (5/24/2019) - In Loader Params, the RSDP pointer has been changed to the Configuration Table pointer. This allows programs to use all available configuration tables, not just the ACPI ones. Also changed some of the initial print statements, added Number_of_ConfigTables and UEFI_Version to the loader parameters, and added a 90 second menu timer for the multi-GPU graphics device selection and the single GPU resolution selection menus. Also made graphics mode selection more consistent when using characters to denote modes >10. There's also what looks like a "startup screen" now, some of which was always there despite only being viewable on standard resolutions higher than 1024x768. This not-really-new screen has a (stoppable) 10-second timeout so that it doesn't really get in the way of anything. Oh, and those pesky Wsign-compare warnings when compiling debug binaries are gone now (switched to using ~0ULL, which really should've been used from the get-go instead of -1).  

V2.1 (4/24/2019) - Fixed a regression introduced in V1.4 (it isn't a bug with this code, it's a widespread issue with UEFI firmware): The ClearScreen function, which is just supposed to clear the screen to whatever the background color is and reset the cursor to (0,0), behaves wildly differently depending on firmware. Some video drivers don't reset cursor position, some do a whole video mode reset and set the video mode to 0, effectively destroying any other mode previously set, and some actually work correctly. I forgot about this and left calls to ClearScreen in, but they're gone now. An extra newline now takes the place of where ClearScreen use to be used. Also updated backend GNU-EFI to use the UEFI 2.x OpenProtocol() function instead of the now-archaic EFI 1.0 HandleProtocol() function (this loader was never intended for EFI 1.x devices anyway).

V2.0 (4/23/2019) - Added the need for Kernel64.txt in the same style as Kernelcmd.txt from V2.x of https://github.com/KNNSpeed/UEFI-Stub-Loader. With this major change, kernels don't need to be named Kernel64 anymore, a string of load options can be passed to kernels, and multi-booting on one machine is supported by way of using the machine's built-in UEFI boot manager. How to format Kernel64.txt has been added to both this document and the usage information in "Releases." Also added new loader params: ESP_Root_Device_Path, ESP_Root_Size, Kernel_Path, Kernel_Path_Size, Kernel_Options, Kernel_Options_Size.

V1.5 (4/10/2019) - Updated graphics output names to blacklist known erroneous drivers from claiming to be graphics devices, added loader params: Bootloader_MajorVersion, Bootloader_MinorVersion, Kernel_BaseAddress, Kernel_Pages, Memory_Map_Descriptor_Version, created ARM64 version (https://github.com/KNNSpeed/Simple-UEFI-Bootloader-ARM64).

V1.4 (4/1/2019) - Major updates to menu display (should work better with lower resolutions), graphics out device names now work, fixed underlying cause of the need for the "weird memory hack" (it's still useful for debugging, though it's now disabled when compiling non-debug versions). Updates from here on out will likely be to the Loader Params as needed by Simple-Kernel; this release should hopefully iron out the last of any kinks. It runs a little faster, now, too!

V1.3 (2/21/2019) - Added Memory_Map_Size and Memory_Map_Descriptor_Size to loader parameters. This is to prevent having to rely on potentially inconsistent techniques (particularly in really unlucky corner cases) to get the memory map size in the kernel. Also updated GNU-EFI backend to 3.0.9, updated the README format to be easier to follow, updated the license TL;DR to be shorter and clearer (i.e. made it actually a TL;DR)--note that the license terms have not changed, only the wording in the TL;DR.

V1.2 (1/8/2018) - Resolved a major issue that prevented larger SYSV ABI kernels (ELF, Mach-O) from running. As far as I can tell everything works properly and completely now.

V1.1 (1/7/2018) - Code organization and build system uploaded. Also fixed bugs.

V1.0 (1/5/2018) - Initial release. Fully featured for PE32+ images.

## Acknowledgements  

- [Nigel Croxon](https://sourceforge.net/u/noxorc/profile/) for [GNU-EFI](https://sourceforge.net/projects/gnu-efi/)
- [UEFI Forum](http://www.uefi.org/) for the [UEFI Specification Version 2.7 (Errata A)](http://www.uefi.org/sites/default/files/resources/UEFI%20Spec%202_7_A%20Sept%206.pdf), as well as for [previous UEFI 2.x specifications](http://www.uefi.org/specifications)
- [Andrey Warkentin](https://github.com/andreiw) for [RaspberryPiPkg](https://github.com/andreiw/RaspberryPiPkg)
- [OSDev Wiki](http://wiki.osdev.org/Main_Page) for its wealth of available information
- [PhoenixWiki](http://wiki.phoenix.com/wiki/index.php/Category:UEFI) for very handy documentation on UEFI functions
- [Matthew Garrett](https://mjg59.dreamwidth.org/) for detailed information about UEFI firmware behavior (e.g. ["Getting started with UEFI development"](https://mjg59.dreamwidth.org/18773.html?thread=767573))
- [The GNU project](https://www.gnu.org/home.en.html) for [GCC](https://gcc.gnu.org/), a fantastic and versatile compiler, and [Binutils](https://www.gnu.org/software/binutils/), equally fantastic binary utilities
- [Martin Storsjo](https://github.com/mstorsjo) for implementing ARM64 PE support in Clang/LLVM and MinGW-w64 and [combining the two, enabling the creation of native Windows on ARM64 and ARM64 UEFI PE binaries](https://github.com/mstorsjo/llvm-mingw)
- [Matt Pietrek](https://blogs.msdn.microsoft.com/matt_pietrek/) for [extensive documentation on the Windows PE file format](https://msdn.microsoft.com/en-us/library/ms809762.aspx)
- Tool Interface Standard for [extensive documentation on ELF files](https://www.uclibc.org/docs/elf.pdf)
- [Apple Inc.](https://www.apple.com/) for [documentation on Mach-O files](https://developer.apple.com/library/content/documentation/DeveloperTools/Conceptual/MachOTopics/0-Introduction/introduction.html)
- [Low Level Bits](https://lowlevelbits.org/) for [further documentation on Mach-O files](https://lowlevelbits.org/parsing-mach-o-files/)
- [cyrozap](https://github.com/cyrozap) for noting ambiguity in licensing terms
