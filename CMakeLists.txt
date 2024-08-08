
cmake_minimum_required(VERSION 3.15.1)

list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules)

project(XCTest LANGUAGES Swift)

option(BUILD_SHARED_LIBS "Build shared libraries" ON)
option(USE_FOUNDATION_FRAMEWORK "Use Foundation.framework on Darwin" NO)

set(DISABLE_XCTWAITER_default NO)

if(CMAKE_SYSTEM_PROCESSOR STREQUAL wasm32)
  set(DISABLE_XCTWAITER_default ON)
endif()

option(DISABLE_XCTWAITER "Disable XCTWaiter" "${DISABLE_XCTWAITER_default}")

if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin AND NOT DISABLE_XCTWAITER)
  find_package(dispatch CONFIG REQUIRED)
  find_package(Foundation CONFIG REQUIRED)
endif()

include(SwiftSupport)
include(GNUInstallDirs)
include(CheckLinkerFlag)

if(CMAKE_SYSTEM_NAME STREQUAL Linux
    OR CMAKE_SYSTEM_NAME STREQUAL FreeBSD
    OR CMAKE_SYSTEM_NAME STREQUAL OpenBSD)
  enable_language(C)
  check_linker_flag(C "LINKER:--build-id=sha1" LINKER_SUPPORTS_BUILD_ID)
endif()

add_library(XCTest
  Sources/XCTest/Private/WallClockTimeMetric.swift
  Sources/XCTest/Private/TestListing.swift
  Sources/XCTest/Private/XCTestCaseSuite.swift
  Sources/XCTest/Private/TestFiltering.swift
  Sources/XCTest/Private/XCTestInternalObservation.swift
  Sources/XCTest/Private/ObjectWrapper.swift
  Sources/XCTest/Private/PerformanceMeter.swift
  Sources/XCTest/Private/PrintObserver.swift
  Sources/XCTest/Private/ArgumentParser.swift
  Sources/XCTest/Private/SourceLocation.swift
  Sources/XCTest/Private/WaiterManager.swift
  Sources/XCTest/Private/IgnoredErrors.swift
  Sources/XCTest/Private/XCTestCase.TearDownBlocksState.swift
  Sources/XCTest/Public/XCTestRun.swift
  Sources/XCTest/Public/XCTestMain.swift
  Sources/XCTest/Public/XCTestCase.swift
  Sources/XCTest/Public/XCTestSuite.swift
  Sources/XCTest/Public/XCTestSuiteRun.swift
  Sources/XCTest/Public/XCTestErrors.swift
  Sources/XCTest/Public/XCTestObservation.swift
  Sources/XCTest/Public/XCTestCaseRun.swift
  Sources/XCTest/Public/XCAbstractTest.swift
  Sources/XCTest/Public/XCTestObservationCenter.swift
  Sources/XCTest/Public/XCTestCase+Performance.swift
  Sources/XCTest/Public/XCTAssert.swift
  Sources/XCTest/Public/XCTIssue.swift
  Sources/XCTest/Public/XCTSkip.swift
  Sources/XCTest/Public/Asynchronous/XCTNSNotificationExpectation.swift
  Sources/XCTest/Public/Asynchronous/XCTNSPredicateExpectation.swift
  Sources/XCTest/Public/Asynchronous/XCTWaiter+Validation.swift
  Sources/XCTest/Public/Asynchronous/XCTWaiter.swift
  Sources/XCTest/Public/Asynchronous/XCTestCase+Asynchronous.swift
  Sources/XCTest/Public/Asynchronous/XCTestExpectation.swift)

if(DISABLE_XCTWAITER)
  target_compile_definitions(XCTest PRIVATE
    DISABLE_XCTWAITER)
endif()

if(USE_FOUNDATION_FRAMEWORK)
  target_compile_definitions(XCTest PRIVATE
    USE_FOUNDATION_FRAMEWORK)
endif()
if(NOT CMAKE_SYSTEM_NAME STREQUAL Darwin)
  target_link_libraries(XCTest PRIVATE
    dispatch
    Foundation)
  if(NOT CMAKE_SYSTEM_NAME STREQUAL Windows)
    target_link_options(XCTest PRIVATE "SHELL:-no-toolchain-stdlib-rpath")
  endif()
endif()
set_target_properties(XCTest PROPERTIES
  Swift_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/swift
  INTERFACE_INCLUDE_DIRECTORIES ${CMAKE_CURRENT_BINARY_DIR}/swift)

if(LINKER_SUPPORTS_BUILD_ID)
  target_link_options(XCTest PRIVATE "LINKER:--build-id=sha1")
endif()


if(ENABLE_TESTING)
  enable_testing()

  enable_language(C)
  find_package(LLVM CONFIG)
  if(LLVM_FOUND)
    message(STATUS "Found LLVM ${LLVM_PACKAGE_VERSION}")
    message(STATUS "Using LLVMConfig.cmake in: ${LLVM_DIR}")

    include(${LLVM_DIR}/LLVMConfig.cmake)

    list(APPEND CMAKE_MODULE_PATH ${LLVM_DIR})
    include(AddLLVM)
  elseif(NOT DEFINED LLVM_MAIN_SRC_DIR OR NOT EXISTS ${LLVM_MAIN_SRC_DIR})
    message(SEND_ERROR "LLVM not found and LLVM_MAIN_SRC_DIR not defined - required for testing")
  endif()

  if(EXISTS ${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py)
    set(LIT_COMMAND "${LLVM_MAIN_SRC_DIR}/utils/lit/lit.py"
        CACHE STRING "command used to spawn llvm-lit")
  elseif(LLVM_DEFAULT_EXTERNAL_LIT)
    set(LIT_COMMAND "${LLVM_DEFAULT_EXTERNAL_LIT}"
        CACHE STRING "command used to spawn llvm-lit")
  else()
    find_program(LIT_COMMAND NAMES llvm-lit lit.py lit)
  endif()

  find_package(Python3 COMPONENTS Interpreter REQUIRED)

  string(REPLACE "\\" "\\\\" CMAKE_Swift_FLAGS_ESCAPED ${CMAKE_Swift_FLAGS})
  add_custom_target(check-xctest
                    COMMAND
                    ${CMAKE_COMMAND} -E env
                      BUILT_PRODUCTS_DIR=${CMAKE_BINARY_DIR}
                      FOUNDATION_BUILT_PRODUCTS_DIR=${XCTEST_PATH_TO_FOUNDATION_BUILD}
                      LIBDISPATCH_SRC_DIR=${XCTEST_PATH_TO_LIBDISPATCH_SOURCE}
                      LIBDISPATCH_BUILD_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}
                      LIBDISPATCH_OVERLAY_DIR=${XCTEST_PATH_TO_LIBDISPATCH_BUILD}/src/swift
                      SWIFT_EXEC=${CMAKE_Swift_COMPILER}
                      SWIFT_FLAGS=${CMAKE_Swift_FLAGS_ESCAPED}
                      $<TARGET_FILE:Python3::Interpreter> ${LIT_COMMAND} -sv ${CMAKE_SOURCE_DIR}/Tests/Functional
                    COMMENT
                      "Running XCTest functional test suite"
                    DEPENDS
                      XCTest
                    USES_TERMINAL)
endif()


set_property(GLOBAL APPEND PROPERTY XCTest_EXPORTS XCTest)
get_swift_host_arch(swift_arch)
install(TARGETS XCTest
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR})
install(FILES
  ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftdoc
  ${CMAKE_CURRENT_BINARY_DIR}/swift/XCTest.swiftmodule
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/swift$<$<NOT:$<BOOL:${BUILD_SHARED_LIBS}>>:_static>/$<LOWER_CASE:${CMAKE_SYSTEM_NAME}>/${swift_arch})

add_subdirectory(cmake/modules)
