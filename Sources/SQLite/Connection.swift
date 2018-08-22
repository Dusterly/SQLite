import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public class Connection {
	let pointer: OpaquePointer

	public init(path: String) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_open_v2(path, &pointer, SQLITE_OPEN_READONLY, nil)

		guard [SQLITE_OK, SQLITE_ROW, SQLITE_DONE].contains(result) else { throw SQLiteError.error }

		self.pointer = pointer!
	}

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Int...) -> T? {
		let statement = Statement(connection: self, query: query, parameters: parameters)
		return statement.scalar()
	}

	public func resultSet(executing query: String, _ parameters: Int...) throws -> [[String: ResultValue]] {
		let statement = Statement(connection: self, query: query, parameters: parameters)
		return try statement.resultSet()
	}
}

enum SQLiteError: Error {
	case error
	case unknown
}
