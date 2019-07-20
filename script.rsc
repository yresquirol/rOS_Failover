#SET VARIABLES
:global ifaces 8;
:global mIface "Wetecsa1"
:global prefix "Wetecsa"
:global gw 10.204.10.1
:global ssid "WIFI_ETECSA"
:global rootRoute "$gw%$mIface"
for route from=2 to=$ifaces do={ :set $rootRoute ($rootRoute,"$gw%$prefix$route") }

#SET INTERFACES
interface wireless set Wetecsa1 ssid=$ssid disabled=no
for iface from=2 to=$ifaces  do={ interface wireless add ssid=$ssid master-interface=$mIface mode=station name="Wetecsa$iface" disabled=no }

#SET DHCP CLIENTS
for iface from=1 to=$ifaces do={ ip dhcp-client add interface="$prefix$iface" use-peer-dns=no use-peer-ntp=no disabled=no }

#SET DNS SERVERS
ip dns set servers=181.225.231.110,181.225.231.120,181.225.233.30,181.225.233.40 allow-remote-requests=yes

#FIREWALL MANGLE
for rule from=1 to=$ifaces do={ ip firewall mangle add action=mark-routing new-routing-mark="$prefix$rule" src-address-list="$prefix$rule" chain=prerouting dst-address-type=!local passthrough=yes }
for rule from=1 to=$ifaces do={ ip firewall mangle add action=mark-connection new-connection-mark="$prefix$rule" chain=prerouting passthrough=yes nth=1,1 dst-address-type=!local disabled=yes src-address-list="full" comment="NTH" connection-state=new }
for rule from=1 to=$ifaces do={ ip firewall mangle add action=mark-routing new-routing-mark="$prefix$rule" connection-mark="$prefix$rule" chain=prerouting src-address-list="full" dst-address-type=!local passthrough=no }

#FIREWALL NAT
for nat from=1 to=$ifaces do={ ip firewall nat add chain=srcnat action=masquerade routing-mark="$prefix$nat" out-interface="$prefix$nat" }

#ROUTES
for route from=1 to=$ifaces do={ ip route add gateway="$gw%$prefix$route" dst-address=0.0.0.0/0 routing-mark="$prefix$route" }
for route from=1 to=$ifaces do={ ip route add gateway="$gw%$prefix$route" dst-address="1.1.1.10$route" }
ip route add gateway=$rootRoute dst-address=0.0.0.0/0 comment=for_router

#SET RULE RUTES FOR DNS
for rule from=1 to=$ifaces do={ ip route rule add dst-address=181.225.231.110/32 table="$prefix$rule" }
for rule from=1 to=$ifaces do={ ip route rule add dst-address=181.225.231.120/32 table="$prefix$rule" }
for rule from=1 to=$ifaces do={ ip route rule add dst-address=181.225.233.30/32 table="$prefix$rule" }
for rule from=1 to=$ifaces do={ ip route rule add dst-address=181.225.233.40/32 table="$prefix$rule" }

#NETWATCH
for netw from=1 to=$ifaces do={ tool netwatch add down-script="ip firewall mangle disable [find new-connection-mark=$prefix$netw \
    and comment=NTH];\r\
    \nsystem script run Failover;" host="1.1.1.10$netw" interval=5s timeout=3s \
    up-script="ip firewall mangle enable [find new-connection-mark=$prefix$netw and\
    \_comment=NTH];\r\
    \nsystem script run Failover;" }


#FAILOVER
:local iface "Wetecsa1"
:local steps 0;
:local tempSteps 1;
:local addrs (10.10.0.9,10.10.0.10,10.10.0.11,10.10.0.20,10.10.0.21,10.10.0.22,10.10.0.23,10.10.0.24,10.10.0.25);
:local ruleIDs [/ip firewall mangle find comment=NTH and disabled=no];
:local steps ([:len $ruleIDs ]);
:foreach ruleID in=$ruleIDs do {
    ip firewall mangle set [find .id=$ruleID] nth="$steps,$tempSteps";
    set tempSteps ($tempSteps + 1);
}
if ([$steps]=0) do {
    foreach addr in=$addrs do {
        do {
            if ([ip firewall address-list get value-name=list [find where address=$addr && comment="auto"]]="full") do {
                ip firewall address-list set list=$iface [find where list=full && comment="auto"];
            }
        } on-error {
            log warning "Ocurrio un error recuperando $addr de la lista";
        }
    }
} else {
    foreach addr in=$addrs do {
        do {
            if ([ip firewall address-list get value-name=list [find where address=$addr && comment="auto"]]=$iface) do {
                ip firewall address-list set list=full [find where list=$iface && comment="auto"];
            }
        } on-error {
            log warning "Ocurrio un error recuperando $addr de la lista";
        }
    }
}


system scheduler add name=init start-time=startup on-event="delay 5;\r\ \nsystem script run Failover;"
foreach var in=[system script environment find] do={ system script environment remove $var }
