# perpx-testnet

dYdX v4 local testnet with 4 validators and custom block timing configuration.

## Configuration

| Parameter | Value |
|-----------|-------|
| Chain ID | `localdydxprotocol` |
| Validators | 4 (alice, bob, carl, dave) |
| Native Token | `perpxtt` |
| Validator Stake | 500,000 tokens |
| Block Time (`timeout_commit`) | 1s |
| Next Block Delay | 200ms (set via governance after startup) |

`★ Insight ─────────────────────────────────────`
**Self-Contained Deployment**: All genesis files, configs, and data are stored locally in `protocol/testing/perpx-testnet/chain/` instead of `$HOME/chain/`. This makes the testnet fully self-contained and portable.
`─────────────────────────────────────────────────`

## Genesis Configuration

The perpx-testnet includes its own `genesis.sh` file that defines all genesis-specific parameters. This sources the parent `../genesis.sh` for shared configuration while allowing perpx-testnet customizations.

### Genesis Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Chain ID | `localdydxprotocol` | Unique chain identifier |
| Native Token | `perpxtt` | PerpX testnet token |
| Genesis Time | `2026-01-01T00:00:00Z` | Fixed genesis time |
| Block Time | 1s | Fast blocks for testing |
| Unbonding Time | 7 days | Faster than mainnet (21 days) |

### Faster Governance Timings

For faster testing, the perpx-testnet uses expedited governance parameters:

| Parameter | Value | Mainnet |
|-----------|-------|---------|
| max_deposit_period | 60s | longer |
| voting_period | 60s | longer |
| expedited_voting_period | 30s | longer |

### Viewing Genesis Configuration

```bash
cd protocol/testing/perpx-testnet
./genesis.sh
```

### Modifying Genesis

To customize the genesis for your testing needs, edit the `genesis.sh` file:

```bash
# Edit genesis configuration
vim genesis.sh

# Regenerate genesis (requires resetting validators)
rm -rf ./chain
./perpx-testnet.sh
```



1. Ensure the dydxprotocold binary is built and installed:
```bash
cd /path/to/v4-chain/protocol
make install
```

2. Run the setup script:
```bash
cd protocol/testing/perpx-testnet
chmod +x perpx-testnet.sh
./perpx-testnet.sh
```

This will:
- Create 4 validators with deterministic keys
- Store all data in local `./chain/` directory
- Configure genesis with shared parameters from `../genesis.sh`
- Set `timeout_commit=1s` in config.toml
- Initialize cosmovisor for each validator

## Starting the Chain

### Option A: Manual Start

Start each validator in separate terminals:
```bash
# Terminal 1
dydxprotocold start --home=./chain/.alice

# Terminal 2
dydxprotocold start --home=./chain/.bob

# Terminal 3
dydxprotocold start --home=./chain/.carl

# Terminal 4
dydxprotocold start --home=./chain/.dave
```

### Option B: Docker Compose

**Recommended** - Docker Compose provides proper networking and isolates each validator.

The perpx-testnet uses a **two-stack architecture**:
1. **Protocol Stack** (perpx-testnet): Validators + Slinky Oracle
2. **Indexer Stack** (separate): Kafka + PostgreSQL + Redis + Indexer services

This separation allows you to run the protocol independently or with the full indexer stack.

#### Protocol Stack (Required)

1. Build the Docker image (from protocol directory):
```bash
cd /path/to/v4-chain/protocol
docker build -t dydxprotocol:perpx -f Dockerfile .
```

2. Run the setup script to initialize validators:
```bash
cd protocol/testing/perpx-testnet
./perpx-testnet.sh
```

3. Create data directories:
```bash
mkdir -p data/{alice,bob,carl,dave}
```

4. Start the protocol:
```bash
docker-compose up -d
```

5. View logs:
```bash
docker-compose logs -f dydxprotocold0
```

#### Indexer Stack (Optional)

The indexer provides HTTP/WebSocket APIs for querying protocol state. To run it:

1. Build the indexer (one-time setup):
```bash
cd ../../../indexer
pnpm install
pnpm run build:all
```

**Note**: This builds all packages and services. It may take 5-10 minutes and only needs to be done once unless you modify indexer code.

2. Start the indexer services:
```bash
docker-compose -f docker-compose-local-deployment.yml up -d
```

3. View indexer logs:
```bash
docker-compose -f docker-compose-local-deployment.yml logs -f
```

4. Access indexer APIs:
- HTTP API: `http://localhost:3002`
- WebSocket: `ws://localhost:3003/v4/ws`

`★ Insight ─────────────────────────────────────`
**Two-Stack Communication**: The protocol stack and indexer stack run independently. The indexer connects to the protocol via `host.docker.internal:26657` (RPC) or gRPC streaming at `host.docker.internal:9092`. This allows you to restart either stack without affecting the other.
`─────────────────────────────────────────────────`

#### Stopping & Resetting

Stop protocol (preserves state):
```bash
docker-compose stop
```

Stop indexer:
```bash
cd ../../../indexer
docker-compose -f docker-compose-local-deployment.yml stop
```

Reset protocol (deletes state):
```bash
docker-compose down
rm -rf ./data/* && ./perpx-testnet.sh
```

Reset indexer:
```bash
docker-compose -f docker-compose-local-deployment.yml down -v
```

## Markets Configuration

The perpx-testnet includes **35 perpetual markets** at genesis, organized by liquidity tier:

### Large-Cap Markets (Tier 0)

| Market ID | Ticker | Atomic Resolution | Initial Margin | Maintenance |
|-----------|--------|-------------------|----------------|-------------|
| 0 | BTC-USD | 1e-10 | 2% | 1.2% |
| 1 | ETH-USD | 1e-9 | 2% | 1.2% |

### Small-Cap Markets (Tier 1)

| Market ID | Ticker | Atomic Resolution | Initial Margin | Maintenance |
|-----------|--------|-------------------|----------------|-------------|
| 2 | LINK-USD | 1e-6 | 10% | 5% |
| 3 | POL-USD | 1e-5 | 10% | 5% |
| 4 | CRV-USD | 1e-5 | 10% | 5% |
| 5 | SOL-USD | 1e-7 | 10% | 5% |
| 6 | ADA-USD | 1e-5 | 10% | 5% |
| 7 | AVAX-USD | 1e-7 | 10% | 5% |
| 8 | FIL-USD | 1e-6 | 10% | 5% |
| 9 | LTC-USD | 1e-7 | 10% | 5% |
| 10 | DOGE-USD | 1e-4 | 10% | 5% |
| 11 | ATOM-USD | 1e-6 | 10% | 5% |
| 12 | DOT-USD | 1e-6 | 10% | 5% |
| 13 | UNI-USD | 1e-6 | 10% | 5% |
| 14 | BCH-USD | 1e-8 | 10% | 5% |
| 15 | TRX-USD | 1e-4 | 10% | 5% |
| 16 | NEAR-USD | 1e-6 | 10% | 5% |
| 18 | XLM-USD | 1e-5 | 10% | 5% |
| 19 | ETC-USD | 1e-7 | 10% | 5% |
| 21 | WLD-USD | 1e-6 | 10% | 5% |
| 23 | APT-USD | 1e-6 | 10% | 5% |
| 24 | ARB-USD | 1e-6 | 10% | 5% |
| 27 | OP-USD | 1e-6 | 10% | 5% |
| 28 | PEPE-USD | 1e0 | 10% | 5% |
| 30 | SHIB-USD | 1e0 | 10% | 5% |
| 31 | SUI-USD | 1e-5 | 10% | 5% |
| 32 | XRP-USD | 1e-5 | 10% | 5% |

### Long-Tail Markets (Tier 2)

| Market ID | Ticker | Atomic Resolution | Initial Margin | Maintenance |
|-----------|--------|-------------------|----------------|-------------|
| 17 | MKR-USD | 1e-9 | 20% | 10% |
| 20 | COMP-USD | 1e-7 | 20% | 10% |
| 22 | APE-USD | 1e-6 | 20% | 10% |
| 25 | BLUR-USD | 1e-5 | 20% | 10% |
| 26 | LDO-USD | 1e-6 | 20% | 10% |
| 29 | SEI-USD | 1e-5 | 20% | 10% |

### Isolated Markets (Tier 4)

| Market ID | Ticker | Atomic Resolution | Initial Margin | Maintenance |
|-----------|--------|-------------------|----------------|-------------|
| 300 | EIGEN-USD | 1e-6 | 5% | 3% |
| 301 | BOME-USD | 1e-3 | 5% | 3% |

### Test Market

| Market ID | Ticker | Atomic Resolution | Initial Margin | Maintenance |
|-----------|--------|-------------------|----------------|-------------|
| 33 | TEST-USD | 1e-4 | 100% | 20% |

`★ Insight ─────────────────────────────────────`
**Atomic Resolution**: Determines the minimum price increment for orders. A value of 1e-10 means prices can move in 0.0000000001 increments. Smaller atomic resolutions allow for finer-grained pricing but require more storage.
`─────────────────────────────────────────────────`

## Oracle Configuration (Slinky)

The perpx-testnet uses **Slinky Oracle v1.1.0** for price feeds:

| Parameter | Value |
|-----------|-------|
| Image | `ghcr.io/skip-mev/slinky-sidecar:v1.1.0` |
| Provider | dYdX Migration API (market map provider) |
| Oracle API | `http://dydxprotocold0:9090` (gRPC) |
| REST API | `http://dydxprotocold0:1317` (REST) |
| Update Interval | 10 seconds |
| Metrics | Prometheus on port 8001 |

### Oracle Data Sources

Slinky aggregates prices from multiple exchanges for each market:

**Primary Sources:**
- Binance (WebSocket)
- Bybit (WebSocket)
- Coinbase (WebSocket)
- Kraken (REST API)
- KuCoin (WebSocket)
- OKX (WebSocket)

**Secondary Sources (market-dependent):**
- Huobi, Gate.io, Crypto.com

### Querying Oracle Prices

```bash
# Query via REST API
curl http://localhost:8080/slinky/v1/market_prices | jq

# Query via gRPC
dydxprotocold q oracle market_price BTC/USD --home=./chain/.alice
```

`★ Insight ─────────────────────────────────────`
**Market Map Provider Pattern**: Slinky uses a "market map" that defines which markets to track and which exchanges to query. The dYdX Migration API provides this market map dynamically, making it easy to add new markets without restarting the oracle.
`─────────────────────────────────────────────────`

## Indexer Services

The indexer provides HTTP/WebSocket APIs for querying protocol state. It runs as a **separate stack** from the protocol.

`★ Insight ─────────────────────────────────────`
**Event Flow**: Indexer connects to protocol via gRPC streaming (`host.docker.internal:9092`) → Ingests events → PostgreSQL for persistence → HTTP/WebSocket APIs for clients. The protocol does NOT send events to Kafka in this architecture; the indexer pulls events from the protocol.
`─────────────────────────────────────────────────`

### Indexer Core Services

| Service | Port | Description |
|---------|------|-------------|
| comlink | 3002 | HTTP API (http://localhost:3002) |
| socks | 3003 | WebSocket API (ws://localhost:3003/v4/ws) |
| ender | 3001 | On-chain event ingestion |
| vulcan | 3005 | Off-chain orderbook events |
| roundtable | 3004 | Job scheduler |

### Infrastructure Services

| Service | Port | Description |
|---------|------|-------------|
| Kafka | 9092, 29092 | Event streaming bus |
| Zookeeper | 2181 | Kafka coordination |
| PostgreSQL | 5435 | Indexed data storage |
| Redis | 6382 | Caching layer |

### Testing Indexer

```bash
# From the perpx-testnet directory
cd ../../../indexer

# Query HTTP API
curl http://localhost:3002/v4/addresses

# Query subaccounts
curl http://localhost:3002/v4/subaccounts

# Query markets
curl http://localhost:3002/v4/perpetualMarkets

# Test WebSocket (requires wscat: npm install -g wscat)
wscat -c ws://localhost:3003/v4/ws
```

### Verification

```bash
# From the indexer directory
docker-compose -f docker-compose-local-deployment.yml ps

# Check Kafka topics
docker-compose -f docker-compose-local-deployment.yml exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Check indexer logs
docker-compose -f docker-compose-local-deployment.yml logs -f ender
docker-compose -f docker-compose-local-deployment.yml logs comlink
```

## Setting NextBlockDelay

After the chain is running, you can check the NextBlockDelay configuration:

```bash
cd protocol/testing/perpx-testnet
chmod +x set-block-delay.sh
./set-block-delay.sh
```

### CLI Command Status

**Important**: The CLI command `dydxprotocold tx blocktime update-synchrony-params` is **not implemented** in the current binary. The `MsgUpdateSynchronyParams` message exists in the protocol, but the CLI command wrapper has not been added.

### NextBlockDelay Options

To set NextBlockDelay to 200ms, you can:

1. **Use the Docker init service**: Runs automatically on startup and displays current configuration
2. **Submit a governance proposal**: Standard governance process
3. **Implement the CLI command**: Add to `protocol/x/blocktime/client/cli/tx.go`:

```go
// Example implementation pattern
cmd.AddCommand(
    cmd.NewCmdUpdateSynchronyParams(),
)
```

### Verification

Query the synchrony params to check current value:
```bash
dydxprotocold q blocktime synchrony-params --home=./chain/.alice
```

Expected output:
```json
{
  "params": {
    "next_block_delay": "0s"
  }
}
```

## Block Timing Architecture

`★ Insight ─────────────────────────────────────`
**Two-tier block timing**:
1. **timeout_commit** (config.toml): Maximum time to wait for block proposal before timeout. Set to 1s for this testnet.
2. **NextBlockDelay** (blocktime module): Additional delay AFTER receiving +2/3 precommits. Set to 200ms for fast finality.

When `NextBlockDelay > 0`, CometBFT uses it instead of `timeout_commit` for the delay after precommit. This provides consistent block times with fast finality.
`─────────────────────────────────────────────────`

## Network Ports Summary

### Protocol Stack (perpx-testnet)

| Service | Port | Description |
|---------|------|-------------|
| dydxprotocold0 P2P | 26656 | P2P networking |
| dydxprotocold0 RPC | 26657 | JSON-RPC |
| dydxprotocold0 REST | 1317 | REST API |
| dydxprotocold0 gRPC | 9090 | gRPC |
| dydxprotocold0 gRPC Streaming | 9093 | gRPC Streaming (used by indexer) |
| Slinky Oracle API | 8080 | Oracle prices |
| Slinky Metrics | 8002 | Prometheus metrics |
| Prometheus | 9091 | Metrics dashboard |

### Indexer Stack (separate)

| Service | Port | Description |
|---------|------|-------------|
| Kafka | 9092, 29092 | Event streaming bus |
| Zookeeper | 2181 | Kafka coordination |
| PostgreSQL | 5435 | Indexed data storage |
| Redis | 6382 | Caching layer |
| comlink API | 3002 | HTTP API |
| socks WebSocket | 3003 | WebSocket API |
| ender | 3001 | On-chain indexer |
| vulcan | 3005 | Off-chain indexer |
| roundtable | 3004 | Job scheduler |

## Verification

### Check Block Production

Monitor blocks being produced:
```bash
dydxprotocold q block --watch --home=./chain/.alice
```

### Check Validator Status

```bash
dydxprotocold status --home=./chain/.alice
```

### Check Sync Status

```bash
dydxprotocold status --home=./chain/.alice 2>&1 | grep catching_up
# Should return: "catching_up": false when synced
```

### Check Oracle Prices

```bash
# Query all market prices
curl http://localhost:8080/slinky/v1/market_prices | jq

# Query specific market
dydxprotocold q oracle market_price BTC/USD --home=./chain/.alice
```

### Check Indexer

```bash
# Wait for services to fully start (~60-90 seconds)

# Check all services are healthy
docker-compose ps

# Verify Kafka topics are created
docker-compose exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Query indexer API
curl http://localhost:3002/v4/addresses

# Query subaccounts
curl http://localhost:3002/v4/subaccounts

# Query perpetual markets
curl http://localhost:3002/v4/perpetualMarkets
```

## Files

| File | Purpose |
|------|---------|
| `genesis.sh` | Genesis configuration for perpx-testnet (sources parent genesis.sh) |
| `perpx-testnet.sh` | Main setup script for 4 validators |
| `set-block-delay.sh` | Script to check NextBlockDelay configuration |
| `init-block-delay.sh` | Docker init service for NextBlockDelay info |
| `docker-compose.yml` | Docker Compose configuration for protocol stack |
| `README.md` | This documentation |

## Indexer Files

| File | Purpose |
|------|---------|
| `indexer/docker-compose-local-deployment.yml` | Docker Compose for indexer stack |
| `indexer/Dockerfile.service.local` | Service container image |
| `indexer/Dockerfile.postgres.local` | PostgreSQL container image |

## Known Limitations

1. **CLI Command Missing**: The `dydxprotocold tx blocktime update-synchrony-params` command doesn't exist. This requires implementing the CLI in `protocol/x/blocktime/client/cli/tx.go`, which is outside the perpx-testnet folder.

2. **NextBlockDelay**: Remains at 0s (default) until manually set via governance or CLI implementation.

3. **Indexer Build Required**: The indexer must be built before running the indexer stack. This is a one-time requirement (`pnpm install && pnpm run build:all` in the indexer directory) unless you modify indexer code. The build requires `pnpm` and may take 5-10 minutes.

4. **Memory Usage (with indexer)**: Running both stacks (4 validators + indexer stack + Kafka + PostgreSQL + Redis) requires significant RAM (8GB+ recommended). Running just the protocol stack requires ~4GB.

5. **Indexer Startup Time**: The indexer stack may take 60-90 seconds to start due to service dependencies (PostgreSQL → postgres-package → indexer services).

6. **Two-Stack Management**: The protocol and indexer run as separate docker-compose stacks. You need to manage them independently (start/stop/reset in different directories).

## References

- **Template**: `protocol/testing/testnet-local/local.sh`
- **Genesis config**: `protocol/testing/genesis.sh`
- **Blocktime module**: `protocol/x/blocktime/`
- **Slinky Config**: `protocol/contrib/slinky/oracle.json`
- **Proto**: `proto/dydxprotocol/blocktime/tx.proto`
- **Indexer**: `indexer/docker-compose-local-deployment.yml`
