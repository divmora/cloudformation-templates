# OwlFlow CloudFormation Templates

This directory contains AWS CloudFormation templates for deploying **OwlFlow**, a lightweight, high-performance workflow automation engine.

---

## 🏛️ Deployment Architectures

| Architecture | Template | Recommended Use Case | Ingress | Cost Profile |
| :--- | :--- | :--- | :--- | :--- |
| **AWS Lambda** | [`owlflow-lambda.yaml`](./owlflow-lambda.yaml) | Webhook triggers (GitLab MRs, Jira comments, GitHub, HTTP), intermittent workloads | Direct HTTPS via **Lambda Function URL** (Supports VPC & Non-VPC) | **Pay-per-request** ($0 at idle) |
| **ECS Fargate** | [`owlflow-ecs-fargate.yaml`](./owlflow-ecs-fargate.yaml) | Continuous sub-minute cron schedules, long-running daemons, high-frequency execution | Direct Public IP or Application Load Balancer | **Continuous baseline** (0.25 vCPU / 0.5 GB) |

---

## 1. AWS Lambda Deployment (`owlflow-lambda.yaml`)

Deploy OwlFlow as a containerized Lambda function powered by the **AWS Lambda Web Adapter**.

### Ingress & VPC Modes:
- **Lambda Function URL**: Provides a built-in HTTPS endpoint for receiving webhook payloads (from GitLab, Jira, GitHub) without paying for or managing an API Gateway or Application Load Balancer.
- **VPC Deployment (Optional)**: If your workflows interact with private VPC resources (such as an internal GitLab instance, self-hosted Jira, internal databases, or private APIs), you can configure `VpcSubnetIds` and `VpcSecurityGroupIds`. When enabled, the template automatically provisions the `AWSLambdaVPCAccessExecutionRole` policy and sets up ENI attachments.
  > **Note on Outbound Internet Egress**: When deploying inside a VPC, ensure target subnets route outbound 0.0.0.0/0 traffic through a NAT Gateway or configure VPC Endpoints for external SaaS services (e.g., gitlab.com, atlassian.net).

### Step 1: Build & Push Lambda Container Image

Build using the dedicated `Dockerfile.lambda`:

```bash
# Set target AWS account, region, and ECR repository
export AWS_ACCOUNT_ID="123456789012"
export AWS_REGION="us-east-1"
export ECR_REPO="owlflow-lambda"
export IMAGE_TAG="latest"

# 1. Authenticate Docker with ECR
aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com

# 2. Create ECR repository (if not already existing)
aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION} || true

# 3. Build & push image
docker build -f Dockerfile.lambda -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} .
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
```

### Step 2: Deploy CloudFormation Stack

#### Standard Deployment (Non-VPC):
```bash
aws cloudformation deploy \
  --template-file owlflow/owlflow-lambda.yaml \
  --stack-name owlflow-lambda-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EnvironmentName=prod \
    ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
    Architecture=arm64 \
    MemorySize=512 \
    Timeout=60 \
    LogLevel=info \
    AuthType=NONE \
    GitLabToken="glpat-xxxxxxxxxxxxxxxxxxxx" \
    JiraUser="bot@example.com" \
    JiraToken="jira-api-token-xxxx" \
    JiraBaseUrl="https://your-org.atlassian.net"
```

#### VPC Deployment (Private Subnets):
```bash
aws cloudformation deploy \
  --template-file owlflow/owlflow-lambda.yaml \
  --stack-name owlflow-lambda-vpc-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    EnvironmentName=prod \
    ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
    VpcSubnetIds="subnet-0123456789abcdef0,subnet-0fedcba9876543210" \
    VpcSecurityGroupIds="sg-0123456789abcdef0" \
    Architecture=arm64 \
    MemorySize=512 \
    Timeout=60 \
    LogLevel=info \
    AuthType=NONE \
    GitLabToken="glpat-xxxxxxxxxxxxxxxxxxxx"
```

### Step 3: Retrieve Function URL & Verify Health

```bash
# Get the HTTPS webhook ingress URL
FUNCTION_URL=$(aws cloudformation describe-stacks \
  --stack-name owlflow-lambda-prod \
  --query "Stacks[0].Outputs[?OutputKey=='FunctionUrl'].OutputValue" \
  --output text)

echo "OwlFlow Ingress URL: ${FUNCTION_URL}"

# Health check
curl -i "${FUNCTION_URL}health"
```

---

## 2. AWS ECS Fargate Deployment (`owlflow-ecs-fargate.yaml`)

Deploy OwlFlow as a containerized daemon on ECS Fargate.

### Step 1: Build & Push Standard Container Image

Build using the root `Dockerfile`:

```bash
export ECR_REPO="owlflow-server"

# 1. Create repository
aws ecr create-repository --repository-name ${ECR_REPO} --region ${AWS_REGION} || true

# 2. Build & push
docker build -t ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} .
docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG}
```

### Step 2: Deploy CloudFormation Stack

```bash
aws cloudformation deploy \
  --template-file owlflow/owlflow-ecs-fargate.yaml \
  --stack-name owlflow-ecs-prod \
  --capabilities CAPABILITY_NAMED_IAM \
  --parameter-overrides \
    VpcId="vpc-xxxxxxxxxxxxxxxxx" \
    SubnetIds="subnet-xxxxxxxx,subnet-yyyyyyyy" \
    AssignPublicIp="ENABLED" \
    EnvironmentName=prod \
    ImageUri=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO}:${IMAGE_TAG} \
    DesiredCount=1 \
    Cpu=256 \
    Memory=512 \
    GitLabToken="glpat-xxxxxxxxxxxxxxxxxxxx"
```

---

## ⚙️ Parameters Reference

### `owlflow-lambda.yaml`

| Parameter | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `EnvironmentName` | `String` | `prod` | Deployment environment (`dev`, `staging`, `prod`) |
| `ImageUri` | `String` | *(Required)* | Full ECR URI for `owlflow-lambda` image |
| `Architecture` | `String` | `arm64` | Target CPU architecture (`arm64`, `x86_64`) |
| `MemorySize` | `Number` | `512` | Function memory in MB (256–10240) |
| `Timeout` | `Number` | `60` | Function timeout in seconds (10–900) |
| `AuthType` | `String` | `NONE` | Function URL authentication (`NONE` for public webhooks, `AWS_IAM` for SigV4) |
| `EnableCors` | `String` | `true` | Enables CORS headers on Function URL |
| `AllowedCorsOrigins` | `CommaDelimitedList` | `*` | Allowed CORS origins |
| `VpcSubnetIds` | `CommaDelimitedList` | `""` | Optional comma-separated list of Subnet IDs for VPC connectivity |
| `VpcSecurityGroupIds` | `CommaDelimitedList` | `""` | Optional comma-separated list of Security Group IDs for VPC connectivity |
| `GitLabToken` | `String` | `""` | Optional GitLab personal access token (NoEcho) |
| `GitLabBaseUrl` | `String` | `""` | Optional self-hosted GitLab URL |
| `JiraUser` | `String` | `""` | Optional Jira Cloud account email |
| `JiraToken` | `String` | `""` | Optional Jira Cloud API token (NoEcho) |
| `JiraBaseUrl` | `String` | `""` | Optional Jira Cloud base URL |
| `LogRetentionInDays` | `Number` | `30` | Days to retain CloudWatch logs |

---

## 🔒 Security Best Practices

1. **Webhook Authentication**: When using `AuthType: NONE`, configure webhook secret verification in your workflow definitions (e.g. `trigger.secret` in OwlFlow workflows) to ensure incoming payloads are signed by GitLab / Jira / GitHub.
2. **Secrets Protection**: Parameter values marked `NoEcho: true` are redacted from the AWS Console and CloudFormation events. For production systems, you can also inject AWS Secrets Manager references directly using dynamic parameters (`{{resolve:secretsmanager:...}}`).
3. **Least Privilege**: IAM execution roles created by these templates restrict CloudWatch Logs writing strictly to the function's own dedicated log group, and VPC permissions are only attached when VPC subnets are provided.
