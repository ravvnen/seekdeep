#!/bin/bash

set -e

echo "Setting up SeekDeep development environment..."

# Update package lists
sudo apt-get update

# Install additional build tools and dependencies that SeekDeep needs
sudo apt-get install -y \
    build-essential \
    cmake \
    git \
    wget \
    curl \
    unzip \
    pkg-config \
    libcurl4-openssl-dev \
    zlib1g-dev \
    libbz2-dev \
    liblzma-dev \
    libssl-dev \
    python3 \
    python3-pip \
    python3-setuptools \
    make \
    file

# Install modern GCC/G++ (GCC-11 is available in Ubuntu 22.04)
sudo apt-get install -y \
    gcc-11 \
    g++-11

# Install Clang (use version available in Ubuntu 22.04)
sudo apt-get install -y \
    clang-14 \
    clang++-14 \
    lldb-14

# Set up alternatives for compiler selection
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 100
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 100
sudo update-alternatives --install /usr/bin/clang clang /usr/bin/clang-14 100
sudo update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-14 100

# Ensure Python 3 is available as python
sudo ln -sf /usr/bin/python3 /usr/bin/python || true

# Create bin directory if it doesn't exist
mkdir -p /workspaces/seekdeep/bin

# Clean up
sudo apt-get autoremove -y
sudo rm -rf /var/lib/apt/lists/*

echo "Development environment setup complete!"
echo "GCC version: $(gcc --version | head -n1)"
echo "G++ version: $(g++ --version | head -n1)"
echo "Clang version: $(clang --version | head -n1)"
echo "CMake version: $(cmake --version | head -n1)"
echo "Python version: $(python --version)"
