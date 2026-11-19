#!/bin/bash
# Apply learned facts to new session

echo "Applying TokenEconomizer Facts"
echo "=============================="

# Show facts being applied
te microskills list

# Apply to current session
export TE_AUTO_APPLY=true

echo ""
echo "Facts applied. Use these commands in this session:"
echo "  - Build: makepkg -si"
echo "  - Test: ./build/verify-gates.sh"
echo "  - ISO: ./build/build-iso.sh"
echo "  - Design: docs/design-system/"
