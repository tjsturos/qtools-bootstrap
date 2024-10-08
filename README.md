# Quilibrium Bootstrap Tools

This repository contains scripts to help you set up, manage, and update the Quilibrium Bootstrap Client.

## Prerequisites

- Ubuntu 20.04 LTS or later
- Git
- Sudo privileges for current user

The script will automatically install Go 1.22.4 if it's not already present on your system. This is done using the `install-go.sh` script, which is part of the qtools-bootstrap repository.

## Quick Start

To get started quickly, run the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main/init.sh | bash
```

This command will download and run the initialization script. The script will:
1. Set up or update the qtools-bootstrap repository in your home directory (`~/qtools-bootstrap`).
2. Install Go 1.22.4 if it's not already installed.
3. Set up the ceremonyclient in your home directory (`~/ceremonyclient`) if not already installed.
4. Build the bootstrap node.
5. Set up a cron job for the current user to check for updates every 10 minutes.
6. Perform necessary configurations and start the bootstrap client service.
7. Set up auto-completion for the `manage-bootstrap` command.

This process will prompt for sudo privileges when needed, ensuring all files are placed in the correct user's home directory and the cron job is set up for the appropriate user.

## Manual Setup

If you prefer to set things up manually, follow these steps:

1. Clone this repository:
   ```
   git clone https://github.com/tjsturos/qtools-bootstrap.git ~/qtools-bootstrap
   ```

2. Navigate to the cloned directory:
   ```
   cd ~/qtools-bootstrap
   ```

3. Run the initialization script:
   ```
   bash init.sh
   ```

This will set up the ceremonyclient in `~/ceremonyclient` (if not already installed) and switch to the `v2.0-bootstrap` branch.

## Usage

The `manage-bootstrap` script provides an interactive menu for managing the Quilibrium Bootstrap Client. To use it:

1. Run the script: `manage-bootstrap`
2. You'll see a menu with various options. Enter the number or letter corresponding to the action you want to perform.
3. To exit the script, you can either:
   - Select option 9 from the menu
   - Press 'q' or 'Q' at any time
   - Press Ctrl+C at any time

The script responds immediately to your input without requiring you to press Enter.

The script also supports direct command-line arguments for quick actions:

```bash
manage-bootstrap <command>
```

Where `<command>` can be:
- `status`: View service status
- `log`: View live log output
- `start`: Start the service
- `stop`: Stop the service
- `restart`: Restart the service
- `update`: Check for updates
- `lastlog`: View last 50 log lines
- `uninstall`: Uninstall the service

Bash completion is available for these command-line arguments. It is automatically set up during installation. If you need to use it immediately after installation without restarting your shell, run:

```bash
source ~/.bashrc
```

### Updating the Bootstrap Client

To update the Bootstrap Client, simply run:

```bash
update-bootstrap
```

This command will check for updates and apply them if available.

To force an update without checking for changes, use the `--force` or `-f` flag:

```bash
update-bootstrap --force
```

or

```bash
update-bootstrap -f
```

Note: While automatic updates are set up during installation, you can always run the update command manually if you want to check for updates immediately.

### Uninstalling

To uninstall the Bootstrap Client, you can use the management menu or run the uninstall script directly:

```bash
bash ~/qtools-bootstrap/uninstall.sh
```

The uninstallation process will ask you which components you want to remove, allowing you to keep certain parts of the setup if desired. This includes:

- The qtools-bootstrap repository
- The ceremonyclient directory
- The systemd service
- Cron jobs
- Aliases (manage-bootstrap and update-bootstrap)
- Auto-completion for manage-bootstrap

You can choose to remove any combination of these components. The auto-completion for manage-bootstrap will be automatically removed if you choose to remove either the qtools-bootstrap repository or the aliases. If you keep both the repository and the aliases, you'll be given a separate option to remove the auto-completion.

## Automatic Updates

The installation process sets up a cron job that checks for updates every 10 minutes. You don't need to do anything manually to keep your client up-to-date.

## Troubleshooting

If you encounter any issues:

1. Make sure you have sudo privileges on your system.
2. Check the service status using the management menu.
3. View the logs for any error messages.

If problems persist, please open an issue on this GitHub repository with details about the error you're experiencing.

## Support

For additional help or questions, please open an issue on this GitHub repository.

## License

The Quilibrium Bootstrap Tools are licensed under the [MIT License](LICENSE).