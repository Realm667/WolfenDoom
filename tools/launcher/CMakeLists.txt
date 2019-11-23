cmake_minimum_required(VERSION 3.2.2)
project(WolfBOA)

if( COMMAND cmake_policy )
	if( POLICY CMP0011 )
		cmake_policy( SET CMP0011 NEW )
	endif()
	if( POLICY CMP0054 )
		cmake_policy( SET CMP0054 NEW )
	endif()
endif()

include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${CMAKE_CURRENT_SOURCE_DIR}/src)
set(BOA_SOURCES
	src/launch-boa.c
	src/win32/launch-boa.rc
)

add_executable(launch-boa
	${BOA_SOURCES}
)
