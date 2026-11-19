#!/bin/bash
# Show TokenEconomizer status

echo "TokenEconomizer Status"
echo "====================="

te status --verbose

echo ""
echo "Learned facts:"
te microskills list

echo ""
echo "Tool pruning:"
te toolprune status
