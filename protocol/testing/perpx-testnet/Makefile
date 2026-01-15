# dYdX v4 Perpx-Testnet Makefile
# Local testnet with 4 validators and custom block timing configuration

.PHONY: help init start stop restart reset logs clean build install docker-up docker-down docker-logs docker-reset

# Default target
.DEFAULT_GOAL := help

# Variables
CHAIN_DIR := $(PWD)/chain
DATA_DIR := $(PWD)/data
COMPOSE_FILE := docker-compose.yml
INDEXER_COMPOSE_FILE := ../../../indexer/docker-compose-local-deployment.yml

##@ General

help: ## Display this help message
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Development

build: ## Build the dydxprotocold binary
	cd ../../.. && make install

install: ## Install dydxprotocold to Go bin
	sudo apt-get update && sudo apt-get install -y build-essential
	@echo "Installing dydxprotocold..."
	cd ../../../protocol/cmd/dydxprotocold && CGO_ENABLED=1 go install -mod=readonly -ldflags '-w -s' -trimpath .

##@ Genesis

init: ## Initialize validators from scratch (removes existing chain)
	@echo "Initializing perpx-testnet validators..."
	rm -rf $(CHAIN_DIR)
	./perpx-testnet.sh
	@echo "✓ Genesis initialized successfully"

show-genesis: ## Display genesis configuration
	./genesis.sh

##@ Local Operations (Manual)

start: ## Start validators manually (requires 4 terminals)
	@echo "To start validators manually, run each command in a separate terminal:"
	@echo ""
	@echo "  dydxprotocold start --home=$(CHAIN_DIR)/.alice"
	@echo "  dydxprotocold start --home=$(CHAIN_DIR)/.bob"
	@echo "  dydxprotocold start --home=$(CHAIN_DIR)/.carl"
	@echo "  dydxprotocold start --home=$(CHAIN_DIR)/.dave"
	@echo ""

stop: ## Stop all running validators
	@echo "Stopping all validators..."
	pkill -f "dydxprotocold start.*$(CHAIN_DIR)" || true
	@echo "✓ Validators stopped"

restart: stop start ## Restart validators

status: ## Check validator status
	@echo "Checking validator status..."
	@for moniker in alice bob carl dave; do \
		echo ""; \
		echo "Validator: $$moniker"; \
		dydxprotocold status --home=$(CHAIN_DIR)/.$$moniker 2>/dev/null || echo "  Not running"; \
	done

##@ Docker

docker-build: ## Build the Docker image for perpx-testnet
	@echo "Building dydxprotocol:perpx Docker image..."
	@docker build -t dydxprotocol:perpx -f ../../Dockerfile ../../.
	@echo "✓ Docker image built: dydxprotocol:perpx"

docker-init: docker-build ## Initialize chain for Docker (create data directories)
	@echo "Creating data directories..."
	@if [ ! -d "$(CHAIN_DIR)/.alice" ]; then \
		echo "Initializing genesis..."; \
		./perpx-testnet.sh; \
	fi
	@echo "Syncing data directories..."
	@for moniker in alice bob carl dave; do \
		mkdir -p $(DATA_DIR)/$$moniker; \
		if [ -d "$(CHAIN_DIR)/.$$moniker/data" ]; then \
			rsync -a --delete $(CHAIN_DIR)/.$$moniker/data/ $(DATA_DIR)/$$moniker/; \
		fi; \
	done
	@echo "✓ Ready for Docker"

docker-up: docker-init ## Start protocol stack with Docker Compose
	docker-compose up -d
	@echo ""
	@echo "✓ Protocol stack started"
	@echo "  View logs: make docker-logs"
	@echo "  View status: docker-compose ps"

docker-down: ## Stop protocol stack (preserves state)
	docker-compose stop
	@echo "✓ Protocol stack stopped"

docker-restart: docker-down docker-up ## Restart protocol stack

docker-logs: ## View Docker logs (all services)
	docker-compose logs -f

docker-logs-validator: ## View validator logs
	docker-compose logs -f dydxprotocold0

docker-logs-oracle: ## View oracle logs
	docker-compose logs -f slinky0

docker-logs-prometheus: ## View Prometheus logs
	docker-compose logs -f prometheus

docker-ps: ## Show running containers
	docker-compose ps

docker-reset: ## Reset protocol stack (deletes all state, reinitializes genesis)
	docker-compose down
	rm -rf $(CHAIN_DIR) $(DATA_DIR)/*
	@echo "✓ Protocol stack reset (will reinitialize on next start)"
	@echo "  To restart: make docker-up"

##@ Indexer (Optional)

indexer-up: ## Start indexer stack (separate docker-compose)
	@if [ -f "$(INDEXER_COMPOSE_FILE)" ]; then \
		cd ../../../indexer && \
		docker-compose -f docker-compose-local-deployment.yml up -d; \
		echo "✓ Indexer stack started"; \
	else \
		echo "Indexer docker-compose file not found"; \
		exit 1; \
	fi

indexer-down: ## Stop indexer stack
	@if [ -f "$(INDEXER_COMPOSE_FILE)" ]; then \
		cd ../../../indexer && \
		docker-compose -f docker-compose-local-deployment.yml stop; \
		echo "✓ Indexer stack stopped"; \
	else \
		echo "Indexer docker-compose file not found"; \
		exit 1; \
	fi

indexer-logs: ## View indexer logs
	@if [ -f "$(INDEXER_COMPOSE_FILE)" ]; then \
		cd ../../../indexer && \
		docker-compose -f docker-compose-local-deployment.yml logs -f; \
	else \
		echo "Indexer docker-compose file not found"; \
		exit 1; \
	fi

indexer-reset: ## Reset indexer stack
	@if [ -f "$(INDEXER_COMPOSE_FILE)" ]; then \
		cd ../../../indexer && \
		docker-compose -f docker-compose-local-deployment.yml down -v; \
		echo "✓ Indexer stack reset"; \
	else \
		echo "Indexer docker-compose file not found"; \
		exit 1; \
	fi

##@ Queries & Testing

query-block: ## Query current block
	dydxprotocold q block --home=$(CHAIN_DIR)/.alice

query-status: ## Query node status
	dydxprotocold status --home=$(CHAIN_DIR)/.alice

query-validators: ## Query validators
	dydxprotocold q staking validators --home=$(CHAIN_DIR)/.alice

query-balances: ## Query balances for test accounts
	@for addr in dydx199tqg4wdlnu4qjlxchpd7seg454937hjrknju4 \
	             dydx10fx7sy6ywd5senxae9dwytf8jxek3t2gcen2vs \
	             dydx1fjg6zp6vv8t9wvy4lps03r5l4g7tkjw9wvmh70 \
	             dydx1wau5mja7j7zdavtfq9lu7ejef05hm6ffenlcsn; do \
		echo ""; \
		echo "Address: $$addr"; \
		dydxprotocold q bank balances $$addr --home=$(CHAIN_DIR)/.alice; \
	done

query-oracle: ## Query oracle prices
	curl -s http://localhost:8080/slinky/v1/market_prices | jq .

query-indexer: ## Query indexer API
	@echo "Querying indexer..."
	curl -s http://localhost:3002/v4/addresses | jq .

##@ Utilities

logs: ## Show validator logs (if running locally)
	@echo "Checking for validator logs..."
	@for moniker in alice bob carl dave; do \
		log_dir="$(CHAIN_DIR)/.$$moniker/log"; \
		if [ -d "$$log_dir" ]; then \
			echo ""; \
			echo "=== $$moniker logs ==="; \
			ls -lt "$$log_dir" | head -5; \
		fi \
	done

clean: ## Remove all generated files
	rm -rf $(CHAIN_DIR) $(DATA_DIR)
	@echo "✓ Cleaned all generated files"

clean-all: clean ## Remove all generated files and stop Docker
	docker-compose down
	rm -rf $(DATA_DIR)/*
	@echo "✓ Complete cleanup"
