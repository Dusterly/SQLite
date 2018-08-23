import Foundation

#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

public protocol Parameter {
	func bind(to enactment: Enactment, at index: Int32) -> Int32
}

extension Int: Parameter {
	public func bind(to enactment: Enactment, at index: Int32) -> Int32 {
		return sqlite3_bind_int64(enactment.pointer, index, Int64(self))
	}
}

extension Double: Parameter {
	public func bind(to enactment: Enactment, at index: Int32) -> Int32 {
		return sqlite3_bind_double(enactment.pointer, index, self)
	}
}

extension Data: Parameter {
	public func bind(to enactment: Enactment, at index: Int32) -> Int32 {
		return withUnsafeBytes {
			return sqlite3_bind_blob(enactment.pointer, index, $0, Int32(count)) { _ in }
		}
	}
}

extension String: Parameter {
	public func bind(to enactment: Enactment, at index: Int32) -> Int32 {
		let cstring = cString(using: .utf8)
		return sqlite3_bind_text(enactment.pointer, index, cstring, Int32(utf8.count)) { _ in }
	}
}
