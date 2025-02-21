# Docker-Workspaces
Installation Directives for Docker
## Windows
### Prequest
* Virtualization enabled in BIOS
* Windows Subsystem for Linux 2 (WSL 2) enabled (recommended)

### Windows Subsystem for Linux (WSL) Installation
* Open PowerShell or Windows Command Prompt in administrator mode by right-clicking and selecting "Run as administrator". Run the following command.

```PowerShell
wsl --install
```
* To open wsl you have to install Linux Distribution.
* To install distrubition, enter:
```powershell
 wsl --install -d <Distribution Name>
``` 
* Replace <Distribution Name> with the name of the distribution you would like to install.
* Or you can install Distribution from Windows Store.
* For upgrade wsl 1 to wsl 2 follow the steps.
``` powershell
wsl.exe --set-version (distribution name) 2
wsl.exe --set-default-version 2
```

* For more about WSL installation you can visit [miscrosoft learn](https://learn.microsoft.com/en-us/windows/wsl/install).
* If you have encountered problem with installation of wsl you can follow orders in [Microsoft Manual installation for older versions of WSL](https://learn.microsoft.com/en-us/windows/wsl/install-manual). 

### WSL 2 Upgrade

  
### Docker Installation
1. Install WSL with at least version 1.1.3.0.
2. Download Docker Desktop for Windows from offical [website](https://www.docker.com/get-started/).
3. Run the installer (Docker Desktop Installer.exe)
4. Follow the usual installation instructions to install Docker Desktop. Depending on which version of Windows you are using, Docker Desktop may prompt you to turn on WSL 2 during installation. Read the information displayed on the screen and turn on the WSL 2 feature to continue.
5. Start Docker Desktop from the Windows Start menu.
6. Navigate to Settings.
7. From the General tab, select Use WSL 2 based engine.. If you have installed Docker Desktop on a system that supports WSL 2, this option is turned on by default.
8. Select Apply & Restart.
9. For further information you can visit offical [docker website](https://docs.docker.com/desktop/features/wsl/).
    

