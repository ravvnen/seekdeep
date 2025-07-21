# SeekDeep Development Container

This development container provides a pre-configured environment for developing and running SeekDeep, a targeted sequencing analysis pipeline.

## Features

- **Ubuntu-based container** with all SeekDeep dependencies pre-installed
- **Modern compilers**: GCC 10+ and Clang 3.8+ for optimal performance
- **Development tools**: CMake, Git, Python 3, and essential build tools
- **VS Code extensions**: C/C++ tools, Python support, Docker integration
- **Automatic setup**: SeekDeep is automatically configured and built on container creation
- **Additional tools**: Muscle for sequence alignment
- **Bash completion**: Auto-completion for SeekDeep commands

## Quick Start

### Using GitHub Codespaces

1. Open this repository in GitHub Codespaces
2. The devcontainer will automatically build and configure SeekDeep
3. Wait for the setup to complete (check terminal output)
4. Start using SeekDeep commands!

### Using VS Code with Dev Containers

1. Install the "Dev Containers" extension in VS Code
2. Open this repository in VS Code
3. When prompted, click "Reopen in Container"
4. Wait for the container to build and setup to complete
5. SeekDeep is ready to use!

## What's Included

### Compilers and Build Tools
- GCC 10 (default C/C++ compiler)
- Clang 3.8+
- CMake 3.x
- Make
- Python 3

### SeekDeep Components
- SeekDeep main pipeline
- All required dependencies (automatically downloaded and compiled)
- Muscle sequence alignment tool
- Bash completion for commands
- Pre-configured environment variables

### Development Environment
- VS Code C/C++ IntelliSense configured
- Python development support
- Makefile and CMake syntax highlighting
- Git integration
- Docker support

## Usage

After the container starts and setup completes, you can use SeekDeep directly:

```bash
# Show all available commands
SeekDeep

# Get help for a specific command
SeekDeep qluster --help

# Example workflow commands
SeekDeep extractor --help
SeekDeep qluster --help
SeekDeep processClusters --help
```

## Development Workflow

### Building SeekDeep
The container automatically builds SeekDeep during setup. To rebuild manually:

```bash
# Clean and rebuild
make clean
make -j $(nproc)

# Or use the install script
./install.sh $(nproc)
```

### Adding Dependencies
To add new libraries or update existing ones:

```bash
# Configure with new dependencies
./configure.py

# Update makefile and install dependencies
./setup.py --compfile compfile.mk --outMakefile makefile-common.mk

# Rebuild
make -j $(nproc)
```

### Running Tests
```bash
# Run any available tests
make test
```

## Directory Structure

```
/workspaces/seekdeep/
├── .devcontainer/          # Development container configuration
│   ├── devcontainer.json   # VS Code devcontainer settings
│   ├── Dockerfile          # Container image definition
│   └── scripts/            # Setup scripts
├── bin/                    # Compiled binaries (SeekDeep, muscle, etc.)
├── external/               # External dependencies
├── src/                    # SeekDeep source code
├── scripts/                # Build and utility scripts
├── configure.py            # Configuration script
├── setup.py               # Dependency installation script
├── install.sh             # Quick install script
└── Makefile               # Build configuration
```

## Environment Variables

The container sets up these environment variables:
- `CC=gcc` - C compiler
- `CXX=g++` - C++ compiler
- `PATH` includes `/workspaces/seekdeep/bin` - SeekDeep binaries available globally
- `MAKEFLAGS=-j$(nproc)` - Use all CPU cores for building

## Port Forwarding

The container forwards these ports:
- **8080**: SeekDeep server (if running server components)
- **3000**: Additional development server

## Troubleshooting

### Container Build Issues
If the container fails to build:
1. Check Docker is running
2. Ensure you have sufficient disk space
3. Try rebuilding: `Ctrl+Shift+P` → "Dev Containers: Rebuild Container"

### SeekDeep Build Issues
If SeekDeep fails to compile:
1. Check the setup log: `cat /tmp/setup.log`
2. Verify dependencies: `./setup.py --compfile compfile.mk --outMakefile makefile-common.mk`
3. Clean and rebuild: `make clean && make -j $(nproc)`

### Missing Tools
If additional tools are needed:
```bash
# Install via apt
sudo apt-get update && sudo apt-get install <package-name>

# Or add to Dockerfile for permanent inclusion
```

## Customization

### Adding VS Code Extensions
Edit `.devcontainer/devcontainer.json` and add to the `extensions` array:
```json
"extensions": [
  "existing-extension",
  "new.extension-id"
]
```

### Modifying Build Configuration
- Edit `Dockerfile` for system-level changes
- Edit `devcontainer.json` for VS Code-specific settings
- Edit `scripts/setup-environment.sh` for setup customizations

## References

- [SeekDeep Installation Guide](https://seekdeep.brown.edu/installing/installingSeekDeep_Ubuntu.html)
- [SeekDeep GitHub Repository](https://github.com/bailey-lab/SeekDeep)
- [VS Code Dev Containers](https://code.visualstudio.com/docs/remote/containers)
- [GitHub Codespaces](https://github.com/features/codespaces)

## Support

For SeekDeep-specific issues, refer to the [official documentation](https://seekdeep.brown.edu/) or contact the SeekDeep team.

For devcontainer issues, check the VS Code Dev Containers documentation or open an issue in this repository.
