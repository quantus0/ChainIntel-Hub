#!/bin/bash

echo "Setting up ChainIntel Hub environment..."

# Install Julia dependencies
julia --project=. -e 'using Pkg; Pkg.instantiate()'

# Install Node.js dependencies
npm install

echo "Setup complete!"