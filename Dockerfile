# ================================================================
# STAGE 1 — Build TitanPl (Builder Stage)
# ================================================================
FROM node:20.20.0-slim AS builder

# Install build dependencies + Rust
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential pkg-config libssl-dev git bash \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
    sh -s -- -y --default-toolchain stable --profile minimal \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV NODE_ENV=production
# Optimization: strip symbols to reduce binary size
ENV RUSTFLAGS="-C strip=symbols"

WORKDIR /app

# ---------- Rust Dependency Cache ----------
# This speeds up subsequent builds by caching our transitive deps
RUN mkdir -p server/src
COPY server/Cargo.toml server/Cargo.lock* server/
RUN echo "fn main(){}" > server/src/main.rs
WORKDIR /app/server
RUN cargo build --release
RUN rm src/main.rs
WORKDIR /app

# ---------- Node Dependency Cache ----------
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci --omit=dev; else npm i --omit=dev; fi

# Install Titan CLI
RUN npm install -g @ezetgalaxy/titan@latest

# ---------- Copy Project & Prepare Assets ----------
COPY . .

# 1. Bundle JS actions (creates server/src/actions/*.jsbundle)
RUN node app/app.js --build

# 2. Extract Native Extensions
SHELL ["/bin/bash", "-c"]
RUN mkdir -p /app/.ext && \
    find /app/node_modules -type f -name "titan.json" -print0 | \
    while IFS= read -r -d '' file; do \
    pkg_dir="$(dirname "$file")"; \
    pkg_name="$(basename "$pkg_dir")"; \
    cp -r "$pkg_dir" "/app/.ext/$pkg_name"; \
    rm -rf "/app/.ext/$pkg_name/node_modules"; \
    done

# 3. Generate Titan Metadata (routes.json, etc.)
RUN titan build

# 4. 🔥 FINAL RUST BUILD (Compiles real code + includes embedded assets)
# We move into the server directory to ensure all paths for include_str! are correct
WORKDIR /app/server
RUN cargo build --release --locked && \
    cp target/release/titan-server /app/titan-server

# ================================================================
# STAGE 2 — Runtime (Render / Production Safe)
# ================================================================
# We use Ubuntu 24.04 for GLIBC 2.39+ support (required by @titanpl/core)
FROM ubuntu:24.04

# Install minimal runtime dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    libssl3 \
    openssl \
    libgcc-s1 \
    libstdc++6 \
    libc6 && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- Copy Built Binary & Metadata ----
COPY --from=builder /app/titan-server ./titan-server
COPY --from=builder /app/server/routes.json ./routes.json
COPY --from=builder /app/server/action_map.json ./action_map.json
COPY --from=builder /app/server/src/actions ./actions

# ---------------- OPTIONAL APP FOLDERS ----------------
# If you have extra data files, copy them here:
COPY --from=builder /app/app/db ./db
# COPY --from=builder /app/app/static ./static

# Native Extensions
COPY --from=builder /app/.ext ./.ext

# ---- Ensure Executable ----
RUN chmod +x ./titan-server

# ---- Create Isolated User ----
RUN useradd -m titan && chown -R titan:titan /app
USER titan

# ---- Environment Constants ----
ENV HOST=0.0.0.0
ENV PORT=5100
ENV TITAN_DEV=0

# ---- Verify Node Not Present (Best Practice) ----
RUN which node || echo "NodeJS not present ✔"

EXPOSE 5100

# ---- Launch Server ----
CMD ["./titan-server"]