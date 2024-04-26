variable "region" {
  description = "Default AWS Region"
  type        = string
  default     = "eu-central-1"
}

variable "clustername" {
  description = "default cluster name"
  type = string
  default = "argo-ex-eks"
}