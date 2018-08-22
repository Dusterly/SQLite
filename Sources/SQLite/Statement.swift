import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

struct Statement {
	let pointer: OpaquePointer

	init(connection: Connection, query: String, parameters: [Int]) {
		var pointer: OpaquePointer?
		sqlite3_prepare_v2(connection.pointer, query, Int32(query.utf8.count), &pointer, nil)
		self.pointer = pointer!

		for (index, parameter) in parameters.enumerated() {
			sqlite3_bind_int64(pointer, Int32(index + 1), Int64(parameter))
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
