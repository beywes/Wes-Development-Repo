# AWS & Infrastructure Automation Repository

This repository serves as a collection of reusable infrastructure components, scripts, automation templates, and standard operating procedures (SOPs) primarily focused on AWS environments. It demonstrates practical skills in cloud engineering, DevOps practices, and infrastructure-as-code (IaC).

## Purpose

*   **Showcase Expertise:** To highlight proficiency in AWS services, Terraform, Ansible, scripting (PowerShell/Bash), and CI/CD concepts.
*   **Reusable Assets:** To provide a personal library of tested and ready-to-use modules, scripts, and templates for accelerating deployments in new projects or roles.
*   **Best Practices:** To implement and document best practices in cloud architecture, security, and automation.

## Repository Structure

The repository is organized into two main top-level directories, representing different stages or environments:

*   `Development/`: Contains the core reusable components, development/testing configurations, and documentation drafts.
    *   `ansible/`: Ansible playbooks and roles developed/tested here.
        *   `playbooks/`
        *   `roles/`
    *   `docs/`: General documentation, architecture diagrams, and SOPs.
        *   `sops/`
    *   `modules/`: Reusable Terraform modules (e.g., VPC, EC2, S3 buckets).
        *   `aws/`
    *   `scripts/`: Standalone Bash and PowerShell scripts for various tasks.
        *   `bash/`
        *   `powershell/`
    *   `templates/`: CloudFormation, ARM, or other infrastructure templates.
        *   `cloudformation/`
    *   `terraform/`: Root Terraform configurations specifically for the development environment, often referencing modules from `Development/modules/`.
*   `Production/`: Contains configurations and potentially specific assets tailored for production environments.
    *   `ansible/`: Production-specific Ansible playbooks, potentially referencing roles from `Development/ansible/roles/`.
        *   `playbooks/`
    *   `docs/`: Production-specific documentation or links.
    *   `terraform/`: Root Terraform configurations for the production environment, typically referencing modules from `Development/modules/`.

*   `README.md`: This file.
*   `SECURITY.md`: Security policy and reporting information.
*   `.gitignore`: Specifies intentionally untracked files that Git should ignore.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository-url>
    ```
2.  **Explore Modules:** Navigate to `Development/modules/aws/` to see available Terraform modules.
3.  **Review Scripts:** Check `Development/scripts/` for useful Bash or PowerShell scripts.
4.  **Examine Environment Configurations:** Look into `Development/terraform/` or `Production/terraform/` to see how modules are consumed in environment-specific deployments.

## Contributing

While primarily a personal portfolio, suggestions and improvements are welcome via issues or pull requests (if applicable).

## Disclaimer

The code and configurations provided here are for demonstration and personal use. Ensure thorough testing and validation before using them in critical production environments. Adapt security configurations and variables according to your specific requirements.
