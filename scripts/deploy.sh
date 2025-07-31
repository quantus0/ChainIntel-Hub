#!/bin/bash

echo "Deploying ChainIntel Hub..."

# Build Docker image
docker build -t chainintel-hub .

# Run container
docker run -d -p 8080:8080 chainintel-hub

echo "Deployment complete!"