variable "opnsense" {
  description = "OPNsense configuration"
  type = object({
    vm_count = number
    vm_id_prefix = number
    node_name = string
    image_url = string
    image_filename = string
    initialization = object({
      hostname = string
      ip_config = object({
        ipv4 = object({
          address = string
        })
      })
      user_account = object({
        keys = list(string)
        password = string
      })
    })
    network_interface = object({
      name = string
    })
    disk = object({
      datastore_id = string
      size = number
    })
    operating_system = object({
      template_file_id = string
      type = string
    })
    mount_point = object({
      volume = string
      size = string
      path = string
    })
    startup = object({
      order = string
      up_delay = string
      down_delay = string
    })
  })
}
