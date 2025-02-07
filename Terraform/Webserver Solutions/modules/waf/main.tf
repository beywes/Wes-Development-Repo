# WAF Web ACL
resource "aws_wafv2_web_acl" "main" {
  name        = "${var.environment}-web-acl"
  description = "WAF Web ACL for ${var.environment} environment"
  scope       = "REGIONAL"

  default_action {
    allow {}
  }

  # Rule to block requests from IPs with high request rates
  rule {
    name     = "RateLimit"
    priority = 1

    override_action {
      none {}
    }

    statement {
      rate_based_statement {
        limit              = 2000
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "RateLimitMetric"
      sampled_requests_enabled  = true
    }
  }

  # Rule to block common SQL injection patterns
  rule {
    name     = "SQLInjectionRule"
    priority = 2

    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "SQLInjectionMetric"
      sampled_requests_enabled  = true
    }
  }

  # Rule to block common XSS patterns
  rule {
    name     = "XSSRule"
    priority = 3

    override_action {
      none {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
        text_transformation {
          priority = 2
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name               = "XSSMetric"
      sampled_requests_enabled  = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "WebACLMetric"
    sampled_requests_enabled  = true
  }

  tags = {
    Name        = "${var.environment}-web-acl"
    Environment = var.environment
  }
}

# Associate WAF Web ACL with ALB
resource "aws_wafv2_web_acl_association" "main" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.main.arn
}
