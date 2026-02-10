# Change this to your 42 login for volume paths and setup
LOGIN       = aarustam
DATA_PATH   = /home/$(LOGIN)/data

.PHONY: all build up down clean fclean re logs ps setup stop start

all: up

up: setup build
	@echo "Starting containers..."
	cd srcs && docker-compose up -d

setup:
	@echo "Setting up data directories..."
	@cd srcs && DATA_PATH="$(DATA_PATH)" ./setup-volumes.sh

build:
	@echo "Building Docker images..."
	cd srcs && docker-compose build

down:
	@echo "Stopping containers..."
	cd srcs && docker-compose down

stop:
	cd srcs && docker-compose stop

start:
	cd srcs && docker-compose start

clean: down
	@echo "Cleaning up containers and images..."
	cd srcs && docker-compose down --rmi all --volumes --remove-orphans

fclean: clean
	@echo "Full cleanup (including data directory)..."
	@rm -rf $(DATA_PATH)
	docker system prune -af --volumes

re: fclean all

logs:
	cd srcs && docker-compose logs -f

ps:
	cd srcs && docker-compose ps

