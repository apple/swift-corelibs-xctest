// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See http://swift.org/LICENSE.txt for license information
// See http://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//

/// Encapsulates all data concerning a test failure or other issue.
public struct XCTIssue: Sendable {
    /// Types of failures and other issues that can be reported for tests.
    public enum IssueType: Int, Sendable {
        /// Issue raised by a failed XCTAssert or related API.
        case assertionFailure = 0

        /// Issue raised by the test throwing an error in Swift. This could also occur if an Objective C test is implemented in the form `- (BOOL)testFoo:(NSError **)outError` and returns NO with a non-nil out error.
        case thrownError = 1

        /// Code in the test throws and does not catch an exception, Objective C, C++, or other.
        case uncaughtException = 2

        /// One of the XCTestCase(measure:) family of APIs detected a performance regression.
        case performanceRegression = 3

        /// One of the framework APIs failed internally. For example, XCUIApplication was unable to launch or terminate an app or XCUIElementQuery was unable to complete a query.
        case system = 4

        /// Issue raised when XCTExpectFailure is used but no matching issue is recorded.
        case unmatchedExpectedFailure = 5

        /// A short human-readable description of this issue type.
        fileprivate var stringRepresentation: String {
            switch self {
            case .assertionFailure:
                "Assertion Failure"
            case .thrownError:
                "Thrown Error"
            case .uncaughtException:
                "Uncaught Exception"
            case .performanceRegression:
                "Performance Regression"
            case .system:
                "System Error"
            case .unmatchedExpectedFailure:
                "Unmatched Expected Failure"
            }
        }
    }

    /// The type of the issue.
    public var type: IssueType

    /// A concise description of the issue, expected to be free of transient data and suitable for use in test run
    /// summaries and for aggregation of results across multiple test runs.
    public var compactDescription: String

    /// A detailed description of the issue designed to help diagnose the issue. May include transient data such as
    /// numbers, object identifiers, timestamps, etc.
    public var detailedDescription: String?

    /// Error associated with the issue.
    public var associatedError: (any Error)?

    public init(
        type: IssueType,
        compactDescription: String,
        detailedDescription: String? = nil,
        associatedError: (any Error)? = nil
    ) {
        self.type = type
        self.compactDescription = compactDescription
        self.detailedDescription = detailedDescription
        self.associatedError = associatedError
    }
}

extension XCTIssue: CustomStringConvertible {
    public var description: String {
        "\(type.stringRepresentation): \(compactDescription)"
    }
}
