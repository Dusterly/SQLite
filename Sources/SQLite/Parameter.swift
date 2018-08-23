import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public protocol Parameter {
	func statusCode(applyingTo enactment: Enactment, at index: Int32) -> Int32
}

extension Parameter {
	public func apply(to enactment: Enactment, at index: Int, for connection: Connection) throws {
		guard statusCode(applyingTo: enactment, at: Int32(index)) == SQLITE_OK else { throw connection.lastError() }
	}
}

extension Int: Parameter {
	public func statusCode(applyingTo enactment: Enactment, at index: Int32) -> Int32 {
		return sqlite3_bind_int64(enactment.pointer, index, Int64(self))
	}
}

extension Double: Parameter {
	public func statusCode(applyingTo enactment: Enactment, at index: Int32) -> Int32 {
		return sqlite3_bind_double(enactment.pointer, index, self)
	}
}

extension Data: Parameter {
	public func statusCode(applyingTo enactment: Enactment, at index: Int32) -> Int32 {
		return withUnsafeBytes {
			return sqlite3_bind_blob(enactment.pointer, index, $0, Int32(count)) { _ in }
		}
	}
}

extension String: Parameter {
	public func statusCode(applyingTo enactment: Enactment, at index: Int32) -> Int32 {
		let cstring = cString(using: .utf8)
		return sqlite3_bind_text(enactment.pointer, index, cstring, Int32(utf8.count)) { _ in }
	}
}
