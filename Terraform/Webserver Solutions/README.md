# AWS WordPress High Availability Solution

This Terraform solution deploys a highly available WordPress infrastructure in AWS with the following components:
- 3 public-facing WordPress web servers
- 3 private database servers
- Application Load Balancer with WAF protection
- Route 53 DNS configuration
- Multi-AZ deployment across 3 availability zones

## Architecture Overview

```plaintext
                                    Route 53
                                       │
                                       ▼
                                 WAF (Regional)
                                       │
                                       ▼
                              Application Load Balancer
                                       │
                     ┌─────────────────┼─────────────────┐
                     ▼                 ▼                 ▼
              Public Subnet 1   Public Subnet 2   Public Subnet 3
             (WordPress Web 1) (WordPress Web 2) (WordPress Web 3)
                     │                 │                 │
                     ▼                 ▼                 ▼
             Private Subnet 1  Private Subnet 2  Private Subnet 3
               (Database 1)     (Database 2)      (Database 3)
```

## Module Structure

```plaintext
.
├── main.tf              # Main configuration file
├── variables.tf         # Input variables
├── modules/
    ├── vpc/            # VPC and networking
    ├── security/       # Security groups
    ├── alb/            # Application Load Balancer
    ├── waf/            # Web Application Firewall
    ├── ec2/            # EC2 instances and WordPress
    └── route53/        # DNS configuration
```

## Prerequisites

1. AWS Account with appropriate permissions
2. Terraform v1.2.0 or later
3. Valid SSL certificate in AWS Certificate Manager
4. Route 53 hosted zone for your domain

## Deployment Instructions

1. Initialize Terraform:
   ```bash
   terraform init
   ```

2. Configure variables in `terraform.tfvars`:
   ```hcl
   aws_region = "us-east-1"
   environment = "production"
   domain_name = "yourdomain.com"
   key_name = "your-ssh-key"
   ```

3. Review the plan:
   ```bash
   terraform plan
   ```

4. Apply the configuration:
   ```bash
   terraform apply
   ```

## Component Details

### VPC Module
- Creates a VPC with CIDR block 10.0.0.0/16
- 3 public subnets for web servers
- 3 private subnets for databases
- NAT Gateways in each public subnet
- Internet Gateway for public access

### Security Module
- ALB Security Group:
  * Inbound: 80, 443 from 0.0.0.0/0
  * Outbound: All traffic
- Webserver Security Group:
  * Inbound: 80 from ALB
  * Inbound: 22 for SSH (restrict in production)
  * Outbound: All traffic
- Database Security Group:
  * Inbound: 3306 from webserver security group
  * Outbound: All traffic

### ALB Module
- Application Load Balancer in public subnets
- HTTPS listener with SSL certificate
- HTTP to HTTPS redirect
- Health checks on port 80, path "/"

### WAF Module
- Rate limiting (2000 requests per 5 minutes per IP)
- SQL injection protection
- XSS protection
- Custom rules can be added as needed

### EC2 Module
- Latest Bitnami WordPress AMI
- Automatic WordPress configuration
- Database setup and secure password generation
- Load balancer target group registration

### Route 53 Module
- A record pointing to ALB
- Alias record for apex domain

## Troubleshooting Guide

### Common Issues

1. **WordPress Not Accessible**
   - Check ALB health checks
   - Verify security group rules
   - Check WordPress configuration in `/opt/bitnami/wordpress/wp-config.php`
   - Inspect Apache logs: `/opt/bitnami/apache2/logs/`

2. **Database Connection Issues**
   - Verify database security group allows traffic
   - Check MySQL configuration: `/opt/bitnami/mysql/conf/my.cnf`
   - Test MySQL connectivity: `nc -zv db_private_ip 3306`
   - Check MySQL logs: `/opt/bitnami/mysql/logs/`

3. **SSL/TLS Issues**
   - Verify certificate ARN in variables
   - Check ALB listener configuration
   - Confirm certificate validity in ACM

4. **Load Balancer Issues**
   - Check target group health status
   - Verify security group allows health checks
   - Review ALB access logs if enabled

### Useful Commands

1. **SSH Access to Instances**
   ```bash
   ssh -i your-key.pem bitnami@instance-ip
   ```

2. **Check WordPress Status**
   ```bash
   sudo /opt/bitnami/ctlscript.sh status
   ```

3. **View Apache Logs**
   ```bash
   sudo tail -f /opt/bitnami/apache2/logs/access_log
   sudo tail -f /opt/bitnami/apache2/logs/error_log
   ```

4. **Check MySQL Status**
   ```bash
   sudo /opt/bitnami/mysql/bin/mysqladmin -u root status
   ```

### Maintenance Tasks

1. **WordPress Updates**
   ```bash
   sudo /opt/bitnami/wordpress/bin/wp core update
   sudo /opt/bitnami/wordpress/bin/wp plugin update --all
   ```

2. **Database Backup**
   ```bash
   sudo /opt/bitnami/mysql/bin/mysqldump -u root wordpress > backup.sql
   ```

3. **Restart Services**
   ```bash
   sudo /opt/bitnami/ctlscript.sh restart apache
   sudo /opt/bitnami/ctlscript.sh restart mysql
   ```

## Security Considerations

1. **Production Hardening**
   - Restrict SSH access to specific IPs
   - Enable WAF logging
   - Implement additional WAF rules
   - Enable ALB access logging
   - Use AWS Secrets Manager for database credentials

2. **Monitoring Setup**
   - Enable CloudWatch monitoring
   - Set up alerts for:
     * Instance health
     * Load balancer 5XX errors
     * Database connections
     * WAF blocks

3. **Backup Strategy**
   - Regular database backups
   - WordPress file system backups
   - Consider AWS Backup service

## Cost Optimization

1. **Resource Sizing**
   - Right-size EC2 instances based on load
   - Monitor and adjust NAT Gateway usage
   - Consider Reserved Instances for production

2. **Monitoring and Alerts**
   - Set up CloudWatch alerts for unusual spending
   - Monitor unused resources
   - Track WAF and ALB usage

## Support and Maintenance

For issues or questions:
1. Check CloudWatch logs
2. Review security group configurations
3. Verify WAF rules and blocks
4. Check instance status and system logs
5. Review ALB access logs

## Version History

- v1.0.0 - Initial release
- Future versions will be documented here
