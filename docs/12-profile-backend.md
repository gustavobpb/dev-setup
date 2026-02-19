# Profile: Backend Developer

**Script:** `steps/12-profile-backend.sh`
**Flag:** `--profiles backend`

Installs a polyglot backend development environment with multiple language runtimes managed via `asdf`, plus API testing and load testing tools.

---

## Tools installed

### asdf — multi-language version manager

Cloned from `asdf-vm/asdf` (v0.14.1) into `~/.asdf`. asdf is the base version manager for Go, Java, and Gradle in this profile.

```bash
asdf plugin list all
asdf install golang latest
asdf global golang latest
asdf current
```

---

### Go

Installed via the `asdf-community/asdf-golang` plugin. The latest stable Go release is detected and set as global.

```bash
go version
go env GOPATH
```

---

### Rust

Installed via `rustup` (the official Rust installer at `sh.rustup.rs`). Installs the stable toolchain without modifying shell files (`--no-modify-path`). The cargo environment is sourced from `~/.cargo/env`.

```bash
rustc --version
cargo --version
cargo new my-project
cargo build --release
```

---

### Java LTS (Eclipse Temurin 21)

Installed via the `halcyon/asdf-java` plugin. Targets the `temurin-21.*` LTS release.

```bash
java --version
javac --version
```

---

### Maven

Installed via `apt-get install maven`. Java build and dependency management tool.

```bash
mvn --version
mvn clean install
mvn package
```

---

### Gradle

Installed via `apt-get install gradle`. Falls back to installing via asdf (`asdf install gradle <latest>`) if the apt version is unavailable.

```bash
gradle --version
gradle build
gradle tasks
```

---

### grpcurl — gRPC CLI client

Downloaded from `fullstorydev/grpcurl` GitHub releases. Like `curl` but for gRPC APIs.

```bash
grpcurl -plaintext localhost:50051 list
grpcurl -plaintext -d '{"name": "World"}' localhost:50051 helloworld.Greeter/SayHello
```

---

### websocat — WebSocket client

Downloaded from `vi/websocat` GitHub releases (musl static binary). A CLI WebSocket client for testing WebSocket endpoints.

```bash
websocat ws://localhost:8080/ws
websocat wss://echo.websocket.org
```

---

### k6 — load testing

Downloaded as a `.deb` package from `grafana/k6` GitHub releases. A modern load testing tool with a JavaScript scripting API.

```bash
k6 run script.js
k6 run --vus 100 --duration 30s script.js
```

---

### wrk — HTTP benchmarking

Installed via `apt-get install wrk`. Falls back to building from source (`wg/wrk` GitHub). A high-performance HTTP benchmarking tool.

```bash
wrk -t 4 -c 100 -d 30s http://localhost:8080/api
wrk -t 4 -c 100 -d 30s -s script.lua http://localhost:8080/api
```

---

## Progress tracking

This script uses granular sub-step progress keys to avoid re-running long installations:

| Key | Protects |
|-----|---------|
| `12/asdf` | asdf installation |
| `12/go` | Go installation |
| `12/rust` | Rust installation |
| `12/java` | Java installation |
| `12/maven` | Maven installation |
| `12/gradle` | Gradle installation |
| `12/grpcurl` | grpcurl installation |
| `12/websocat` | websocat installation |
| `12/k6` | k6 installation |
| `12/wrk` | wrk installation |

The overall step key `12-profile-backend.sh` is written to `~/.dev-setup.progress` on completion.
