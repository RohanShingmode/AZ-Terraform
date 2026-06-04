# Generate a new standard RSA key pair
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
---

# Terraform Variable Type Constraints Guide

This repository demonstrates the use of various **Type Constraints** in Terraform. Type constraints ensure that the values assigned to variables match the expected data format, helping to catch errors early and making the infrastructure code more robust and predictable.

Below is a breakdown of the variable types used in this configuration, categorized by Primitive, Collection, and Structural types.

## 1. Primitive Types

Primitive types represent simple, single values.

### `string`

Represents a sequence of characters (text).

* **Variable:** `environment`
* **Default Value:** `"stag"`
* **Usage:** Used for names, IDs, or any text-based configuration.

### `number`

Represents numeric values (can be whole numbers or fractional).

* **Variable:** `disk_size`
* **Default Value:** `30`
* **Usage:** Used for sizes, counts, or port numbers.

### `bool`

Represents boolean values: `true` or `false`.

* **Variable:** `delete_os_disk`
* **Default Value:** `true`
* **Usage:** Used for feature toggles or binary choices (e.g., enable/disable a setting).

---

## 2. Collection Types

Collection types group multiple values of the *same* primitive type together.

### `list(type)`

A sequence of values of a specific type, identified by consecutive whole numbers starting with zero. Lists preserve the order of elements.

* **Variable:** `region`
* **Type Constraint:** `list(string)`
* **Default Value:** `["West US", "East US", "Central India"]`
* **Usage:** Ideal when order matters or when duplicate values are permitted.

### `set(type)`

A collection of *unique* values that do not have any secondary identifiers or specific ordering.

* **Variable:** `azure_regions`
* **Type Constraint:** `set(string)`
* **Default Value:** `["eastus", "westus", "centralus"]`
* **Usage:** Best used when you need to ensure all elements are unique and the order of elements does not matter (e.g., a list of subnets or unique region deployments).

### `map(type)`

A collection of values where each is identified by a unique string label (key). All values in a map must be of the same specified type.

* **Variable:** `resource_tags`
* **Type Constraint:** `map(string)`
* **Default Value:**
```hcl
{
  "project"     = "test"
  "environment" = "dev"
  "version"     = "pre-test"
}

```


* **Usage:** Highly recommended for tagging resources, assigning labels, or grouping key-value pairs of the same data type.

---

## 3. Structural Types

Structural types allow multiple values of *different* types to be grouped together.

### `tuple([type1, type2, ...])`

A sequence of elements where each element has its own distinct type, and the number of elements is fixed.

* **Variable:** `network_configuration`
* **Type Constraint:** `tuple([string, string, number])`
* **Default Value:** `["10.0.0.0/16", "10.0.2.0", 24]`
* **Usage:** Useful when you need a specific, fixed sequence of differently typed values (e.g., [VPC CIDR, Subnet CIDR, Mask]).

### `object({attribute1=type1, ...})`

A collection of named attributes that each have their own specific type. Unlike maps (where all values must be the same type), objects allow mixed types.

* **Variable:** `vm_config`
* **Type Constraint:** ```hcl
object({
size    = string
version = string
sku     = string
offer   = string
})
```

```


* **Default Value:**
```hcl
{
  size    = "Standard_DS1_v2"
  version = "latest"
  sku     = "22_04-lts"
  offer   = "0001-com-ubuntu-server-jammy"
}

```


* **Usage:** Excellent for passing complex configuration blocks to modules or resources without needing dozens of individual primitive variables.

---

## Summary Reference Table

| Classification | Terraform Type | Description | Example Variable |
| --- | --- | --- | --- |
| **Primitive** | `string` | Text characters | `environment` |
| **Primitive** | `number` | Numeric values | `disk_size` |
| **Primitive** | `bool` | True or False | `delete_os_disk` |
| **Collection** | `list(type)` | Ordered, indexable sequence | `region` |
| **Collection** | `set(type)` | Unordered, unique values | `azure_regions` |
| **Collection** | `map(type)` | Key-value pairs of the *same* type | `resource_tags` |
| **Structural** | `tuple([...])` | Fixed-length, ordered mixed types | `network_configuration` |
| **Structural** | `object({...})` | Named attributes of *mixed* types | `vm_config` |

## How to Use

1. Place the variables defined in this repository into a file named `variables.tf`.
2. Reference them in your `main.tf` using the `var.` syntax (e.g., `var.environment` or `var.vm_config.size`).
3. Override defaults as needed using a `terraform.tfvars` file or via command-line flags (`-var="environment=prod"`).