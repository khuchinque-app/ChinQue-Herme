#!/usr/bin/env bash
# SSH automation functions for container access
# Source this file in ~/.bashrc or ~/.zshrc:
#   source /path/to/ssh-functions.sh
#
# Usage:
#   sshc 3     # from local terminal -> VPS -> container root3
#   sshcv 4    # from inside VPS -> container root4
#   sshd 2     # docker exec into container root2

VPS_IP="<YOUR_VPS_PUBLIC_IP>"

# SSH from local computer (outside VPS -> VPS -> container)
sshc() {
    case "$1" in
        1) ssh root@$VPS_IP -p 2201 ;;
        2) ssh root@$VPS_IP -p 2202 ;;
        3) ssh root@$VPS_IP -p 2203 ;;
        4) ssh root@$VPS_IP -p 2204 ;;
        5) ssh root@$VPS_IP -p 2205 ;;
        *)
            echo "Usage: sshc <1-5>"
            echo "  Connects to container root<1-5> from your local terminal"
            echo "  Password: hermes123"
            ;;
    esac
}

# SSH from inside the VPS (VPS -> container via docker-proxy)
sshcv() {
    case "$1" in
        1) ssh root@127.0.0.1 -p 2201 ;;
        2) ssh root@127.0.0.1 -p 2202 ;;
        3) ssh root@127.0.0.1 -p 2203 ;;
        4) ssh root@127.0.0.1 -p 2204 ;;
        5) ssh root@127.0.0.1 -p 2205 ;;
        *)
            echo "Usage: sshcv <1-5>"
            echo "  Connects to container root<1-5> from inside the VPS"
            echo "  Password: hermes123"
            ;;
    esac
}

# Docker exec (no SSH needed)
sshd() {
    case "$1" in
        1) sudo docker exec -it root1 bash ;;
        2) sudo docker exec -it root2 bash ;;
        3) sudo docker exec -it root3 bash ;;
        4) sudo docker exec -it root4 bash ;;
        5) sudo docker exec -it root5 bash ;;
        *)
            echo "Usage: sshd <1-5>"
            echo "  Drops into container root<1-5> via docker exec"
            ;;
    esac
}
