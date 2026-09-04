# Swift CLI Development for macOS and Linux

## Stack

### Basics

- https://github.com/apple/swift-argument-parser
- https://github.com/swiftlang/swift-subprocess

### Foundation Framework

Just `import Foundation`. No package dependency.

On Linux, `import Foundation` is narrower than on Darwin — networking and XML are separate modules. For the actually-broadest portable surface:

```swift
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
#if canImport(FoundationXML)
import FoundationXML
#endif
```

That compiles on macOS (those modules don’t exist, `canImport` is false) and on Linux (they do). `URL` itself stays in `Foundation`; `URLSession` / `URLRequest` need the networking import.

Don’t use `FoundationEssentials` if you want breadth — that’s the *narrower* shared subset.

### Specific I/O

- low-level system: https://github.com/apple/swift-system
	- Import quirk on Linux vs Darwin:
	  ```swift
	  #if canImport(System)
	  import System
	  #else
	  import SystemPackage
	  #endif
	  ```
- TUI: https://github.com/tuist/Noora

## How

### Basics

#### Program

Sources in `Sources/MyTool/`:

```swift
@main
struct MyTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "mytool",
        abstract: "Does the thing.",
        version: "1.0.0"
    )

    @Argument(help: "Path to the input.")
    var input: String

    mutating func run() async throws { /* ... */ }
}
```

#### Tests

Tests in `Tests/MyToolTests/`:

```swift
import Testing
import ArgumentParser
@testable import MyTool

@Test func parsesInput() throws {
    let command = try MyTool.parse(["hello"])
    #expect(command.input == "hello")
}
```

#### Package.swift

`platforms` is the Apple minimum only; Linux still builds. Put the @main command in `Sources/MyTool/`:

```swift
// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MyTool",
    platforms: [.macOS(.v13)],
    products: [
        .executable(name: "mytool", 
                    targets: ["MyTool"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser",
                 from: "1.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyTool",
            dependencies: [
                .product(name: "ArgumentParser",
                         package: "swift-argument-parser"),
            ]
        ),
        .testTarget(
		    name: "MyToolTests",
		    dependencies: [
		        "MyTool",
		        .product(name: "ArgumentParser",
		                 package: "swift-argument-parser"),
		    ]
		)
    ]
)
```

#### Test, Run, Build

```bash
swift test
swift run

# on macOS
swift build -c release   # .build/release/mytool

# on Linux
swift build -c release --static-swift-stdlib

# on macOS for Linux (cross-compile)
# requires swift.org toolchain (swiftly), not Xcode’s
swift sdk install <static-linux-sdk-url-matching-your-swift>
swift build -c release --swift-sdk x86_64-swift-linux-musl
swift build -c release --swift-sdk aarch64-swift-linux-musl
```

### Running Shell Commands

Composing other CLIs is normal. The boundary is **your domain vs someone else’s tool**.

**Stay in Swift** when it’s your logic, or a library already exists (`swift-system` for files, a Git library vs `git`, JSON via `JSONDecoder`, etc.).

**Shell out** when the other tool *is* the product: `git`, `ffmpeg`, `docker`, `xcodebuild`, `gh`. Reimplementing those is a trap. Also shell out for one-shot system utilities (`which`, `uname`) you don’t want to wrap.

Use **`swift-subprocess`**, not `Foundation.Process`, not `/bin/sh -c "…"`. Example:

```swift
import Subprocess

let result = try await run(
    .name("git"),                    // PATH lookup; use .path("/usr/bin/git") to pin
    arguments: ["status", "--porcelain"],
    output: .string(limit: 1_048_576)
)

guard result.terminationStatus.isSuccess else {
    throw MyError.gitFailed(result.terminationStatus)
}
print(result.standardOutput ?? "")
```

Stream instead of collect when output is large or live:

```swift
try await run(.name("ffmpeg"), arguments: args) { _, stdout in
    for try await line in stdout.lines(encoding: UTF8.self) {
        // progress
    }
}
```

Rules of thumb:
- Pass `arguments: [String]` — never interpolate into a shell string (quoting/injection).
- Prefer `.name("git")` for user-installed tools; `.path(...)` when the binary is part of your contract.
- Check `terminationStatus`. Non-zero is the error channel; stderr is the message.
- Don’t go through `bash`/`zsh` unless you truly need globbing, pipes, or a user’s shell config — and then you probably still don’t.

Typical shape of a Swift CLI: ArgumentParser for the interface, Swift for orchestration, subprocess for the heavy existing tools.