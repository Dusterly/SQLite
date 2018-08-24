import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public struct Operation {
	let stmtPointer: OpaquePointer
	private let connection: Connection

	init(connection: Connection, query: String, parameters: [Parameter]) throws {
		self.stmtPointer = try pointer(preparingQuery: query, connection: connection)
		self.connection = connection

		for (index, parameter) in parameters.enumerated() {
			try parameter.apply(to: self, at: index + 1, for: connection)
		}
	}

	func execute() throws {
		guard sqlite3_step(stmtPointer) == SQLITE_DONE else { throw connection.lastError() }
	}

	func scalar<T: ResultValue>() throws -> T? {
		guard sqlite3_step(stmtPointer) == SQLITE_ROW else { throw connection.lastError() }
		defer { sqlite3_finalize(stmtPointer) }
		return ResultRow(operation: self, connection: connection).value(at: 0)
	}

	func resultSet() throws -> [[String: ResultValue]] {
		var result: [[String: ResultValue]] = []
		while sqlite3_step(stmtPointer) == SQLITE_ROW {
			let row = ResultRow(operation: self, connection: connection)
			result.append(try row.columnValues())
		}

		return result
	}
}

private func pointer(preparingQuery query: String, connection: Connection) throws -> OpaquePointer {
	var stmtPointer: OpaquePointer?
	let result = sqlite3_prepare_v2(connection.connPointer, query, Int32(query.utf8.count), &stmtPointer, nil)
	guard result == SQLITE_OK else { throw connection.lastError() }
	guard let pointer = stmtPointer, result == SQLITE_OK else { throw connection.lastError() }
	return pointer
}
