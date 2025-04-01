# Win Bootstrap
 _       ___             ____              __       __                 
| |     / (_)___        / __ )____  ____  / /______/ /__________ _____ 
| | /| / / / __ \______/ __  / __ \/ __ \/ __/ ___/ __/ ___/ __ `/ __ \
| |/ |/ / / / / /_____/ /_/ / /_/ / /_/ / /_(__  ) /_/ /  / /_/ / /_/ /
|__/|__/_/_/ /_/     /_____/\____/\____/\__/____/\__/_/   \__,_/ .___/ 
                                                              /_/      

A PowerShell script for automated Windows setup and software installation.

## Features

- 🚀 One-click installation of essential software using Chocolatey
- 🛠️ Integration with WinUtil by ChrisTitus for system optimization
- 📑 Microsoft Activation Scripts (MAS) integration
- 🎨 Interactive menu-driven interface
- 📦 Pre-configured with essential software packages:
  - Development: Git, Python, Cursor IDE, Strawberry Perl
  - Productivity: Obsidian, PowerToys
  - Security: ProtonVPN, Signal
  - And more...

## Quick Start

### Direct Run (Original Script)
```powershell
iex(irm https://win.iamw.top)
```

### Run from Your Fork
```powershell
iex(irm https://raw.githubusercontent.com/yourusername/win-bootstrap/main/bootstrap.ps1)
```

## Customization

1. Fork this repository
2. Edit `bootstrap.ps1`
3. Modify the `$appsToInstall` array to customize your software list:
```powershell
$appsToInstall = @(
    "app1",
    "app2",
    "app3"
    # Add or remove apps as needed
)
```

## Requirements

- Windows 10/11
- Administrator privileges
- Internet connection

## Running the Script

1. Open PowerShell as Administrator
2. Run the script using one of the Quick Start commands above
3. Choose from the menu options:
   - 1️⃣ WinUtil - System optimization tools
   - 2️⃣ Microsoft Activation Scripts
   - 3️⃣ Chocolatey & Apps installation
   - 0️⃣ Exit

## Finding Chocolatey Packages

To find available packages for your customization:
1. Visit [Chocolatey Package Repository](https://community.chocolatey.org/packages)
2. Search for your desired software
3. Use the package ID in your `$appsToInstall` array

## License

MIT License

## Contributing

1. Fork the repository
2. Create your feature branch
3. Commit your changes
4. Push to the branch
5. Create a new Pull Request 