config {
  format = "compact"
  call_module_type = "local"
}

plugin "terraform" {
  enabled = true
  preset  = "all"
}

plugin "aws" {
  enabled = true
  version = "0.48.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "azurerm" {
  enabled = true
  version = "0.32.0"
  source  = "github.com/terraform-linters/tflint-ruleset-azurerm"
}

# Standard_B1s (Bv1) tem retirement anunciado para nov/2028, sem urgência.
# O substituto direto, Standard_B2ts_v2 (família Bsv2), exige cota
# standardBsv2Family aprovada na subscription — hoje é 0, e a troca
# quebrou o apply em teste/homol/prod (409 quota exceeded) em 2026-07-13.
# Revertido para Standard_B1s até pedir o aumento de cota com calma;
# ver docs/BACKLOG.md.
rule "azurerm_linux_virtual_machine_retired_size" {
  enabled = false
}
