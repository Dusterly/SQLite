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

		let result: Int? = connection.scalar(executing: "select count(*) from Crew")

		XCTAssertEqual(result, 8)
	}

	func testHandlesText() throws {
		let connection = try Connection(path: pathToTestDB)

		let result: String? = connection.scalar(executing: "select 'Hey, Kaylee'")

		XCTAssertEqual(result, "Hey, Kaylee")
	}

	func testHandlesBlob() throws {
		let connection = try Connection(path: pathToTestDB)

		let result: Data? = connection.scalar(executing: "select data from TestData where data is not null")

		XCTAssertEqual(result, "data_only".data(using: .ascii))
	}

	func testHandlesReal() throws {
		let connection = try Connection(path: pathToTestDB)
		let result: Double? = connection.scalar(executing: "select 3.0")

		XCTAssertEqual(result, 3.0)
	}

	func testHandlesNull() throws {
		let connection = try Connection(path: pathToTestDB)

		XCTAssertNil(connection.scalar(executing: "select null") as Int?)
		XCTAssertNil(connection.scalar(executing: "select null") as Double?)
		XCTAssertNil(connection.scalar(executing: "select null") as String?)
		XCTAssertNil(connection.scalar(executing: "select null") as Data?)
	}

	func testCanReturnRows() throws {
		let connection = try Connection(path: pathToTestDB)

		let result = try connection.resultSet(executing: "select * from Crew")

		XCTAssertEqual(result.count, 8)

		guard let row = result.first else { return XCTFail("no rows") }
		XCTAssertEqual(row["name"] as? String, "Mal")
		XCTAssertEqual(row["role"] as? String, "Captain")
	}

	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
		("testFindsTheCrew", testFindsTheCrew),
		("testHandlesText", testHandlesText),
		("testHandlesBlob", testHandlesBlob),
		("testHandlesReal", testHandlesReal),
		("testHandlesNull", testHandlesNull),
		("testCanReturnRows", testCanReturnRows),
	]
}
