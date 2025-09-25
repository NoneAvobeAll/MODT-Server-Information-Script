<<<<<<< HEAD
# MODT-Server-Information-Script
A bash script that provides comprehensive server information and status display for Linux systems. This script generates a Message of the Day (MOTD) with detailed system metrics and health information.
=======
# MODT Server Information Script

A bash script that provides comprehensive server information and status display for Linux systems. This script generates a Message of the Day (MOTD) with detailed system metrics and health information.

## Features

- System Information Display
  - Hostname and OS details
  - Kernel version
  - System uptime
  - CPU information and usage
  - Memory utilization
  - Disk space usage
  - Network status and information
  - Running services status
  - System load averages

## Requirements

- Linux-based operating system
- Bash shell
- Root/sudo privileges for some system information
- Common system utilities:
  - `top`
  - `free`
  - `df`
  - `uptime`
  - `ifconfig`/`ip`
  - `systemctl`

## Installation

1. Clone this repository:
   ```bash
   git clone [repository-url]
   ```

2. Make the script executable:
   ```bash
   chmod +x MODT-ServerINFO.sh
   ```

## Usage

Run the script with root privileges:

```bash
sudo ./MODT-ServerINFO.sh
```

The script will display comprehensive system information that can be used as a Message of the Day or for system monitoring purposes.

## Output Example

The script outputs information including but not limited to:
- System hostname and OS version
- Current system time and uptime
- CPU usage and load averages
- Memory usage statistics
- Disk space utilization
- Network interface information
- Critical service status

## Customization

You can modify the script to:
- Add or remove information sections
- Adjust formatting and colors
- Change update intervals
- Customize threshold warnings
- Add additional system metrics

## Contributing

Feel free to fork this repository and submit pull requests for any improvements or additional features.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Author

NoneAvobeAll

## Support

For support, please open an issue in the repository's issue tracker.
>>>>>>> development
