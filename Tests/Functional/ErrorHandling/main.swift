// RUN: %{swiftc} %s -o %T/ErrorHandling
// RUN: %T/ErrorHandling > %t || true
// RUN: %{xctest_checker} %t %s

#if os(macOS)
    import SwiftXCTest
#else
    import XCTest
#endif

// CHECK: Test Suite 'All tests' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'ErrorHandling' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
class ErrorHandling: XCTestCase {
    static var allTests = {
        return [
            // Tests for XCTAssertThrowsError
            ("test_shouldRethrowErrorFromHandler", test_shouldRethrowErrorFromHandler),
            ("test_shouldNotRethrowWhenHandlerDoesNotThrow", test_shouldNotRethrowWhenHandlerDoesNotThrow),
            ("test_shouldButDoesNotThrowErrorInAssertion", test_shouldButDoesNotThrowErrorInAssertion),
            ("test_shouldThrowErrorInAssertion", test_shouldThrowErrorInAssertion),
            ("test_throwsErrorInAssertionButFailsWhenCheckingError", test_throwsErrorInAssertionButFailsWhenCheckingError),
            
            // Tests for "testFoo() throws"
            ("test_canAndDoesThrowErrorFromTestMethod", test_canAndDoesThrowErrorFromTestMethod),
            ("test_canButDoesNotThrowErrorFromTestMethod", test_canButDoesNotThrowErrorFromTestMethod),
            
            // Tests for throwing assertion expressions
            ("test_assertionExpressionCanThrow", test_assertionExpressionCanThrow),

            // Tests for XCTAssertNoThrow
            ("test_shouldNotThrowErrorDefiningSuccess", test_shouldNotThrowErrorDefiningSuccess),
            ("test_shouldThrowErrorDefiningFailure", test_shouldThrowErrorDefiningFailure),

            // Tests for XCTUnwrap
            ("test_shouldNotThrowErrorOnUnwrapSuccess", test_shouldNotThrowErrorOnUnwrapSuccess),
            ("test_shouldThrowErrorOnUnwrapFailure", test_shouldThrowErrorOnUnwrapFailure),
            ("test_shouldThrowErrorOnEvaluationFailure", test_shouldThrowErrorOnEvaluationFailure),
            ("test_implicitlyUnwrappedOptional_notNil", test_implicitlyUnwrappedOptional_notNil),
            ("test_implicitlyUnwrappedOptional_nil", test_implicitlyUnwrappedOptional_nil),
            ("test_unwrapAnyOptional_notNil", test_unwrapAnyOptional_notNil),
            ("test_unwrapAnyOptional_nil", test_unwrapAnyOptional_nil),
            ("test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure", test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure),
            ("test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure", test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure),
            ("test_shouldReportCorrectTypeOnUnwrapFailure", test_shouldReportCorrectTypeOnUnwrapFailure),
            ("test_shouldReportCustomFileLineLocation", test_shouldReportCustomFileLineLocation),
            ("test_shouldReportFailureNotOnMainThread", test_shouldReportFailureNotOnMainThread),
            ("test_canRecordIssue", test_canRecordIssue),
        ]
    }()
    
    func functionThatDoesNotThrowError() throws {
    }
    
    enum SomeError: Swift.Error {
        case anError(String)
        case shouldNotBeReached
    }
    
    func functionThatDoesThrowError() throws {
        throw SomeError.anError("an error message")
    }

// CHECK: Test Case 'ErrorHandling.test_shouldRethrowErrorFromHandler' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+3]]: error: ErrorHandling.test_shouldRethrowErrorFromHandler : XCTAssertThrowsError threw error "anError\("an error message"\)" -
// CHECK: Test Case 'ErrorHandling.test_shouldRethrowErrorFromHandler' failed \(\d+\.\d+ seconds\)
    func test_shouldRethrowErrorFromHandler() throws {
        try XCTAssertThrowsError(try functionThatDoesThrowError()) {_ in try functionThatDoesThrowError() }
    }

// CHECK: Test Case 'ErrorHandling.test_shouldNotRethrowWhenHandlerDoesNotThrow' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldNotRethrowWhenHandlerDoesNotThrow' passed \(\d+\.\d+ seconds\)
    func test_shouldNotRethrowWhenHandlerDoesNotThrow() throws {
        try XCTAssertThrowsError(try functionThatDoesThrowError()) {_ in try functionThatDoesNotThrowError() }
    }

// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+3]]: error: ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion : XCTAssertThrowsError failed: did not throw error -
// CHECK: Test Case 'ErrorHandling.test_shouldButDoesNotThrowErrorInAssertion' failed \(\d+\.\d+ seconds\)
    func test_shouldButDoesNotThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesNotThrowError())
    }
    
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorInAssertion' passed \(\d+\.\d+ seconds\)
    func test_shouldThrowErrorInAssertion() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .anError(let message):
                XCTAssertEqual(message, "an error message")
            default:
                XCTFail("Unexpected error: \(thrownError)")
            }
        }
    }
    
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+11]]: error: ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError : XCTAssertEqual failed: \("an error message"\) is not equal to \(""\) -
// CHECK: Test Case 'ErrorHandling.test_throwsErrorInAssertionButFailsWhenCheckingError' failed \(\d+\.\d+ seconds\)
    func test_throwsErrorInAssertionButFailsWhenCheckingError() {
        XCTAssertThrowsError(try functionThatDoesThrowError()) { error in
            guard let thrownError = error as? SomeError else {
                XCTFail("Threw the wrong type of error")
                return
            }
            
            switch thrownError {
            case .anError(let message):
                XCTAssertEqual(message, "")
            default:
                XCTFail("Unexpected error: \(thrownError)")
            }
        }
    }

// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \<EXPR\>:0: error: ErrorHandling.test_canAndDoesThrowErrorFromTestMethod : threw error "anError\("an error message"\)"
// CHECK: Test Case 'ErrorHandling.test_canAndDoesThrowErrorFromTestMethod' failed \(\d+\.\d+ seconds\)
    func test_canAndDoesThrowErrorFromTestMethod() throws {
        try functionThatDoesThrowError()
    }
    
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_canButDoesNotThrowErrorFromTestMethod' passed \(\d+\.\d+ seconds\)
    func test_canButDoesNotThrowErrorFromTestMethod() throws {
        try functionThatDoesNotThrowError()
    }
    
    func functionThatShouldReturnButThrows() throws -> Int {
        throw SomeError.anError("did not actually return")
    }

// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+3]]: error: ErrorHandling.test_assertionExpressionCanThrow : XCTAssertEqual threw error "anError\("did not actually return"\)" -
// CHECK: Test Case 'ErrorHandling.test_assertionExpressionCanThrow' failed \(\d+\.\d+ seconds\)
    func test_assertionExpressionCanThrow() {
        XCTAssertEqual(try functionThatShouldReturnButThrows(), 1)
    }


// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorDefiningSuccess' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorDefiningSuccess' passed \(\d+\.\d+ seconds\)
    func test_shouldNotThrowErrorDefiningSuccess() {
        XCTAssertNoThrow(try functionThatDoesNotThrowError())
    }

// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorDefiningFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+3]]: error: ErrorHandling.test_shouldThrowErrorDefiningFailure : XCTAssertNoThrow failed: threw error "anError\("an error message"\)" -
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorDefiningFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldThrowErrorDefiningFailure() {
        XCTAssertNoThrow(try functionThatDoesThrowError())
    }

    func functionShouldReturnOptionalButThrows() throws -> String? {
        throw SomeError.anError("an error message")
    }

// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorOnUnwrapSuccess' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_shouldNotThrowErrorOnUnwrapSuccess' passed \(\d+\.\d+ seconds\)
    func test_shouldNotThrowErrorOnUnwrapSuccess() throws {
        let optional: String? = "is not nil"

        let unwrapped = try XCTUnwrap(optional)
        XCTAssertEqual(unwrapped, optional)
    }

// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorOnUnwrapFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_shouldThrowErrorOnUnwrapFailure : XCTUnwrap failed: expected non-nil value of type "String" -
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorOnUnwrapFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldThrowErrorOnUnwrapFailure() throws {
        let optional: String? = nil
        _ = try XCTUnwrap(optional)

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorOnEvaluationFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_shouldThrowErrorOnEvaluationFailure : XCTUnwrap threw error "anError\("an error message"\)" - Failure error message
// CHECK: \<EXPR\>:0: error: ErrorHandling.test_shouldThrowErrorOnEvaluationFailure : threw error "anError\("an error message"\)"
// CHECK: Test Case 'ErrorHandling.test_shouldThrowErrorOnEvaluationFailure' failed \(\d+\.\d+ seconds\)
        func test_shouldThrowErrorOnEvaluationFailure() throws {
        _ = try XCTUnwrap(functionShouldReturnOptionalButThrows(), "Failure error message")

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_implicitlyUnwrappedOptional_notNil' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_implicitlyUnwrappedOptional_notNil' passed \(\d+\.\d+ seconds\)
    func test_implicitlyUnwrappedOptional_notNil() throws {
        let implicitlyUnwrappedOptional: String! = "is not nil"

        let unwrapped = try XCTUnwrap(implicitlyUnwrappedOptional)
        XCTAssertEqual(unwrapped, implicitlyUnwrappedOptional)
    }

// CHECK: Test Case 'ErrorHandling.test_implicitlyUnwrappedOptional_nil' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_implicitlyUnwrappedOptional_nil : XCTUnwrap failed: expected non-nil value of type "String" - Failure error message
// CHECK: Test Case 'ErrorHandling.test_implicitlyUnwrappedOptional_nil' failed \(\d+\.\d+ seconds\)
    func test_implicitlyUnwrappedOptional_nil() throws {
        let implicitlyUnwrappedOptional: String! = nil
        _ = try XCTUnwrap(implicitlyUnwrappedOptional, "Failure error message")

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_unwrapAnyOptional_notNil' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: Test Case 'ErrorHandling.test_unwrapAnyOptional_notNil' passed \(\d+\.\d+ seconds\)
    func test_unwrapAnyOptional_notNil() throws {
        let anyOptional: Any? = "is not nil"

        let unwrapped = try XCTUnwrap(anyOptional)
        XCTAssertEqual(unwrapped as! String, anyOptional as! String)
    }

// CHECK: Test Case 'ErrorHandling.test_unwrapAnyOptional_nil' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_unwrapAnyOptional_nil : XCTUnwrap failed: expected non-nil value of type "Any" - Failure error message
// CHECK: Test Case 'ErrorHandling.test_unwrapAnyOptional_nil' failed \(\d+\.\d+ seconds\)
    func test_unwrapAnyOptional_nil() throws {
        let anyOptional: Any? = nil
        _ = try XCTUnwrap(anyOptional, "Failure error message")

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+5]]: error: ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure : XCTUnwrap failed: expected non-nil value of type "String" -
// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldReportFailureOnUnwrapFailure_catchUnwrapFailure() {
        do {
            let optional: String? = nil
            _ = try XCTUnwrap(optional)
        } catch {}
    }

// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure : XCTUnwrap threw error "anError\("an error message"\)" -
// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldReportFailureOnUnwrapFailure_catchExpressionFailure() {
        do {
            _ = try XCTUnwrap(functionShouldReturnOptionalButThrows())
        } catch {}
    }

    struct CustomType {
        var name: String
    }

// CHECK: Test Case 'ErrorHandling.test_shouldReportCorrectTypeOnUnwrapFailure' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+4]]: error: ErrorHandling.test_shouldReportCorrectTypeOnUnwrapFailure : XCTUnwrap failed: expected non-nil value of type "CustomType" -
// CHECK: Test Case 'ErrorHandling.test_shouldReportCorrectTypeOnUnwrapFailure' failed \(\d+\.\d+ seconds\)
    func test_shouldReportCorrectTypeOnUnwrapFailure() throws {
        let customTypeOptional: CustomType? = nil
        _ = try XCTUnwrap(customTypeOptional)

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_shouldReportCustomFileLineLocation' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: custom_file.swift:1234: error: ErrorHandling.test_shouldReportCustomFileLineLocation : XCTUnwrap failed: expected non-nil value of type "CustomType" -
// CHECK: Test Case 'ErrorHandling.test_shouldReportCustomFileLineLocation' failed \(\d+\.\d+ seconds\)
    func test_shouldReportCustomFileLineLocation() throws {
        let customTypeOptional: CustomType? = nil
        _ = try XCTUnwrap(customTypeOptional, file: "custom_file.swift", line: 1234)

        // Should not be reached:
        throw SomeError.shouldNotBeReached
    }

// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureNotOnMainThread' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+7]]: error: ErrorHandling.test_shouldReportFailureNotOnMainThread : XCTUnwrap failed: expected non-nil value of type "CustomType" -
// CHECK: Test Case 'ErrorHandling.test_shouldReportFailureNotOnMainThread' failed \(\d+\.\d+ seconds\)
    func test_shouldReportFailureNotOnMainThread() throws {
        let queue = DispatchQueue(label: "Test")
        let semaphore = DispatchSemaphore(value: 0)
        queue.async {
            let customTypeOptional: CustomType? = nil
            _ = try? XCTUnwrap(customTypeOptional)
            semaphore.signal()
        }

        semaphore.wait()
    }

    // CHECK: Test Case 'ErrorHandling.test_canRecordIssue' started at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
    // CHECK: .*[/\\]ErrorHandling[/\\]main.swift:[[@LINE+10]]: error: ErrorHandling.test_canRecordIssue : ABC 123
    // CHECK: Test Case 'ErrorHandling.test_canRecordIssue' failed \(\d+\.\d+ seconds\)
    func test_canRecordIssue() {
        struct MyError: Error {}
        let issue = XCTIssue(
            type: .performanceRegression,
            compactDescription: "ABC 123",
            detailedDescription: "DEF 987",
            associatedError: MyError()
        )
        record(issue)
    }
}

// CHECK: Test Suite 'ErrorHandling' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(6 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds

XCTMain([testCase(ErrorHandling.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(6 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+-\d+-\d+ \d+:\d+:\d+\.\d+
// CHECK: \t Executed \d+ tests, with \d+ failures \(6 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
