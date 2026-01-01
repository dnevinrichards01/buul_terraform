### Welcome to Buul's AWS Architecture

*For details and a tutorial, visit [Buul's backend repo](https://github.com/dnevinrichards01/buul_backend/tree/try_it_out_local) which is serving as the Buul project's 'hub'.*

### Diagram
Some components have been removed for simplicity but are listed below. Feel free to contact me for more details on the cloud architecture.
<img width="982" height="787" alt="architecture_diagramt drawio" src="https://github.com/user-attachments/assets/f52d0c89-008f-47ab-a7bb-53ff752a2f65" />

### About

#### Buul is a personal finance app that:
1. automatically invests and maximizes your credit-card cashback
2. converts spending into compound interest
3. is tackling the retirement crisis

#### AWS Components used:
1. **Secure Networking**: VPC, VPCEs, NAT gateway and Internet gateway, and route tables, and security groups
2. **Identity-based security**: IAM roles and resource policies
3. **Storage**: PostgreSQL RDS
4. **Containers**: ECS and ECR to store and deploy docker images / containers
5. **Container communication**: Redis Elasticache (single node) and SQS
6. **Load Balancing:** Application Load Balancer
7. **Envelope encryption of sensitive fields**: KMS 
8. **Environment variables:** Secrets Manager, Parameter Store
9. **DNS:** Route53 (with regional / latency routing)
10. **Logging:** Cloudwatch and Cloudtrail

