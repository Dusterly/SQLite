import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public struct Statement {
	let pointer: OpaquePointer
	private let connection: Connection

	init(connection: Connection, query: String, parameters: [Parameter]) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_prepare_v2(connection.pointer, query, Int32(query.utf8.count), &pointer, nil)

		guard result == SQLITE_OK else { throw connection.lastError() }
// swiftlint:disable force_unwrapping
		self.pointer = pointer!
		self.connection = connection
// swiftlint:enable force_unwrapping

		for (index, parameter) in parameters.enumerated() {
			_ = parameter.bind(to: self, at: Int32(index + 1))
		}
	}

	func execute() throws {
		guard sqlite3_step(pointer) == SQLITE_DONE else { throw connection.lastError() }
	}

	func scalar<T: ResultValue>() throws -> T? {
		guard sqlite3_step(pointer) == SQLITE_ROW else { throw connection.lastError() }
		defer { sqlite3_finalize(pointer) }
		return ResultRow(stmtPointer: pointer, connection: connection).value(at: 0)
	}

	func resultSet() throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		while sqlite3_step(pointer) == SQLITE_ROW {
			let row = ResultRow(stmtPointer: pointer, connection: connection)
			result.append(try row.columnValues())
		}

		return result
	}
}
