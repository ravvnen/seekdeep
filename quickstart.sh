#!/bin/bash

# Quick Start Script for SeekDeep DevContainer
# This script helps users get started with the SeekDeep development environment

set -e

echo "🧬 SeekDeep DevContainer Quick Start"
echo "=================================="
echo ""

# Check if we're in a devcontainer
if [ -n "$CODESPACES" ]; then
    echo "✅ Running in GitHub Codespaces"
elif [ -n "$REMOTE_CONTAINERS" ]; then
    echo "✅ Running in VS Code Dev Container"
else
    echo "ℹ️  Not running in a devcontainer - this script is optimized for devcontainer environments"
fi

echo ""

# Check if SeekDeep is already built
if [ -f "/workspaces/seekdeep/bin/SeekDeep" ]; then
    echo "✅ SeekDeep is already built and ready!"
    echo ""
    echo "Available commands:"
    /workspaces/seekdeep/bin/SeekDeep 2>/dev/null || echo "SeekDeep executable found"
else
    echo "🔧 SeekDeep not found. Running setup..."
    
    # Run the setup script if it exists
    if [ -f "/tmp/setup-environment.sh" ]; then
        echo "Running automated setup..."
        /tmp/setup-environment.sh
    else
        echo "Running manual setup..."
        cd /workspaces/seekdeep
        
        # Configure
        echo "Configuring..."
        python3 ./configure.py
        
        # Install dependencies
        echo "Installing dependencies..."
        python3 ./setup.py --compfile compfile.mk --outMakefile makefile-common.mk
        
        # Build
        echo "Building SeekDeep..."
        make -j $(nproc)
        
        # Install additional tools
        echo "Installing additional tools..."
        python3 ./setup.py --libs muscle:3.8.31 --symlinkBin --overWrite
        
        # Setup bash completion
        python3 ./setup.py --addBashCompletion
        
        echo "✅ Setup complete!"
    fi
fi

echo ""
echo "🎉 Quick Start Guide:"
echo ""
echo "1. Basic usage:"
echo "   SeekDeep                    # Show all commands"
echo "   SeekDeep [command] --help   # Get help for specific command"
echo ""
echo "2. Example workflow:"
echo "   SeekDeep extractor --help              # Extract sequences"
echo "   SeekDeep qluster --help                # Quality clustering"
echo "   SeekDeep processClusters --help        # Process clusters"
echo ""
echo "3. Development:"
echo "   make -j \$(nproc)                      # Rebuild SeekDeep"
echo "   ./install.sh \$(nproc)                 # Full reinstall"
echo ""
echo "4. Additional tools:"
echo "   muscle --help                          # Sequence alignment"
echo ""
echo "📚 Documentation: https://seekdeep.brown.edu/"
echo "💻 GitHub: https://github.com/bailey-lab/SeekDeep"
echo ""
echo "Happy analyzing! 🧬"
