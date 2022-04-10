terraform {
    required_version = ">= 1.0"
    backend "local" {} # tf_state file. Can change from "local" to "gcs" (for google) or "s3" (for aws)
    required_providers  {  # Optional
        google= {
            source = "hashicorp/google"
        }
    }
}

#TF RELIES ON PLUGINS CALLED PROVIDERS TO INTERACT WITH CLOUD PROVIDERS, SAS PROVIDERS AND OTHER APIS.
#WHAT IT DOES IS IT ADDS A SET OF PREDEFINED RESOURCE TYPES AND DATA SOURCES THAT TF CAN MANAGE
#LIKE THE BELOW MODULE DEFINITIONS
provider "google" {
    project = var.project
    region = var.region
    # ANOTHER TRICK: EARLIER WE SET THE ENV VAR IN THE "GOOGLE_APPLICATION_CREDENTIALS". IN CASE WE DON'T WANT TO MAKE USE USE OF ENV VARS WE CAN PASS OUR CREDENTIALS FILE WITH THE CREDENTIALS ATTRIBUTE  
    //credentials = file(var.credentials) # use this if you do not want to set env-var GOOGLE_APPLICATION_CREDENTIALS
}
#MODULE DEFINITIONS THAT ARE IMPORTED FROM THIS "hashicorp/google" LIBRARY

# Data Lake Bucket
# Ref: "https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/storage_bucket"
#A RESOURCE: A PHYSICAL COMPONENT SUCH AS A SERVER OR A STORAGE BUCKET OR A DATABASE OR DWH
#AND IT CONTAINS ARGUMENTS TO CONFIGURE THIS RESOURCE, WHICH COULD BE SOMETHING LIKE: MACHINE SIZES, DISK IMAGE NAMES, VPC IDS
resource "google_storage_bucket" "data-lake-bucket" {
  name = "${local.data_lake_bucket}_${var.project}" # Concatenation DL bucket and Project name for unique naming
  location = var.region


# Optional, but recommended settings:
storage_class = var.storage_class
uniform_bucket_level_access = true

    versioning {
        enabled = true

    }
    lifecycle_rule {
        action {
            type = "Delete"
        }
        condition {
            age = 30 // days
        }
    }

    force_destroy = true
}

// In-Progress
//
# DWH
# Ref: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/bigquery_dataset
resource "google_bigquery_dataset" "dataset" {
  dataset_id = var.BQ_DATASET
  project = var.project
  location = var.region
}


