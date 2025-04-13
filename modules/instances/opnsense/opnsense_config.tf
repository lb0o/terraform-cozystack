resource "null_resource" "install_dependencies" {
  provisioner "local-exec" {
    command = "sudo apt-get update && sudo apt-get install -y sshpass"
  }
}

resource "null_resource" "wait_for_opnsense" {
  depends_on = [proxmox_virtual_environment_vm.firewall]

  provisioner "local-exec" {
    command = <<EOT
      for i in $(seq 1 30); do
        if ping -c 1 ${var.opnsense.initialization.ip_config.ipv4.address} >/dev/null 2>&1; then
          echo "OPNsense endpoint is reachable"
          exit 0
        fi
        echo "Waiting for OPNsense endpoint to become available... (attempt $i/30)"
        sleep 10
      done
      echo "OPNsense endpoint did not become available after 300 seconds"
      exit 1
    EOT

  }
}

resource "null_resource" "initial_opnsense_setup" {
  depends_on = [
    proxmox_virtual_environment_vm.firewall,
    null_resource.install_dependencies,
    null_resource.wait_for_opnsense
  ]

  provisioner "local-exec" {
    command = <<EOT
      sshpass -p 'opnsense' ssh -o StrictHostKeyChecking=no 
      -o UserKnownHostsFile=/dev/null 
      installer@${var.opnsense.initialization.ip_config.ipv4.address} <<'EOF'
      
        echo "Uploading OPNsense configuration..."

        cat <<EOF_CONFIG > /conf/config.xml
<?xml version="1.0"?>
<opnsense>
  <system>
    <hostname>opnsense</hostname>
    <domain>local</domain>
    <timezone>UTC</timezone>
  </system>
  <interfaces>
    <lan>
      <if>vtnet1</if>
      <ipaddr>${var.opnsense.initialization.ip_config.ipv4.address}</ipaddr>
      <subnet>24</subnet>
      <gateway/>
      <descr>LAN</descr>
    </lan>
    <wan>
      <if>vtnet0</if>
      <ipaddr>${var.opnsense.initialization.ip_config.ipv4.address}</ipaddr>
      <subnet>24</subnet>
      <gateway>${var.opnsense.initialization.ip_config.ipv4.gateway}</gateway>
      <descr>WAN</descr>
    </wan>
  </interfaces>
  <dhcpd>
    <lan>
      <enable/>
      <range>
        <from>${var.opnsense.dhcp.start}</from>
        <to>${var.opnsense.dhcp.end}</to>
      </range>
      <defaultleasetime>7200</defaultleasetime>
      <maxleasetime>86400</maxleasetime>
    </lan>
  </dhcpd>
  <nat>
    <outbound>
      <mode>automatic</mode>
    </outbound>
  </nat>
  <filter>
    <rule>
      <type>block</type>
      <interface>lan</interface>
      <ipprotocol>inet</ipprotocol>
      <descr>Block LAN to Proxmox host</descr>
      <source>
        <network>lan</network>
      </source>
      <destination>
        <address>${var.proxmox.endpoint}</address>
      </destination>
    </rule>
  </filter>
</opnsense>
EOF_CONFIG

        echo "Restoring config..."
        /usr/local/sbin/opnsense-shell -c 'config restore'

        echo "Rebooting OPNsense to apply configuration..."
        reboot

EOF
EOT
  }

  lifecycle {
    create_before_destroy = true
  }
}
