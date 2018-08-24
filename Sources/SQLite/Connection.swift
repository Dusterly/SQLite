import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public typealias ResultSet = [[String: ResultValue]]

public class Connection {
	let connPointer: OpaquePointer

	private var lastInsertedID: Int {
		return Int(sqlite3_last_insert_rowid(connPointer))
	}

	public init(path: String) throws {
		connPointer = try pointer(openingDatabaseAtPath: path)
	}

	deinit { sqlite3_close(connPointer) }

	public func execute(_ statement: String, _ parameters: Parameter...) throws {
		let operation = try Operation(connection: self, query: statement, parameters: parameters)
		try operation.execute()
	}

	public func insertedID(executing statement: String, _ parameters: Parameter...) throws -> Int {
		try execute(statement, parameters: parameters)
		return lastInsertedID
	}

	private func execute(_ statement: String, parameters: [Parameter]) throws {
		let operation = try Operation(connection: self, query: statement, parameters: parameters)
		try operation.execute()
	}

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Parameter...) throws -> T? {
		let operation = try Operation(connection: self, query: query, parameters: parameters)
		return try operation.scalar()
	}

	public func resultSet(executing query: String, _ parameters: Parameter...) throws -> ResultSet {
		let operation = try Operation(connection: self, query: query, parameters: parameters)
		return try operation.resultSet()
	}

	func lastError() -> SQLiteError {
		return sqliteError(messageFrom: connPointer)
	}
}

enum SQLiteError: Error {
	case generic
	case message(String)
}

private func pointer(openingDatabaseAtPath path: String) throws -> OpaquePointer {
	var openedPointer: OpaquePointer?
	let result = sqlite3_open_v2(path, &openedPointer, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)
	guard let pointer = openedPointer, result == SQLITE_OK else { throw sqliteError(messageFrom: openedPointer) }
	return pointer
}

private func sqliteError(messageFrom pointer: OpaquePointer?) -> SQLiteError {
	guard let message = String(validatingUTF8: sqlite3_errmsg(pointer)) else { return .generic }
	return .message(message)
}
