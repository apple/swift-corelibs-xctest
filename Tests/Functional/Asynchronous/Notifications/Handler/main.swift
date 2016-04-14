// RUN: %{swiftc} %s -o %{built_tests_dir}/Asynchronous-Notifications-Handler
// RUN: %{built_tests_dir}/Asynchronous-Notifications-Handler > %t || true
// RUN: %{xctest_checker} %t %s

#if os(Linux) || os(FreeBSD) || os(Android)
    import XCTest
    import Foundation
#else
    import SwiftXCTest
    import SwiftFoundation
#endif

// CHECK: Test Suite 'All tests' started at \d+:\d+:\d+\.\d+
// CHECK: Test Suite '.*\.xctest' started at \d+:\d+:\d+\.\d+

// CHECK: Test Suite 'NotificationHandlerTestCase' started at \d+:\d+:\d+\.\d+
class NotificationHandlerTestCase: XCTestCase {
// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObserved_handlerReturnsFalse_andFails' started at \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Handler/main.swift:27: error: NotificationHandlerTestCase.test_notificationNameIsObserved_handlerReturnsFalse_andFails : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'returnFalse' from any object
// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObserved_handlerReturnsFalse_andFails' failed \(\d+\.\d+ seconds\).
    func test_notificationNameIsObserved_handlerReturnsFalse_andFails() {
        expectation(forNotification: "returnFalse", object: nil, handler: {
            notification in
            return false
        })
        NSNotificationCenter.defaultCenter().postNotificationName("returnFalse", object: nil)
        waitForExpectations(withTimeout: 0.1)
    }
    
// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObserved_handlerReturnsTrue_andPasses' started at \d+:\d+:\d+\.\d+
// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObserved_handlerReturnsTrue_andPasses' passed \(\d+\.\d+ seconds\).
    func test_notificationNameIsObserved_handlerReturnsTrue_andPasses() {
        expectation(forNotification: "returnTrue", object: nil, handler: {
            notification in
            return true
        })
        NSNotificationCenter.defaultCenter().postNotificationName("returnTrue", object: nil)
        waitForExpectations(withTimeout: 0.1)
    }

// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled' started at \d+:\d+:\d+\.\d+
// CHECK: .*/Tests/Functional/Asynchronous/Notifications/Handler/main.swift:\d+: error: NotificationHandlerTestCase.test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled : Asynchronous wait failed - Exceeded timeout of 0.1 seconds, with unfulfilled expectations: Expect notification 'note' from any object
// CHECK: Test Case 'NotificationHandlerTestCase.test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled' failed \(\d+\.\d+ seconds\).
    func test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled() {
        expectation(forNotification: "note", object: nil, handler: { _ in
            XCTFail("Should not call the notification expectation handler")
            return true
        })
        waitForExpectations(withTimeout: 0.1, handler: nil)
        NSNotificationCenter.defaultCenter().postNotificationName("note", object: nil)
    }
    
    static var allTests: [(String, NotificationHandlerTestCase -> () throws -> Void)] {
        return [
                   ("test_notificationNameIsObserved_handlerReturnsFalse_andFails", test_notificationNameIsObserved_handlerReturnsFalse_andFails),
                   ("test_notificationNameIsObserved_handlerReturnsTrue_andPasses", test_notificationNameIsObserved_handlerReturnsTrue_andPasses),
                   ("test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled", test_notificationNameIsObservedAfterTimeout_handlerIsNotCalled),
        ]
    }
}
// CHECK: Test Suite 'NotificationHandlerTestCase' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds


XCTMain([testCase(NotificationHandlerTestCase.allTests)])

// CHECK: Test Suite '.*\.xctest' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
// CHECK: Test Suite 'All tests' failed at \d+:\d+:\d+\.\d+
// CHECK: \t Executed 3 tests, with 2 failures \(0 unexpected\) in \d+\.\d+ \(\d+\.\d+\) seconds
