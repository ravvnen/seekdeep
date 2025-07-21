#!/bin/bash

# Test script to verify SeekDeep devcontainer setup
# This script checks that all dependencies and tools are properly installed

echo "🧪 Testing SeekDeep DevContainer Setup"
echo "====================================="
echo ""

errors=0

# Test 1: Check compilers
echo "1. Testing compilers..."
if gcc --version >/dev/null 2>&1; then
    echo "   ✅ GCC: $(gcc --version | head -n1)"
else
    echo "   ❌ GCC not found"
    ((errors++))
fi

if g++ --version >/dev/null 2>&1; then
    echo "   ✅ G++: $(g++ --version | head -n1)"
else
    echo "   ❌ G++ not found"
    ((errors++))
fi

if clang --version >/dev/null 2>&1; then
    echo "   ✅ Clang: $(clang --version | head -n1)"
else
    echo "   ❌ Clang not found"
    ((errors++))
fi

# Test 2: Check build tools
echo ""
echo "2. Testing build tools..."
if cmake --version >/dev/null 2>&1; then
    echo "   ✅ CMake: $(cmake --version | head -n1)"
else
    echo "   ❌ CMake not found"
    ((errors++))
fi

if make --version >/dev/null 2>&1; then
    echo "   ✅ Make: $(make --version | head -n1)"
else
    echo "   ❌ Make not found"
    ((errors++))
fi

if python3 --version >/dev/null 2>&1; then
    echo "   ✅ Python: $(python3 --version)"
else
    echo "   ❌ Python3 not found"
    ((errors++))
fi

# Test 3: Check SeekDeep files
echo ""
echo "3. Testing SeekDeep setup..."
if [ -f "/workspaces/seekdeep/configure.py" ]; then
    echo "   ✅ configure.py found"
else
    echo "   ❌ configure.py not found"
    ((errors++))
fi

if [ -f "/workspaces/seekdeep/setup.py" ]; then
    echo "   ✅ setup.py found"
else
    echo "   ❌ setup.py not found"
    ((errors++))
fi

if [ -f "/workspaces/seekdeep/install.sh" ]; then
    echo "   ✅ install.sh found"
else
    echo "   ❌ install.sh not found"
    ((errors++))
fi

# Test 4: Check if SeekDeep is built
echo ""
echo "4. Testing SeekDeep binary..."
if [ -f "/workspaces/seekdeep/bin/SeekDeep" ]; then
    echo "   ✅ SeekDeep binary found"
    if /workspaces/seekdeep/bin/SeekDeep --version >/dev/null 2>&1 || /workspaces/seekdeep/bin/SeekDeep >/dev/null 2>&1; then
        echo "   ✅ SeekDeep executable works"
    else
        echo "   ⚠️  SeekDeep binary found but may not be working correctly"
    fi
else
    echo "   ℹ️  SeekDeep binary not found (run setup to build)"
fi

# Test 5: Check additional tools
echo ""
echo "5. Testing additional tools..."
if [ -f "/workspaces/seekdeep/bin/muscle" ]; then
    echo "   ✅ Muscle found"
else
    echo "   ℹ️  Muscle not found (will be installed during setup)"
fi

# Test 6: Check environment
echo ""
echo "6. Testing environment..."
if [ -n "$CC" ]; then
    echo "   ✅ CC environment variable: $CC"
else
    echo "   ℹ️  CC environment variable not set"
fi

if [ -n "$CXX" ]; then
    echo "   ✅ CXX environment variable: $CXX"
else
    echo "   ℹ️  CXX environment variable not set"
fi

if echo "$PATH" | grep -q "/workspaces/seekdeep/bin"; then
    echo "   ✅ SeekDeep bin in PATH"
else
    echo "   ℹ️  SeekDeep bin not in PATH (will be added during setup)"
fi

# Summary
echo ""
echo "📊 Test Summary"
echo "==============="
if [ $errors -eq 0 ]; then
    echo "✅ All critical tests passed! DevContainer is properly configured."
    echo ""
    echo "Next steps:"
    echo "1. Run ./quickstart.sh to build SeekDeep"
    echo "2. Or run /tmp/setup-environment.sh for full automated setup"
else
    echo "❌ $errors critical errors found. Please check the devcontainer configuration."
fi

echo ""
echo "💡 For help, see .devcontainer/README.md"

exit $errors
