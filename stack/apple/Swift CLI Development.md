# Swift CLI Development

We assume here that the CLI should run on macOS and Linux.

## References

- https://www.swift.org/getting-started/cli-swiftpm/
- https://www.swift.org/get-started/command-line-tools/

## Stack

### Basics

- [CommandLine](https://developer.apple.com/documentation/swift/commandline)
	- Enum from the Swift standard library 
	- `CommandLine.arguments   // [argv0, ...]  always been there`
	- `CommandLine.executablePath  // FilePath?  — SE-0513, recent 6.x`
	- If `executablePath` doesn’t compile, your toolchain predates it; `CommandLine.arguments[0]` is *not* a substitute (relative, or just the name from `PATH`).
	- ⚠️ Don't read `CommandLine.arguments` when using `ArgumentParser` anyway. `CommandLine.executablePath` is the one exception — “where is this binary?” — which ArgumentParser doesn’t answer.
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
- CLI Chrome: https://github.com/tuist/Noora (Swift.org-recommended)
- TUI (fullscreen): https://github.com/SwiftTUI/swift-tui (unofficial)

## How

### Basic Template

#### Package.swift

`platforms` is the Apple minimum only; Linux still builds. Put the @main command in `Sources/MyTool/`:

```swift
// swift-tools-version: 6.1
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
        .package(url: "https://github.com/apple/swift-system",
                 from: "1.8.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyTool",
            dependencies: [
                .product(name: "ArgumentParser",
                         package: "swift-argument-parser"),
                .product(name: "SystemPackage",
                         package: "swift-system"),
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


#### Program

Sources in `Sources/MyTool/`:

```swift
import ArgumentParser

@main
struct MyTool: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
	    // by default camel case types result in kebab case commands
        commandName: "mytool", // default here would be my-tool
        abstract: "Does the thing.",
        version: "1.0.0",
        subcommands: [MySubcommand.self]
    )
    
    // options & flags are named and have no position but are not inherited by subcommands, so we define them on the subcommand that actually runs

	// no run method since we have subcommands. MyTool here is only a "dispatcher"
}

struct MySubcommand: AsyncParsableCommand {
	// arguments are positional. order is declaration order.
	// put arguments only on leaf commands - not on commands that have subcommands
    @Argument(help: "Path to the input.")
	var input: String          // mytool my-subcommand ./file.txt
	
	// named, order position irrelevant
	@Option(help: "Timeout in seconds.")
	var timeout: Int = 30      // mytool my-subcommand ./file.txt --timeout 10
	
	// named, order position irrelevant
	@Flag(name: .shortAndLong, // mytool my-subcommand ./file.txt --timeout 10 -v
		  help: "Print more output.")
	var verbose = false
	
	// mutating because can change properties. Must keep keyword even if no mutation.
    mutating func run() async throws { /* ... */ }
}
```

To reuse certain sets of options and flags, use `ParsableArguments` and `@OptionGroup`.

#### Tests

Tests in `Tests/MyToolTests/`:

```swift
import Testing
import ArgumentParser
@testable import MyTool

@Test func parsesInput() throws {
    let command = try MySubcommand.parse(["hello"])
    #expect(command.input == "hello")
}
```

### Test, Run, Build

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

### Working With Paths

Use `FilePath` when actually working with paths. Convert to `URL` only at the Foundation I/O call (`Data(contentsOf:)`, `FileManager`). Never store actual paths as `URL` — `URL(string:)` is the wrong parser for file paths.

| Example Use Case | Get it from |
|---|---|
| **file path argument** | `@Argument var input: String` then `FilePath(input)`. Add `completion: .file()`. |
| **`~/.config/my-tool/`** | `HOME` / `XDG_CONFIG_HOME` + append. `FilePath` does **not** expand `~`. |
| **path to this binary** | `CommandLine.executablePath` (SE-0513). **Not** `Bundle.main` — that’s wrong for SPM CLIs. **Not** cwd. |

Cwd (where it was *invoked from*) is separate: `FileManager.default.currentDirectoryPath` → `FilePath`.

```swift
import Foundation
#if canImport(System)
import System
#else
import SystemPackage
#endif

let configHome = ProcessInfo.processInfo.environment["XDG_CONFIG_HOME"]
    .map(FilePath.init)
    ?? FilePath(ProcessInfo.processInfo.environment["HOME"]!).appending(".config")
let config = configHome.appending("my-tool")
try FileManager.default.createDirectory(
    at: URL(filePath: config.string),
    withIntermediateDirectories: true
)
```

### Running Shell Commands

Composing other CLIs is normal. The boundary is **your domain vs someone else’s tool**.

**Stay in Swift** when it’s your logic, or a library already exists (`swift-system` for files, a Git library vs `git`, JSON via `JSONDecoder`, etc.).

**Shell out** when the other tool *is* the product: `git`, `ffmpeg`, `docker`, `xcodebuild`, `gh`. Reimplementing those is a trap. Also shell out for one-shot system utilities (`which`, `uname`) you don’t want to wrap.

Use **`swift-subprocess`**, not `Foundation.Process`, not `/bin/sh -c "…"`. It uses `FilePath` in some APIs (`.path(_:)`, working directory) but does **not** re-export it — still `import System` / `SystemPackage`. `1.0` needs Swift 6.2:

```swift
.package(url: "https://github.com/swiftlang/swift-subprocess", from: "1.0.0"),
// target:
.product(name: "Subprocess", package: "swift-subprocess"),
```

Example:

```swift
import Subprocess
#if canImport(System)
import System
#else
import SystemPackage
#endif

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

### Agent-Friendly APIs

#### General Approach

1. **Provide one and the same CLI API for humans and agents.**
	- Good pattern: one binary, humans and agents both call it. Potential TUI is a *subcommand* (`my-tool tui`), not mixed into data commands. MCP/skills are thin adapters on top, not a second product.
2. **The CLI API should allow to input all data via launch arguments/options and then run without waiting on further prompts.**
	- Agents are bad at interactive CLIs (inputting data after launch, like text, decisions, passwords).

- ArgumentParser flags = the API. Noora only when stdin is a TTY.
- `--json` (and/or JSON-when-piped).
- `--yes` / `--non-interactive` / `MYTOOL_NONINTERACTIVE=1`.
- Stable exit codes.
- Optional later: `mytool commands --json`, a skill, or `mytool mcp`.

Don’t build `mytool-agent`. Agents already shell out; they need a boring, complete, non-interactive CLI.

#### Safe Baseline / MVP

The agent-safe baseline is non-interactive and non-Noora: flags in, text (or JSON) out, exit. No conversation after launch.

That's also the MVP. Not optimally convenient for humans, but definitely works for humans and agents alike. It’s the one agents and scripts can actually use. Interactivity is a later convenience, not part of an MVP.

- Non-Interactive
	- Prompts are what you avoid. Not because agents can’t read them — because the command never finishes until something types.
	- if data is missing, give feedback and exit. don't ask for that missing data.
	- ArgumentParser already is the agent API: flags, --help, typed args, non-zero exit on bad input.
	- don’t readLine() / wait for a TTY
	- don’t run interactive subprocesses (git, ssh, docker login) without their non-interactive flags
- Non-Noora
	- put the result on stdout as plain text or --json
	- keep chatter on stderr
	- JSON/--jq is an extra for chaining IDs and MCP, not for the LLM to “understand” the CLI.
	- Noora is optional human chrome on top.

Humans get a slightly dry CLI. Agents get something they can actually call. Add Noora later only for prompts/progress that always have a flag equivalent.

#### Use Noora Only Carefully
 
**Restrain prompts, not chrome.** You cannot reliably tell agent from human.

TTY detection (`isatty`) is the usual proxy: piped/`CI`/`--json` → machine mode. Agents often **fake a TTY** (Claude Code, Codex), which is why `hey` for example uses `HEY_NONINTERACTIVE=1`. Detection is a hint, not a guarantee.

| Noora | Agent-safe? |
|---|---|
| Colors, alerts, progress on **stderr** | Yes, if they no-op when not a TTY / `--json` |
| Prompts (yes/no, pickers, text) | **No** unless every one has a flag and you skip them when `--non-interactive`, `*_NONINTERACTIVE=1`, or stdin isn’t a TTY |

Human-friendly default: missing flag → prompt. Agent-friendly default: missing flag + non-interactive → error or a documented default, never wait.

The CLI is one API. Noora is optional presentation for a real terminal, never the only way to supply a value.