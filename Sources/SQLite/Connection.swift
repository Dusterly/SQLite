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

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Int...) -> T? {
		let stmtPointer = pointer(preparing: query, parameters: parameters)
		bind(parameters, to: stmtPointer)
		sqlite3_step(stmtPointer)
		return ResultRow(stmtPointer: stmtPointer).value(at: 0)
	}

	public func resultSet(executing query: String, _ parameters: Int...) throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		let stmtPointer = pointer(preparing: query, parameters: parameters)
		bind(parameters, to: stmtPointer)

		while sqlite3_step(stmtPointer) == SQLITE_ROW {
			let row = ResultRow(stmtPointer: stmtPointer)
			result.append(try row.values())
		}

		return result
	}

	private func pointer(preparing query: String, parameters: [Int]) -> OpaquePointer {
		var stmtPointer: OpaquePointer?
		sqlite3_prepare_v2(pointer, query, Int32(query.utf8.count), &stmtPointer, nil)
		return stmtPointer!
	}

	private func bind(_ parameters: [Int], to stmtPointer: OpaquePointer) {
		for (index, parameter) in parameters.enumerated() {
			sqlite3_bind_int64(stmtPointer, Int32(index + 1), Int64(parameter))
		}
	}
}

enum SQLiteError: Error {
	case error
	case unknown
}
