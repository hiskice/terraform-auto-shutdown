provider "azurerm" {
  version = "~> 2.9.0"
  features {}
}

data "azurerm_resource_group" "example" {
  name     = "rg_sofian"
}

data "azurerm_automation_account" "example" {
  name                = "autosofian"
  resource_group_name = "${data.azurerm_resource_group.example.name}"
}



resource "local_file" "example" {
  filename = "runbook-weekly-auto-shutdown-vm.ps1"  
}

resource "azurerm_automation_runbook" "example" {
  name                    = "runbook-weekly-auto-shutdown-vm"
  location                = "${data.azurerm_resource_group.example.location}"
  resource_group_name     = "${data.azurerm_resource_group.example.name}"
  automation_account_name = "${data.azurerm_automation_account.example.name}"
  log_verbose             = "true"
  log_progress            = "true"
  description             = "This is an example runbook"
  runbook_type            = "PowerShellWorkflow"
  
  content                 = "${local_file.example.filename}"

}

resource "azurerm_automation_schedule" "example" {
  name                    = "weekly-auto-shutdown-vm"
  resource_group_name     = "${data.azurerm_resource_group.example.name}"
  automation_account_name = "${data.azurerm_automation_account.example.name}"
  frequency               = "Week"
  interval                = 1
  timezone                = "Romance Standard Time"
  start_time              = "2020-05-17T00:00:00+01:00"
  description             = "This is an example schedule"
  week_days               = ["Saturday"]
}



resource "azurerm_automation_job_schedule" "example" {
  
  resource_group_name     = "${data.azurerm_resource_group.example.name}"
  automation_account_name = "${data.azurerm_automation_account.example.name}"
  schedule_name           = "${azurerm_automation_schedule.example.name}"
  runbook_name            = "${azurerm_automation_runbook.example.name}"

  parameters = {
    tagname = "auto-shutdown"
    tagvalue  = "yes"
    shutdown  = true
  }
}