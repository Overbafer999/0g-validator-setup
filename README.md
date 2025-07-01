# 0G Labs V3 Galileo Validator Setup

<div align="center">

```
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
```

**🚀 Automated 0G Labs Testnet V3 Galileo Validator Setup**

[![Twitter](https://img.shields.io/twitter/follow/OVER9725?style=social)](https://twitter.com/OVER9725)
[![GitHub Stars](https://img.shields.io/github/stars/Ovebafer999/0g-validator-setup)](https://github.com/Ovebafer999/0g-validator-setup)

</div>

## ⚡ Quick Install

```bash
curl -s https://raw.githubusercontent.com/Ovebafer999/0g-validator-setup/main/install.sh | bash
```

## 📋 What This Script Does

✅ **Auto-installs everything:**
- 0G Node + Dependencies
- Wallet creation/recovery
- Fast sync setup
- Monitoring tools
- Auto-update system
- Backup utilities

✅ **Includes management tools:**
- Real-time node monitor
- Validator manager
- Alert system (Telegram/Discord)
- Auto-updater
- Backup/restore tools

## 🖥️ System Requirements

| Component | Requirement |
|-----------|-------------|
| **OS** | Ubuntu 20.04+ |
| **CPU** | 8 cores |
| **RAM** | 64 GB |
| **Storage** | 1 TB NVMe SSD |
| **Network** | 100 Mbps |

## 🎯 Network Info

- **Chain ID:** `16601`
- **Token:** `OG`
- **RPC:** https://evmrpc-testnet.0glabs.live
- **Explorer:** https://chainscan-galileo.0glabs.live
- **Faucet:** https://faucet.0glabs.live

## 🛠️ After Installation

**Monitor your node:**
```bash
cd ~/0g-tools && ./monitor_node.sh
```

**Create validator:**
```bash
./validator_manager.sh
```

**Setup alerts:**
```bash
./auto_update.sh --setup
```

## 📱 Get Test Tokens

1. Go to [0G Faucet](https://faucet.0glabs.live)
2. Enter your EVM address (shown after wallet creation)
3. Request 0.1 OG tokens

## 🔧 Manual Commands

**Check node status:**
```bash
sudo systemctl status 0gd
curl -s localhost:26657/status | jq .result.sync_info.catching_up
```

**Check logs:**
```bash
sudo journalctl -u 0gd -f
```

**Create validator:**
```bash
0gchaind tx staking create-validator \
  --amount=1000000ua0gi \
  --pubkey=$(0gchaind tendermint show-validator --home $HOME/.0gchain) \
  --moniker="YOUR_MONIKER" \
  --chain-id=16601 \
  --commission-rate=0.05 \
  --commission-max-rate=0.20 \
  --commission-max-change-rate=0.01 \
  --min-self-delegation=1 \
  --from=wallet \
  --gas=auto \
  --gas-adjustment=1.4 \
  --home $HOME/.0gchain -y
```

## 🔗 Useful Links

- **Documentation:** https://docs.0g.ai
- **Discord:** https://discord.gg/0glabs
- **Twitter:** https://twitter.com/0G_labs
- **GitHub:** https://github.com/0glabs

## 🐛 Troubleshooting

**Node not syncing?**
```bash
sudo systemctl restart 0gd
```

**Need help?**
- [GitHub Issues](https://github.com/Ovebafer999/0g-validator-setup/issues)
- [Discord Support](https://discord.gg/0glabs)

## ⚠️ Important

- **Backup your keys!** Run `./backup_validator.sh`
- **Keep your server secure**
- **Monitor your node regularly**

---

<div align="center">

**Created by [OveR](https://twitter.com/OVER9725)**

Don't forget to follow [@OVER9725](https://twitter.com/OVER9725) for updates! ⭐

</div>
