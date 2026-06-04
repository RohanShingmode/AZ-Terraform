# Terraform Lifecycle Meta-Arguments

## Overview

In Terraform, **lifecycle rules** are special instructions — called **meta-arguments** — that allow you to customize how Terraform handles the creation, modification, and destruction of resources.

While commonly discussed in the context of Azure, it is important to note that **lifecycle rules are a core Terraform feature**. They work the exact same way across all providers:

| Provider | Works? |
|----------|--------|
| Azure (`azurerm`) | ✅ Yes |
| AWS (`aws`) | ✅ Yes |
| Google Cloud (`google`) | ✅ Yes |
| Any other provider | ✅ Yes |

They are incredibly useful for managing the quirks and safety requirements of cloud deployments.

---

## Lifecycle Block Syntax

All lifecycle arguments live inside a `lifecycle {}` block within a resource:

```hcl
resource "azurerm_storage_account" "example" {
  name = "mystorageaccount"
  # ... other arguments

  lifecycle {
    prevent_destroy       = true
    create_before_destroy = true
    ignore_changes        = [tags]
    replace_triggered_by  = [azurerm_resource_group.example.id]
  }
}
```

---

## The Four Primary Lifecycle Arguments

### 1. `prevent_destroy`

**Behavior:** Blocks Terraform from executing any plan that would destroy the resource.

**Primary Use Case:** Safeguards critical data stores, production databases, or core network configurations from accidental deletion.

> **Important Note:** This acts as a guardrail during `terraform apply`, but the resource **can still be deleted** if you run an explicit `terraform destroy` or manually remove the resource block from your configuration.

```hcl
resource "azurerm_storage_account" "example" {
  name                     = "productiondata123"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  lifecycle {
    prevent_destroy = true
  }
}
```

**When Terraform hits `prevent_destroy = true`, it errors:**
```
Error: Instance cannot be destroyed
  on main.tf line 1, in resource "azurerm_storage_account" "example":
  Resource azurerm_storage_account.example has lifecycle.prevent_destroy
  set, but the plan calls for this resource to be destroyed.
```

---

### 2. `create_before_destroy`

**Behavior:** Forces Terraform to build a replacement resource **completely before** destroying the old one.

**Primary Use Case:** Prevents service downtime for resources like web servers, target groups, or SSL certificates that cannot be updated in place.

```hcl
# for_each works with set(string) — avoids duplicates that a list would allow
resource "azurerm_storage_account" "example" {
  for_each = var.storage_acc_name

  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
  }

  tags = {
    environment = "staging"
  }
}
```

#### ⚠️ Critical Gotcha: `for_each` Key Renaming

`create_before_destroy` does **NOT** apply when using `for_each` with key renaming.

| Scenario | `create_before_destroy` Works? |
|---|---|
| Same key, immutable field changed | ✅ Yes |
| `for_each` key renamed | ❌ No — treated as two unrelated resources |
| `moved` block used | ✅ Yes (no destroy at all) |
| Stable key, `each.value` changed | ✅ Yes |

**Why?** When a `for_each` key changes (e.g., `"account890"` → `"account894"`), Terraform treats the old and new keys as **completely independent resources**. They have separate lifecycle events with no link between them, so `create_before_destroy` has nothing to act on.

**Fix — use a stable key with `each.value` for the name:**
```hcl
variable "storage_acc_name" {
  type = map(string)
  default = {
    "account1" = "azurelearnning894"  # key stays "account1" forever
    "account2" = "spiderman12012003"
  }
}

resource "azurerm_storage_account" "example" {
  for_each = var.storage_acc_name
  name     = each.value  # only the value changes; key is stable

  lifecycle {
    create_before_destroy = true  # NOW this works correctly
  }
}
```

**Fix — use `moved` block for key renames (Terraform 1.1+):**
```hcl
moved {
  from = azurerm_storage_account.example["azurelearnning890"]
  to   = azurerm_storage_account.example["azurelearnning894"]
}
```

---

### 3. `ignore_changes`

**Behavior:** Tells Terraform to ignore changes to specific resource attributes after the initial creation. Terraform will no longer detect drift for these attributes.

**Primary Use Case:** Useful when an external system (like Azure Policy, auto-scaling, or another tool) modifies a resource attribute outside of Terraform, and you don't want Terraform to fight it on every plan.

```hcl
resource "azurerm_storage_account" "example" {
  name                     = "mystorageaccount"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }

  lifecycle {
    # Terraform will ignore any tag changes made outside of Terraform
    ignore_changes = [tags]
  }
}
```

**Ignore multiple attributes:**
```hcl
lifecycle {
  ignore_changes = [
    tags,
    account_replication_type,
    access_tier
  ]
}
```

**Ignore ALL attributes (use with caution):**
```hcl
lifecycle {
  ignore_changes = all
}
```

#### ⚠️ Critical Gotcha: Only Applies to Existing Resources

`ignore_changes` only applies to **updates on existing resources**. It does **not** apply to the initial creation of a new resource. On first `terraform apply`, all attribute values are used as-is.

---

### 4. `replace_triggered_by`

**Behavior:** Forces Terraform to destroy and recreate a resource whenever **another specified resource or attribute** changes — even if the resource itself has no changes.

**Primary Use Case:** Useful when a resource has an implicit dependency that Terraform cannot detect automatically. For example, when a VM's configuration depends on a network interface or security group that was replaced.

```hcl
resource "azurerm_linux_virtual_machine" "example" {
  name                = "my-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_B1s"
  # ... other arguments

  lifecycle {
    # Force VM replacement whenever the NIC is replaced
    replace_triggered_by = [
      azurerm_network_interface.example.id
    ]
  }
}

resource "azurerm_network_interface" "example" {
  name                = "my-nic"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  # ...
}
```

#### Triggering on a Specific Attribute

You can also trigger replacement based on a specific attribute change, not just the whole resource:

```hcl
lifecycle {
  replace_triggered_by = [
    azurerm_network_interface.example.private_ip_address
  ]
}
```

#### Triggering on a `terraform_data` Resource (Terraform 1.4+)

Use `terraform_data` to create a manual replacement trigger (like a version bump):

```hcl
variable "vm_image_version" {
  default = "1.0.0"
}

resource "terraform_data" "vm_replacement_trigger" {
  input = var.vm_image_version
}

resource "azurerm_linux_virtual_machine" "example" {
  name = "my-vm"
  # ...

  lifecycle {
    replace_triggered_by = [terraform_data.vm_replacement_trigger]
  }
}
```

Changing `vm_image_version` from `"1.0.0"` to `"1.1.0"` will force the VM to be replaced on the next `terraform apply`.

#### ⚠️ Important Points for `replace_triggered_by`

- The referenced resource **must** exist in the same Terraform configuration.
- Requires **Terraform 1.2+**.
- Replacement follows standard destroy/create order unless `create_before_destroy = true` is also set.
- This is a one-way trigger: it does **not** work in reverse automatically.

---

## Quick Reference Summary

| Argument | What It Does | Key Gotcha |
|---|---|---|
| `prevent_destroy` | Blocks `apply` from destroying the resource | Does not block `terraform destroy` |
| `create_before_destroy` | Creates replacement before destroying old resource | Does not work with `for_each` key renaming |
| `ignore_changes` | Ignores drift on specified attributes | Does not apply on initial resource creation |
| `replace_triggered_by` | Forces replacement when a dependency changes | Requires Terraform 1.2+ |

---

## Combining Lifecycle Arguments

Multiple lifecycle arguments can be combined in a single block:

```hcl
resource "azurerm_storage_account" "example" {
  for_each = var.storage_acc_name

  name                     = each.value
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "staging"
  }

  lifecycle {
    create_before_destroy = true
    ignore_changes        = [tags]
    # prevent_destroy     = true  # uncomment for production resources
  }
}
```

---

## Variable Configuration (Avoiding Duplicates with `for_each`)

```hcl
# ❌ WRONG — list allows duplicates; for_each will error
variable "storage_acc_name" {
  type    = list(string)
  default = ["account1", "account1"]  # duplicate!
}

# ✅ CORRECT — set automatically enforces uniqueness
variable "storage_acc_name" {
  type        = set(string)
  description = "Set of storage account names (no duplicates allowed)"
  default     = ["spiderman12012003", "azurelearnning894"]
}
```

---

## References

- [Terraform Docs — `lifecycle` Meta-Argument](https://developer.hashicorp.com/terraform/language/meta-arguments/lifecycle)
- [Terraform Docs — `moved` Block](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [AzureRM Provider — Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)
