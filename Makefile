.PHONY: all validate lint clean

TEMPLATES := $(shell find . -type f \( -name "*.yaml" -o -name "*.yml" \) ! -path "*/.*/*")

all: validate

validate:
	@echo "Validating CloudFormation templates..."
	@which cfn-lint > /dev/null 2>&1 && cfn-lint $(TEMPLATES) || echo "cfn-lint not installed (run: pip install cfn-lint)"
	@which aws > /dev/null 2>&1 && echo "AWS CLI detected." || echo "AWS CLI not found."

lint:
	@echo "Linting YAML templates..."
	@which yamllint > /dev/null 2>&1 && yamllint $(TEMPLATES) || echo "yamllint not installed (run: pip install yamllint)"

clean:
	@echo "Cleaning temporary files..."
	@rm -rf .tmp/ *.packaged.yaml
