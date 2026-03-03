# ================================================================
# STAGE 1 — Builder
# ================================================================
FROM node:20.20.0-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl ca-certificates build-essential pkg-config git bash \
    && rm -rf /var/lib/apt/lists/*

ENV npm_config_platform=linux
ENV npm_config_arch=x64
ENV NODE_ENV=production

COPY package.json ./

RUN npm install --omit=dev

# ---- Extract Extensions (.ext) ----
RUN mkdir -p /app/.ext && \
    find /app/node_modules -type f -name "titan.json" -print0 | \
    while IFS= read -r -d '' file; do \
        pkg_dir="$(dirname "$file")"; \
        pkg_name="$(basename "$pkg_dir")"; \
        cp -r "$pkg_dir" "/app/.ext/$pkg_name"; \
        rm -rf "/app/.ext/$pkg_name/node_modules"; \
    done

COPY . .

RUN npx titan build


# ================================================================
# STAGE 2 — Production (PURE ENGINE)
# ================================================================
FROM debian:bookworm-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl && \
    rm -rf /var/lib/apt/lists/*

# Copy runtime artifacts
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/.ext ./.ext
COPY --from=builder /app/app/db ./db

# Copy entire bin folder from engine package
COPY --from=builder /app/node_modules/@titanpl/engine-linux-x64/bin /bin

# Ensure executable permissions
RUN chmod +x /bin/*

RUN useradd -m titan && chown -R titan:titan /app
USER titan

ENV HOST=0.0.0.0
ENV PORT=5100
ENV TITAN_DEV=0

EXPOSE 5100

# Replace titan-server with actual filename if different
CMD ["/bin/titan-server", "start", "dist"]