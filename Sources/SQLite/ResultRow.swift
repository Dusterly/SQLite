import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

struct ResultRow {
	private let operation: Operation
	private let connection: Connection

	init(operation: Operation, connection: Connection) {
		self.operation = operation
		self.connection = connection
	}

	func columnValues() throws -> [String: ResultValue] {
		return Dictionary(uniqueKeysWithValues: try columnValuePairs().compactMap {
			guard let value = $1 else { return nil }
			return ($0, value)
		})
	}

	private func columnValuePairs() throws -> [(String, ResultValue?)] {
		return try (0..<sqlite3_column_count(operation.stmtPointer)).compactMap { index in
			guard let columnName = columnName(at: index) else { throw connection.lastError() }
			return (columnName, try value(at: index))
		}
	}

	private func value(at index: Int32) throws -> ResultValue? {
		guard let type = try type(ofColumnAt: index) else { return nil }
		return type.init(operation: operation, index: index)
	}

	func value<T: ResultValue>(at index: Int32) -> T? {
		guard sqlite3_column_type(operation.stmtPointer, index) != SQLITE_NULL else { return nil }
		return T(operation: operation, index: index)
	}

	private func columnName(at index: Int32) -> String? {
		return String(validatingUTF8: sqlite3_column_name(operation.stmtPointer, index))
	}

	private func type(ofColumnAt index: Int32) throws -> ResultValue.Type? {
		switch sqlite3_column_type(operation.stmtPointer, index) {
		case SQLITE_INTEGER: return Int.self
		case SQLITE_FLOAT: return Double.self
		case SQLITE_TEXT: return String.self
		case SQLITE_BLOB: return Data.self
		case SQLITE_NULL: return nil
		default: throw SQLiteError.generic
		}
	}
}
