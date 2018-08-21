#if os(macOS)
import Libsqlite3Mac
#else
import Libsqlite3Linux
#endif

struct SQLite {
    var text = "Hello, World!"
}
