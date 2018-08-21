import XCTest
@testable import SQLite

final class SQLiteTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SQLite().text, "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
