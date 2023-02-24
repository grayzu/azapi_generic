variable "resource_group" {
  description = "Resource group to deploy the container app"
  type = object({
    id       = string
    location = string
  })
}

variable "law" {
  description = "Log Analytics Workspace to connect to the container env"
  type = object(
    {
      workspace_id = string
      shared_key   = string
    }
  )
}

variable "containers" {
  description = "values for the containers in the container app"
  type = list(object({
    image = string
    name  = string
  }))
}

variable "registries" {
  description = "values for the registries in the container app"
  type = list(object({
    password_ref = string
    server       = string
    username     = string
  }))
}

variable "secrets" {
  description = "values for the secrets in the container app"
  type = list(object({
    name  = string
    value = string
  }))
  sensitive = true
}

variable "ingress" {
  description = "values for the ingress in the container app"
  type = object({
    target_port = number
    external    = bool
  })
}
