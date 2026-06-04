# Terraform Meta-Arguments Guide: `count` vs `for_each`

In Terraform, if you need to create multiple identical (or nearly identical) resources, writing out the resource block multiple times violates the DRY (Don't Repeat Yourself) principle.

Terraform provides two **meta-arguments** to solve this: `count` and `for_each`. This guide explains how to use both and when to choose one over the other.

---

## 1. The `count` Meta-Argument

The `count` argument accepts a whole number and creates that many instances of the resource or module.

### How it works

When you use `count`, Terraform identifies each resource instance by its **numeric index**, starting at zero. You can access this current index inside the resource block using `count.index`.

### Example: Creating 3 identical subnets

```hcl
variable "subnet_names" {
  type    = list(string)
  default = ["frontend", "backend", "database"]
}

resource "azurerm_subnet" "example" {
  count                = 3 # Creates 3 resources
  name                 = var.subnet_names[count.index]
  resource_group_name  = "my-resource-group"
  virtual_network_name = "my-vnet"
  address_prefixes     = ["10.0.${count.index}.0/24"]
}

```

### The "List Shift" Problem with `count`

Because `count` relies on the numeric index (e.g., `[0]`, `[1]`, `[2]`), it is highly sensitive to list order.
If you delete `"frontend"` from the list above, `"backend"` shifts from index `[1]` to index `[0]`. Terraform will see this as a change to the existing resources and will often **destroy and recreate** resources that you never intended to touch, just because their position in the list changed.

---

## 2. The `for_each` Meta-Argument

The `for_each` argument accepts a `map` or a `set of strings` and creates an instance for each item in that collection.

### How it works

Unlike `count`, `for_each` identifies resources by a **unique string key**, not a numeric index. Inside the resource block, you access the current item using `each.key` and `each.value`.

* **If using a Set:** `each.key` and `each.value` are the same (the string itself).
* **If using a Map:** `each.key` is the map key, and `each.value` is the map value.

### Example: Creating subnets using a Map

```hcl
variable "subnets" {
  type = map(string)
  default = {
    "frontend" = "10.0.1.0/24"
    "backend"  = "10.0.2.0/24"
    "database" = "10.0.3.0/24"
  }
}

resource "azurerm_subnet" "example" {
  for_each             = var.subnets # Iterates over the map
  name                 = each.key    # "frontend", "backend", etc.
  resource_group_name  = "my-resource-group"
  virtual_network_name = "my-vnet"
  address_prefixes     = [each.value] # The CIDR block
}

```

### The Benefit of `for_each`

If you delete the `"frontend"` key from the map, Terraform only destroys the `"frontend"` subnet. Because the other subnets are tracked by their names (`["backend"]` and `["database"]`) rather than their numerical position, they remain entirely untouched.

---

## 3. Summary Comparison

| Feature | `count` | `for_each` |
| --- | --- | --- |
| **Accepts Type** | Whole Number (Integer) | Map or Set of Strings |
| **Iterator Object** | `count.index` | `each.key` and `each.value` |
| **State Tracking** | By Index: `azurerm_subnet.example[0]` | By String: `azurerm_subnet.example["frontend"]` |
| **Best Used For** | Completely identical resources where order doesn't matter (e.g., 5 identical un-named web servers). | Resources with unique attributes, names, or configurations that might be added/removed over time. |

**Best Practice Rule of Thumb:** Default to using `for_each` when creating multiple resources. Only use `count` when the resources are truly interchangeable and identical, or when you want to conditionally toggle a single resource on or off using `count = var.enable ? 1 : 0`.

---

### See It In Action (The List Shift Problem)

To truly understand why `for_each` is generally preferred over `count` for lists of resources, it helps to see how Terraform calculates state changes when an item is removed. Use the interactive visualizer below to see the exact difference in how Terraform handles updates.