<div align="center">

# ClassicPanel

**The old Control Panel, back. One fast, searchable launcher.**

![PowerShell](https://img.shields.io/badge/PowerShell-5.1%2B-5391FE?logo=powershell&logoColor=white)
![Windows](https://img.shields.io/badge/Windows-10%20%7C%2011-0078D4?logo=windows&logoColor=white)
![License](https://img.shields.io/badge/license-MIT-green)
![Dependencies](https://img.shields.io/badge/dependencies-none-brightgreen)

<!-- Add a screenshot: docs/screenshot.png -->
<!-- ![ClassicPanel](docs/screenshot.png) -->

</div>

Windows keeps hiding the good stuff behind Settings. **ClassicPanel** is to the Control Panel what Start8 was to the Start menu: one dark, searchable window with 50+ classic applets and admin consoles, grouped and one click away. Printers, network adapters, services, Device Manager and more, the old way.

## Features

- 50+ classic tools in 8 categories, with live search
- Printer toolkit: Devices and Printers, Add Printer wizard, Print Server Properties, Print Management, **Restart Spooler** and **Clear Print Queue** in one click
- Admin consoles: Computer Management, Services, Event Viewer, Disk Management, Group Policy, Registry
- Asks for admin only when a tool needs it
- Keyboard friendly: `Ctrl+F` search, `Enter` opens first result, `Esc` closes
- Single file, no modules, no dependencies, high-DPI aware
- Optional Start Menu and Desktop shortcut

## Quick start

```powershell
git clone https://github.com/<your-username>/ClassicPanel.git
cd ClassicPanel
powershell -ExecutionPolicy Bypass -File .\ClassicPanel.ps1
```

Install shortcuts (then just search "ClassicPanel" in Start):

```powershell
.\ClassicPanel.ps1 -Install
.\ClassicPanel.ps1 -Uninstall   # remove them
```

## Categories

| Category | Examples |
|---|---|
| Printers & Devices | Devices and Printers, Add Printer, Print Server Properties, Restart Spooler, Clear Queue, Device Manager |
| System | System Properties, Power Options, Date and Time, Region, Fonts, Troubleshooting |
| Network | Network Connections, Sharing Center, Firewall, Internet Options, Remote Desktop |
| Admin Tools | Computer Management, Services, Event Viewer, Task Scheduler, Disk Management, Group Policy, Registry |
| Apps & Features | Programs and Features, Windows Features, Outlook mail profiles |
| Hardware & Sound | Sound, Mouse, Keyboard, Game Controllers, Color Management |
| Accounts & Security | netplwiz, Credential Manager, Security and Maintenance, Certificates, Backup and Restore |
| Classic Panels | Classic Control Panel, All Items (God Mode) |

## Add your own tools

Open `ClassicPanel.ps1` and add a line to the `$Items` list:

```powershell
# Category, Name, Description, Exe, Args, NeedsAdmin
@('Admin Tools','My Tool','What it does','mytool.exe','--flag',$false),
```

## Notes

- Some consoles (Group Policy, Local Users and Groups, Print Management) only exist on Windows Pro/Enterprise.
- If scripts are blocked, use the `-ExecutionPolicy Bypass` form above.

## License

MIT
