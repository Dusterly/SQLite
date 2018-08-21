import XCTest

import SQLiteTests

var tests = [XCTestCaseEntry]()
tests += SQLiteTests.allTests()
XCTMain(tests)