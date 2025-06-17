# Infraestrutura Compartilhada

## Componentes

- VPC com subnets públicas
- Application Load Balancer (ALB)
- IAM Roles:
  - ECS Execution Role
  - GitHub Actions OIDC Role

## Deploy manual

Execute o script de bootstrap:

```bash
./bootstrap.sh
