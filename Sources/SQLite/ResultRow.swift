import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

struct ResultRow {
	let stmtPointer: OpaquePointer

	func values() throws -> [String: ResultValue] {
		let columnCount = sqlite3_column_count(stmtPointer)
		var row: [String: ResultValue] = [:]

		for index in 0..<columnCount {
			guard let columnName = columnName(at: index) else { continue }
			guard let datatype = try datatype(at: index) else { continue }
			row[columnName] = value(at: index, as: datatype)
		}
		return row
	}

	private func value(at index: Int32, as datatype: ResultValue.Type) -> ResultValue {
		return datatype.init(stmt: stmtPointer, index: index)
	}

	func value<T: ResultValue>(at index: Int32) -> T? {
		guard sqlite3_column_type(stmtPointer, index) != SQLITE_NULL else { return nil }
		return T(stmt: stmtPointer, index: index)
	}

	private func columnName(at index: Int32) -> String? {
		return String(validatingUTF8: sqlite3_column_name(stmtPointer, index))
	}

	private func datatype(at index: Int32) throws -> ResultValue.Type? {
		switch sqlite3_column_type(stmtPointer, index) {
		case SQLITE_INTEGER: return Int.self
		case SQLITE_FLOAT: return Double.self
		case SQLITE_TEXT: return String.self
		case SQLITE_BLOB: return Data.self
		case SQLITE_NULL: return nil
		default: throw SQLiteError.unknown
		}
	}
}
