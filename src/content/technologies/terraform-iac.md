---
title: "GitHub Copilot for Terraform & Infrastructure as Code"
description: "Master Copilot's IaC capabilities — from Terraform modules and variable definitions to CI/CD pipelines, Ansible playbooks, and cloud resource management."
language: "Terraform/IaC"
icon: "🏗️"
difficulty: intermediate
duration: "40 minutes"
tags: ["terraform", "iac", "infrastructure", "cloud", "devops"]
lastUpdated: 2026-04-08
order: 6
---

# GitHub Copilot for Terraform & Infrastructure as Code

Infrastructure as Code is inherently pattern-heavy — resource definitions, variable blocks, output declarations, and module structures follow predictable templates that vary mainly in the specific resource attributes. This makes IaC an ideal domain for AI-assisted coding. GitHub Copilot can generate complete Terraform resources from comments, scaffold entire modules, and help you write the CI/CD pipelines that deploy them.

---

## Why Copilot Excels at IaC

| Factor | Why It Matters |
|---|---|
| **Declarative syntax** | Terraform's HCL is structured and repetitive — perfect for pattern completion |
| **Provider documentation** | Copilot has seen the AWS, Azure, and GCP provider resources extensively |
| **Module patterns** | Standard module structure (variables → resources → outputs) is highly predictable |
| **YAML-heavy ecosystem** | GitHub Actions, Ansible, and Kubernetes all benefit from the same pattern matching |
| **Security patterns** | IAM policies, security groups, and RBAC configurations follow documented patterns |

> **💡 Tip:** Always review Copilot-generated Terraform carefully. Infrastructure mistakes can be costly. Use `terraform plan` and policy-as-code tools to validate before applying.

---

## Terraform Resource Generation

Copilot generates complete Terraform resources with required and commonly-used optional attributes.

### Example: AWS VPC with Subnets

**Prompt:**

```hcl
# Create a VPC with public and private subnets across 2 availability zones
# Include NAT gateway for private subnet internet access
# Tag all resources with the project name

variable "project_name" {
  description = "Project name for resource tagging"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}
```

**Copilot generates:**

```hcl
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name    = "${var.project_name}-vpc"
    Project = var.project_name
  }
}

resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name    = "${var.project_name}-public-${count.index + 1}"
    Project = var.project_name
    Type    = "public"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(var.vpc_cidr, 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name    = "${var.project_name}-private-${count.index + 1}"
    Project = var.project_name
    Type    = "private"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "${var.project_name}-igw"
    Project = var.project_name
  }
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${var.project_name}-nat-eip"
    Project = var.project_name
  }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id

  tags = {
    Name    = "${var.project_name}-nat"
    Project = var.project_name
  }

  depends_on = [aws_internet_gateway.main]
}
```

### ✏️ Exercise

1. Add a comment: `# Route tables for public and private subnets` and let Copilot generate the routing
2. Write: `# Security group for web servers — allow HTTP/HTTPS inbound, all outbound`
3. Generate the output blocks: `# Outputs: VPC ID, public subnet IDs, private subnet IDs`
4. Run `terraform validate` to check the generated configuration

---

## Terraform Modules

Copilot understands module structure and generates reusable, parameterized modules.

### Example: RDS Module

**Prompt — create `modules/rds/main.tf`:**

```hcl
# Terraform module for an AWS RDS PostgreSQL instance
# Supports multi-AZ deployment, automated backups, and encryption
# Stores credentials in AWS Secrets Manager

variable "instance_name" {
  description = "Name identifier for the RDS instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the database will be deployed"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs for the DB subnet group"
  type        = list(string)
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t3.medium"
}
```

**Copilot generates the resources:**

```hcl
resource "aws_db_subnet_group" "this" {
  name       = "${var.instance_name}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name = "${var.instance_name}-subnet-group"
  }
}

resource "random_password" "master" {
  length  = 32
  special = false
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.instance_name}-db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.master.result
    host     = aws_db_instance.this.address
    port     = aws_db_instance.this.port
    dbname   = var.instance_name
  })
}

resource "aws_db_instance" "this" {
  identifier     = var.instance_name
  engine         = "postgres"
  engine_version = "16.1"
  instance_class = var.instance_class

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true

  db_name  = replace(var.instance_name, "-", "")
  username = "dbadmin"
  password = random_password.master.result

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.db.id]

  multi_az            = true
  publicly_accessible = false

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.instance_name}-final"

  tags = {
    Name = var.instance_name
  }
}

output "endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.this.endpoint
}

output "secret_arn" {
  description = "ARN of the Secrets Manager secret containing DB credentials"
  value       = aws_secretsmanager_secret.db_credentials.arn
}
```

### ✏️ Exercise

1. Create a `modules/ecs/main.tf` and write: `# Terraform module for an ECS Fargate service with ALB`
2. Define variables for container image, CPU, memory, and desired count
3. Let Copilot generate the ECS cluster, task definition, service, and ALB resources
4. Add: `# IAM role for the ECS task execution` and review the generated policy

---

## GitHub Actions CI/CD for Terraform

Copilot generates complete CI/CD workflows for Terraform operations.

### Example: Terraform PR Workflow

**Prompt — create `.github/workflows/terraform.yml`:**

```yaml
# GitHub Actions workflow for Terraform
# Runs plan on PRs, apply on merge to main
# Uses OIDC for AWS authentication (no static credentials)
name: Terraform

on:
  pull_request:
    paths:
      - 'infrastructure/**'
  push:
    branches:
      - main
    paths:
      - 'infrastructure/**'
```

**Copilot generates:**

```yaml
permissions:
  id-token: write
  contents: read
  pull-requests: write

env:
  TF_VERSION: "1.7.0"
  WORKING_DIR: "./infrastructure"

jobs:
  plan:
    name: Terraform Plan
    runs-on: ubuntu-latest
    if: github.event_name == 'pull_request'
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        working-directory: ${{ env.WORKING_DIR }}
        run: terraform init -no-color

      - name: Terraform Plan
        working-directory: ${{ env.WORKING_DIR }}
        id: plan
        run: terraform plan -no-color -out=tfplan
        continue-on-error: true

      - name: Comment PR with Plan
        uses: actions/github-script@v7
        with:
          script: |
            const plan = `${{ steps.plan.outputs.stdout }}`;
            const truncated = plan.length > 60000 
              ? plan.substring(0, 60000) + '\n\n... (truncated)'
              : plan;
            github.rest.issues.createComment({
              issue_number: context.issue.number,
              owner: context.repo.owner,
              repo: context.repo.repo,
              body: `## Terraform Plan\n\`\`\`\n${truncated}\n\`\`\``
            });

  apply:
    name: Terraform Apply
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main' && github.event_name == 'push'
    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: us-east-1

      - uses: hashicorp/setup-terraform@v3
        with:
          terraform_version: ${{ env.TF_VERSION }}

      - name: Terraform Init
        working-directory: ${{ env.WORKING_DIR }}
        run: terraform init -no-color

      - name: Terraform Apply
        working-directory: ${{ env.WORKING_DIR }}
        run: terraform apply -auto-approve -no-color
```

### ✏️ Exercise

1. Add a `validate` job that runs `terraform fmt -check` and `terraform validate` on every PR
2. Write a comment: `# Job to run tflint for additional Terraform linting` and let Copilot scaffold it
3. Add a `drift-detection` workflow that runs `terraform plan` on a cron schedule to detect infrastructure drift

---

## IaC Pro Tips

### 1. Comment with Cloud Context

```hcl
# ❌ Too vague
resource "aws_instance" "server" {

# ✅ Specific — Copilot fills in correctly
# EC2 instance for the API server — t3.medium, Amazon Linux 2023,
# in the private subnet with SSM access (no SSH key needed)
resource "aws_instance" "api" {
```

### 2. Define Variables First

Write your `variables.tf` before `main.tf`. Copilot uses variable definitions as context for resource generation.

### 3. Use Consistent Naming

Stick to a naming convention (`project-env-resource`) and Copilot will follow it throughout your configuration.

### 4. Keep Modules Focused

One module per logical resource group (networking, database, compute). Copilot generates better code for focused modules.

---

## Common Patterns

| Prompt / Context | What Copilot Generates |
|---|---|
| `resource "aws_` + resource type | Complete resource with common attributes |
| `# Terraform module for` + description | Full module with variables, resources, and outputs |
| `# GitHub Actions workflow for Terraform` | CI/CD pipeline with plan, apply, and validation |
| `# IAM policy for` + service description | JSON policy document with least-privilege permissions |
| `# Security group for` + use case | Ingress/egress rules with proper CIDR blocks |
| `variable "` + descriptive name | Variable block with description, type, and default |
| `# Backend configuration for S3` | Remote state with DynamoDB locking |
| `# Ansible playbook to` + description | YAML playbook with tasks and handlers |

---

## Summary & Next Steps

You've explored how Copilot accelerates Infrastructure as Code:

- **Terraform resources** — complete resource definitions from comments
- **Module patterns** — reusable modules with variables and outputs
- **CI/CD for IaC** — GitHub Actions workflows for plan and apply
- **Best practices** — naming, structure, and security patterns

### What to Try Next

1. **Build a complete environment** — VPC, database, compute, and monitoring with Copilot
2. **Try Pulumi** — Copilot handles infrastructure-as-code in TypeScript, Python, and Go
3. **Explore Ansible** — Copilot generates playbooks, roles, and inventory configurations
4. **Use Copilot Chat** for troubleshooting `terraform plan` errors and state management
