#!/bin/bash
# Ensure compatibility with bash

# Replace echo -e with printf
# Replace [[ with [
# Add fallback logic for missing temperature data
# Standardize output formatting

# Colors
RED='\033[1;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# Clear screen
clear

# Header
printf "%b\n" "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${RESET}"

# Hostname
if command -v figlet &>/dev/null; then
    printf "%b\n" "${BLUE}│${CYAN} $(figlet -f slant "SCT-DEV" 2>/dev/null | sed 's/^/│ /')${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}Hostname   : ${GREEN}$(hostname)${RESET}"
fi

# Load Average
LOAD1=$(cut -d ' ' -f1 /proc/loadavg)
if [ $(echo "$LOAD1 > 2.0" | bc -l) -eq 1 ]; then
    printf "%b\n" "${BLUE}│ ${WHITE}Load Avg   : ${RED}$(cut -d ' ' -f1-3 /proc/loadavg)${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}Load Avg   : ${YELLOW}$(cut -d ' ' -f1-3 /proc/loadavg)${RESET}"
fi

# CPU Temperature
TEMP=$(sensors 2>/dev/null | awk '/^Package id 0:|^Tdie:|^Tctl:/ {print $2; exit}')
if [ -z "$TEMP" ] && [ -f /sys/class/thermal/thermal_zone0/temp ]; then
    TEMP_RAW=$(cat /sys/class/thermal/thermal_zone0/temp)
    TEMP=$(awk "BEGIN {printf \"%.1f°C\", $TEMP_RAW/1000}")
fi

if [ -z "$TEMP" ]; then
    printf "%b\n" "${BLUE}│ ${WHITE}CPU Temp   : ${RED}Not available${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}CPU Temp   : ${GREEN}$TEMP${RESET}"
fi

# Memory
printf "%b\n" "${BLUE}│ ${WHITE}Memory     : ${GREEN}$(free -h | awk '/Mem:/ {print $3 "/" $2}')${RESET}"

# Disk Usage
printf "%b\n" "${BLUE}│ ${WHITE}Disk (/ )  : ${GREEN}$(df -h / | awk 'NR==2 {print $3 "/" $2 " used"}')${RESET}"

# Shell
printf "%b\n" "${BLUE}│ ${WHITE}Shell      : ${CYAN}$SHELL${RESET}"

# IP Address
printf "%b\n" "${BLUE}│ ${WHITE}IP Address : ${YELLOW}$(hostname -I | awk '{print $1}')${RESET}"

# Date/Time
printf "%b\n" "${BLUE}│ ${WHITE}Date/Time  : ${GREEN}$(date +"%a, %d %b %Y %H:%M:%S %Z")${RESET}"

# ── Service Status Bar ───────────────────────────────────────────────────
# Author: Abubakkar (System Admin)
# Professional status display for installed stack components.
#clear
#echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────────┐${RESET}"

#check service status
check_service() {
    local service=$1
    local name=$2

    # Fast systemctl check using status exit codes
    if command -v systemctl &>/dev/null; then
        local exit_code
        systemctl status "$service" &>/dev/null
        exit_code=$?
        
        case $exit_code in
            0)  # Active/running
                echo -ne "${BLUE}│${RESET}\033[1;32m[✔ $name U]\033[0m "
                ;;
            3)  # Inactive/stopped but exists
                echo -ne "${BLUE}│${RESET}\033[1;31m[✘ $name D]\033[0m "
                ;;
            4)  # Service doesn't exist - skip output
                ;;
            *)  # Other states (failed, etc.) - treat as stopped
                echo -ne "${BLUE}│${RESET}\033[1;31m[✘ $name D]\033[0m "
                ;;
        esac
        return
    fi

    # Fallback to service command (SysVinit, older distros)
    if command -v service &>/dev/null; then
        local status_output
        status_output=$(service "$name" status 2>&1)
        local exit_code=$?
        
        if echo "$status_output" | grep -q "running\|active"; then
            echo -ne "${BLUE}│${RESET}\033[1;32m[✔ $name U]\033[0m "
        elif [ $exit_code -eq 0 ] || echo "$status_output" | grep -q "stopped\|inactive\|dead"; then
            echo -ne "${BLUE}│${RESET}\033[1;31m[✘ $name D]\033[0m "
        fi
        return
    fi
}
# PHP – detects installed versions & checks FPM
if [ -d /etc/php ]; then
    for phpver in $(ls /etc/php | sort -r); do
        check_service "php${phpver}-fpm.service" "PHP ${phpver}-FPM"
    done
fi

# Database servers
check_service "mariadb.service" "MariaDB"
check_service "mysql.service" "MySQL"
check_service "postgresql.service" "PostgreSQL"
check_service "mongodb.service" "MongoDB"
check_service "cassandra.service" "Cassandra"
check_service "couchdb.service" "CouchDB"
check_service "elasticsearch.service" "Elasticsearch"
check_service "kibana.service" "Kibana"
check_service "logstash.service" "Logstash"

# Web servers
check_service "nginx.service" "NGINX"
check_service "apache2.service" "Apache2"
check_service "lighttpd.service" "Lighttpd"
check_service "caddy.service" "Caddy"
check_service "httpd.service" "HAProxy"
check_service "traefik.service" "Traefik"
check_service "openresty.service" "OpenResty"
check_service "tomcat.service" "Tomcat"
check_service "jetty.service" "Jetty"

# Messaging / Queues
check_service "rabbitmq-server.service" "RabbitMQ"
check_service "kafka.service" "Kafka"
check_service "redis-sentinel.service" "Redis Sentinel"
check_service "zeromq.service" "ZeroMQ"
check_service "mosquitto.service" "Mosquitto MQTT"

# Document server
check_service "onlyoffice-documentserver.service" "OnlyOffice"
check_service "collabora.service" "Collabora Online"
check_service "nextcloud-documentserver.service" "Nextcloud Server"

# NTP sync
check_service "chronyd.service" "Chrony"
check_service "ntpd.service" "NTPD"

# Caching
check_service "redis-server.service" "Redis"

# Supervisor
check_service "supervisor.service" "Supervisor"

# Kubernetes
check_service "kubelet.service" "Kubelet"
check_service "kube-proxy.service" "Kube Proxy"
check_service "kube-apiserver.service" "Kube API Server"
check_service "kube-controller-manager.service" "Kube Controller Manager"
check_service "kube-scheduler.service" "Kube Scheduler"
check_service "kube-dns.service" "Kube DNS"

# Containers
check_service "docker.service" "Docker"
check_service "podman.service" "Podman"
check_service "lxc.service" "LXC"
check_service "lxd.service" "LXD"
check_service "containerd.service" "Containerd"

# Zombie Processes
ZOMBIES=$(ps -eo stat,pid | awk '$1 ~ /^Z/ {print $2}')
if [ -n "$ZOMBIES" ]; then
    count=$(echo "$ZOMBIES" | wc -l)
    printf "%b\n" "${BLUE}│ ${WHITE}Zombies    : ${RED}$count process(es) detected${RESET}"
    printf "%b\n" "${BLUE}│ ${WHITE}Zombie PIDs: ${YELLOW}$(echo $ZOMBIES | tr '\n' ' ')${RESET}"
else
    printf "%b\n" "${BLUE}│ ${WHITE}Zombies    : ${GREEN}None detected${RESET}"
fi

echo ""
  echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────────┘${RESET}"

