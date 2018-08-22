import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

struct ResultRow {
	let stmtPointer: OpaquePointer

	func value<T: ResultValue>(at index: Int) -> T? {
		guard sqlite3_column_type(stmtPointer, 0) != SQLITE_NULL else { return nil }
		return T(stmt: stmtPointer, index: 0)
	}
}
