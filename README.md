# Quilibrium Bootstrap Tools

This repository contains scripts to help you set up, manage, and update the Quilibrium Bootstrap Client.

## Quick Start

To get started quickly, run the following command in your terminal:

```bash
bash <(curl -s https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main/init.sh)
```

This command will download the entire repository and run the initialization script, which sets up everything you need.

## Usage

After installation, you can use the following commands:

- `update-bootstrap`: Update the Quilibrium Bootstrap Client
- `manage-bootstrapclient`: Open the management menu for the Bootstrap Client

### Updating the Bootstrap Client

To update the Bootstrap Client, simply run:

```bash
update-bootstrap
```

This command will check for updates and apply them if available. If you want to force the update without checking for new versions, you can use the `-f` or `--force` flag:

```bash
update-bootstrap -f
```

### Management Menu

To access the management menu, run:

```bash
manage-bootstrapclient
```

The management menu provides the following options:

1. View Service Status
2. View Live Log Output
3. Start Service
4. Stop Service
5. Restart Service
6. Check for Updates
7. View Last 50 Log Lines
8. Exit

Simply follow the on-screen prompts to manage your Bootstrap Client.

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