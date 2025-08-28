# debian-nvidia-installer

NVIDIA driver installer with a Bash TUI. This tool allows you to install NVIDIA drivers on Debian using an interactive text-based interface (TUI).
It automates steps such as package installation, compatibility checks, and graphics environment configuration.

<img src="data/screenshots/main-menu.png">

<div style="display:flex; gap:10px;">
  <img src="data/screenshots/drivers-menu.png" width="394" height="266">
  <img src="data/screenshots/post-installation-menu.png" width="394" height="266">
</div>

### Requirements

* Debian Trixie distribution
* 64-bit architecture
* Compatible NVIDIA graphics card
  > Official NVIDIA drivers on Debian Trixie do not support [GPUs based on the Fermi or Kepler architecture](https://www.nvidia.com/en-us/drivers/unix/legacy-gpu/).
  
  > See [Debian’s guide on installing legacy drivers](https://wiki.debian.org/NvidiaGraphicsDrivers#Tesla_Drivers) if needed.
* Bash-compatible shell
* Administrator privileges (sudo/root)

# How to Run

After installation, you can start the script through the shortcut in the applications menu or via the terminal by running the command:

```bash
sudo debian-nvidia-installer
```
> ⚠️ **It is necessary to run as root**, as the tool makes system changes such as installing packages and modifying configuration files.

# Installation

You can install `debian-nvidia-installer` by downloading the `.deb` package from the **[Releases](https://github.com/devleonardoamaral/debian-nvidia-installer/releases)** section of this repository.

### Option 1: Graphical Interface (GUI)

1. Download the script’s `.deb` file.  
2. **Double-click** the file to open it in your system’s package manager.  
3. Click **“Install”**. You may be asked to enter your administrator password.  

> 💡 Compatible with package managers like **GDebi**, **Discover** (KDE), **GNOME Software**, and similar tools.

### Option 2: Terminal

Before you start, **check the version of the script you downloaded from GitHub**.
Replace `X.X.X` in the commands below with the correct version.
For example, if the version is `0.0.1`, the file will be `debian-nvidia-installer_0.0.1.deb`.

> ⚠️ **Important:** do not install the file directly from the download location. Always move it to the temporary directory (`/tmp`) to avoid permission issues.

#### Step 1 – Move the file to the temporary directory

```bash
mv ./debian-nvidia-installer_X.X.X.deb /tmp/
```

This moves the `.deb` file to `/tmp`, which is safe for installing packages without special permissions.

#### Step 2 – Enter the temporary directory

```bash
cd /tmp
```

The `cd` command means “change directory.” Here you enter the `/tmp` folder where the file was moved.

#### Step 3 – Install the package

```bash
sudo apt install ./debian-nvidia-installer_X.X.X.deb
```

#### Step 4 – Clean up the file after installation (optional)

```bash
rm ./debian-nvidia-installer_X.X.X.deb
```

This removes the `.deb` file, which is no longer needed. It’s optional because all files in `/tmp` are deleted after a system restart.

### Option 3: Build and Install Manually (for Advanced Users)

#### Step 1 – Clone the repository

```bash
git clone https://github.com/devleonardoamaral/debian-nvidia-installer.git
```

This creates a local copy of the repository on your computer.

#### Step 2 – Build the `.deb` package

```bash
dpkg-deb --build --root-owner-group debian-nvidia-installer
```

* Creates the `.deb` file from the repository folder.
* `--root-owner-group` ensures the file permissions are compatible with the system.

#### Step 3 – Install the package

Use the same steps as [Option 1: Graphical Interface (GUI)](#option-1-graphical-interface-gui) or [Option 2: Terminal](#option-2-terminal). The generated file, `debian-nvidia-installer.deb`, **does not include the version number**.


# Uninstallation

```bash
sudo apt purge --autoremove debian-nvidia-installer
```

* `sudo` runs the command as administrator.
* `apt purge` removes the package completely, including its configuration files.
* `--autoremove` also removes any dependencies that are no longer needed.

---

Para a versão em **Português do Brasil**, veja [README.pt_BR.md](README.pt_BR.md)
