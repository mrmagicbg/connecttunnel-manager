---

# SonicWall Connect Tunnel — Linux Split‑Tunnel Override  
### Restore Local LAN Access on Ubuntu 25+ When SonicWall Injects Conflicting Routes

---

## 1. Problem Summary

SonicWall Connect Tunnel aggressively injects routing entries, including:

- Entire **10.0.0.0/8** broken into hundreds of subnets  
- Entire **172.16.0.0/12**  
- Entire **192.168.0.0/16**  
- DNS overrides  
- Thousands of `/32` host routes  
- Overlapping subnets such as:  
  - `10.10.10.0/16`  
  - `10.10.10.0/28`  
  - `10.10.10.0/29`  
  - `10.10.10.0/30`  
  - etc.

If your home LAN uses a subnet inside these ranges (e.g., **10.10.10.0/24**), SonicWall’s injected routes override your local routing, causing:

- Loss of access to local devices (NAS, Proxmox, Home Assistant, printers, etc.)  
- Traceroute and ping going through the VPN  
- DNS hijacking  
- Broken SMB/NFS/SSH access  

---

## 2. Solution Overview

We deploy a **NetworkManager dispatcher script** that:

- Detects when the VPN interface (`tun0`) comes up  
- Dynamically identifies all local interfaces using the LAN subnet  
- Removes only the **conflicting SonicWall‑injected routes**  
- Re‑applies a **high‑priority LAN route**  
- Ensures the LAN always routes through the local gateway  
- Works with Ethernet, Wi‑Fi, USB tethering, or any interface  
- Automatically runs on every VPN reconnect  

This creates a clean, stable **split‑tunnel override** without modifying SonicWall or renumbering your LAN.

---

## 3. Create the Route‑Fix Script

Create the file:

```
/usr/local/bin/fix-sonicwall-routes.sh
```

Add the following:

```bash
#!/bin/bash

LAN_NET="10.10.10.0/24"

# Detect LAN interfaces dynamically
INTERFACES=($(ip -o -4 addr show | awk '/10\.10\.10\./ {print $2}' | sort -u))

# Detect the LAN gateway
GATEWAY=$(ip route | awk '/default/ && /10\.10\.10\.1/ {print $3; exit}')

echo "Detected LAN interfaces: ${INTERFACES[*]}"
echo "Detected LAN gateway: $GATEWAY"

# 1. Remove SonicWall-injected conflicting routes
echo "Removing conflicting SonicWall routes..."
for r in $(ip route | awk '/10\.10\.10\./ && /tun0/ {print $1}'); do
    ip route del $r 2>/dev/null
done

# 2. Re-apply LAN override
for IFACE in "${INTERFACES[@]}"; do
    echo "Applying LAN override on $IFACE..."
    ip route replace $LAN_NET via $GATEWAY dev $IFACE metric 1
done

exit 0
```

Make it executable:

```
sudo chmod +x /usr/local/bin/fix-sonicwall-routes.sh
```

---

## 4. Create the NetworkManager Dispatcher Hook

Create:

```
/etc/NetworkManager/dispatcher.d/99-fix-sonicwall
```

Add:

```bash
#!/bin/bash

IFACE="$1"
STATUS="$2"

# Trigger only when tun0 comes up
if [[ "$IFACE" == "tun0" && "$STATUS" == "up" ]]; then
    /usr/local/bin/fix-sonicwall-routes.sh
fi
```

Make it executable:

```
sudo chmod +x /etc/NetworkManager/dispatcher.d/99-fix-sonicwall
```

---

## 5. Testing Procedure

### **Before connecting VPN**
Run:

```
ip route | grep 10.10.10
```

Expected:

- Only your local `/24` route  
- No tun0 routes  

### **Connect VPN**
Run:

```
ip route | grep 10.10.10
```

Expected:

- Only:  
  ```
  10.10.10.0/24 via 10.10.10.1 dev <iface> metric 1
  ```
- No SonicWall `/28`, `/29`, `/30`, `/31` fragments  
- No `10.10.10.0 via tun0`  

### **Traceroute test**
```
traceroute 10.10.10.21
```

Expected:

```
1  10.10.10.1
2  10.10.10.21
```

### **Ping test**
```
ping 10.10.10.1
ping <NAS>
ping <Proxmox>
ping <HomeAssistant>
```

### **Corporate test**
```
ping 10.103.2.11
```

### **Internet routing**
```
curl ifconfig.me
```

Expected:

- Your **home IP**, not corporate  

---

## 6. How It Works Internally

### The script:

- Detects all interfaces with a `10.10.10.x` address  
- Detects the correct gateway (`10.10.10.1`)  
- Removes all SonicWall‑injected `10.10.10.*` routes via tun0  
- Re‑applies your `/24` route with **metric 1**  
- Ensures your LAN always wins routing decisions  
- Runs automatically when tun0 comes up  

---

## 7. Optional Enhancements

You can extend this setup with:

- DNS split‑tunneling  
- Logging to `/var/log/sonicwall-fix.log`  
- A watchdog service to re‑apply fixes if SonicWall reinjects routes  
- A rollback script  
- A health‑check command  
- A systemd service instead of NetworkManager  

(Ask if you want any of these generated.)

---

## 8. Summary

This setup provides:

- Full LAN access while on SonicWall  
- Full corporate access  
- Local internet routing  
- Automatic healing on reconnect  
- No renumbering required  
- No SonicWall configuration changes  
- Clean, reproducible, future‑proof behavior  

This is the most reliable and least intrusive method to counter SonicWall’s aggressive route injection on Linux.

---

