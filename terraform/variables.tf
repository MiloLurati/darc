# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-central-1"
}

variable "iam_user" {
  type = string
  default = "default_iam_user"
}