.PHONY: deps compile test format dialyzer credo credo-strict credo-fix run-dev run-prod clean

# Development commands
deps:
	docker-compose run --rm dev mix deps.get

compile:
	docker-compose run --rm dev mix compile

test:
	docker-compose run --rm dev mix test

format:
	docker-compose run --rm dev mix format

dialyzer:
	docker-compose run --rm dev mix dialyzer

credo:
	docker-compose run --rm dev mix credo

credo-strict:
	docker-compose run --rm dev mix credo --strict
	
credo-fix:
	./scripts/fix_credo_issues.sh

# Application commands
run-dev:
	docker-compose run --rm dev iex -S mix

run-prod:
	docker-compose up

# Cleanup
clean:
	docker-compose down
	rm -rf _build deps