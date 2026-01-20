.PHONY: help setup deploy logs restart stop status clean

help: ## Show this help message
	@echo "Convex Backend Management Commands"
	@echo ""
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

setup: ## Run initial EC2 setup
	@./scripts/setup-ec2.sh

deploy: ## Deploy/update the backend
	@cd /opt/convex && docker compose pull && docker compose up -d

logs: ## View backend logs
	@cd /opt/convex && docker compose logs -f backend

restart: ## Restart all services
	@cd /opt/convex && docker compose restart

stop: ## Stop all services
	@cd /opt/convex && docker compose down

status: ## Show service status
	@cd /opt/convex && docker compose ps

clean: ## Clean up old Docker images
	@docker image prune -f

admin-key: ## Generate admin key
	@cd /opt/convex && docker compose exec backend ./generate_admin_key.sh
