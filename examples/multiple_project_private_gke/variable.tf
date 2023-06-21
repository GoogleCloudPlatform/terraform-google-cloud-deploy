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

variable "pipeline_name" {
  type = string
}

variable "location" {
  type = string
}

variable "project" {
  type = string
}

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
}

variable "trigger_sa_name" {
  type = string
}

variable "trigger_sa_create" {
  type = bool
}

