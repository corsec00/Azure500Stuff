data "template_file" "aadpodidentity" {
  template = file("${path.module}/template_files/aadpodidentity.tpl")
  vars = {
    msi_name        = "aks-user-msi"
    msi_resource_id = azurerm_user_assigned_identity.aks_user_msi.id
    msi_client_id   = azurerm_user_assigned_identity.aks_user_msi.client_id
  }
}

data "template_file" "aadpodidentitybinding" {
  template = file("${path.module}/template_files/aadpodidentitybinding.tpl")
  vars = {
    msi_name = "aks-user-msi"
  }
}

resource "local_file" "aadpodidentity" {
  content = data.template_file.aadpodidentity.rendered

  filename = "${path.module}/yaml_files/aadpodidentity.yaml"
}

resource "local_file" "aadpodidentitybinding" {
  content = data.template_file.aadpodidentitybinding.rendered

  filename = "${path.module}/yaml_files/aadpodidentitybinding.yaml"
}