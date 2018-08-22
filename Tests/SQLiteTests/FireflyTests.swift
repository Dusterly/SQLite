import Foundation
import SQLite
import XCTest

#if os(macOS)
// swiftlint:disable force_unwrapping
let pathToTestDB = Bundle(for: FireflyTests.self).path(forResource: "firefly", ofType: "sqlite")!
// swiftlint:enable force_unwrapping
#else
let pathToTestDB = "Tests/SQLiteTests/firefly.sqlite"
#endif

class FireflyTests: XCTestCase {
	func testThrowsIfDatabaseDoesNotExist() {
		XCTAssertThrowsError(try Connection(path: "doesn't exist.sqlite"))
	}

	func testConnectsToExistingDatabase() throws {
		_ = try Connection(path: pathToTestDB)
	}

	func testFindsTheCrew() throws {
		let connection = try Connection(path: pathToTestDB)

		let result: Int = connection.scalar(executing: "select count(*) from Crew")

		XCTAssertEqual(result, 8)
	}

	func testHandlesText() throws {
		let connection = try Connection(path: pathToTestDB)

		let result: String = connection.scalar(executing: "select 'Hey, Kaylee'")

		XCTAssertEqual(result, "Hey, Kaylee")
	}

	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
		("testFindsTheCrew", testFindsTheCrew),
		("testHandlesText", testHandlesText),
	]
}
