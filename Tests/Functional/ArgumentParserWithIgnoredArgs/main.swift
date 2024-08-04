// RUN: %{swiftc} %s -o %T/ArgumentParserWithIgnoredArgs
// RUN: %T/ArgumentParserWithIgnoredArgs

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

class ArgumentParsingWithIgnoredArgsTestCase: XCTestCase {
    static var allTests = {
        return [
          ("testFail", testFail),
          ("testSuccess", testSuccess),
        ]
    }()
    func testFail() { XCTFail("failure") }
    func testSuccess() { }
}

let arguments = ["main", "--testing-library=xctest", "--testing-library", "xctest", "\(String(reflecting: ArgumentParsingWithIgnoredArgsTestCase.self))/testSuccess", "--testing-library",]
XCTMain([testCase(ArgumentParsingWithIgnoredArgsTestCase.allTests)], arguments: arguments)
