# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.16

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
CMAKE_COMMAND = /usr/bin/cmake

# The command to remove a file.
RM = /usr/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /home/yong/polymer/git_L_FTS_Public

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /home/yong/polymer/git_L_FTS_Public/make_swig

# Include any dependencies generated for this target.
include CMakeFiles/main.dir/depend.make

# Include the progress variables for this target.
include CMakeFiles/main.dir/progress.make

# Include the compile flags for this target's objects.
include CMakeFiles/main.dir/flags.make

CMakeFiles/main.dir/src/ParamParser.cpp.o: CMakeFiles/main.dir/flags.make
CMakeFiles/main.dir/src/ParamParser.cpp.o: ../src/ParamParser.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/yong/polymer/git_L_FTS_Public/make_swig/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object CMakeFiles/main.dir/src/ParamParser.cpp.o"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/main.dir/src/ParamParser.cpp.o -c /home/yong/polymer/git_L_FTS_Public/src/ParamParser.cpp

CMakeFiles/main.dir/src/ParamParser.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/main.dir/src/ParamParser.cpp.i"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/yong/polymer/git_L_FTS_Public/src/ParamParser.cpp > CMakeFiles/main.dir/src/ParamParser.cpp.i

CMakeFiles/main.dir/src/ParamParser.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/main.dir/src/ParamParser.cpp.s"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/yong/polymer/git_L_FTS_Public/src/ParamParser.cpp -o CMakeFiles/main.dir/src/ParamParser.cpp.s

CMakeFiles/main.dir/src/SimulationBox.cpp.o: CMakeFiles/main.dir/flags.make
CMakeFiles/main.dir/src/SimulationBox.cpp.o: ../src/SimulationBox.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/yong/polymer/git_L_FTS_Public/make_swig/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object CMakeFiles/main.dir/src/SimulationBox.cpp.o"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/main.dir/src/SimulationBox.cpp.o -c /home/yong/polymer/git_L_FTS_Public/src/SimulationBox.cpp

CMakeFiles/main.dir/src/SimulationBox.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/main.dir/src/SimulationBox.cpp.i"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/yong/polymer/git_L_FTS_Public/src/SimulationBox.cpp > CMakeFiles/main.dir/src/SimulationBox.cpp.i

CMakeFiles/main.dir/src/SimulationBox.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/main.dir/src/SimulationBox.cpp.s"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/yong/polymer/git_L_FTS_Public/src/SimulationBox.cpp -o CMakeFiles/main.dir/src/SimulationBox.cpp.s

CMakeFiles/main.dir/src/PolymerChain.cpp.o: CMakeFiles/main.dir/flags.make
CMakeFiles/main.dir/src/PolymerChain.cpp.o: ../src/PolymerChain.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/home/yong/polymer/git_L_FTS_Public/make_swig/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building CXX object CMakeFiles/main.dir/src/PolymerChain.cpp.o"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/main.dir/src/PolymerChain.cpp.o -c /home/yong/polymer/git_L_FTS_Public/src/PolymerChain.cpp

CMakeFiles/main.dir/src/PolymerChain.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/main.dir/src/PolymerChain.cpp.i"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /home/yong/polymer/git_L_FTS_Public/src/PolymerChain.cpp > CMakeFiles/main.dir/src/PolymerChain.cpp.i

CMakeFiles/main.dir/src/PolymerChain.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/main.dir/src/PolymerChain.cpp.s"
	/opt/intel/compiler/2021.3.0/linux/bin/intel64/icpc $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /home/yong/polymer/git_L_FTS_Public/src/PolymerChain.cpp -o CMakeFiles/main.dir/src/PolymerChain.cpp.s

# Object files for target main
main_OBJECTS = \
"CMakeFiles/main.dir/src/ParamParser.cpp.o" \
"CMakeFiles/main.dir/src/SimulationBox.cpp.o" \
"CMakeFiles/main.dir/src/PolymerChain.cpp.o"

# External object files for target main
main_EXTERNAL_OBJECTS =

libmain.a: CMakeFiles/main.dir/src/ParamParser.cpp.o
libmain.a: CMakeFiles/main.dir/src/SimulationBox.cpp.o
libmain.a: CMakeFiles/main.dir/src/PolymerChain.cpp.o
libmain.a: CMakeFiles/main.dir/build.make
libmain.a: CMakeFiles/main.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/home/yong/polymer/git_L_FTS_Public/make_swig/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Linking CXX static library libmain.a"
	$(CMAKE_COMMAND) -P CMakeFiles/main.dir/cmake_clean_target.cmake
	$(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/main.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
CMakeFiles/main.dir/build: libmain.a

.PHONY : CMakeFiles/main.dir/build

CMakeFiles/main.dir/clean:
	$(CMAKE_COMMAND) -P CMakeFiles/main.dir/cmake_clean.cmake
.PHONY : CMakeFiles/main.dir/clean

CMakeFiles/main.dir/depend:
	cd /home/yong/polymer/git_L_FTS_Public/make_swig && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /home/yong/polymer/git_L_FTS_Public /home/yong/polymer/git_L_FTS_Public /home/yong/polymer/git_L_FTS_Public/make_swig /home/yong/polymer/git_L_FTS_Public/make_swig /home/yong/polymer/git_L_FTS_Public/make_swig/CMakeFiles/main.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : CMakeFiles/main.dir/depend

