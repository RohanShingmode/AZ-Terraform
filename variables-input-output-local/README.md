# Terraform Variables

Understanding variables in Terraform is crucial for creating dynamic, reusable, and configurable infrastructure code.

## Types of Variables

* **Input Variables:** Serve as parameters for a Terraform module, allowing users to customize behavior without editing the source code directly.
* **Output Values:** Return values from a Terraform module, acting like return values from a function. They expose information about your infrastructure to the command line or to other modules.
* **Local Values:** A convenience feature for assigning a short, descriptive name to a complex expression, scoped strictly to the current module.

## Data Types

Terraform supports several variable types, which can be categorized into primitive and non-primitive types.

### Primitive Types
* `string`: A sequence of Unicode characters representing text.
* `number`: A numeric value (can be integer or fractional).
* `bool`: A boolean value, either `true` or `false`.

### Non-Primitive (Complex) Types
* `list`: A sequence of values of the same type, accessed by an index.
* `set`: An unordered collection of unique values of the same type.
* `map`: A collection of key-value pairs where all values are the same type, accessed by a string key.
* `object`: A collection of named attributes where each attribute can have a different type.
* `tuple`: A sequence of elements where each element has its own specific type.

---

## Variable Precedence

When the same variable is assigned multiple values in different locations, Terraform uses a strict order of precedence to determine the final value. The list below goes from **Lowest to Highest** priority.

| Priority | Source | Description |
| :--- | :--- | :--- |
| **1 (Lowest)** | `default` block | The fallback value specified inside your `variables.tf` file. |
| **2** | Environment Variables | Variables prefixed with `TF_VAR_` (e.g., `export TF_VAR_region="us-east-1"`). |
| **3** | `terraform.tfvars` | The standard text file automatically loaded by Terraform. |
| **4** | `terraform.tfvars.json` | The JSON equivalent file, which overrides the standard HCL version. |
| **5** | `*.auto.tfvars` / `*.auto.tfvars.json` | Autoloaded files evaluated in **alphabetical (lexical) order** by filename. |
| **6** | CLI Flags (`-var-file`) | Custom variable files loaded manually via command execution. |
| **7 (Highest)** | CLI Flags (`-var`) | Individual key-value assignments provided inline directly on the terminal. |