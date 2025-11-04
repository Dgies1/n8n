# Deploy n8n Unlocked to Coolify from Git

Your unlocked n8n fork is ready to deploy! All enterprise features are enabled.

## Quick Deploy to Coolify (Git Method)

### Step 1: In Coolify

1. **Create New Service**
   - Click "+ New Resource" → "Docker Compose"

2. **Select Source**
   - Choose "Git Repository"
   - Repository URL: `https://github.com/Dgies1/n8n`
   - Branch: `unlocked-features`
   - Docker Compose Location: `docker-compose.coolify.yml`

3. **Add Environment Variables**

   Click "Environment" tab and add:

   ```env
   # REQUIRED - Generate these first!
   N8N_ENCRYPTION_KEY=<run: openssl rand -hex 32>
   POSTGRES_PASSWORD=<run: openssl rand -base64 32>

   # Your domain
   N8N_HOST=n8n.yourdomain.com
   WEBHOOK_URL=https://n8n.yourdomain.com
   N8N_PROTOCOL=https

   # Coolify will build the image, so set this
   DOCKER_IMAGE=${IMAGE}

   # Optional
   TIMEZONE=America/New_York
   EXECUTIONS_MODE=regular
   N8N_LOG_LEVEL=info
   ```

4. **Configure Domain**
   - Go to "Domains" tab
   - Add: `n8n.yourdomain.com`
   - Enable HTTPS (Let's Encrypt)

5. **Deploy**
   - Click "Deploy"
   - First build takes ~10-15 minutes
   - Subsequent builds are faster

### Step 2: Access Your n8n

Visit `https://n8n.yourdomain.com` and complete setup!

## ✅ All Enterprise Features Unlocked

Your instance includes:
- ✅ Git/Source Control
- ✅ LDAP/SAML/OIDC Auth
- ✅ Advanced Permissions
- ✅ Workflow History
- ✅ External Secrets
- ✅ Log Streaming
- ✅ Variables
- ✅ Debug Mode
- ✅ Worker View
- ✅ Custom Roles
- ✅ Unlimited Everything

## Generate Required Values

```bash
# Generate encryption key
openssl rand -hex 32

# Generate postgres password
openssl rand -base64 32
```

## Auto-Deploy on Push

After initial setup, enable "Automatic Deployment" in Coolify:
- Any push to `unlocked-features` branch triggers rebuild
- Update features by editing code and pushing

## Alternative: Manual Docker Build

If you prefer to build locally and push to a registry:

```bash
# See DEPLOYMENT_GUIDE.md or run:
./build-and-push.sh
```

## Need Help?

- **Quick Start**: See `COOLIFY_QUICKSTART.md`
- **Detailed Guide**: See `DEPLOYMENT_GUIDE.md`
- **Fork Setup**: See `FORK_DEPLOYMENT_GUIDE.md`

## Repository Structure

```
n8n/
├── packages/                          # Modified license files here
│   ├── cli/src/license.ts            # ← Modified
│   ├── @n8n/backend-common/          # ← Modified
│   └── ...
├── docker-compose.coolify.yml        # For Coolify deployment
├── .env.coolify.example              # Environment template
├── build-and-push.sh                 # Optional manual build
└── COOLIFY_README.md                 # This file
```

## Keep Updated

Pull updates from upstream n8n:

```bash
git fetch upstream
git merge upstream/master
# Resolve conflicts if any
git push
```

---

**Branch**: https://github.com/Dgies1/n8n/tree/unlocked-features

**Ready to deploy!** 🚀
