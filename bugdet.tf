locals {
  budget_notification_thresholds = [
    0.5,
    0.8,
    1,
  ]
}

resource "google_monitoring_notification_channel" "budget" {
  project      = data.google_project.minecraft.project_id
  display_name = "Budget notification Channel"
  type         = "email"

  user_labels = local.common_labels
  labels = {
    email_address = var.gcp_admin
  }
}

resource "google_billing_budget" "minecraft" {
  billing_account = data.google_billing_account.self.id
  display_name    = "Billing budget for ${data.google_project.minecraft.id}"

  budget_filter {
    projects = [
      "projects/${data.google_project.minecraft.number}",
    ]
  }

  amount {
    specified_amount {
      currency_code = "EUR"
      units         = "5"
    }
  }

  dynamic "threshold_rules" {
    for_each = toset(local.budget_notification_thresholds)
    content {
      threshold_percent = threshold_rules.key
    }
  }

  all_updates_rule {
    monitoring_notification_channels = [
      google_monitoring_notification_channel.budget.id,
    ]
    disable_default_iam_recipients = true
  }
}
