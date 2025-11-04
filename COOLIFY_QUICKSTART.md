# Quick Start: Deploy n8n Unlocked to Coolify

This is a streamlined guide to get your unlocked n8n instance deployed to Coolify quickly.

## 🚀 Quick Deploy (3 Main Steps)

### Step 1: Build and Push Docker Image

```bash
# Make the script executable (first time only)
chmod +x build-and-push.sh

# Run the automated build script
./build-and-push.sh
```

The script will:
- Install dependencies
- Build the modified n8n
- Create Docker image
- Tag and push to your registry

**Example registries:**
- Docker Hub: `yourusername/n8n-unlocked`
- GitHub: `ghcr.io/yourusername/n8n-unlocked`
- Private: `registry.yourdomain.com/n8n-unlocked`

### Step 2: Set Up Environment Variables

1. Copy the example file:
   ```bash
   cp .env.coolify.example .env
   ```

2. Edit `.env` and set these **required** values:
   ```env
   # Generate with: openssl rand -hex 32
   N8N_ENCRYPTION_KEY=your_64_char_hex_string_here

   # Generate with: openssl rand -base64 32
   POSTGRES_PASSWORD=your_secure_password_here

   # Your domain
   N8N_HOST=n8n.yourdomain.com
   WEBHOOK_URL=https://n8n.yourdomain.com

   # Your pushed Docker image
   DOCKER_IMAGE=yourusername/n8n-unlocked:latest
   ```

### Step 3: Deploy in Coolify

1. **Login to Coolify**

2. **Create New Service**
   - Click "+ New Resource" → "Docker Compose"

3. **Paste Docker Compose**
   - Copy contents from `docker-compose.coolify.yml`
   - Paste into Coolify's compose editor

4. **Add Environment Variables**
   - In Coolify, go to "Environment Variables" tab
   - Add all variables from your `.env` file:
     - `POSTGRES_PASSWORD`
     - `N8N_ENCRYPTION_KEY`
     - `N8N_HOST`
     - `WEBHOOK_URL`
     - `DOCKER_IMAGE`
     - `TIMEZONE` (optional)

5. **Configure Domain**
   - Go to "Domains" tab
   - Add your domain: `n8n.yourdomain.com`
   - Enable "HTTPS" (Let's Encrypt)

6. **Deploy**
   - Click "Deploy" button
   - Wait for containers to start (2-3 minutes)

7. **Access n8n**
   - Visit `https://n8n.yourdomain.com`
   - Complete initial setup
   - **All enterprise features are unlocked! 🎉**

## ✅ Verify Enterprise Features

After logging in, check these features are available:

- ⚙️ **Settings → Source Control** - Git integration
- 👥 **Settings → Users** - Advanced permissions
- 🔒 **Settings → LDAP/SAML** - Enterprise authentication
- 📊 **Settings → Log Streaming** - External logging
- 🔐 **Settings → External Secrets** - Secrets management
- 📈 **Workflow History** - Version tracking
- 🔧 **Variables** - Environment variables
- 🎯 **Advanced Execution Filters** - Detailed filtering

## 🔧 Manual Build (Alternative)

If you prefer to build manually instead of using the script:

```bash
# Install dependencies
pnpm install

# Build the application
pnpm build > build.log 2>&1

# Check build status
tail -n 20 build.log

# Build Docker image
pnpm build:docker

# Tag your image
docker tag n8nio/n8n:latest yourusername/n8n-unlocked:latest

# Push to registry
docker push yourusername/n8n-unlocked:latest
```

## 🆘 Troubleshooting

### Build Fails
```bash
# Check build log
cat build.log | grep -i error

# Clean and rebuild
rm -rf node_modules
pnpm install
pnpm build > build.log 2>&1
```

### Docker Push Fails - Login Required

**Docker Hub:**
```bash
docker login
```

**GitHub Container Registry:**
```bash
echo $GITHUB_TOKEN | docker login ghcr.io -u your-username --password-stdin
```

**Private Registry:**
```bash
docker login your-registry.com
```

### Container Won't Start in Coolify

1. Check logs in Coolify UI
2. Verify environment variables are set correctly
3. Ensure `DOCKER_IMAGE` points to your pushed image
4. Check PostgreSQL is healthy before n8n starts

### Can't Access n8n Web Interface

1. Verify domain DNS points to Coolify server
2. Check HTTPS certificate is generated (may take a minute)
3. Ensure port 5678 is accessible
4. Check Coolify proxy/traefik is running

### Enterprise Features Not Showing

1. Verify you're using your custom image (not official n8n)
2. Check `DOCKER_IMAGE` environment variable in Coolify
3. Verify build completed without errors
4. Rebuild and redeploy if needed

## 📦 What You Get

Your unlocked n8n instance includes:

| Feature | Status |
|---------|--------|
| Git/Source Control | ✅ Unlocked |
| LDAP Authentication | ✅ Unlocked |
| SAML SSO | ✅ Unlocked |
| OIDC | ✅ Unlocked |
| Advanced Permissions | ✅ Unlocked |
| Log Streaming | ✅ Unlocked |
| External Secrets | ✅ Unlocked |
| Workflow History | ✅ Unlocked |
| Variables | ✅ Unlocked |
| Debug in Editor | ✅ Unlocked |
| Worker View | ✅ Unlocked |
| API Key Scopes | ✅ Unlocked |
| Custom Roles | ✅ Unlocked |
| Unlimited Workflows | ✅ Unlocked |
| Unlimited Users | ✅ Unlocked |
| Unlimited Variables | ✅ Unlocked |

## 🔐 Security Reminders

- ✅ Use strong random passwords
- ✅ Keep `N8N_ENCRYPTION_KEY` backed up securely
- ✅ Never commit `.env` to git
- ✅ Enable HTTPS (Let's Encrypt)
- ✅ Regularly backup database and volumes
- ⚠️ Never change encryption key after initial setup

## 📚 Additional Resources

- **Detailed Guide**: See `DEPLOYMENT_GUIDE.md` for comprehensive documentation
- **n8n Docs**: https://docs.n8n.io
- **Coolify Docs**: https://coolify.io/docs
- **n8n Community**: https://community.n8n.io

## 🆕 Updating

To update after code changes:

```bash
# Rebuild
./build-and-push.sh

# In Coolify: Redeploy the service
```

---

**That's it!** You now have a fully unlocked n8n instance running on Coolify with all enterprise features available. 🎉
