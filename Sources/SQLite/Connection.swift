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

	private var lastInsertedID: Int {
		return Int(sqlite3_last_insert_rowid(pointer))
	}

	public init(path: String) throws {
		var pointer: OpaquePointer?
		let result = sqlite3_open_v2(path, &pointer, SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX, nil)

		guard result == SQLITE_OK else { throw sqliteError(messageFrom: pointer) }

		self.pointer = pointer!
	}

	deinit { sqlite3_close(pointer) }

	public func execute(_ enactment: String, _ parameters: Parameter...) throws {
		let enactment = try Enactment(connection: self, query: enactment, parameters: parameters)
		try enactment.execute()
	}

	public func insertedID(executing enactment: String, _ parameters: Parameter...) throws -> Int {
		try execute(enactment, parameters: parameters)
		return lastInsertedID
	}

	private func execute(_ enactment: String, parameters: [Parameter]) throws {
		let enactment = try Enactment(connection: self, query: enactment, parameters: parameters)
		try enactment.execute()
	}

	public func scalar<T: ResultValue>(executing query: String, _ parameters: Parameter...) throws -> T? {
		let enactment = try Enactment(connection: self, query: query, parameters: parameters)
		return try enactment.scalar()
	}

	public func resultSet(executing query: String, _ parameters: Parameter...) throws -> ResultSet {
		let enactment = try Enactment(connection: self, query: query, parameters: parameters)
		return try enactment.resultSet()
	}

	func lastError() -> SQLiteError {
		return sqliteError(messageFrom: pointer)
	}
}

enum SQLiteError: Error {
	case generic
	case message(String)
}

private func sqliteError(messageFrom pointer: OpaquePointer?) -> SQLiteError {
	guard let message = String(validatingUTF8: sqlite3_errmsg(pointer)) else { return .generic }
	return .message(message)
}
