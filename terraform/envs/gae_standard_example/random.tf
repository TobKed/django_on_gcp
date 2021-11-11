# random variables for ease of use
# you should not keep them as that, use variables instead
# pleas take a look at: https://www.terraform.io/docs/language/values/variables.html

resource "random_password" "secret" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "random_string" "user" {
  length  = 16
  special = false
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}
