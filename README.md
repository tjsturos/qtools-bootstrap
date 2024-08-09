# Quilibrium Bootstrap Tools

This repository contains scripts to help you set up, manage, and update the Quilibrium Bootstrap Client.

## Quick Start

To get started quickly, run the following command in your terminal:

```
bash <(curl -s https://raw.githubusercontent.com/tjsturos/qtools-bootstrap/main/init.sh)
```

This command will download and run the initialization script, which sets up everything you need.

## Manual Setup

If you prefer to set up the Bootstrap Client manually, you can follow these steps:

1. Clone the repository: `git clone https://github.com/tjsturos/qtools-bootstrap`
2. Change into the cloned directory: `cd qtools-bootstrap`
3. Run the initialization script: `bash init.sh`

## Managing the Bootstrap Client

Once the Bootstrap Client is set up, you can manage it using the `manage-bootstrapclient.sh` script. This script provides a menu-driven interface for:

* Viewing service status
* Viewing live log output
* Starting the service
* Stopping the service
* Restarting the service
* Checking for updates
* Viewing the last 50 log lines

To run the management script, use the following command:

```
bash manage-bootstrapclient.sh
```

## Updating the Bootstrap Client

The Bootstrap Client will automatically check for updates every 10 minutes. If an update is available, it will be applied automatically.

You can also manually check for updates and apply them using the following command:

```
bash update-bootstrap.sh
```

## Troubleshooting

If you encounter any issues with the Bootstrap Client or the management script, you can view the log files for troubleshooting purposes. The log files are located in the `/var/log/bootstrapclient` directory.

## Contributing

Contributions are welcome! If you find any issues or have suggestions for improvements, please open an issue or submit a pull request on the GitHub repository.

## License

The Quilibrium Bootstrap Tools are licensed under the [MIT License](LICENSE).