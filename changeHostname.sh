#!/bin/bash

# changeHostname.sh - Script to change the hostname on a Linux system

# Function to display a message and exit
function exit_with_message() {
    echo "$1"
    exit 1
}

# Check for root privileges
if [[ $EUID -ne 0 ]]; then
    exit_with_message "This script must be run as root. Use sudo."
fi

# Prompt for the new hostname
read -p "Enter the new hostname: " new_hostname

# Validate input
if [[ -z "$new_hostname" ]]; then
    exit_with_message "Hostname cannot be empty."
fi

# Change the hostname temporarily
hostnamectl set-hostname "$new_hostname"
if [[ $? -ne 0 ]]; then
    exit_with_message "Failed to set the hostname temporarily."
fi
echo "Temporary hostname set to $new_hostname."

# Update /etc/hostname
echo "$new_hostname" > /etc/hostname
if [[ $? -ne 0 ]]; then
    exit_with_message "Failed to update /etc/hostname."
fi
echo "Updated /etc/hostname."

# Update /etc/hosts
if grep -q "127.0.1.1" /etc/hosts; then
    sed -i "s/^127\.0\.1\.1\s.*/127.0.1.1   $new_hostname/" /etc/hosts
else
    echo "127.0.1.1   $new_hostname" >> /etc/hosts
fi
if [[ $? -ne 0 ]]; then
    exit_with_message "Failed to update /etc/hosts."
fi
echo "Updated /etc/hosts."

# Confirm and reboot
read -p "Do you want to reboot now to apply changes? (y/n): " reboot_choice
if [[ "$reboot_choice" =~ ^[Yy]$ ]]; then
    echo "Rebooting the system..."
    reboot
else
    echo "Hostname changed to $new_hostname. Please reboot manually for changes to take full effect."
fi
