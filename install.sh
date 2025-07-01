#!/bin/bash

# 0G Labs V3 Galileo Validator Universal Setup Script
# Author: OveR (@OVER9725)
# GitHub: https://github.com/Overbafer999/0g-validator-setup
# Version: 1.1 - Improved pipe handling

set -e

# Smart pipe detection and auto-fix
if [ ! -t 0 ]; then
    echo "🔧 Detected pipe execution. Auto-fixing for better compatibility..."
    
    # Download script to temp location
    TEMP_SCRIPT="/tmp/0g_installer_$(date +%s).sh"
    
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/Overbafer999/0g-validator-setup/main/install.sh -o "$TEMP_SCRIPT"
    elif command -v wget >/dev/null 2>&1; then
        wget -q https://raw.githubusercontent.com/Overbafer999/0g-validator-setup/main/install.sh -O "$TEMP_SCRIPT"
    else
        echo "Installing wget for download..."
        apt update &>/dev/null && apt install -y wget &>/dev/null
        wget -q https://raw.githubusercontent.com/Overbafer999/0g-validator-setup/main/install.sh -O "$TEMP_SCRIPT"
    fi
    
    chmod +x "$TEMP_SCRIPT"
    echo "✅ Restarting in interactive mode..."
    exec bash "$TEMP_SCRIPT" "$@"
fi

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Global variables
CHAIN_ID="16601"
TOKEN_SYMBOL="OG"
BINARY_URL="https://github.com/0glabs/0gchain-NG/releases/download/v1.1.1/galileo-v1.1.1.tar.gz"
GENESIS_URL="https://github.com/0glabs/0gchain-NG/releases/download/v1.1.1/genesis.json"
PEERS="85a9b9a1b7fa0969704db2bc37f7c100855a75d9@8.218.88.60:26656"
TOOLS_DIR="$HOME/0g-tools"

# Print functions
print_step() { echo -e "${CYAN}[STEP]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }

# ASCII Banner by OveR
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
  ██████╗  ██████╗     ██╗      █████╗ ██████╗ ███████╗
 ██╔═████╗██╔════╝     ██║     ██╔══██╗██╔══██╗██╔════╝
 ██║██╔██║██║  ███╗    ██║     ███████║██████╔╝███████╗
 ████╔╝██║██║   ██║    ██║     ██╔══██║██╔══██╗╚════██║
 ╚██████╔╝╚██████╔╝    ███████╗██║  ██║██████╔╝███████║
  ╚═════╝  ╚═════╝     ╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝
                                                        
 ██╗   ██╗██████╗     ██╗   ██╗ █████╗ ██╗     ██╗██████╗  █████╗ ████████╗ ██████╗ ██████╗ 
 ██║   ██║╚════██╗    ██║   ██║██╔══██╗██║     ██║██╔══██╗██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗
 ██║   ██║ █████╔╝    ██║   ██║███████║██║     ██║██║  ██║███████║   ██║   ██║   ██║██████╔╝
 ╚██╗ ██╔╝ ╚═══██╗    ╚██╗ ██╔╝██╔══██║██║     ██║██║  ██║██╔══██║   ██║   ██║   ██║██╔══██╗
  ╚████╔╝ ██████╔╝     ╚████╔╝ ██║  ██║███████╗██║██████╔╝██║  ██║   ██║   ╚██████╔╝██║  ██║
   ╚═══╝  ╚═════╝       ╚═══╝  ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝
EOF
    echo -e "${NC}"
    echo -e "${CYAN}========================================================================================${NC}"
    echo -e "${CYAN}                     0G Labs V3 Galileo Validator Universal Setup${NC}"
    echo -e "${CYAN}                                    Created by OveR${NC}"
    echo -e "${CYAN}                              Follow: https://twitter.com/OVER9725${NC}"
    echo -e "${CYAN}========================================================================================${NC}"
    echo -e "${GREEN}Chain ID: $CHAIN_ID | Token: $TOKEN_SYMBOL | Version: v1.1.1${NC}"
    echo -e "${CYAN}========================================================================================${NC}"
    echo ""
}

# Check system requirements
check_requirements() {
    print_step "Checking system requirements..."
    
    # Check OS
    if [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "Only Linux is supported"
        exit 1
    fi
    
    # Check sudo
    if ! sudo -n true 2>/dev/null; then
        print_error "Sudo privileges required"
        exit 1
    fi
    
    # Check RAM
    total_mem=$(free -m | awk 'NR==2{printf "%.0f", $2/1024}')
    if [ "$total_mem" -lt 60 ]; then
        print_warning "Recommended: 64GB RAM. You have: ${total_mem}GB"
    fi
    
    # Check disk space
    available_space=$(df / | awk 'NR==2 {print int($4/1024/1024)}')
    if [ "$available_space" -lt 900 ]; then
        print_warning "Recommended: 1TB free space. You have: ${available_space}GB"
    fi
    
    print_success "System check completed"
}

# Get user input
get_user_input() {
    print_step "Configuration setup..."
    
    read -p "Enter your validator name (moniker): " MONIKER
    while [[ -z "$MONIKER" ]]; do
        print_error "Moniker cannot be empty!"
        read -p "Enter your validator name (moniker): " MONIKER
    done
    
    read -p "Enter wallet name [default: wallet]: " WALLET_NAME
    WALLET_NAME=${WALLET_NAME:-wallet}
    
    print_info "Moniker: $MONIKER"
    print_info "Wallet: $WALLET_NAME"
}

# Install dependencies
install_dependencies() {
    print_step "Installing dependencies..."
    
    sudo apt update &>/dev/null
    sudo apt install -y curl git jq build-essential gcc unzip wget lz4 &>/dev/null
    
    print_success "Dependencies installed"
}

# Install Go
install_go() {
    print_step "Installing Go..."
    
    if command -v go &> /dev/null; then
        print_info "Go already installed: $(go version | awk '{print $3}')"
        return
    fi
    
    cd $HOME
    wget -q "https://golang.org/dl/go1.22.0.linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "go1.22.0.linux-amd64.tar.gz"
    rm "go1.22.0.linux-amd64.tar.gz"
    
    echo "export PATH=\$PATH:/usr/local/go/bin:\$HOME/go/bin" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
    
    print_success "Go installed: $(go version | awk '{print $3}')"
}

# Install binary
install_binary() {
    print_step "Installing 0G binary..."
    
    cd $HOME
    rm -rf galileo galileo-*.tar.gz
    
    wget -q "$BINARY_URL" -O galileo.tar.gz
    tar -xzf galileo.tar.gz
    cd galileo
    
    sudo cp bin/0gchaind /usr/local/bin/
    sudo chmod +x /usr/local/bin/0gchaind
    
    print_success "Binary installed: $(0gchaind version)"
}

# Initialize node
initialize_node() {
    print_step "Initializing node..."
    
    # Set variables
    echo "export MONIKER=\"$MONIKER\"" >> $HOME/.bash_profile
    echo "export WALLET_NAME=\"$WALLET_NAME\"" >> $HOME/.bash_profile
    source $HOME/.bash_profile
    
    # Init node
    0gchaind init "$MONIKER" --chain-id $CHAIN_ID --home $HOME/.0gchain
    
    # Download genesis
    wget -q "$GENESIS_URL" -O $HOME/.0gchain/config/genesis.json
    0gchaind validate-genesis --home $HOME/.0gchain &>/dev/null
    
    print_success "Node initialized"
}

# Configure node
configure_node() {
    print_step "Configuring node..."
    
    CONFIG_FILE="$HOME/.0gchain/config/config.toml"
    APP_FILE="$HOME/.0gchain/config/app.toml"
    
    # Update config
    sed -i "s/^persistent_peers = .*/persistent_peers = \"$PEERS\"/" $CONFIG_FILE
    sed -i 's/^pruning = .*/pruning = "custom"/' $APP_FILE
    sed -i 's/^pruning-keep-recent = .*/pruning-keep-recent = "100"/' $APP_FILE
    sed -i 's/^pruning-interval = .*/pruning-interval = "50"/' $APP_FILE
    
    print_success "Node configured"
}

# Setup State Sync
setup_state_sync() {
    print_step "Setting up State Sync..."
    
    RPC_SERVER="https://evmrpc-testnet.0glabs.live:26657"
    
    LATEST_HEIGHT=$(curl -s $RPC_SERVER/block | jq -r .result.block.header.height)
    SYNC_BLOCK_HEIGHT=$(($LATEST_HEIGHT - 2000))
    SYNC_BLOCK_HASH=$(curl -s "$RPC_SERVER/block?height=$SYNC_BLOCK_HEIGHT" | jq -r .result.block_id.hash)
    
    CONFIG_FILE="$HOME/.0gchain/config/config.toml"
    sed -i "s/^enable = false/enable = true/" $CONFIG_FILE
    sed -i "s/^rpc_servers = \"\"/rpc_servers = \"$RPC_SERVER,$RPC_SERVER\"/" $CONFIG_FILE
    sed -i "s/^trust_height = 0/trust_height = $SYNC_BLOCK_HEIGHT/" $CONFIG_FILE
    sed -i "s/^trust_hash = \"\"/trust_hash = \"$SYNC_BLOCK_HASH\"/" $CONFIG_FILE
    
    print_success "State Sync configured"
}

# Create systemd service
create_service() {
    print_step "Creating systemd service..."
    
    sudo tee /etc/systemd/system/0gd.service > /dev/null <<EOF
[Unit]
Description=0G Node
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$HOME
ExecStart=/usr/local/bin/0gchaind start --home $HOME/.0gchain
Restart=on-failure
RestartSec=5
LimitNOFILE=65535

[Install]
WantedBy=multi-user.target
EOF
    
    sudo systemctl daemon-reload
    sudo systemctl enable 0gd
    
    print_success "Service created"
}

# Create wallet
create_wallet() {
    print_step "Wallet setup..."
    
    echo -e "${YELLOW}Choose option:${NC}"
    echo "1) Create new wallet"
    echo "2) Recover from seed phrase"
    echo "3) Skip wallet creation"
    
    read -p "Choose [1]: " wallet_option
    wallet_option=${wallet_option:-1}
    
    case $wallet_option in
        1)
            0gchaind keys add $WALLET_NAME --eth --home $HOME/.0gchain
            ;;
        2)
            0gchaind keys add $WALLET_NAME --eth --recover --home $HOME/.0gchain
            ;;
        3)
            print_warning "Wallet creation skipped"
            return
            ;;
    esac
    
    echo -e "${GREEN}=================================${NC}"
    echo -e "${GREEN}0G Address:${NC}"
    0gchaind keys show $WALLET_NAME -a --home $HOME/.0gchain
    echo -e "${GREEN}EVM Address:${NC}"
    echo "0x$(0gchaind debug addr $(0gchaind keys show $WALLET_NAME -a --home $HOME/.0gchain) | grep hex | awk '{print $3}')"
    echo -e "${GREEN}=================================${NC}"
    
    print_warning "SAVE YOUR SEED PHRASE SECURELY!"
    read -p "Press Enter to continue..."
}

# Create management tools
create_tools() {
    print_step "Creating management tools..."
    
    mkdir -p $TOOLS_DIR
    
    # Node monitor
    cat > $TOOLS_DIR/monitor.sh << 'EOF'
#!/bin/bash
while true; do
    clear
    echo "=== 0G Node Monitor ==="
    echo "Status: $(systemctl is-active 0gd)"
    echo "Sync: $(curl -s localhost:26657/status 2>/dev/null | jq -r .result.sync_info.catching_up)"
    echo "Height: $(curl -s localhost:26657/status 2>/dev/null | jq -r .result.sync_info.latest_block_height)"
    echo "Peers: $(curl -s localhost:26657/net_info 2>/dev/null | jq -r .result.n_peers)"
    echo ""
    echo "Press Ctrl+C to exit"
    sleep 10
done
EOF

    # Validator manager
    cat > $TOOLS_DIR/validator.sh << 'EOF'
#!/bin/bash
WALLET_NAME="wallet"
CHAIN_ID="16601"

echo "=== 0G Validator Manager ==="
echo "1) Create validator"
echo "2) Check balance" 
echo "3) Check validator status"
echo "0) Exit"

read -p "Choose option: " choice

case $choice in
    1)
        read -p "Enter stake amount in OG [1]: " stake
        stake=${stake:-1}
        stake_amount=$((stake * 1000000))
        
        0gchaind tx staking create-validator \
          --amount=${stake_amount}ua0gi \
          --pubkey=$(0gchaind tendermint show-validator --home $HOME/.0gchain) \
          --moniker="$(0gchaind keys show $WALLET_NAME -a --home $HOME/.0gchain | head -1)" \
          --chain-id=$CHAIN_ID \
          --commission-rate=0.05 \
          --commission-max-rate=0.20 \
          --commission-max-change-rate=0.01 \
          --min-self-delegation=1 \
          --from=$WALLET_NAME \
          --gas=auto \
          --gas-adjustment=1.4 \
          --home $HOME/.0gchain -y
        ;;
    2)
        0gchaind query bank balances $(0gchaind keys show $WALLET_NAME -a --home $HOME/.0gchain) --home $HOME/.0gchain
        ;;
    3)
        valoper=$(0gchaind keys show $WALLET_NAME --bech val -a --home $HOME/.0gchain 2>/dev/null)
        if [ ! -z "$valoper" ]; then
            0gchaind query staking validator $valoper --home $HOME/.0gchain
        else
            echo "Validator not found"
        fi
        ;;
esac
EOF

    # Backup script
    cat > $TOOLS_DIR/backup.sh << 'EOF'
#!/bin/bash
BACKUP_DIR="$HOME/0g_backup_$(date +%Y%m%d_%H%M%S)"
mkdir -p $BACKUP_DIR

echo "Creating backup..."
cp $HOME/.0gchain/config/priv_validator_key.json $BACKUP_DIR/ 2>/dev/null || echo "Validator key not found"
cp $HOME/.0gchain/config/node_key.json $BACKUP_DIR/ 2>/dev/null || echo "Node key not found"
cp $HOME/.0gchain/data/priv_validator_state.json $BACKUP_DIR/ 2>/dev/null || echo "Validator state not found"

echo "Backup created in: $BACKUP_DIR"
echo "SAVE THIS FOLDER SECURELY!"
EOF

    # Auto updater
    cat > $TOOLS_DIR/update.sh << 'EOF'
#!/bin/bash
echo "Checking for updates..."
CURRENT_VERSION=$(0gchaind version 2>/dev/null)
LATEST_RELEASE_URL="https://api.github.com/repos/0glabs/0gchain-NG/releases/latest"

LATEST_INFO=$(curl -s $LATEST_RELEASE_URL)
LATEST_VERSION=$(echo $LATEST_INFO | jq -r .tag_name)

echo "Current: $CURRENT_VERSION"
echo "Latest: $LATEST_VERSION"

if [ "$CURRENT_VERSION" != "$LATEST_VERSION" ]; then
    echo "Update available!"
    read -p "Update now? (y/n): " update
    if [[ $update =~ ^[Yy]$ ]]; then
        echo "Updating..."
        sudo systemctl stop 0gd
        
        DOWNLOAD_URL=$(echo $LATEST_INFO | jq -r '.assets[] | select(.name | contains("galileo")) | .browser_download_url')
        cd $HOME
        wget -q "$DOWNLOAD_URL" -O galileo-new.tar.gz
        tar -xzf galileo-new.tar.gz
        sudo cp galileo/bin/0gchaind /usr/local/bin/
        sudo chmod +x /usr/local/bin/0gchaind
        
        sudo systemctl start 0gd
        echo "Update completed!"
        rm -rf galileo galileo-new.tar.gz
    fi
else
    echo "Already up to date!"
fi
EOF

    chmod +x $TOOLS_DIR/*.sh
    print_success "Management tools created in $TOOLS_DIR"
}

# Start node
start_node() {
    print_step "Starting node..."
    
    sudo systemctl start 0gd
    sleep 5
    
    if sudo systemctl is-active --quiet 0gd; then
        print_success "Node started successfully!"
    else
        print_error "Failed to start node"
        sudo journalctl -u 0gd -n 20 --no-pager
        exit 1
    fi
}

# Show useful info
show_info() {
    echo ""
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║                    INSTALLATION COMPLETED!                    ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    echo -e "${CYAN}🎉 0G Labs V3 Galileo Validator Setup Complete! 🎉${NC}"
    echo ""
    
    echo -e "${YELLOW}Management Tools (in $TOOLS_DIR):${NC}"
    echo "• ./monitor.sh      - Real-time node monitoring"
    echo "• ./validator.sh    - Validator management"
    echo "• ./backup.sh       - Backup validator keys"
    echo "• ./update.sh       - Check/install updates"
    echo ""
    
    echo -e "${YELLOW}Quick Commands:${NC}"
    echo "• Node logs: sudo journalctl -u 0gd -f"
    echo "• Node status: sudo systemctl status 0gd"
    echo "• Restart node: sudo systemctl restart 0gd"
    echo ""
    
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. 📊 Monitor: cd $TOOLS_DIR && ./monitor.sh"
    echo "2. 💰 Get tokens: https://faucet.0glabs.live"
    echo "3. 🎯 Create validator: ./validator.sh"
    echo "4. 💾 Backup keys: ./backup.sh"
    echo ""
    
    echo -e "${BLUE}Important Links:${NC}"
    echo "• Explorer: https://chainscan-galileo.0glabs.live"
    echo "• Faucet: https://faucet.0glabs.live"
    echo "• Discord: https://discord.gg/0glabs"
    echo ""
    
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    echo -e "${CYAN}📱 Don't forget to follow @OVER9725 on Twitter for updates!${NC}"
    echo -e "${CYAN}🔗 https://twitter.com/OVER9725${NC}"
    echo -e "${GREEN}────────────────────────────────────────────────────────${NC}"
    
    print_warning "IMPORTANT: Backup your validator keys using ./backup.sh!"
}

# Cleanup function
cleanup_temp_files() {
    [ -f "$TEMP_SCRIPT" ] && rm -f "$TEMP_SCRIPT" 2>/dev/null || true
}

# Main function
main() {
    show_banner
    
    echo -e "${BLUE}System Info:${NC}"
    echo "OS: $(lsb_release -d 2>/dev/null | cut -f2 || echo "Unknown")"
    echo "CPU: $(nproc) cores"
    echo "RAM: $(free -h | awk 'NR==2{print $2}')"
    echo "Disk: $(df -h / | awk 'NR==2{print $4}')"
    echo ""
    
    read -p "Proceed with installation? (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Installation cancelled"
        cleanup_temp_files
        exit 0
    fi
    
    check_requirements
    get_user_input
    install_dependencies
    install_go
    install_binary
    initialize_node
    configure_node
    setup_state_sync
    create_service
    create_wallet
    create_tools
    start_node
    show_info
    cleanup_temp_files
}

# Error handling with cleanup
trap 'print_error "Installation failed!"; cleanup_temp_files; exit 1' ERR

# Run main function
main "$@"
