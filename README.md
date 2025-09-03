# NeoChange.nvim

A Neovim plugin for seamless configuration branch switching with an interactive floating window interface.

## ✨ Features

- 🎨 **Interactive Floating Window** - Beautiful branch selector with vim-like navigation
- ⚡ **Direct Branch Switching** - Quick switching with tab completion  
- 🔄 **Automatic Reload** - Configuration reloads automatically after branch switch
- 👁️ **Visual Indicators** - Current branch clearly marked with ● symbol
- 🛠️ **Zero Configuration** - Works out of the box

## 📦 Installation

### Requirements

- Neovim 0.7+ with Lua support
- Git repository in your config directory
- Multiple configuration branches

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  "rizukirr/neochange.nvim"
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use 'rizukirr/neochange.nvim'
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'rizukirr/neochange.nvim'
```

## 🎯 Usage

### Interactive Branch Selector
```vim
:NeoChange
```
Opens a floating window with all available branches.

**Controls:**
- `j` / `↓` - Move down
- `k` / `↑` - Move up  
- `Enter` / `Space` - Select branch
- `q` / `Esc` - Close window

### Direct Branch Switching
```vim
:NeoChange python-nvim
```
Switches directly to the specified branch with tab completion.

## 🏗️ Setup Example

Structure your Neovim config as a git repository:

```
~/.config/nvim/
├── init.lua
├── lua/
│   ├── config/
│   └── plugins/
└── .git/
```

Create different branches for different configurations:

```bash
# Create branches for different setups
git checkout -b python-nvim    # Python development config
git checkout -b cpp-nvim       # C++ development config  
git checkout -b minimal        # Lightweight config

# Use NeoChange to switch between them
:NeoChange python-nvim
```

## ⚙️ Configuration

**No configuration required!** NeoChange works automatically after installation.

The plugin auto-loads and registers the `:NeoChange` command when Neovim starts.

## 📖 Documentation

Complete documentation is available within Neovim:

```vim
:h neochange
```

## 🤝 Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

### Development Setup

```bash
git clone https://github.com/rizukirr/neochange.nvim
cd neochange.nvim
make setup        # Set up development environment
make ci           # Run all CI checks (format, lint, test)
```

### Development Commands

- `make setup` - Set up development environment with all dependencies
- `make test` - Run all tests using plenary.nvim
- `make test-watch` - Run tests in watch mode (requires entr)
- `make lint` - Run luacheck linter on lua/ and tests/
- `make format` - Format code with stylua
- `make format-check` - Check code formatting without changes
- `make install-dev` - Install development dependencies (plenary.nvim)
- `make ci` - Run complete CI suite (format-check, lint, test)
- `make clean` - Clean up cache files

## 🐛 Issues & Support

- 📋 [Report Issues](https://github.com/rizukirr/neochange.nvim/issues)
- 💬 [Discussions](https://github.com/rizukirr/neochange.nvim/discussions)
- 📖 Documentation: `:h neochange`

## 📜 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for easy configuration management
- Built with love for the Neovim community
- Thanks to all contributors!

---

⭐ **Star this repository if you find it useful!**
