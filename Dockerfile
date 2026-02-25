# ================================================================
# STAGE 1 — Builder (Node + Rust)
# ================================================================
FROM node:20.20.0-slim AS builder

# ---- System deps ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential pkg-config libssl-dev git bash \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
       sh -s -- -y --default-toolchain stable --profile minimal \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV NODE_ENV=production
ENV RUSTFLAGS="-C strip=symbols"

WORKDIR /app

# ------------------------------------------------
# 1️⃣ Rust Dependency Cache Layer
# ------------------------------------------------
RUN mkdir -p server/src
COPY server/Cargo.toml server/Cargo.lock* server/
RUN echo "fn main(){}" > server/src/main.rs

WORKDIR /app/server
RUN cargo build --release
RUN rm src/main.rs

WORKDIR /app

# ------------------------------------------------
# 2️⃣ Node Dependency Cache Layer
# ------------------------------------------------
COPY package.json package-lock.json* ./
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Install Titan CLI globally
RUN npm install -g @ezetgalaxy/titan@latest

# ------------------------------------------------
# 3️⃣ Copy Full Project
# ------------------------------------------------
COPY . .

# ------------------------------------------------
# 4️⃣ Extract Extensions
# ------------------------------------------------
SHELL ["/bin/bash", "-c"]
RUN mkdir -p /app/.ext && \
    if [ -d node_modules ]; then \
      find node_modules -type f -name "titan.json" -print0 | \
      while IFS= read -r -d '' file; do \
        pkg_dir="$(dirname "$file")"; \
        pkg_name="$(basename "$pkg_dir")"; \
        cp -r "$pkg_dir" "/app/.ext/$pkg_name"; \
        rm -rf "/app/.ext/$pkg_name/node_modules"; \
      done; \
    fi

# ------------------------------------------------
# 5️⃣ Titan Production Build
# ------------------------------------------------
RUN titan build



# ================================================================
# STAGE 2 — Runtime (Minimal, Node-Free)
# ================================================================
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- Copy production artifacts ----
COPY --from=builder /app/server/target/release/titan-server ./titan-server
COPY --from=builder /app/server/routes.json ./
COPY --from=builder /app/server/action_map.json ./
COPY --from=builder /app/server/src/actions ./actions
COPY --from=builder /app/.ext ./.ext

# Optional folders (uncomment if needed)
# COPY --from=builder /app/app/static ./static
# COPY --from=builder /app/app/public ./public
COPY --from=builder /app/app/db ./db

# ---- Security hardening ----
RUN chmod +x ./titan-server && \
    useradd -m titan && \
    chown -R titan:titan /app

USER titan

# ---- Platform defaults ----
ENV HOST=0.0.0.0
ENV PORT=5100

EXPOSE 5100

CMD ["./titan-server"]