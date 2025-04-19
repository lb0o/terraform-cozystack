```mermaid
---
config:
  layout: fixed
---
flowchart TD
classDef container fill:#f5f5f5,stroke:#333,stroke-width:1px
classDef user fill:#e1f5fe,stroke:#0288d1,stroke-width:1px,color:#01579b
classDef interface fill:#e8f5e9,stroke:#2e7d32,stroke-width:1px,color:#1b5e20
classDef creds fill:#fff8e1,stroke:#ff8f00,stroke-width:1px,color:#e65100
classDef security fill:#ffebee,stroke:#c62828,stroke-width:1px,color:#b71c1c
   
subgraph Network_Machine_Container["Container: Network Machine"]
    eth0["eth0 (WAN Interface)<br><wan_ip>/24<br>Gateway: <gateway>"]
    eth1["eth1 (LAN Interface)<br><lan_gateway>/24"]
    DHCP_Server["DHCP Server"]
    Suricata["Suricata IDS/IPS<br>Network Traffic Analyzer"]
end

subgraph Developer_Machine_Container["Container: Developer Machine"]
    veth0["veth0 Interface<br><dev_ip>/24<br>Gateway: <lan_gateway><br>DNS: <lan_gateway>"]
end

subgraph Proxmox_Node["Proxmox Node"]
    direction TB
    Network_Machine_Container
    Developer_Machine_Container
end

subgraph Terraform_Host["Terraform Host"]
    direction TB
    SSH_Config["SSH Config (.tmpssh/config)"]
    SSH_Key_Network["network_id_rsa"]
    SSH_Key_Dev["dev_id_rsa"]
end

INBOUND --- eth0
eth0 --- DHCP_Server
eth1 --"LAN Bridge (<lan_subnet>/24)"--- DHCP_Server
eth1 --"LAN Bridge (<lan_subnet>/24)"--- veth0
eth1 -- "Monitors" --> Suricata
SSH_Config --"SSH to <wan_ip>"--> Network_Machine_Container
SSH_Key_Network --> SSH_Config
SSH_Key_Dev --> SSH_Config

%% Apply classes to elements
class Network_Machine_Container,Developer_Machine_Container,Proxmox_Node,Terraform_Host container
class veth0,eth0,eth1 interface
class SSH_Config,SSH_Key_Network,SSH_Key_Dev creds
class Suricata security