cmake_minimum_required(VERSION 3.5.1)
project (artificialIntelligenceBenchmark)

file(GLOB_RECURSE all_SRC "source/*.cpp" "source/*.h")

add_executable(artificialIntelligenceBenchmark ${all_SRC})

include_directories(/usr/local/include)
link_directories(/usr/local/lib)

TARGET_LINK_LIBRARIES(artificialIntelligenceBenchmark png16)

add_custom_command(TARGET artificialIntelligenceBenchmark PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                       ${CMAKE_SOURCE_DIR}/AnalysisImages $<TARGET_FILE_DIR:artificialIntelligenceBenchmark>)