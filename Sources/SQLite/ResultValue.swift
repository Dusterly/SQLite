// swiftlint:disable force_unwrapping
import Foundation
import Libsqlite3

public protocol ResultValue {
	init(operation: Operation, index: Int32)
}

extension Int: ResultValue {
	public init(operation: Operation, index: Int32) {
		self = Int(sqlite3_column_int64(operation.stmtPointer, index))
	}
}

extension Double: ResultValue {
	public init(operation: Operation, index: Int32) {
		self = sqlite3_column_double(operation.stmtPointer, index)
	}
}

extension Data: ResultValue {
	public init(operation: Operation, index: Int32) {
		let bytes = sqlite3_column_blob(operation.stmtPointer, index)!
		let length = Int(sqlite3_column_bytes(operation.stmtPointer, index))
		self.init(bytes: bytes, count: length)
	}
}

extension String: ResultValue {
	public init(operation: Operation, index: Int32) {
		let cstring = sqlite3_column_text(operation.stmtPointer, index)!
		self.init(cString: cstring)
	}
}
