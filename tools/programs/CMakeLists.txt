cmake_minimum_required(VERSION 3.16)
project(palhack)

set(PALHACK_SOURCES palhack.c)

add_executable(palhack ${PALHACK_SOURCES})
target_link_libraries(palhack png)

project(mkfontsingle)

set(MKFONTSINGLE_SOURCES mkfontsingle.c)
set(MKFONTSINGLE_INCLUDE /usr/include/freetype2)

# set(USE_X_POS_INFO 0 CACHE BOOL "(mkfontsingle) Output X position info")
# set(USE_Y_POS_INFO 0 CACHE BOOL "(mkfontsingle) Output Y position info")

# if (USE_X_POS_INFO)
# 	set(X_POS_INFO 1)
# endif()
# if (USE_Y_POS_INFO)
# 	set(Y_POS_INFO 1)
# endif()

# configure_file(${CMAKE_SOURCE_DIR}/config.h.in ${CMAKE_SOURCE_DIR}/config.h)
add_executable(mkfontsingle ${MKFONTSINGLE_SOURCES})
target_include_directories(mkfontsingle PUBLIC ${MKFONTSINGLE_INCLUDE})
target_link_libraries(mkfontsingle m png freetype)
# target_compile_definitions(mkfontsingle PUBLIC CFF_CONFIG_OPTION_OLD_ENGINE T1_CONFIG_OPTION_OLD_ENGINE)
