.PHONY: bootstrap test labs-up labs-down labs-status labs-test labs-fpm-up labs-fpm-down labs-fpm-status labs-fpm-test lint clean

bootstrap:                     ## Fetch and pin the upstream exploit
	python3 tools/bootstrap_upstream.py

test:                          ## Run the unit test suite
	python3 -m unittest discover -s tests -v

lint:                          ## Run gitleaks to detect leaked secrets
	gitleaks detect --source . --no-git --redact -v

labs-up:                       ## Start all local laboratories (ports 8100-8106)
	python3 tools/php2shell_labs.py up

labs-down:                     ## Stop all local laboratories
	python3 tools/php2shell_labs.py down

labs-status:                   ## Show laboratory container status
	python3 tools/php2shell_labs.py status

labs-test:                     ## Run the dispatcher against each lab
	python3 tools/php2shell_labs.py test

labs-fpm-up:                   ## Start the nginx + PHP-FPM laboratories (no Docker)
	python3 tools/php2shell_fpm_labs.py up

labs-fpm-down:                 ## Stop the nginx + PHP-FPM laboratories
	python3 tools/php2shell_fpm_labs.py down

labs-fpm-status:               ## Show FPM laboratory status
	python3 tools/php2shell_fpm_labs.py status

labs-fpm-test:                 ## Run primitive + endgame against the FPM lab
	python3 tools/php2shell_fpm_labs.py test

inventory:                     ## Print the profile and offset inventory
	python3 tools/php2shell_inventory.py

validate-profiles:             ## Validate profiles (requires jsonschema)
	python3 -c "import json, jsonschema; \
	  schema = json.load(open('profiles/schema.json')); \
	  from pathlib import Path; \
	  [jsonschema.validate(json.loads(p.read_text()), schema) or print(f'  ok  {p.name}') \
	   for p in sorted(Path('profiles').glob('*.json')) if p.name != 'schema.json']"

clean:                         ## Remove generated files and vendor checkout
	rm -rf vendor/php2shell-upstream
	rm -rf lab/rce/out/

help:                          ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*##' $(MAKEFILE_LIST) | \
	  awk 'BEGIN {FS = ":.*## "}; {printf "  \033[36m%-20s\033[0m %s\n", $$1, $$2}'
