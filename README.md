# Systemd-boot Configuration Generator

This script automatically generates systemd-boot configuration files for installed Linux kernels on Arch Linux systems.

## Features

- Automatically detects installed kernels
- Generates configuration files for each kernel, including fallback images if present
- Removes configuration files for non-existent kernels
- Updates existing configuration files only if necessary
- Supports various filesystems, with special handling for Btrfs subvolumes

## Usage

1. Clone this repository:
   ```
   git clone https://github.com/yourusername/systemd-boot-config-generator.git
   ```

2. Make the script executable:
   ```
   chmod +x generate-systemd-boot-config.sh
   ```

3. Run the script with root privileges:
   ```
   sudo ./generate-systemd-boot-config.sh
   ```

## Requirements

- Arch Linux or compatible distribution
- systemd-boot as the bootloader
- Root privileges to run the script

## Configuration

The script uses the following directories by default:
- `/boot/loader/entries` for systemd-boot configuration files
- `/boot` for kernel and initramfs images

If your system uses different locations, you can modify the `CONFIG_DIR` and `KERNEL_DIR` variables at the beginning of the script.

## How It Works

1. The script first removes any configuration files for kernels that are no longer present in the system.
2. It then scans the `/boot` directory for installed kernels.
3. For each kernel found, it generates a configuration file with the appropriate options based on your system's configuration.
4. If a fallback initramfs image exists for a kernel, a separate configuration file is generated for it.
5. Existing configuration files are only updated if the options have changed.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
```
