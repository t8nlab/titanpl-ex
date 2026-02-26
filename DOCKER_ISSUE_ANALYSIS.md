# Docker Startup Issue Analysis

This document outlines the root cause of the silent exits encountered when running the TitanPL server inside Docker.

## 🚨 The Main Problem: Dockerfile Logic (Not Rust Code)

Contrary to initial impressions, the Rust source code was functioning correctly. The "silent exit" was caused by a flawed build sequence in the `Dockerfile`.

### 1. The "Ghost Binary" Bug
The original `Dockerfile` used a common optimization to cache dependencies:
```dockerfile
RUN mkdir -p server/src
COPY server/Cargo.toml server/Cargo.lock* server/
RUN echo "fn main(){}" > server/src/main.rs
WORKDIR /app/server
RUN cargo build --release
```
This builds a "dummy" binary. However, after the real source code was copied in, there was **no second `cargo build` command**.
*   **Result**: The container was packaging and running the dummy "do-nothing" binary instead of the real server. This is why it exited immediately with code 0 and no logs.

### 2. GLIBC Version Mismatch
The `@titanpl/core` native extension was compiled against a modern environment requiring **GLIBC 2.39**. 
*   **Old Image**: `debian:bookworm-slim` (provided GLIBC 2.36).
*   **Symptom**: The binary would fail to link at runtime, causing a crash before any Rust code (including logs) could execute.
*   **Fix**: Upgraded the runner to `ubuntu:24.04` which provides GLIBC 2.39+.

### 3. CPU Instruction Set Conflicts
The use of `-C target-cpu=native` in the `RUSTFLAGS` was causing the compiler to optimize for the host machine's CPU (e.g., your Windows dev machine). When run inside a virtualized Docker container, these "native" instructions often caused illegal instruction crashes.

---

## 🛠️ Summary of Refactoring

While the Dockerfile was the primary culprit, we performed several "hardening" steps in the Rust code to ensure that *any* future issues are immediately visible:

| Feature | Change | Result |
| :--- | :--- | :--- |
| **Visibility** | Phase 1-6 Logging | Explicitly see where the boot process stops. |
| **Error Handling** | Removed silent fallbacks | Missing config now triggers a fatal error instead of a default. |
| **Single-Binary** | Asset Embedding | `routes.json` and JS actions are baked into the binary. |
| **Portability** | `t.fs` Polyfill | JS actions look for files in the binary before the disk. |

**The server is now robust against both code errors and environment mismatches.**
