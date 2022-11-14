cmake_minimum_required(VERSION 3.5)

project(viewer LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)

set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_VERBOSE_MAKEFILE ON)
set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

include(GNUInstallDirs)
include(FeatureSummary)


find_package(Git QUIET REQUIRED)

execute_process(COMMAND
  "${GIT_EXECUTABLE}" describe --dirty --broken --always --tags
  WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
  OUTPUT_VARIABLE GIT_VERSION
  ERROR_QUIET OUTPUT_STRIP_TRAILING_WHITESPACE
)

add_definitions( -DGIT_VERSION="${GIT_VERSION}" )

find_package(Qt5 COMPONENTS Core Quick Xml Widgets Charts LinguistTools REQUIRED)
find_package(Qt5QuickCompiler)
qtquick_compiler_add_resources(RESOURCES viewer.qrc)
#qt5_add_resources(RESOURCES viewer.qrc)


file(GLOB TS_FILES i18n/*.ts)

add_executable(viewer WIN32
  src/customnetworkaccessmanager.cpp
  src/filereader.cpp
  src/igc.cpp
  src/igcfiltered.cpp
  src/imagesaver.cpp
  src/main.cpp
  src/networkaccessmanagerfactory.cpp
  src/pdfwriter.cpp
  src/resultscreater.cpp
  src/sortfilterproxymodel.cpp
  src/uploader.cpp
  src/worker.cpp
  viewer.rc
  ${RESOURCES}
  ${TS_FILES}
)

QT5_ADD_TRANSLATION(QM_FILES ${TS_FILES}
    OPTIONS "-idbased")
add_custom_target(translations DEPENDS ${QM_FILES})
add_dependencies(viewer translations)

QT5_CREATE_TRANSLATION(QT_FILES "${CMAKE_SOURCE_DIR}"
    OPTIONS "-no-obsolete")

install(FILES ${QM_FILES}
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/viewer/i18n")

install(FILES "viewer.desktop"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/applications")

install(FILES "images/viewer64.ico" "images/viewer64.png"
    DESTINATION "${CMAKE_INSTALL_DATAROOTDIR}/icons/hicolor/applications/64x64")

install(TARGETS viewer RUNTIME
        DESTINATION ${CMAKE_INSTALL_BINDIR})

target_compile_definitions(viewer
  PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(viewer
  PRIVATE Qt5::Core Qt5::Gui Qt5::Quick Qt5::Widgets Qt5::Charts Qt5::Xml)


option(DEPLOY_QT_LIBRARIES "Deploy Qt libraries to executable path" OFF)
if(DEPLOY_QT_LIBRARIES)
    if(WIN32)
        include(DeployQt)
        windeployqt(viewer)
    elseif(APPLE)
        include(DeployQt)
        macdeployqt(viewer)
    endif()
endif()
 feature_summary(WHAT ALL FATAL_ON_MISSING_REQUIRED_PACKAGES)


# generate proper GUI program on specified platform
if(WIN32) # Check if we are on Windows
    if(MSVC) # Check if we are using the Visual Studio compiler
	set_target_properties(${PROJECT_NAME} PROPERTIES
	    WIN32_EXECUTABLE YES
	    LINK_FLAGS "/ENTRY:mainCRTStartup"
	)
    elseif(CMAKE_COMPILER_IS_GNUCXX)
	    # SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -mwindows") # Not tested
    else()
	message(SEND_ERROR "You are using an unsupported Windows compiler! (Not MSVC or GCC)")
    endif(MSVC)
elseif(APPLE)
    set_target_properties(${PROJECT_NAME} PROPERTIES
	    MACOSX_BUNDLE YES
    )
elseif(UNIX)
    # Nothing special required
else()
    message(SEND_ERROR "You are on an unsupported platform! (Not Win32, Mac OS X or Unix)")
endif(WIN32)
