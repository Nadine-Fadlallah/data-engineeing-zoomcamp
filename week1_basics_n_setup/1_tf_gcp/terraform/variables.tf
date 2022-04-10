locals { #== CONSTANS 
    data_lake_bucket = "dtc_data_lake"
}

#VARIABLES ARE GENERALLY PASSED AT RUNTIME
variable "project" {
    description = "Your gcp Project ID"
}

variable "region" {
    description = "Region for GCP resources. Choose as per location: https://cloud.google.com/about/locations"
    default = "europe-west6"
    type = string
}

variable "bucket_name" {
    description = "The name of the Google cloud Storage bucket. Must be globally unique"
    default = ""
}

variable "storage_class" {
    description = "Storage class type for your bucket. Chceck official docs for more info."
    default = "STANDARD"
}

variable "BQ_DATASET" { #EQUIVALENT TO A SCHEMA IN DWH
    description = "BigQuery Dataset that raw data (from GCS) will be written to"
    type = string
    default = "trips_data_all"
}

variable "TABLE_NAME" {
    description = "BigQuery Table"
    type = string
    default = "ny_trips"
}




