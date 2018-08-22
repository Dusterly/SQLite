import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public protocol ResultValue {
	init(stmt: OpaquePointer, index: Int32)
}

extension Int: ResultValue {
	public init(stmt: OpaquePointer, index: Int32) {
		self = Int(sqlite3_column_int64(stmt, index))
	}
}

extension Double: ResultValue {
	public init(stmt: OpaquePointer, index: Int32) {
		self = sqlite3_column_double(stmt, index)
	}
}

extension Data: ResultValue {
	public init(stmt: OpaquePointer, index: Int32) {
		let bytes = sqlite3_column_blob(stmt, index)!
		let length = Int(sqlite3_column_bytes(stmt, index))
		self.init(bytes: bytes, count: length)
	}
}

extension String: ResultValue {
	public init(stmt: OpaquePointer, index: Int32) {
		let cstring = sqlite3_column_text(stmt, index)!
		self.init(cString: cstring)
	}
}
