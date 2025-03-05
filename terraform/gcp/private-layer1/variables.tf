variable "name" {
  type        = string
  description = "Name of every resource's name tag; if empty, auto-generated"
  default     = null
}

variable "compute_disk" {
  type        = any
  description = "Config for additional compute disk"
  default     = null
}

variable "cn_options" {
  type        = any
  description = "The options to deploy CN nodes"
  default     = {}
}

variable "pn_options" {
  type        = any
  description = "The options to deploy PN nodes"
  default     = {}
}

variable "en_options" {
  type        = any
  description = "The options to deploy PN nodes"
  default     = {}
}

variable "monitor_options" {
  type        = any
  description = "The options to deploy monitor node"
  default     = {}
}

variable "metadata" {
  description = "A map of metadatas to add to all resources"
  default     = {}
}

variable "ssh_client_ips" {
  type        = list(any)
  description = "SSH ingress IP list"
  default     = []
}

variable "create_gcp_key_pair" {
  description = "Flag to determine whether to create a GCP SSH key pair."
  type        = bool
  default     = false  # Default to false; set to true to create the key pair
}

variable "project" {
  description = "The name of the project to create or use"
  type        = string
}

variable "project_id" {
  type        = string
  description = "GCP project ID"
  default     = null
}

variable "org_id" {
  description = "The organization ID for the GCP project"
  type        = string
}

variable "billing_account" {
  description = "The billing account ID for the GCP project"
  type        = string
}

variable "gcp_region" {
  type        = string
  description = "GCP region where all resources will be created"
  default     = "asia-northeast3"
}

variable "network" {
  type        = string
  description = "Network Name to be used"
  default     = ""
}

variable "subnetwork" {
  type        = string
  description = "Subnet Name to be used"
  default     = ""
}

variable "network_tags" {
  description = "List of network tags to apply to the VPC."
  type        = list(string)
  default     = []
}

variable "image_family" {
  description = "The image family for the boot disk"
  type        = string
}

variable "image_project" {
  description = "The project containing the image"
  type        = string
}