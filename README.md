# 🖥️ Tidbyt Base NFT Display

Display your Base network NFTs on your Tidbyt device with style! This app fetches NFTs from your Base L2 wallet and creates an engaging display that rotates through your collection.

![Tidbyt Display Example](assets/preview.png)

## ✨ Features

- 🎨 Display NFTs from Base blockchain
- 🔄 Auto-rotate through your NFT collection
- 🖼️ Show NFT images and metadata
- ⚡ Real-time updates every 10 seconds
- 🔐 Secure configuration handling
- 🎯 Error handling and validation

## 📋 Prerequisites

Before you begin, ensure you have:
- 📱 A Tidbyt device
- 🛠️ [Pixlet](https://tidbyt.dev/docs/build/installing-pixlet) installed
- 🔑 An Alchemy API key
- 👛 A Base wallet with NFTs
- 🔧 `jq` command-line tool

## 🚀 Quick Start

1. **Clone the repository:**
```bash
git clone https://github.com/ASTM79/tidbyt-base-nft-display-public.git
cd tidbyt-base-nft-display-public
```

2. **Set up configuration:**
```bash
cp config.template.json config.json
nano config.json  # Edit with your credentials
```

3. **Make the update script executable:**
```bash
chmod +x update.sh
```

4. **Run the display:**
```bash
./update.sh
```

## 🔧 Configuration

Create your `config.json` from the template and fill in:

```json
{
    "wallet_address": "YOUR_WALLET_ADDRESS",
    "alchemy_api_key": "YOUR_ALCHEMY_API_KEY",
    "tidbyt": {
        "device_id": "YOUR_DEVICE_ID",
        "api_token": "YOUR_TIDBYT_API_TOKEN",
        "update_interval": 10
    }
}
```

## 📁 Project Structure

- `new_nft_display.star` - Main Tidbyt app code
- `update.sh` - Display update script
- `config.template.json` - Configuration template
- `.gitignore` - Git ignore rules

## 🔒 Security

This project takes security seriously:
- ✅ Uses config templates to avoid credential exposure
- ✅ Gitignore prevents sensitive file commits
- ✅ Comprehensive input validation
- ✅ Error handling for API failures

## 🛠️ Installation

### macOS
```bash
# Install Homebrew if needed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install required tools
brew install jq
brew install pixlet
```

### Linux (Ubuntu/Debian)
```bash
# Install required tools
sudo apt-get update
sudo apt-get install jq
```

## 🔍 Troubleshooting

Common issues and solutions:

1. **No NFTs displaying:**
   - Verify wallet address is correct
   - Check Alchemy API key permissions
   - Ensure wallet has NFTs on Base network

2. **Update script errors:**
   - Verify Tidbyt API token
   - Check device ID
   - Ensure pixlet is installed correctly

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request. For major changes, please open an issue first to discuss what you would like to change.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Tidbyt team for their amazing platform
- Base blockchain for NFT support
- Alchemy for their robust API

## 📞 Support

If you're having issues, please:
1. Check the troubleshooting guide
2. Open an issue with detailed information
3. Join our community discussions

## 🔮 Future Plans

- [ ] Support for multiple wallets
- [ ] Custom display layouts
- [ ] Animation options
- [ ] NFT metadata filtering
- [ ] Advanced image processing