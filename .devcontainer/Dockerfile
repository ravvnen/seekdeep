FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Set environment variables to avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/New_York

# Set timezone
RUN echo $TZ | tee /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata

# Update system and install basic dependencies
RUN apt-get update && \
    apt-get dist-upgrade -y && \
    apt-get autoremove -y && \
    apt-get install -y \
        software-properties-common \
        build-essential \
        curl \
        git \
        make \
        wget \
        unzip \
        file \
        libcurl4-openssl-dev \
        python3 \
        python3-pip \
        python3-setuptools \
        zlib1g-dev \
        libbz2-dev \
        liblzma-dev \
        libssl-dev \
        pkg-config \
        && rm -rf /var/lib/apt/lists/*

# Add Ubuntu toolchain repository for latest GCC
RUN add-apt-repository ppa:ubuntu-toolchain-r/test -y

# Add CMake repository for latest version
RUN add-apt-repository ppa:george-edison55/cmake-3.x -y || \
    (wget -O - https://apt.kitware.com/keys/kitware-archive-latest.asc 2>/dev/null | gpg --dearmor - | tee /usr/share/keyrings/kitware-archive-keyring.gpg >/dev/null && \
    echo 'deb [signed-by=/usr/share/keyrings/kitware-archive-keyring.gpg] https://apt.kitware.com/ubuntu/ focal main' | tee /etc/apt/sources.list.d/kitware.list >/dev/null)

# Add LLVM repository for Clang
RUN wget -O - http://llvm.org/apt/llvm-snapshot.gpg.key | apt-key add - && \
    echo "deb http://llvm.org/apt/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-3.8 main" | tee /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://llvm.org/apt/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc)-3.8 main" | tee -a /etc/apt/sources.list.d/llvm.list && \
    echo "deb http://llvm.org/apt/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/llvm.list && \
    echo "deb-src http://llvm.org/apt/$(lsb_release -sc)/ llvm-toolchain-$(lsb_release -sc) main" | tee -a /etc/apt/sources.list.d/llvm.list

# Update and install compilers and tools
RUN apt-get update && \
    apt-get install -y \
        g++-10 \
        gcc-10 \
        clang-3.8 \
        cmake \
        && rm -rf /var/lib/apt/lists/*

# Set gcc/g++ 10 as default (SeekDeep requires g++-10 or higher)
RUN update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-10 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-10 100 && \
    update-alternatives --install /usr/bin/clang clang /usr/bin/clang-3.8 100 && \
    update-alternatives --install /usr/bin/clang++ clang++ /usr/bin/clang++-3.8 100

# Set Python 3 as default
RUN ln -sf /usr/bin/python3 /usr/bin/python

# Create a non-root user for better security
RUN useradd -m -s /bin/bash vscode && \
    usermod -aG sudo vscode && \
    echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to vscode user
USER vscode

# Set working directory
WORKDIR /workspaces/seekdeep

# Add SeekDeep bin to PATH for the vscode user
ENV PATH="/workspaces/seekdeep/bin:$PATH"

# Copy setup scripts (these will be run when container starts)
COPY .devcontainer/scripts/setup-environment.sh /tmp/setup-environment.sh
RUN chmod +x /tmp/setup-environment.sh
