#!/bin/bash

# 
# INSTALLATION:
# 1. mkdir -p ~/.bash_custom
# 2. Copy this file to ~/.bash_custom/proxy.sh
# 3. echo 'source "$HOME/.bash_custom/proxy.sh"' >> ~/.bashrc
# 4. For zsh users: echo 'source "$HOME/.bash_custom/proxy.sh"' >> ~/.zshrc
# 5. Restart terminal or run: source ~/.bashrc
# 
# USAGE:
# proxy_on                              - Enable proxy for current session
# proxy_off                             - Disable proxy for current session  
# proxy_status                          - Show current proxy settings
# with_proxy <command>                  - Run single command with proxy
# 
# EXAMPLES:
# proxy_on && curl https://google.com   - Enable proxy then test connection
# proxy_off                             - Disable proxy when done
# with_proxy curl https://google.com    - One-time proxy usage without enabling globally



# ====================== PROXY CONFIGURATION ======================
# Configuration Area (modify as needed)
PROXY_URL='!!!SET PROXY'  # Proxy with username/password
NO_PROXY="localhost,127.0.0.1,192.168.*,10.*,.internal"    # Addresses to bypass the proxy

# ====================== FUNCTION DEFINITIONS ======================
function proxy_on {
    # Set HTTP/HTTPS proxy environment variables
    export http_proxy="$PROXY_URL"
    export https_proxy="$PROXY_URL"
    export HTTP_PROXY="$PROXY_URL"
    export HTTPS_PROXY="$PROXY_URL"

    # Set no_proxy environment variables
    export no_proxy="$NO_PROXY"
    export NO_PROXY="$NO_PROXY"

    # Securely display the proxy URL (hides password)
    local display_url=$(echo "$PROXY_URL" | sed -E 's#https?://[^@]+@#http://***:***@#')
    echo -e "\033[32mProxy enabled\033[0m\n  Proxy address: ${display_url}"
}

function proxy_off {
    unset http_proxy https_proxy HTTP_PROXY HTTPS_PROXY
    unset no_proxy NO_PROXY 2>/dev/null
    echo -e "\033[31mProxy disabled\033[0m"
}

function proxy_status {
    echo -e "\033[36mCurrent Proxy Status\033[0m"
    # Use column -t for automatic alignment based on whitespace
    (
        printf "    HTTP:\t%s\n" "${http_proxy:-Not set}"
        printf "   HTTPS:\t%s\n" "${https_proxy:-Not set}"
        printf "NO_PROXY:\t%s\n" "${no_proxy:-Not set}"
    )
}

function with_proxy {
    # Check if a command was provided
    if [ $# -eq 0 ]; then
        echo "Usage: with_proxy <command>"
        echo "Example: with_proxy curl https://www.google.com"
        return 1
    fi

    # Use 'env' to run a command with temporary environment variables
    echo "--> Running with proxy..."
    env \
        http_proxy="$PROXY_URL" \
        https_proxy="$PROXY_URL" \
        HTTP_PROXY="$PROXY_URL" \
        HTTPS_PROXY="$PROXY_URL" \
        no_proxy="$NO_PROXY" \
        NO_PROXY="$NO_PROXY" \
        "$@"
}
