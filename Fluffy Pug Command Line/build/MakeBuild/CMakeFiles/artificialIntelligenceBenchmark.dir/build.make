# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.5

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /Applications/CMake.app/Contents/bin/cmake

# The command to remove a file.
RM = /Applications/CMake.app/Contents/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line"

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild"

# Include any dependencies generated for this target.
include CMakeFiles/artificialIntelligenceBenchmark.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/artificialIntelligenceBenchmark.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/artificialIntelligenceBenchmark.dir/flags.make

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o: CMakeFiles/artificialIntelligenceBenchmark.dir/flags.make
CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o: ../../source/main.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir="/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild/CMakeFiles" --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++   $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o -c "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/source/main.cpp"

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.i"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/source/main.cpp" > CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.i

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.s"
	/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/c++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/source/main.cpp" -o CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.s

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.requires:

.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.requires

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.provides: CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.requires
	$(MAKE) -f CMakeFiles/artificialIntelligenceBenchmark.dir/build.make CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.provides.build
.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.provides

CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.provides.build: CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o


# Object files for target artificialIntelligenceBenchmark
artificialIntelligenceBenchmark_OBJECTS = \
"CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o"

# External object files for target artificialIntelligenceBenchmark
artificialIntelligenceBenchmark_EXTERNAL_OBJECTS =

artificialIntelligenceBenchmark: CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o
artificialIntelligenceBenchmark: CMakeFiles/artificialIntelligenceBenchmark.dir/build.make
artificialIntelligenceBenchmark: CMakeFiles/artificialIntelligenceBenchmark.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir="/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild/CMakeFiles" --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable artificialIntelligenceBenchmark"
	/Applications/CMake.app/Contents/bin/cmake -E copy_directory /Users/Matt/Project-Fluffy-Pug/Fluffy\ Pug\ Command\ Line/AnalysisImages /Users/Matt/Project-Fluffy-Pug/Fluffy\ Pug\ Command\ Line/build/MakeBuild
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/artificialIntelligenceBenchmark.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/artificialIntelligenceBenchmark.dir/build: artificialIntelligenceBenchmark

.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/build

CMakeFiles/artificialIntelligenceBenchmark.dir/requires: CMakeFiles/artificialIntelligenceBenchmark.dir/source/main.cpp.o.requires

.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/requires

CMakeFiles/artificialIntelligenceBenchmark.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/artificialIntelligenceBenchmark.dir/cmake_clean.cmake
.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/clean

CMakeFiles/artificialIntelligenceBenchmark.dir/depend:
	cd "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild" && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line" "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line" "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild" "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild" "/Users/Matt/Project-Fluffy-Pug/Fluffy Pug Command Line/build/MakeBuild/CMakeFiles/artificialIntelligenceBenchmark.dir/DependInfo.cmake" --color=$(COLOR)
.PHONY : CMakeFiles/artificialIntelligenceBenchmark.dir/depend

