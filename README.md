# AWS CloudFormation Templates

A curated catalog of production-ready AWS CloudFormation infrastructure-as-code (IaC) templates for applications and services maintained by DIVMORA Technologies.

---

## 📁 Repository Catalog

| Service / Workload | Directory | Supported Deployments | Description |
| :--- | :--- | :--- | :--- |
| **GitLab Fleet Governor** | [`gitlab-fleet-governor/`](./gitlab-fleet-governor/README.md) | AWS Lambda (Serverless), ECS Fargate | Declarative policy-as-code and compliance auditing engine for GitLab enterprise fleets. |
| **OwlFlow** | [`owlflow/`](./owlflow/README.md) | AWS Lambda (Serverless), ECS Fargate | High-performance automation and workflow engine with webhook ingress and cron scheduling. |
| **AWS Log to OTel Processor** | [`otel-aws-log-processor/`](./otel-aws-log-processor/README.md) | AWS Lambda (Serverless) | Real-time processor converting AWS access logs (ALB, NLB, CloudFront, WAF) to OpenTelemetry OTLP format. |

---

## 🆚 Standard CloudFormation Templates vs. CloudFormation StackSets

| Dimension | `cloudformation-templates` (This Repository) | `cloudformation-staksets` |
| :--- | :--- | :--- |
| **Deployment Target** | **Single Account / Single Region** | **Multi-Account / Multi-Region across AWS Organizations** |
| **Primary Scope** | Application services, APIs, databases, container tasks | Enterprise security baselines, IAM guardrails, AWS Config rules |
| **Trigger Mechanism** | Direct CI/CD pipelines (`aws cloudformation deploy`) | AWS Organizations Management Account or Delegated Admin StackSets |
| **Blast Radius** | Isolated to specific environment (dev, staging, prod) | Global or OU-wide |

---

## 🛠️ Validation & Linting

Verify and validate templates with the included `Makefile`:

```bash
# Validate templates against CloudFormation schema
make validate

# Lint templates with cfn-lint (if installed)
make lint
```
