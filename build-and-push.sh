#!/bin/bash

# Build and Push Script for n8n Unlocked
# This script automates the build and push process for Docker deployment

set -e

echo "=================================================="
echo "n8n Unlocked - Build and Push Script"
echo "=================================================="
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if pnpm is installed
if ! command -v pnpm &> /dev/null; then
    echo -e "${RED}Error: pnpm is not installed${NC}"
    echo "Please install pnpm first: npm install -g pnpm"
    exit 1
fi

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Error: Docker is not installed${NC}"
    echo "Please install Docker first"
    exit 1
fi

# Get registry details from user
echo -e "${YELLOW}Enter your Docker registry details:${NC}"
echo ""
echo "Examples:"
echo "  Docker Hub: username/n8n-unlocked"
echo "  GitHub CR:  ghcr.io/username/n8n-unlocked"
echo "  Private:    registry.example.com/n8n-unlocked"
echo ""
read -p "Docker image name (with registry): " IMAGE_NAME

if [ -z "$IMAGE_NAME" ]; then
    echo -e "${RED}Error: Image name cannot be empty${NC}"
    exit 1
fi

read -p "Tag version (default: latest): " TAG_VERSION
TAG_VERSION=${TAG_VERSION:-latest}

FULL_IMAGE="$IMAGE_NAME:$TAG_VERSION"

echo ""
echo -e "${GREEN}Configuration:${NC}"
echo "  Image: $FULL_IMAGE"
echo ""
read -p "Continue with build? (y/N): " confirm

if [[ ! $confirm =~ ^[Yy]$ ]]; then
    echo "Build cancelled"
    exit 0
fi

# Step 1: Install dependencies
echo ""
echo -e "${YELLOW}[1/5] Installing dependencies...${NC}"
pnpm install

# Step 2: Build the application
echo ""
echo -e "${YELLOW}[2/5] Building n8n (this may take several minutes)...${NC}"
pnpm build > build.log 2>&1

# Check if build was successful
if tail -n 20 build.log | grep -q "error\|Error\|ERROR"; then
    echo -e "${RED}Build failed! Check build.log for details${NC}"
    echo "Last 20 lines of build.log:"
    tail -n 20 build.log
    exit 1
fi

echo -e "${GREEN}✓ Build completed successfully${NC}"

# Step 3: Build Docker image
echo ""
echo -e "${YELLOW}[3/5] Building Docker image...${NC}"
pnpm build:docker

if [ $? -ne 0 ]; then
    echo -e "${RED}Docker build failed!${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker image built successfully${NC}"

# Step 4: Tag the image
echo ""
echo -e "${YELLOW}[4/5] Tagging Docker image...${NC}"
docker tag n8nio/n8n:latest "$FULL_IMAGE"

echo -e "${GREEN}✓ Image tagged as: $FULL_IMAGE${NC}"

# Step 5: Push to registry
echo ""
echo -e "${YELLOW}[5/5] Pushing to registry...${NC}"
echo "Note: You may need to login to your registry first"
echo ""

read -p "Push image to registry now? (y/N): " push_confirm

if [[ $push_confirm =~ ^[Yy]$ ]]; then
    docker push "$FULL_IMAGE"

    if [ $? -eq 0 ]; then
        echo ""
        echo -e "${GREEN}=================================================="
        echo "✓ Successfully built and pushed!"
        echo "=================================================="
        echo ""
        echo "Image: $FULL_IMAGE"
        echo ""
        echo "Next steps:"
        echo "1. Update DOCKER_IMAGE in your .env file:"
        echo "   DOCKER_IMAGE=$FULL_IMAGE"
        echo ""
        echo "2. Deploy to Coolify using docker-compose.coolify.yml"
        echo ""
        echo "See DEPLOYMENT_GUIDE.md for detailed instructions"
        echo -e "${NC}"
    else
        echo -e "${RED}Push failed! Make sure you're logged into the registry${NC}"
        echo ""
        echo "To login:"
        echo "  Docker Hub: docker login"
        echo "  GitHub CR:  echo \$GITHUB_TOKEN | docker login ghcr.io -u USERNAME --password-stdin"
        echo "  Private:    docker login registry.example.com"
        exit 1
    fi
else
    echo ""
    echo -e "${GREEN}Build completed successfully!${NC}"
    echo ""
    echo "Image: $FULL_IMAGE"
    echo ""
    echo "To push manually later:"
    echo "  docker push $FULL_IMAGE"
    echo ""
fi
