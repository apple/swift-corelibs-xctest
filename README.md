# XCTest

The XCTest library is designed to provide a common framework for writing unit tests in Swift, for Swift packages and applications.

This version of XCTest implements the majority of unit testing APIs included in XCTest from Xcode 7 and later. Its goal is to enable your project's tests to run on all the platforms Swift supports without having to rewrite them.


## Using XCTest

Your tests are organized into a simple hierarchy. Each `XCTestCase` subclass has a set of `test` methods, each of which should test one part of your code.

For general information about using XCTest, see:

* [Testing with Xcode](https://developer.apple.com/library/mac/documentation/DeveloperTools/Conceptual/testing_with_xcode/chapters/03-testing_basics.html)
* [XCTest API documentation](https://developer.apple.com/documentation/xctest)

### Using XCTest with Swift Package Manager

The Swift Package Manager integrates directly with XCTest to provide a streamlined experience for unit testing SwiftPM packages. If you are using XCTest within a SwiftPM package, unit test files are located within the package's `Tests` subdirectory, and you can build and run the full test suite in one step by running `swift test`.

For more information about using XCTest with SwiftPM, see its [documentation](https://github.com/apple/swift-package-manager).

### Test Method Discovery

Unlike the version of XCTest included with Xcode, this version does not use the Objective-C runtime to automatically discover test methods because that runtime is not available on all platforms Swift supports. This means that in certain configurations, the full set of test methods must be explicitly provided to XCTest.

When using XCTest via SwiftPM on macOS, this is not necessary because SwiftPM uses the version of XCTest included with Xcode to run tests. But when using this version of XCTest _without_ SwiftPM, or _with_ SwiftPM on a platform other than macOS (including Linux), the full set of test methods cannot be discovered automatically, and your test target must tell XCTest about them explicitly.

The recommended way to do this is to create a static property in each of your `XCTestCase` subclasses. By convention, this property is named `allTests`, and should contain all of the tests in the class. For example:

```swift
class TestNSURL : XCTestCase {
    static var allTests = {
        return [
            ("test_bestNumber", test_bestNumber),
            ("test_URLStrings", test_URLStrings),
            ("test_fileURLWithPath", test_fileURLWithPath),
            // Other tests go here
        ]
    }()

    func test_bestNumber() {
        // Write your test here. Most of the XCTAssert functions you are familiar with are available.
        XCTAssertTrue(theBestNumber == 42, "The number is wrong")
    }

    // Other tests go here
}
```

After creating an `allTests` property in each `XCTestCase` subclass, you must tell XCTest about those classes' tests.

If the project is a SwiftPM package which supports macOS, the easiest way to do this is to run `swift test --generate-linuxmain` from a macOS machine. This command generates files within the package's `Tests` subdirectory which contains the necessary source code for passing all test classes and methods to XCTest. These files should be committed to source control and re-generated whenever `XCTestCase` subclasses or test methods are added to or removed from your package's test suite.

If the project is a SwiftPM package but does not support macOS, you may edit the package's default  `LinuxMain.swift` file manually to add all `XCTestCase` subclasses.

If the project is not a SwiftPM package, follow the steps in the next section to create an executable which calls the `XCTMain` function manually.

### Standalone Command Line Usage

When used by itself, without SwiftPM, this version of XCTest does not use the external `xctest` CLI test runner included with Xcode to run tests. Instead, you must create your own executable which links `libXCTest.so`, and in your `main.swift`, invoke the `XCTMain` function with an array of the tests from all `XCTestCase` subclasses that you wish to run, wrapped by the `testCase` helper function. For example:

```swift
XCTMain([
    testCase(TestNSString.allTests),
    testCase(TestNSArray.allTests),
    testCase(TestNSDictionary.allTests),
])
```

The `XCTMain` function does not return, and will cause your test executable to exit with either `0` for success or `1` for failure. Certain command line arguments can be used to modify the test runner behavior:

* A particular test or test case can be selected to execute. For example:

```
$ ./FooTests Tests.FooTestCase/testFoo                            # Run a single test method
$ ./FooTests Tests.FooTestCase                                    # Run all the tests in FooTestCase
$ ./FooTests Tests.FooTestCase/testFoo,Tests.FooTestCase/testBar  # Run multiple test methods
```
* Tests can be listed, instead of executed.

```
$ ./FooTests --list-tests
Listing 4 tests in FooTests.xctest:

Tests.FooTestCase/testFoo
Tests.FooTestCase/testBar
Tests.BarTestCase/test123

$ ./FooTests --dump-tests-json
{"tests":[{"tests":[{"tests":[{"name":"testFoo"},{"name":"testBar"}],"name":"Tests.FooTestCase"},{"tests":[{"name":"test123"}],"name":"Tests.BarTestCase"}],"name":"Tests.xctest"}],"name":"All tests"}
```

## Contributing to XCTest

To contribute, you'll need to be able to build this project and and run its test suite. The easiest way to do so is via the Swift build script.

First, follow [the instructions in the Swift README](https://github.com/apple/swift/blob/main/README.md) to build Swift from source. Confirm you're able to build the Swift project using `utils/build-script -R`.

Once you are able to build the Swift project, build XCTest and run its tests:

```
$ cd swift-corelibs-xctest
$ ../swift/utils/build-script --preset corelibs-xctest
```

This project is only guaranteed to build with the very latest commit on the Swift and swift-corelibs-foundation `main` branches. You may update to the latest commits using the Swift `utils/update-checkout` script:

```
$ ../swift/utils/update-checkout
```

### Using Xcode

To browse files in this project using Xcode, use `XCTest.xcworkspace`. You may build the project using the `SwiftXCTest` scheme. Run the `SwiftXCTestFunctionalTests` scheme to run the tests.

However, in order to successfully build the project in Xcode, **you must use an Xcode toolchain with an extremely recent version of Swift**. The Swift website provides [Xcode toolchains to download](https://swift.org/download/#latest-development-snapshots), as well as [instructions on how to use Xcode with those toolchains](https://swift.org/download/#apple-platforms). Swift development moves fairly quickly, and so even a week-old toolchain may no longer work.

> If none of the toolchains available to download are recent enough to build XCTest, you may build your own toolchain by using the [`utils/build-toolchain` script](https://github.com/apple/swift/blob/main/utils/build-toolchain) in the Swift repository.
>
> Keep in mind that the build script invocation in "Contributing to XCTest" above will always work, regardless of which Swift toolchains you have installed. The Xcode workspace exists simply for the convenience of contributors. It is not necessary to successfully build this project in Xcode in order to contribute.
