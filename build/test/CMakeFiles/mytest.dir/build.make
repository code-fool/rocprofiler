# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.24

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:

#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:

# Disable VCS-based implicit rules.
% : %,v

# Disable VCS-based implicit rules.
% : RCS/%

# Disable VCS-based implicit rules.
% : RCS/%,v

# Disable VCS-based implicit rules.
% : SCCS/s.%

# Disable VCS-based implicit rules.
% : s.%

.SUFFIXES: .hpux_make_needs_suffix_list

# Produce verbose output by default.
VERBOSE = 1

# Command-line flag to silence nested $(MAKE).
$(VERBOSE)MAKESILENT = -s

#Suppress display of executed commands.
$(VERBOSE).SILENT:

# A target that is always out of date.
cmake_force:
.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /opt/cmake-3.24.2/bin/cmake

# The command to remove a file.
RM = /opt/cmake-3.24.2/bin/cmake -E rm -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/ps/blake3/roc540-2

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/ps/blake3/roc540-2/build

# Utility rule file for mytest.

# Include any custom commands dependencies for this target.
include test/CMakeFiles/mytest.dir/compiler_depend.make

# Include the progress variables for this target.
include test/CMakeFiles/mytest.dir/progress.make

test/CMakeFiles/mytest:
	cd /home/ps/blake3/roc540-2/build/test && sh -xc /home/ps/blake3/roc540-2/test/../bin/build_kernel.sh\ /home/ps/blake3/roc540-2/test/dummy_kernel/dummy_kernel\ /home/ps/blake3/roc540-2/build\ '/opt/rocm'\ ''
	cd /home/ps/blake3/roc540-2/build/test && sh -xc /home/ps/blake3/roc540-2/test/../bin/build_kernel.sh\ /home/ps/blake3/roc540-2/test/simple_convolution/simple_convolution\ /home/ps/blake3/roc540-2/build\ '/opt/rocm'\ ''

mytest: test/CMakeFiles/mytest
mytest: test/CMakeFiles/mytest.dir/build.make
.PHONY : mytest

# Rule to build all files generated by this target.
test/CMakeFiles/mytest.dir/build: mytest
.PHONY : test/CMakeFiles/mytest.dir/build

test/CMakeFiles/mytest.dir/clean:
	cd /home/ps/blake3/roc540-2/build/test && $(CMAKE_COMMAND) -P CMakeFiles/mytest.dir/cmake_clean.cmake
.PHONY : test/CMakeFiles/mytest.dir/clean

test/CMakeFiles/mytest.dir/depend:
	cd /home/ps/blake3/roc540-2/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/ps/blake3/roc540-2 /home/ps/blake3/roc540-2/test /home/ps/blake3/roc540-2/build /home/ps/blake3/roc540-2/build/test /home/ps/blake3/roc540-2/build/test/CMakeFiles/mytest.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : test/CMakeFiles/mytest.dir/depend

