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
		guard sqlite3_column_type(stmtPointer, 0) != SQLITE_NULL else { return nil }
		return T(stmt: stmtPointer, index: 0)
	}

	private func pointer(preparing query: String) -> OpaquePointer {
		var stmtPointer: OpaquePointer?
		sqlite3_prepare_v2(pointer, query, Int32(query.utf8.count), &stmtPointer, nil)
		return stmtPointer!
	}
}

private enum SQLiteError: Error {
	case error
}
