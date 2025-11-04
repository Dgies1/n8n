# n8n Unlocked - Deployment Guide for Coolify

This guide explains how to build and deploy your modified n8n instance (with all enterprise features unlocked) to Coolify.

## Prerequisites

- Docker installed locally
- Access to a Docker registry (Docker Hub, GitHub Container Registry, or private registry)
- Coolify instance set up and accessible
- pnpm installed locally

## Step 1: Build the Modified n8n

### 1.1 Install Dependencies

```bash
pnpm install
```

### 1.2 Build the Application

```bash
# Build all packages (this will take several minutes)
# Output is redirected to a log file as per project guidelines
pnpm build > build.log 2>&1

# Check if build succeeded
tail -n 20 build.log
```

### 1.3 Build the Docker Image

```bash
# Build the Docker image with your modifications
pnpm build:docker

# Tag the image (replace with your registry details)
docker tag n8nio/n8n:latest your-username/n8n-unlocked:latest

# Or if using a custom tag:
docker tag n8nio/n8n:latest your-username/n8n-unlocked:1.0.0
```

## Step 2: Push to Docker Registry

### Option A: Docker Hub

```bash
# Login to Docker Hub
docker login

# Push the image
docker push your-username/n8n-unlocked:latest
```

### Option B: GitHub Container Registry (ghcr.io)

```bash
# Login to GitHub Container Registry
echo $GITHUB_TOKEN | docker login ghcr.io -u your-github-username --password-stdin

# Tag for GitHub Container Registry
docker tag n8nio/n8n:latest ghcr.io/your-github-username/n8n-unlocked:latest

# Push the image
docker push ghcr.io/your-github-username/n8n-unlocked:latest
```

### Option C: Private Registry

```bash
# Login to your private registry
docker login your-registry.com

# Tag for private registry
docker tag n8nio/n8n:latest your-registry.com/n8n-unlocked:latest

# Push the image
docker push your-registry.com/n8n-unlocked:latest
```

## Step 3: Prepare Coolify Deployment

### 3.1 Create Environment Variables

Copy the example environment file:

```bash
cp .env.coolify.example .env
```

Edit `.env` and set your values:

```env
# Generate a secure PostgreSQL password
POSTGRES_PASSWORD=your_secure_random_password

# Generate encryption key with: openssl rand -hex 32
N8N_ENCRYPTION_KEY=your_64_character_hex_string

# Set your domain
N8N_HOST=n8n.yourdomain.com
WEBHOOK_URL=https://n8n.yourdomain.com

# Update with your pushed image
DOCKER_IMAGE=your-username/n8n-unlocked:latest
```

### 3.2 Prepare docker-compose.yml

The `docker-compose.coolify.yml` file is already created and ready to use.

## Step 4: Deploy to Coolify

### Method 1: Via Coolify UI (Recommended)

1. **Log into Coolify**
2. **Create a new Service**
   - Click "New Resource" → "Docker Compose"

3. **Configure the Service**
   - Name: `n8n-unlocked`
   - Paste the contents of `docker-compose.coolify.yml`

4. **Set Environment Variables**
   - In Coolify, add all environment variables from your `.env` file
   - Make sure to set:
     - `POSTGRES_PASSWORD`
     - `N8N_ENCRYPTION_KEY`
     - `N8N_HOST`
     - `WEBHOOK_URL`
     - `DOCKER_IMAGE` (your pushed image)

5. **Configure Domain**
   - Set up your domain in Coolify's domain settings
   - Enable SSL/HTTPS (Let's Encrypt)

6. **Deploy**
   - Click "Deploy" and wait for the containers to start

### Method 2: Via Git Repository

1. **Push to Git**
   ```bash
   git add docker-compose.coolify.yml .env.coolify.example DEPLOYMENT_GUIDE.md
   git commit -m "Add Coolify deployment configuration"
   git push
   ```

2. **Connect in Coolify**
   - In Coolify, create a new "Docker Compose" service
   - Connect your Git repository
   - Specify `docker-compose.coolify.yml` as the compose file
   - Set environment variables in Coolify UI

3. **Deploy**
   - Coolify will automatically deploy from your Git repo

## Step 5: Verify Deployment

1. **Check Container Status**
   - In Coolify, verify both `postgres` and `n8n` containers are running

2. **Access n8n**
   - Navigate to `https://n8n.yourdomain.com`
   - You should see the n8n login/setup page

3. **Verify Enterprise Features**
   - After setting up your account, check Settings
   - All enterprise features should be available:
     - Git/Source Control
     - LDAP/SAML/OIDC
     - Advanced Permissions
     - Workflow History
     - Variables
     - External Secrets
     - And more!

## Step 6: Post-Deployment Configuration

### Configure Source Control (Git Integration)

1. Go to Settings → Source Control
2. Connect your Git repository
3. Configure SSH keys (if needed)
4. Start versioning your workflows!

### Set Up User Management

1. Go to Settings → Users
2. Invite team members
3. Configure roles and permissions

### Configure Webhooks

Ensure your `WEBHOOK_URL` is correctly set to your public domain so external services can trigger your workflows.

## Updating Your Deployment

When you make changes to the n8n code:

```bash
# Rebuild
pnpm build > build.log 2>&1

# Rebuild Docker image
pnpm build:docker

# Tag with new version
docker tag n8nio/n8n:latest your-username/n8n-unlocked:1.0.1

# Push to registry
docker push your-username/n8n-unlocked:1.0.1

# Update DOCKER_IMAGE in Coolify environment variables
# Redeploy in Coolify
```

## Troubleshooting

### Container Fails to Start

Check logs in Coolify:
```bash
# Or via Docker CLI if you have access:
docker logs n8n-unlocked-n8n-1
```

### Database Connection Issues

Verify PostgreSQL is running and credentials are correct:
- Check `POSTGRES_PASSWORD` matches in both services
- Ensure `postgres` service is healthy before n8n starts

### Missing Enterprise Features

If features don't appear:
1. Verify the Docker image is your custom-built one (not official n8n)
2. Check the build completed successfully
3. Rebuild and redeploy if needed

### Encryption Key Issues

If you lose your encryption key:
- You won't be able to decrypt existing credentials
- Keep `N8N_ENCRYPTION_KEY` backed up securely
- Never change it after initial deployment (credentials will break)

## Backup Strategy

### Database Backup
```bash
# From Coolify server or container
docker exec n8n-unlocked-postgres-1 pg_dump -U n8n n8n > backup.sql
```

### Volume Backup
```bash
# Backup n8n data volume
docker run --rm -v n8n-unlocked_n8n_data:/data -v $(pwd):/backup alpine tar czf /backup/n8n-data-backup.tar.gz /data
```

## Security Considerations

1. **Use Strong Passwords**: Generate secure random passwords for database
2. **Secure Encryption Key**: Use `openssl rand -hex 32` to generate
3. **HTTPS Only**: Always use SSL/TLS in production
4. **Keep Updated**: Regularly rebuild with latest n8n base and security patches
5. **Firewall**: Restrict database access to n8n container only
6. **Backup Credentials**: Store encryption key in a password manager

## Resources

- [n8n Documentation](https://docs.n8n.io)
- [Coolify Documentation](https://coolify.io/docs)
- [n8n Community Forum](https://community.n8n.io)

## License Note

This deployment guide is for self-hosted instances under n8n's fair-code Sustainable Use License. All modifications are for personal/organizational use and comply with the license terms.
