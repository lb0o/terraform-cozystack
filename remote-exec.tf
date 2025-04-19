# Configuration of security and network settings on the network machine
resource "null_resource" "networking_gateway_setup" {
  depends_on = [
    proxmox_virtual_environment_container.network_machine,
    proxmox_virtual_environment_container.dev_machine,
    module.cluster_network
  ]

provisioner "remote-exec" {
  inline = [
    # Add SSH key
    "mkdir -p ~/.ssh",
    "echo '${trimspace(tls_private_key.network_machine_ssh_key.public_key_openssh)}' >> ~/.ssh/authorized_keys",
    "chmod 600 ~/.ssh/authorized_keys",

    # Add SSH private key for dev machine
    "echo '${trimspace(tls_private_key.dev_machine_ssh_key.private_key_pem)}' >> ~/.ssh/id_rsa",
    "echo '${trimspace(tls_private_key.dev_machine_ssh_key.public_key_openssh)}' >> ~/.ssh/id_rsa.pub",
    "chmod 600 ~/.ssh/id_rsa",
    "chmod 644 ~/.ssh/id_rsa.pub",

    # Add alias to ~/.bashrc using printf (robust to quote issues)
    "printf \"alias ssh_cozy_dev_machine='ssh -i ~/.ssh/id_rsa root@${cidrhost(var.network.lan_cidr, 100)}'\\n\" >> ~/.bashrc",

    "sleep 30",

    # Bring up eth1
    "ip link set eth1 up",
    "ip addr add ${cidrhost(var.network.lan_cidr, 1)}/24 dev eth1",

    # Install packages (no UFW, no isc-dhcp-server)
    "apt-get update",
    "DEBIAN_FRONTEND=noninteractive apt-get install -y dnsmasq iproute2 iptables",

    # Configure dnsmasq for DHCP and local DNS resolution
    <<-EOT
    bash -c '
    # Write main config to include additional configs
    echo "conf-dir=/etc/dnsmasq.d,.conf" > /etc/dnsmasq.conf

    # Write DHCP and DNS settings
    cat > /etc/dnsmasq.d/dhcp.conf <<EOF
    interface=eth1
    dhcp-range=${cidrhost(var.network.lan_cidr, 100)},${cidrhost(var.network.lan_cidr, 200)},12h
    dhcp-option=3,${cidrhost(var.network.lan_cidr, 1)}
    dhcp-option=6,${cidrhost(var.network.lan_cidr, 1)}
    domain-needed
    bogus-priv
    expand-hosts
    domain=lan
    dhcp-leasefile=/var/lib/misc/dnsmasq.leases
    EOF
    '
    EOT
    ,


    # Enable IP forwarding
    "sysctl -w net.ipv4.ip_forward=1",
    "echo 'net.ipv4.ip_forward = 1' >> /etc/sysctl.conf",

    # Setup NAT
    "iptables -t nat -A POSTROUTING -s 10.0.0.0/24 -o eth0 -j MASQUERADE",

    # Drop LAN-to-WAN traffic (silently)
    "iptables -I FORWARD 1 -s 10.0.0.0/24 -d 192.168.1.0/24 -j DROP",

    # Allow internet forwarding
    "iptables -A FORWARD -s 10.0.0.0/24 -o eth0 -j ACCEPT",
    "iptables -A FORWARD -i eth0 -d 10.0.0.0/24 -m state --state RELATED,ESTABLISHED -j ACCEPT",

    # Save iptables manually (create dir if needed)
    "mkdir -p /etc/iptables",
    "iptables-save > /etc/iptables/rules.v4",

    # Start dnsmasq
    "service dnsmasq restart"
  ]
}




  connection {
    type        = "ssh"
    host        = "${cidrhost(var.network.wan_cidr, 18)}"
    user        = "root"
    private_key = tls_private_key.network_machine_ssh_key.private_key_pem
  }
}

# Configuration of security monitoring stack (Suricata, SELKS, Elasticsearch, Kibana, Logstash)
resource "null_resource" "security_monitoring_stack_setup" {
  depends_on = [
    null_resource.networking_gateway_setup
  ]

  provisioner "remote-exec" {
    inline = [
      "apt update",
      "apt install -y sudo curl git docker.io docker-compose",
      "systemctl enable docker && systemctl start docker",
      "git clone https://github.com/StamusNetworks/SELKS",
      "cd SELKS/docker/",
      "bash easy-setup.sh --iA --non-interactive --interface eth1 --es-memory 512m --ls-memory 512m --no-pull-containers --restart-mode unless-stopped",
      # remove ulimits block from compose
      "sed -i '/ulimits:/,+3d' compose.yml",
      "sudo -E docker-compose up -d",
      # restart docker
      "systemctl restart docker"
    ]

    connection {
      type        = "ssh"
      host        = "${cidrhost(var.network.wan_cidr, 18)}"
      user        = "root"
      private_key = tls_private_key.network_machine_ssh_key.private_key_pem
    }
  }
}
