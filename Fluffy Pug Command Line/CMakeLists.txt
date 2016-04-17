cmake_minimum_required(VERSION 3.5.1)
project (artificialIntelligenceBenchmark)

file(GLOB all_SRC
    "*.h"
    "*.cpp"
)

add_executable(artificialIntelligenceBenchmark ${all_SRC})

include_directories(/usr/local/include)
TARGET_LINK_LIBRARIES(artificialIntelligenceBenchmark /usr/local/lib)
link_directories(/usr/local/lib)

find_library(PNG_LIB png16 /usr/local/lib)

set(LIBRARY_SEARCH_PATH
/usr/local/lib
)

TARGET_LINK_LIBRARIES(artificialIntelligenceBenchmark png16 ${PNG_LIB})


add_custom_command(TARGET artificialIntelligenceBenchmark PRE_BUILD
                   COMMAND ${CMAKE_COMMAND} -E copy_directory
                       ${CMAKE_SOURCE_DIR}/AnalysisImages $<TARGET_FILE_DIR:artificialIntelligenceBenchmark>)