// swiftlint:disable force_unwrapping
import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public typealias ResultSet = [[String: ResultValue]]

public class Connection {
	let pointer: OpaquePointer

	public init(path: String) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_open_v2(path, &pointer, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)

		guard result == SQLITE_OK else { throw SQLiteError.fromConnection(pointer: pointer!) }

		self.pointer = pointer!
	}

	public func execute(_ statement: String, _ parameters: Parameter...) throws {
		let statement = try Statement(connection: self, query: statement, parameters: parameters)
		try statement.execute()
	}

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Parameter...) throws -> T? {
		let statement = try Statement(connection: self, query: query, parameters: parameters)
		return try statement.scalar()
	}

	public func resultSet(executing query: String, _ parameters: Parameter...) throws -> ResultSet {
		let statement = try Statement(connection: self, query: query, parameters: parameters)
		return try statement.resultSet()
	}

	func lastError() -> SQLiteError {
		return .fromConnection(pointer: pointer)
	}
}

enum SQLiteError: Error {
	case generic
	case message(String)

	fileprivate static func fromConnection(pointer: OpaquePointer) -> SQLiteError {
		guard let message = String(validatingUTF8: sqlite3_errmsg(pointer)) else { return .generic }
		return .message(message)
	}
}
