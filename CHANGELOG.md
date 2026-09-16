# Changelog

## [0.2.0](https://github.com/divmora/cloudformation-templates/compare/v0.1.0...v0.2.0) (2026-09-16)


### Features

* **gitlab-fleet-governor:** add lambda and ecs fargate cloudformation templates ([d34ed18](https://github.com/divmora/cloudformation-templates/commit/d34ed18ba48fb877e3152969ed4ce21e0d519a58))
* initialize cloudformation-templates with owlflow lambda and ecs fargate templates ([b9c33cc](https://github.com/divmora/cloudformation-templates/commit/b9c33cc154f53c721903657549e1adf810c3a65a))
* **otel-aws-log-processor:** add multi-bucket, cross-account EventBridge, and KMS support ([2b4f162](https://github.com/divmora/cloudformation-templates/commit/2b4f162fb977bbe433f5c01ee1688b732783cc5a))
* **otel-aws-log-processor:** add serverless lambda cloudformation template and documentation ([0ae4779](https://github.com/divmora/cloudformation-templates/commit/0ae4779726216d994342341f0e334783c068a85a))
* **owlflow:** add vpc deployment support and function url documentation to lambda template ([86b4a30](https://github.com/divmora/cloudformation-templates/commit/86b4a3061c691c1640fdac55f56e16f1770b281f))


### Bug Fixes

* **otel-aws-log-processor:** remove redundant DeadLetterConfig from Lambda function ([8d91785](https://github.com/divmora/cloudformation-templates/commit/8d917859f929f9b8dee534685a7732678605d730))
* **otel-aws-log-processor:** use SSE-SQS encryption for EventBridge compatibility ([b8de158](https://github.com/divmora/cloudformation-templates/commit/b8de1583d238b20411580ddacd8e346ee0b52635))
* **templates:** resolve cfn-lint W3005 redundant DependsOn and E3030/E3033 Cors AllowMethods ([004e502](https://github.com/divmora/cloudformation-templates/commit/004e5024dec5eef390e7405b5fd75f74e6d6ab0b))
