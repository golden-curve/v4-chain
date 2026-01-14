#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================================="
echo "Initializing NextBlockDelay Configuration Check"
echo "=================================================="
echo ""

# Wait for chain to start and produce some blocks
echo "Waiting for chain to start producing blocks..."
sleep 60

echo ""
echo "=================================================="
echo "Blocktime Synchrony Parameters"
echo "=================================================="
echo ""

# Query current synchrony params using the local chain directory
dydxprotocold q blocktime synchrony-params --home="$SCRIPT_DIR/chain/.alice" 2>/dev/null || echo "Failed to query synchrony params (chain may still be starting)"

echo ""
echo "=================================================="
echo "NextBlockDelay Configuration Information"
echo "=================================================="
echo ""
echo "The perpx-testnet is configured with:"
echo "  - timeout_commit (config.toml): 1s"
echo "  - NextBlockDelay (blocktime module): [See query above]"
echo ""
echo "When NextBlockDelay > 0, CometBFT uses it instead of timeout_commit"
echo "for the delay after receiving +2/3 precommits."
echo ""
echo "To set NextBlockDelay to 200ms:"
echo "  1. Submit a governance proposal"
echo "  2. Query current params: dydxprotocold q blocktime synchrony-params --home=\$CHAIN_DIR/.alice"
echo ""
echo "=================================================="
