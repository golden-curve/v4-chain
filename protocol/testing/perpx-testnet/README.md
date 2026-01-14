# perpx-testnet

dYdX v4 local testnet with 4 validators and fast block timing.

| Parameter | Value |
|-----------|-------|
| Chain ID | `localdydxprotocol` |
| Validators | 4 (alice, bob, carl, dave) |
| Native Token | `perpxtt` |
| Block Time | ~1s (timeout_commit) |

`★ Insight ─────────────────────────────────────`
**Self-Contained Testnet**: All validator data is stored locally in `./chain/` instead of `$HOME/.dydxprotocol/`. Run `make help` to see all available commands.
`─────────────────────────────────────────────────`

## Quick Start

### Prerequisites

```bash
# Build dydxprotocold binary (from protocol root)
cd /path/to/v4-chain/protocol
make build
```

### Docker (Recommended)

```bash
# Initialize and start the testnet
make docker-up

# View logs
make docker-logs-validator

# Query status
make query-status
```

### Manual (Local Development)

```bash
# Initialize validators
make init

# Start validators (4 terminals)
make start

# Stop validators
make stop
```

## Makefile Commands

```bash
make help                    # Show all available commands

## Genesis
make init                    # Initialize validators (removes existing chain)
make show-genesis            # Display genesis configuration

## Docker
make docker-build            # Build Docker image
make docker-up               # Start protocol stack (builds image if needed)
make docker-down             # Stop protocol stack (preserves state)
make docker-reset            # Reset protocol stack (deletes state)
make docker-logs             # View all logs
make docker-logs-validator   # View validator logs
make docker-ps               # Show running containers

## Manual Operations
make start                   # Show commands to start validators manually
make stop                    # Stop running validators
make status                  # Check validator status

## Queries
make query-block             # Query current block
make query-status            # Query node status
make query-validators        # Query validators
make query-balances          # Query test account balances
make query-oracle            # Query oracle prices

## Utilities
make clean                   # Remove generated files
make clean-all               # Complete cleanup (stop Docker + remove files)
```

## Indexer (Optional)

The indexer provides HTTP/WebSocket APIs for querying protocol state.

```bash
# Build indexer (one-time setup, from protocol root)
cd ../../../indexer
pnpm install
pnpm run build:all

# Start indexer stack (from perpx-testnet)
make indexer-up

# Query indexer API
make query-indexer

# Stop indexer
make indexer-down
```

**Indexer APIs:**
- HTTP API: `http://localhost:3002`
- WebSocket: `ws://localhost:3003/v4/ws`

## Configuration

### Block Timing

| Setting | Value | Location |
|---------|-------|----------|
| `timeout_commit` | 1s | `config.toml` |
| `next_block_delay` | 100ms | `protocol/x/blocktime/types/params.go` |

**Note**: `next_block_delay` is hardcoded to 100ms in `DefaultSynchronyParams()` for fast blocks. To change this, modify the value in `protocol/x/blocktime/types/params.go:33`.

### Markets

35 perpetual markets at genesis including:
- **Large-Cap**: BTC-USD, ETH-USD
- **Small-Cap**: SOL, ADA, AVAX, DOT, ATOM, LINK, etc.
- **Test Market**: TEST-USD (for testing)

### Oracle

Slinky Oracle v1.1.0 aggregates prices from Binance, Bybit, Coinbase, Kraken, and others.

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     perpx-testnet                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  alice   │  │   bob    │  │  carl    │  │   dave   │   │
│  │ Validator│  │ Validator│  │ Validator│  │ Validator│   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│        │              │              │              │       │
│        └──────────────┴──────────────┴──────────────┘       │
│                       │                                     │
│                ┌──────▼──────┐                              │
│                │ Slinky      │                              │
│                │ Oracle      │                              │
│                └─────────────┘                              │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼ (Optional)
┌─────────────────────────────────────────────────────────────┐
│                     Indexer Stack                           │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │  ender   │  │ comlink  │  │  socks   │  │ vulcan   │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
│        │              │              │              │       │
│        └──────────────┴──────────────┴──────────────┘       │
│                       │                                     │
│                ┌──────▼──────┐                              │
│                │ PostgreSQL  │  Kafka  │  Redis            │
│                └─────────────┘─────────────────────────────┘│
└─────────────────────────────────────────────────────────────┘
```

## Troubleshooting

### "Error: aborted" when running `make init`

The keyring already has keys. The script now handles this automatically by deleting existing keys before re-adding them.

### Validators not starting

```bash
# Check if ports are available
make docker-ps

# Reset and restart
make docker-reset
make docker-up
```

### Indexer connection issues

The indexer connects to protocol via `host.docker.internal:9092` (gRPC streaming). Ensure the protocol stack is running first.

## Files

| File | Purpose |
|------|---------|
| `Makefile` | All commands (run `make help`) |
| `genesis.sh` | Genesis configuration |
| `perpx-testnet.sh` | Validator setup script |
| `docker-compose.yml` | Docker configuration |

## References

- **Parent Genesis**: `../genesis.sh`
- **Blocktime Module**: `protocol/x/blocktime/`
- **Slinky Oracle**: `protocol/contrib/slinky/`
