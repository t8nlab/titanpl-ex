# ================================================================
# STAGE 1 — Builder (Node + Rust)
# ================================================================
FROM node:20.20.0-slim AS builder

# ---- System dependencies ----
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential pkg-config libssl-dev git bash \
    && curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | \
       sh -s -- -y --default-toolchain stable --profile minimal \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C strip=symbols"

WORKDIR /app

# ------------------------------------------------
# 1️⃣ Copy entire project first
#    (important for file: deps like @titan/route)
# ------------------------------------------------
COPY . .

# ------------------------------------------------
# 2️⃣ Install Node dependencies
# ------------------------------------------------
RUN if [ -f package-lock.json ]; then npm ci; else npm install; fi

# Install Titan CLI (framework toolchain)
RUN npm install -g @ezetgalaxy/titan@latest

# Optional debug validation (safe to keep)
RUN node -v && titan --version

# ------------------------------------------------
# 3️⃣ Extract Titan Extensions
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
# 4️⃣ Titan Production Build
# ------------------------------------------------
RUN titan build


# ================================================================
# STAGE 2 — Runtime (Minimal, Secure)
# ================================================================
FROM debian:bookworm-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---- Copy compiled Rust binary ----
COPY --from=builder /app/server/target/release/titan-server ./titan-server

# ---- Copy generated runtime metadata ----
COPY --from=builder /app/server/routes.json ./
COPY --from=builder /app/server/action_map.json ./
COPY --from=builder /app/server/src/actions ./actions
COPY --from=builder /app/.ext ./.ext
COPY --from=builder /app/app/db ./db

# ---- Security hardening ----
RUN chmod +x ./titan-server && \
    useradd -m titan && \
    chown -R titan:titan /app

USER titan

ENV HOST=0.0.0.0
ENV PORT=5100

EXPOSE 5100

CMD ["./titan-server"]