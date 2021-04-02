terraform {
    required_version = ">= 0.12.0"
}

provider "oci" {
  tenancy_ocid     = var.tenancy_ocid
  region           = var.region
}

resource "oci_core_image" "ceg_dbmigrate_image" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    display_name = "zdm-migrate-v3"
    launch_mode = "NATIVE"

    image_source_details {
        source_type = "objectStorageUri"
        source_uri = "https://objectstorage.ap-sydney-1.oraclecloud.com/p/2prI47egyxVuK2RD1bcdYS37MgCe1IFZ2wNd2oya1YmeEMuILLjmVBT_fSUNahXG/n/idmldytingzx/b/DBMigrationToolImage02Apr21_SYD/o/DBMigrationToolImage02Apr21_SYD"

        #Optional
        #operating_system = "${var.image_image_source_details_operating_system}"
        #operating_system_version = "${var.image_image_source_details_operating_system_version}"
        #source_image_type = "${var.source_image_type}"
    }
}

locals {
    ceg_dbmigrate_image_id      = oci_core_image.ceg_dbmigrate_image.id
}


#################### ZDM-GG Public Instance Setup ################
// Do not change 'hostname_label' as ZDM node name needs to be the same
resource "oci_core_instance" "zdm-migrate-v3" {
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain_name
  display_name        = "zdm-migrate-v3"
  shape               = var.vm_shape

  create_vnic_details {
    subnet_id        = var.subnet_ocid
    display_name     = "zdm-publicvnic"
    assign_public_ip = true
    hostname_label   = "zdm-migrate-v3"
  }

  source_details {
    source_id = local.ceg_dbmigrate_image_id
    source_type = "image"
  }

  metadata = {
   ssh_authorized_keys = var.ssh_public_key
  }
}
