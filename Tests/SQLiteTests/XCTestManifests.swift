import XCTest
#if !os(macOS)
public let allTests = [
	testCase(ConnectionTests.allTests),
	testCase(FireflyTests.allTests),
]
#endif
