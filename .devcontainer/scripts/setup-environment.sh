#!/bin/bash

# SeekDeep Development Environment Setup Script
# This script sets up the development environment for SeekDeep in the devcontainer

set -e

echo "🚀 Setting up SeekDeep development environment..."

# Navigate to the SeekDeep directory
cd /workspaces/seekdeep

# Verify compilers are available
echo "📋 Checking compiler versions..."
gcc --version
g++ --version
cmake --version
python3 --version

# Set environment variables
export CC=gcc
export CXX=g++

# Configure SeekDeep
echo "⚙️ Configuring SeekDeep..."
if [ ! -f compfile.mk ]; then
    echo "Running configure.py..."
    python3 ./configure.py
else
    echo "compfile.mk already exists, skipping configure step"
fi

# Install SeekDeep dependencies
echo "📦 Installing SeekDeep dependencies..."
if [ ! -d external ]; then
    echo "Setting up dependencies with setup.py..."
    python3 ./setup.py --compfile compfile.mk --outMakefile makefile-common.mk
else
    echo "Dependencies already installed in external/ directory"
fi

# Build SeekDeep (use all available cores)
echo "🔨 Building SeekDeep..."
if [ ! -f bin/SeekDeep ]; then
    echo "Compiling SeekDeep with $(nproc) cores..."
    make -j $(nproc)
else
    echo "SeekDeep binary already exists, skipping build"
fi

# Install additional tools (muscle)
echo "🧬 Installing additional tools..."
if [ ! -f bin/muscle ]; then
    echo "Installing muscle..."
    python3 ./setup.py --libs muscle:3.8.31 --symlinkBin --overWrite
else
    echo "muscle already installed"
fi

# Set up bash completion
echo "💫 Setting up bash completion..."
if [ ! -f ~/.bash_completion ] || ! grep -q "SeekDeep" ~/.bash_completion; then
    echo "Adding SeekDeep bash completion..."
    python3 ./setup.py --addBashCompletion
else
    echo "Bash completion already configured"
fi

# Add SeekDeep to PATH in .bashrc if not already there
if ! grep -q "SeekDeep/bin" ~/.bashrc; then
    echo "🔗 Adding SeekDeep to PATH..."
    echo "" >> ~/.bashrc
    echo "# Add SeekDeep bin to your path" >> ~/.bashrc
    echo "export PATH=\"/workspaces/seekdeep/bin:\$PATH\"" >> ~/.bashrc
    echo "Added SeekDeep to PATH in ~/.bashrc"
else
    echo "SeekDeep already in PATH"
fi

# Source the updated bashrc
source ~/.bashrc

# Verify installation
echo "✅ Verifying SeekDeep installation..."
if [ -f /workspaces/seekdeep/bin/SeekDeep ]; then
    echo "SeekDeep binary found at: /workspaces/seekdeep/bin/SeekDeep"
    /workspaces/seekdeep/bin/SeekDeep --version || echo "SeekDeep executable is available"
else
    echo "❌ SeekDeep binary not found!"
    exit 1
fi

echo ""
echo "🎉 SeekDeep development environment setup complete!"
echo ""
echo "Usage:"
echo "  SeekDeep                    - Show all available commands"
echo "  SeekDeep [command] --help   - Get help for a specific command"
echo ""
echo "Available tools:"
echo "  - SeekDeep: Main analysis pipeline"
echo "  - muscle: Multiple sequence alignment tool"
echo ""
echo "Environment variables:"
echo "  CC:  $CC"
echo "  CXX: $CXX"
echo ""
echo "Happy coding! 🧬"
