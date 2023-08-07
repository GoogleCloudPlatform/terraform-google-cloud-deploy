/**
 * Copyright 2023 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "stage_targets" {
  type = list(object({
    target_name        = string
    profiles           = list(string)
    target_create      = bool
    target_type        = string
    target_spec        = map(string)
    require_approval   = bool
    exe_config_sa_name = string
    execution_config   = map(string)
    strategy           = any
  }))
  description = "List of object specifications for Deploy Targets"
}

variable "pipeline_name" {
  type        = string
  description = "Name of the Delivery Pipeline"
}

variable "location" {
  type        = string
  description = "Location of the Pipeline"
}

variable "project" {
  type        = string
  description = "Project ID"
}

variable "trigger_sa_name" {
  type        = string
  description = "Name of the Trigger service account"
}

variable "trigger_sa_create" {
  type        = bool
  description = "True for trigger service account creation, False to reuse existing trigger service account"
  default     = true
}
