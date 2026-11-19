#!/bin/bash
# Show TokenEconomizer cost savings

echo "PalexusOS TokenEconomizer Cost Report"
echo "======================================"

te report view --aggregate

echo ""
echo "Cost breakdown by agent:"
te report view --by-agent

echo ""
echo "Recent savings:"
te report view --since "7 days ago"
