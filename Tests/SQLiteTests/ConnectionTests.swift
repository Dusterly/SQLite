import Foundation
import SQLite
import XCTest

class ConnectionTests: XCTestCase {
	func testThrowsIfDatabaseDoesNotExist() {
		XCTAssertThrowsError(try Connection(path: "doesn't exist.sqlite"))
	}

	func testConnectsToExistingDatabase() throws {
		_ = try Connection(path: pathToTestDB)
	}

	static let allTests = [
		("testThrowsIfDatabaseDoesNotExist", testThrowsIfDatabaseDoesNotExist),
		("testConnectsToExistingDatabase", testConnectsToExistingDatabase),
	]
}
