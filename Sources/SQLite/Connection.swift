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

	public func scalar(executing query: String) -> Int {
		var stmtPointer: OpaquePointer?
		sqlite3_prepare_v2(pointer, query, Int32(query.utf8.count), &stmtPointer, nil)
		sqlite3_step(stmtPointer)
		return Int(sqlite3_column_int64(stmtPointer, 0))
	}

	public func scalar(executing query: String) -> String {
		var stmtPointer: OpaquePointer?
		sqlite3_prepare_v2(pointer, query, Int32(query.utf8.count), &stmtPointer, nil)
		sqlite3_step(stmtPointer)
		let cstring = sqlite3_column_text(stmtPointer, 0)!
		return String(cString: cstring)
	}
}

private enum SQLiteError: Error {
	case error
}
