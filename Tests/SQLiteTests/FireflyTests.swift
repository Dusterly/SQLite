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
// swiftlint:disable force_try
	private let connection = try! Connection(path: pathToTestDB)
// swiftlint:enable force_try

	override func tearDown() {
		_ = try? connection.execute("drop table if exists Test")
	}

	func testFindsTheCrew() throws {
		let result: Int? = try connection.scalar(executing: "select count(*) from Crew")

		XCTAssertEqual(result, 8)
	}

	func testHandlesText() throws {
		let result: String? = try connection.scalar(executing: "select 'Hey, Kaylee'")

		XCTAssertEqual(result, "Hey, Kaylee")
	}

	func testHandlesBlob() throws {
		let result: Data? = try connection.scalar(executing: "select data from TestData where data is not null")

		XCTAssertEqual(result, "data_only".data(using: .ascii))
	}

	func testHandlesReal() throws {
		let result: Double? = try connection.scalar(executing: "select 3.0")

		XCTAssertEqual(result, 3.0)
	}

	func testHandlesNull() throws {
		XCTAssertNil(try connection.scalar(executing: "select null") as Int?)
		XCTAssertNil(try connection.scalar(executing: "select null") as Double?)
		XCTAssertNil(try connection.scalar(executing: "select null") as String?)
		XCTAssertNil(try connection.scalar(executing: "select null") as Data?)
	}

	func testCanReturnRows() throws {
		let result = try connection.resultSet(executing: "select name, role from Crew")

		XCTAssertEqual(result.count, 8)
		XCTAssertEqual(result.first as? [String: String], ["name": "Mal", "role": "Captain"])
	}

	func testHandlesIntegerParameters() throws {
		let result: Int? = try connection.scalar(executing: "select ?", 4)

		XCTAssertEqual(result, 4)
	}

	func testHandlesIntegerParameters_2() throws {
		let result = try connection.resultSet(executing: "select name, role from Crew where id = ?", 4)

		XCTAssertEqual(result as? [[String: String]], [["name": "Kaylee", "role": "Mechanic"]])
	}

	func testHandlesDoubleParameters() throws {
		let result: Int? = try connection.scalar(executing: "select count(*) from TestData where double = ?", 3.0)

		XCTAssertEqual(result, 1)
	}

	func testHandlesDataParameters() throws {
// swiftlint:disable force_unwrapping
		let result: Int? = try connection.scalar(executing:
			"select count(*) from TestData where data = ?", "data_only".data(using: .ascii)!)
// swiftlint:enable force_unwrapping

		XCTAssertEqual(result, 1)
	}

	func testHandlesStringParameters() throws {
		let result = try connection.resultSet(executing: "select name, role from Crew where name = ?", "Kaylee")

		XCTAssertEqual(result as? [[String: String]], [["name": "Kaylee", "role": "Mechanic"]])
	}

	func testThrowsIfInvalidStatement() {
		XCTAssertThrowsError(try connection.resultSet(executing: "select * from Crew where name = ", "Kaylee"))
	}

	func testExecutesStatements() throws {
		try connection.execute("create table Test ( answer Integer )")
		try connection.execute("insert into Test values (?)", 42)

		let result: Int? = try connection.scalar(executing: "select * from Test")

		XCTAssertEqual(result, 42)
	}

	func testReturnsTheLastInsertedID() throws {
		try connection.execute("create table Test ( id Integer primary key autoincrement, answer Integer )")

		let result = try connection.insertedID(executing: "insert into Test values (null, 43)")

		XCTAssertEqual(1, result)
	}

	static let allTests = [
		("testFindsTheCrew", testFindsTheCrew),
		("testHandlesText", testHandlesText),
		("testHandlesBlob", testHandlesBlob),
		("testHandlesReal", testHandlesReal),
		("testHandlesNull", testHandlesNull),
		("testCanReturnRows", testCanReturnRows),
		("testHandlesIntegerParameters", testHandlesIntegerParameters),
		("testHandlesIntegerParameters_2", testHandlesIntegerParameters_2),
		("testHandlesDoubleParameters", testHandlesDoubleParameters),
		("testHandlesDataParameters", testHandlesDataParameters),
		("testHandlesStringParameters", testHandlesStringParameters),
		("testThrowsIfInvalidStatement", testThrowsIfInvalidStatement),
		("testExecutesStatements", testExecutesStatements),
		("testReturnsTheLastInsertedID", testReturnsTheLastInsertedID),
	]
}
