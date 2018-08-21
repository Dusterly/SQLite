#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public class Connection {
	public init(path: String) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_open_v2(path, &pointer, SQLITE_OPEN_READONLY, nil)

		guard [SQLITE_OK, SQLITE_ROW, SQLITE_DONE].contains(result) else { throw SQLiteError.error }
	}
}

private enum SQLiteError: Error {
	case error
}
