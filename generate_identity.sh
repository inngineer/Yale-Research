#!/bin/bash
# Convenience wrapper for identity generation
# Run from project root: ./generate_identity.sh

cd "$(dirname "$0")/src" || exit 1

echo "=========================================="
echo "Yale Fingerprinting Research"
echo "Identity Generation Tool"
echo "=========================================="
echo ""

# Check if arguments provided
if [ $# -eq 0 ]; then
    echo "Usage:"
    echo "  ./generate_identity.sh list                    # List available components"
    echo "  ./generate_identity.sh random [strategy]       # Generate random identity"
    echo "  ./generate_identity.sh preset <name>           # Use preset profile"
    echo "  ./generate_identity.sh custom <args>           # Custom components"
    echo ""
    echo "Examples:"
    echo "  ./generate_identity.sh list"
    echo "  ./generate_identity.sh random aggressive"
    echo "  ./generate_identity.sh preset gaming_enthusiast"
    echo ""
    exit 0
fi

sudo pkill -f warp
sudo rm -rf ~/.config/warp-terminal/ ~/.local/state/warp-terminal/ ~/.cache/warp-terminal/ 


# Run formulate_identity.py with arguments
./formulate_identity.py "$@"

# If generation successful, offer to build
if [ $? -eq 0 ] && [ "$1" != "list" ]; then
    echo ""
    read -p "Build and compile now? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        ./build_identity.py
        echo ""
        echo "✅ Ready to use!"
        echo ""
        echo "Test it:"
        echo "  LD_PRELOAD=./identity.so hostname"
        echo "  LD_PRELOAD=./identity.so /opt/warpdotdev/warp-terminal/warp"
    fi
fi
