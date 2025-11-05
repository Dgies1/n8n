ARG NODE_VERSION=22.21.0

# ==============================================================================
# Stage 1: Install dependencies and build n8n with unlocked features
# ==============================================================================
FROM node:${NODE_VERSION}-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@9.12.3 --activate

# Install build dependencies
RUN apk add --no-cache \
    git \
    openssh \
    python3 \
    make \
    g++ \
    jq \
    openssl

WORKDIR /build

# Copy entire repository (needed for pnpm workspace to work correctly)
COPY . .

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the application
RUN pnpm build

# ==============================================================================
# Stage 2: Create base runtime image with system dependencies
# ==============================================================================
FROM node:${NODE_VERSION}-alpine AS base

# Install runtime dependencies
RUN apk add --no-cache \
    git \
    openssh \
    openssl \
    graphicsmagick \
    tini \
    tzdata \
    ca-certificates \
    libc6-compat \
    curl \
    jq \
    su-exec \
    libxml2

# Install fonts
RUN apk --no-cache add --virtual fonts msttcorefonts-installer fontconfig && \
    update-ms-fonts && \
    fc-cache -f && \
    apk del fonts && \
    find /usr/share/fonts/truetype/msttcorefonts/ -type l -exec unlink {} \;

# Install full-icu
RUN npm install -g full-icu@1.5.0

ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu

# ==============================================================================
# Stage 3: Final runtime image with built n8n
# ==============================================================================
FROM base AS runtime

ARG N8N_VERSION=unlocked
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
ENV SHELL=/bin/sh

WORKDIR /home/node

# Copy built application from builder
COPY --from=builder /build /usr/local/lib/node_modules/n8n

# Create symlink to n8n CLI
RUN cd /usr/local/lib/node_modules/n8n && \
    npm rebuild sqlite3 && \
    ln -s /usr/local/lib/node_modules/n8n/packages/cli/bin/n8n /usr/local/bin/n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

# Install pdfjs canvas dependency
RUN cd /usr/local/lib/node_modules/n8n/node_modules/pdfjs-dist && \
    npm install @napi-rs/canvas || true

EXPOSE 5678/tcp

USER node

ENTRYPOINT ["tini", "--", "n8n"]

LABEL org.opencontainers.image.title="n8n-unlocked" \
      org.opencontainers.image.description="n8n Workflow Automation - All Enterprise Features Unlocked" \
      org.opencontainers.image.source="https://github.com/Dgies1/n8n" \
      org.opencontainers.image.version=${N8N_VERSION}
