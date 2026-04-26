# High Availability Load Balancer (GCP Cloud Load Balancing Emulator)
# Balanceador de Carga de Alta Disponibilidad (Emulador de GCP Cloud Load Balancing)

[English](#english) | [Español](#español)

---

<a id="english"></a>
## English

### Overview
This project provides an automated setup to emulate the core components of Google Cloud Load Balancing on a Contabo VPS (or any Debian/Ubuntu server). It uses **HAProxy** for Layer 4/7 routing and **Keepalived** for high availability via a Floating IP (VRRP).

### Included Files
- `haproxy.cfg`: Main configuration file handling Frontend, URL Maps (routing based on paths), Backend Services, and Health Checks.
- `keepalived-master.conf`: VRRP configuration for the active/primary node.
- `keepalived-backup.conf`: VRRP configuration for the passive/secondary node.
- `install_lb.sh`: Bash script to install dependencies and optimize the Linux kernel for high performance and security.

### Hardening & Security Instructions
This setup includes out-of-the-box hardening measures:

#### 1. Basic DoS / DDoS Protection (Rate Limiting)
- In `haproxy.cfg` (`frontend https_in`), a `stick-table` is configured to track IP connections.
- **Rule:** Rejects connections if an IP exceeds **100 connections in 3 seconds** or maintains over **50 concurrent connections**, mitigating HTTP floods.
- **Kernel (`sysctl`):** The installation script enables `net.ipv4.tcp_syncookies=1` to prevent TCP SYN Flood attacks.

#### 2. Modern SSL / TLS Configuration
- Enforces HTTPS by permanently redirecting port 80 traffic to 443.
- Uses modern Mozilla-recommended Ciphers and restricts protocols to TLS v1.2 and TLS v1.3.
- **Let's Encrypt Setup:** HAProxy requires a combined `.pem` file containing the private key and full chain. Once generated with Certbot, run:
  ```bash
  cat /etc/letsencrypt/live/yourdomain.com/fullchain.pem /etc/letsencrypt/live/yourdomain.com/privkey.pem > /etc/haproxy/certs/site.pem
  ```

#### 3. Detailed Logging for Auditing
- HAProxy is configured with `log /dev/log local0` and `option httplog` for structured logging (client IPs, response codes, latency). Ensure `rsyslog` captures `local0` to write these logs to `/var/log/haproxy.log`.

#### 4. Basic System Firewall (UFW)
Secure your VPS by allowing only required ports:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp  # Don't lock yourself out of SSH!
# Allow VRRP traffic between Master and Backup for Keepalived
sudo ufw allow in on eth0 to any port vrrp
sudo ufw enable
```

#### 5. Network Configuration on Contabo
- In your Contabo panel, assign a **Floating IP** to your Master server.
- Ensure the `interface eth0` setting in `keepalived.conf` matches your actual public network interface name (use `ip a` to check).

---

<a id="español"></a>
## Español

### Resumen
Este proyecto provee una configuración automatizada para emular los componentes principales de Google Cloud Load Balancing en un VPS de Contabo (o cualquier servidor Debian/Ubuntu). Utiliza **HAProxy** para el ruteo de Capa 4/7 y **Keepalived** para alta disponibilidad mediante una IP Flotante (VRRP).

### Archivos Incluidos
- `haproxy.cfg`: Archivo de configuración principal que maneja el Frontend, URL Maps (ruteo basado en rutas), Backend Services y Health Checks.
- `keepalived-master.conf`: Configuración VRRP para el nodo activo/principal.
- `keepalived-backup.conf`: Configuración VRRP para el nodo pasivo/secundario.
- `install_lb.sh`: Script en Bash para instalar dependencias y optimizar el kernel de Linux para alto rendimiento y seguridad.

### Instrucciones de Hardening y Seguridad
Esta arquitectura incluye medidas de seguridad preconfiguradas:

#### 1. Protección contra DoS / DDoS Básico (Límites de Conexiones)
- En `haproxy.cfg` (`frontend https_in`), se configuró una `stick-table` para rastrear las conexiones por IP.
- **Regla:** Rechaza conexiones si una IP excede **100 conexiones en 3 segundos** o mantiene más de **50 conexiones concurrentes**, mitigando los ataques HTTP Flood.
- **Kernel (`sysctl`):** El script de instalación activa `net.ipv4.tcp_syncookies=1` para prevenir ataques TCP SYN Flood.

#### 2. Configuración de SSL / TLS Moderno
- Fuerza el uso de HTTPS redirigiendo permanentemente el tráfico del puerto 80 al 443.
- Utiliza Ciphers modernos recomendados por Mozilla y restringe los protocolos a TLS v1.2 y TLS v1.3.
- **Configuración Let's Encrypt:** HAProxy requiere un archivo `.pem` combinado que contenga la llave privada y la cadena completa. Tras generarlo con Certbot, ejecuta:
  ```bash
  cat /etc/letsencrypt/live/tudominio.com/fullchain.pem /etc/letsencrypt/live/tudominio.com/privkey.pem > /etc/haproxy/certs/site.pem
  ```

#### 3. Logs Detallados para Auditoría
- HAProxy cuenta con `log /dev/log local0` y `option httplog` para un registro estructurado (IPs de clientes, códigos de respuesta, latencia). Asegúrate de que `rsyslog` capture `local0` para escribir estos logs en `/var/log/haproxy.log`.

#### 4. Firewall Básico del Sistema (UFW)
Asegura tu VPS permitiendo solo los puertos requeridos:
```bash
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 22/tcp  # ¡No te bloquees el acceso SSH!
# Permitir tráfico VRRP entre los nodos Master y Backup para Keepalived
sudo ufw allow in on eth0 to any port vrrp
sudo ufw enable
```

#### 5. Configuración de Red en Contabo
- En tu panel de Contabo, asigna una **IP Flotante (Floating IP)** a tu servidor Maestro.
- Asegúrate de que el parámetro `interface eth0` en `keepalived.conf` coincida con el nombre real de tu interfaz de red pública (usa `ip a` para verificarlo).
