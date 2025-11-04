# Deploy n8n Unlocked from GitHub Fork to Coolify

This guide shows how to deploy directly from your GitHub fork to Coolify, which is cleaner and more maintainable than manual Docker builds.

## Benefits of Git-Based Deployment

- 🔄 Automatic rebuilds on git push
- 📦 No manual Docker image pushing
- 🔒 Version controlled modifications
- 🔁 Easy to rollback or update
- 🌐 Deploy from anywhere

## Step 1: Fork and Push Your Changes

### 1.1 Fork the Repository

1. Go to https://github.com/n8n-io/n8n
2. Click "Fork" button
3. Create fork in your account

### 1.2 Update Your Local Repository

```bash
# Navigate to your n8n directory
cd ~/Projects/n8n

# Rename current origin to upstream
git remote rename origin upstream

# Add your fork as origin
git remote add origin https://github.com/YOUR-USERNAME/n8n.git

# Create a branch for your modifications
git checkout -b unlocked-features

# Stage all your changes
git add \
  packages/cli/src/license.ts \
  packages/@n8n/backend-common/src/license-state.ts \
  packages/cli/src/services/frontend.service.ts \
  packages/cli/src/environments.ee/source-control/source-control-helper.ee.ts \
  docker-compose.coolify.yml \
  .env.coolify.example \
  build-and-push.sh \
  COOLIFY_QUICKSTART.md \
  DEPLOYMENT_GUIDE.md

# Commit your changes
git commit -m "feat: unlock all enterprise features for self-hosted deployment

Modifications:
- All license checks now return true
- All quota limits set to unlimited
- Frontend configured to show all enterprise features
- Added Coolify deployment configuration files

Features unlocked:
- Git/Source Control
- LDAP/SAML/OIDC authentication
- Advanced permissions & custom roles
- Workflow history & diffs
- External secrets
- Log streaming
- Variables
- Debug mode
- Worker view
- Unlimited users/workflows/variables"

# Push to your fork
git push -u origin unlocked-features
```

## Step 2: Create Dockerfile for Coolify

Coolify can build directly from Git, but we need a Dockerfile in the root:

```bash
# Create a root Dockerfile that uses n8n's build process
cat > Dockerfile << 'EOF'
ARG NODE_VERSION=22.21.0

# Stage 1: Install dependencies and build
FROM node:${NODE_VERSION}-alpine AS builder

# Install pnpm
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install build dependencies
RUN apk add --no-cache \
    git \
    openssh \
    python3 \
    make \
    g++ \
    jq

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./
COPY patches ./patches
COPY packages ./packages

# Install dependencies
RUN pnpm install --frozen-lockfile

# Build the application
RUN pnpm build

# Stage 2: Use n8n's production Dockerfile
FROM n8nio/base:${NODE_VERSION}

ARG N8N_VERSION=custom-unlocked
ENV NODE_ENV=production
ENV N8N_RELEASE_TYPE=stable
ENV NODE_ICU_DATA=/usr/local/lib/node_modules/full-icu
ENV SHELL=/bin/sh

WORKDIR /home/node

# Copy built application from builder
COPY --from=builder /app/packages/cli/dist /usr/local/lib/node_modules/n8n/dist
COPY --from=builder /app/packages/cli/package.json /usr/local/lib/node_modules/n8n/
COPY --from=builder /app/node_modules /usr/local/lib/node_modules/n8n/node_modules

# Create symlink and setup
RUN cd /usr/local/lib/node_modules/n8n && \
    npm rebuild sqlite3 && \
    ln -s /usr/local/lib/node_modules/n8n/dist/index.js /usr/local/bin/n8n && \
    mkdir -p /home/node/.n8n && \
    chown -R node:node /home/node

EXPOSE 5678/tcp
USER node

CMD ["n8n"]

LABEL org.opencontainers.image.title="n8n-unlocked" \
      org.opencontainers.image.description="n8n Workflow Automation - Enterprise Features Unlocked" \
      org.opencontainers.image.version=${N8N_VERSION}
EOF

# Commit the Dockerfile
git add Dockerfile
git commit -m "feat: add Dockerfile for direct Git deployment"
git push
```

## Step 3: Deploy in Coolify

### Method A: Docker Compose (Recommended)

1. **In Coolify:**
   - Click "+ New Resource" → "Docker Compose"
   - Select "From Git Repository"

2. **Configure Git Source:**
   - Repository: `https://github.com/YOUR-USERNAME/n8n`
   - Branch: `unlocked-features`
   - Docker Compose Location: `docker-compose.coolify.yml`

3. **Set Environment Variables:**
   ```env
   POSTGRES_PASSWORD=your_secure_password
   N8N_ENCRYPTION_KEY=your_64_char_hex_key
   N8N_HOST=n8n.yourdomain.com
   WEBHOOK_URL=https://n8n.yourdomain.com
   DOCKER_IMAGE=${IMAGE} # Coolify will set this automatically
   ```

4. **Configure Build:**
   - Enable "Build from Git"
   - Dockerfile Path: `Dockerfile`
   - Build Context: `/`

5. **Deploy:**
   - Click "Deploy"
   - Coolify will build and deploy automatically

### Method B: Single Docker Service

1. **In Coolify:**
   - Click "+ New Resource" → "Docker"
   - Select "From Git Repository"

2. **Configure:**
   - Repository: `https://github.com/YOUR-USERNAME/n8n`
   - Branch: `unlocked-features`
   - Dockerfile: `Dockerfile`

3. **Environment Variables:**
   ```env
   # If using external PostgreSQL
   DB_TYPE=postgresdb
   DB_POSTGRESDB_DATABASE=n8n
   DB_POSTGRESDB_HOST=your-postgres-host
   DB_POSTGRESDB_PORT=5432
   DB_POSTGRESDB_USER=n8n
   DB_POSTGRESDB_PASSWORD=your_password

   N8N_ENCRYPTION_KEY=your_key
   N8N_HOST=n8n.yourdomain.com
   WEBHOOK_URL=https://n8n.yourdomain.com
   ```

4. **Deploy**

## Step 4: Automatic Updates

With Git-based deployment, updates are easy:

```bash
# Make changes to license files or add features
vim packages/cli/src/license.ts

# Commit and push
git add .
git commit -m "update: improve license bypass"
git push

# In Coolify: Click "Redeploy" or enable auto-deploy on push
```

## Step 5: Keep Updated with Upstream n8n

To pull updates from the original n8n repository:

```bash
# Fetch latest from n8n
git fetch upstream

# Merge updates (may have conflicts with your changes)
git merge upstream/master

# Or rebase your changes on top of latest
git rebase upstream/master

# Resolve any conflicts
# Then push to your fork
git push origin unlocked-features
```

## Comparing Approaches

| Feature | Manual Docker Build | Git-Based Deployment |
|---------|-------------------|---------------------|
| Setup Complexity | Medium | Easy |
| Update Process | Manual rebuild + push | Git push |
| Version Control | Manual | Automatic |
| Rollback | Manual image tags | Git revert |
| CI/CD | Requires setup | Built-in |
| Team Collaboration | Share images | Share repo |

## Recommended: Use Git-Based Deployment

For the best experience:

1. ✅ Fork the repository
2. ✅ Push your modifications
3. ✅ Deploy from Git in Coolify
4. ✅ Updates via git push
5. ✅ Track changes in your fork

## Environment Variables for Git Deployment

```env
# Required
N8N_ENCRYPTION_KEY=<openssl rand -hex 32>
POSTGRES_PASSWORD=<secure password>

# Domain
N8N_HOST=n8n.yourdomain.com
WEBHOOK_URL=https://n8n.yourdomain.com
N8N_PROTOCOL=https
N8N_PORT=5678

# Database (if using docker-compose)
DB_TYPE=postgresdb
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=${POSTGRES_PASSWORD}

# Optional
TIMEZONE=America/New_York
EXECUTIONS_MODE=regular
N8N_LOG_LEVEL=info
```

## Troubleshooting

### Build Fails in Coolify

Check build logs in Coolify, common issues:
- Missing pnpm-lock.yaml
- Build timeout (increase in settings)
- Memory limits (needs ~4GB for build)

### Large Build Time

First build takes 10-15 minutes. Subsequent builds are faster with cache.

To speed up:
- Use Coolify's build cache
- Consider using the manual Docker build method for faster iterations

### Conflicts When Merging Upstream

```bash
# See conflicting files
git status

# Edit files to resolve conflicts
# Look for <<<<<<< HEAD markers

# After resolving
git add .
git commit -m "merge: resolve conflicts with upstream"
git push
```

## Best Practices

1. **Branch Strategy:**
   - `master` - track upstream n8n
   - `unlocked-features` - your modifications
   - `production` - deployed version

2. **Keep Fork Updated:**
   - Regularly merge from upstream
   - Test after merging
   - Document breaking changes

3. **Security:**
   - Keep fork private if you prefer
   - Or make public to share with community
   - Never commit `.env` files

4. **Backups:**
   - Git itself is a backup
   - Still backup database separately
   - Keep encryption key secure

---

**Recommendation:** Fork → Git-based deployment is the cleanest approach for long-term maintenance!
