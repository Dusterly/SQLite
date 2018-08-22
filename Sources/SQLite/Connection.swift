import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public class Connection {
	var pointer: OpaquePointer?

	public init(path: String) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_open_v2(path, &pointer, SQLITE_OPEN_READONLY, nil)

		guard [SQLITE_OK, SQLITE_ROW, SQLITE_DONE].contains(result) else { throw SQLiteError.error }

		self.pointer = pointer
	}

	public func scalar<T: ResultValue>(executing query: String) -> T? {
		let stmtPointer = pointer(preparing: query)
		sqlite3_step(stmtPointer)
		return ResultRow(stmtPointer: stmtPointer).value(at: 0)
	}

	public func resultSet(executing query: String) throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		let stmtPointer = pointer(preparing: query)

		while sqlite3_step(stmtPointer) == SQLITE_ROW {
			let row = ResultRow(stmtPointer: stmtPointer)
			result.append(try row.values())
		}

		return result
	}

	private func pointer(preparing query: String) -> OpaquePointer {
		var stmtPointer: OpaquePointer?
		sqlite3_prepare_v2(pointer, query, Int32(query.utf8.count), &stmtPointer, nil)
		return stmtPointer!
	}
}

enum SQLiteError: Error {
	case error
	case unknown
}
