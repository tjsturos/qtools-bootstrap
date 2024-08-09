# Quilibrium Bootstrap Tools

This repository contains scripts to help you set up, manage, and update the Quilibrium Bootstrap Client.

## Quick Start

To get started quickly, run the following command in your terminal:

```bash
curl -s https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main/init.sh | sudo bash
```

This command will download and run the initialization script with sudo privileges. The script will:
1. Set up or update the qtools-bootstrap repository in your home directory (`~/qtools-bootstrap`).
2. Set up the ceremonyclient in your home directory (`~/ceremonyclient`) if not already installed.
3. Perform necessary configurations and start the bootstrap client service.

This process works correctly even when run with sudo, ensuring all files are placed in the correct user's home directory.

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

3. Run the initialization script with sudo privileges:
   ```
   sudo bash init.sh
   ```

This will set up the ceremonyclient in `~/ceremonyclient` (if not already installed) and switch to the `v2.0-bootstrap` branch.

## Usage

After installation, you can use the following commands:

- `update-bootstrap`: Update the Quilibrium Bootstrap Client
- `manage-bootstrapclient`: Open the management menu for the Bootstrap Client

### Updating the Bootstrap Client

To update the Bootstrap Client, simply run:

```bash
sudo update-bootstrap
```

This command will check for updates and apply them if available.

To force an update without checking for changes, use the `--force` or `-f` flag:

```bash
sudo update-bootstrap --force
```

or

```bash
sudo update-bootstrap -f
```

Note: While automatic updates are set up during installation, you can always run the update command manually if you want to check for updates immediately.

### Management Menu

To access the management menu, run:

```bash
sudo manage-bootstrapclient
```

The management menu provides the following options:

1. View Service Status
2. View Live Log Output
3. Start Service
4. Stop Service
5. Restart Service
6. Check for Updates
7. View Last 50 Log Lines
8. Uninstall
9. Exit

Simply follow the on-screen prompts to manage your Bootstrap Client.

### Uninstalling

To uninstall the Quilibrium Bootstrap Client, you can either:

1. Use the management menu and select the "Uninstall" option.
2. Run the uninstall script directly:

```bash
sudo bash ~/qtools-bootstrap/uninstall.sh
```

This will remove most components of the Bootstrap Client, including the service, qtools-bootstrap repository, and cron job. However, the ceremonyclient directory will be left intact.

## Automatic Updates

The installation process sets up a cron job that checks for updates every 10 minutes. You don't need to do anything manually to keep your client up-to-date.

## Troubleshooting

If you encounter any issues:

1. Make sure you're running the scripts with sudo privileges.
2. Check the service status using the management menu.
3. View the logs for any error messages.

If problems persist, please open an issue on this GitHub repository with details about the error you're experiencing.

## Support

For additional help or questions, please open an issue on this GitHub repository.

## License

The Quilibrium Bootstrap Tools are licensed under the [MIT License](LICENSE).