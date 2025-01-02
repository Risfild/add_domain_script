#!/bin/sh

# Function to list all domains with numbering
list_domains() {
    local config_file="/etc/config/dhcp"
    awk '/list domain/ {print ++i")", $3}' "$config_file" | tr -d "'"
}

# Function to remove a domain by its index
remove_domain_by_index() {
    local index="$1"
    local domain
    domain=$(list_domains | sed -n "${index}p" | awk '{print $2}')

    if [ -z "$domain" ]; then
        echo "Invalid selection. No domain corresponds to the entered number."
        return
    fi

    # Remove the domain from the ipset section
    uci del_list dhcp.@ipset[0].domain="$domain"
    uci commit dhcp

    echo "Domain $domain successfully removed from the configuration."
}

# Function to check if a domain exists
domain_exists() {
    local domain="$1"
    if nslookup "$domain" > /dev/null 2>&1; then
        return 0  # Domain exists
    else
        return 1  # Domain does not exist
    fi
}

# Function to add a domain
add_domain() {
    while true; do
        read -p "Enter the domain to add (or 'c' to cancel): " domain

        # Check if the user wants to cancel
        if [ "$domain" = "c" ]; then
            echo "Returning to the main menu."
            break
        fi

        # Check for empty input
        if [ -z "$domain" ]; then
            echo "Domain cannot be empty. Please try again."
            continue
        fi

        # Validate domain format (simplified)
        if ! echo "$domain" | grep -Eq "^[a-zA-Z0-9.-]+$"; then
            echo "Invalid domain format. Please enter a valid domain."
            continue
        fi

        # Check if the domain exists
        if ! domain_exists "$domain"; then
            echo "Domain $domain does not exist. Please check the spelling or ensure the domain is active."
            continue
        fi

        # Add the domain to the ipset section
        uci add_list dhcp.@ipset[0].domain="$domain"
        uci commit dhcp

        echo "Domain $domain successfully added to the configuration."
    done
}

# Main loop
while true; do
    echo "Please select an option:"
    echo "1) Add a domain"
    echo "2) Remove a domain"
    echo "3) List all domains"
    echo "4) Exit"
    read -p "Enter your choice [1-4]: " choice

    case "$choice" in
        1)
            add_domain
            ;;
        2)
            while true; do
                echo "Existing domains:"
                list_domains

                read -p "Enter the number of the domain to remove (or 'c' to cancel): " domain_number

                # Check if the user wants to cancel
                if [ "$domain_number" = "c" ]; then
                    echo "Returning to the main menu."
                    break
                fi

                # Validate input is a number
                if ! echo "$domain_number" | grep -Eq "^[0-9]+$"; then
                    echo "Invalid input. Please enter a valid number or 'c' to cancel."
                    continue
                fi

                remove_domain_by_index "$domain_number"
            done
            ;;
        3)
            echo "Existing domains:"
            list_domains
            ;;
        4)
            echo "Applying changes and restarting the dnsmasq service..."
            /etc/init.d/dnsmasq restart
            echo "Exiting the script."
            break
            ;;
        *)
            echo "Invalid choice. Please enter a number between 1 and 4."
            ;;
    esac
done
