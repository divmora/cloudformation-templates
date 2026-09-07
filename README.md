# AWS CloudFormation Templates

A curated catalog of production-ready AWS CloudFormation infrastructure-as-code (IaC) templates for applications and services maintained by DIVMORA Technologies.

---

## 📁 Repository Catalog

| Service / Workload | Directory | Supported Deployments | Description |
| :--- | :--- | :--- | :--- |
| **OwlFlow** | [`owlflow/`](./owlflow/README.md) | AWS Lambda (Serverless), ECS Fargate | High-performance automation and workflow engine with webhook ingress and cron scheduling. |

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
