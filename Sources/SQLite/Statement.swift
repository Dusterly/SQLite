import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public struct Statement {
	let pointer: OpaquePointer

	init(connection: Connection, query: String, parameters: [Parameter]) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_prepare_v2(connection.pointer, query, Int32(query.utf8.count), &pointer, nil)

		guard result == SQLITE_OK else { throw SQLiteError.error }
// swiftlint:disable force_unwrapping
		self.pointer = pointer!
// swiftlint:enable force_unwrapping

		for (index, parameter) in parameters.enumerated() {
			_ = parameter.bind(to: self, at: Int32(index + 1))
		}
	}

	func scalar<T: ResultValue>() -> T? {
		sqlite3_step(pointer)
		return ResultRow(stmtPointer: pointer).value(at: 0)
	}

	func resultSet() throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		while sqlite3_step(pointer) == SQLITE_ROW {
			let row = ResultRow(stmtPointer: pointer)
			result.append(try row.values())
		}

		return result
	}
}
