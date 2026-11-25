<#
.SYNOPSIS
    ClassicPanel - brings the old Control Panel and admin tools back, in one fast launcher.

.DESCRIPTION
    A dark, searchable launcher for the classic Windows Control Panel applets,
    printer tools and MMC admin consoles that Windows keeps burying in Settings.

.PARAMETER Install
    Creates Start Menu and Desktop shortcuts.

.PARAMETER Uninstall
    Removes those shortcuts.

.EXAMPLE
    .\ClassicPanel.ps1
    .\ClassicPanel.ps1 -Install
#>
[CmdletBinding()]
param(
    [switch]$Install,
    [switch]$Uninstall
)

$ScriptPath = $MyInvocation.MyCommand.Path
$Version    = '1.0.0'

# ---------- shortcuts ----------
$StartLink   = Join-Path ([Environment]::GetFolderPath('Programs')) 'ClassicPanel.lnk'
$DesktopLink = Join-Path ([Environment]::GetFolderPath('Desktop'))  'ClassicPanel.lnk'

if ($Install) {
    $ws = New-Object -ComObject WScript.Shell
    foreach ($p in $StartLink, $DesktopLink) {
        $s = $ws.CreateShortcut($p)
        $s.TargetPath   = "$env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe"
        $s.Arguments    = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$ScriptPath`""
        $s.IconLocation = "$env:SystemRoot\System32\control.exe,0"
        $s.Description  = 'ClassicPanel - the old Control Panel, back'
        $s.Save()
    }
    Write-Host 'Installed. Search "ClassicPanel" in the Start menu.' -ForegroundColor Green
    return
}
if ($Uninstall) {
    Remove-Item $StartLink, $DesktopLink -Force -ErrorAction SilentlyContinue
    Write-Host 'Shortcuts removed.' -ForegroundColor Yellow
    return
}

# ---------- setup ----------
Add-Type -AssemblyName System.Windows.Forms, System.Drawing
Add-Type -TypeDefinition @'
using System.Runtime.InteropServices;
public static class CPDpi { [DllImport("user32.dll")] public static extern bool SetProcessDPIAware(); }
'@
[void][CPDpi]::SetProcessDPIAware()
[System.Windows.Forms.Application]::EnableVisualStyles()

$IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(
    [Security.Principal.WindowsBuiltInRole]::Administrator)

function Get-Color($hex) { [System.Drawing.ColorTranslator]::FromHtml($hex) }

$Bg      = Get-Color '#15171C'
$Side    = Get-Color '#1B1E25'
$TileBg  = Get-Color '#242832'
$TileHot = Get-Color '#2F3542'
$Text    = Get-Color '#E8EAED'
$Muted   = Get-Color '#9AA0A6'

$Accent = @{
    'Printers & Devices' = '#4C9AFF'
    'System'             = '#A78BFA'
    'Network'            = '#34D399'
    'Admin Tools'        = '#F59E0B'
    'Apps & Features'    = '#F472B6'
    'Hardware & Sound'   = '#22D3EE'
    'Accounts & Security'= '#F87171'
    'Classic Panels'     = '#9AA0A6'
}

# ---------- tools: Category, Name, Description, Exe, Args, NeedsAdmin ----------
$Items = @(
    # Printers & Devices
    @('Printers & Devices','Devices and Printers','Classic printers, scanners and devices view','control.exe','printers',$false),
    @('Printers & Devices','Add Printer Wizard','Install a network or local printer the old way','rundll32.exe','printui.dll,PrintUIEntry /il',$false),
    @('Printers & Devices','Print Server Properties','Drivers, ports and forms for all printers','printui.exe','/s /t2',$false),
    @('Printers & Devices','Print Management','Manage printers, drivers and queues (Pro/Enterprise)','printmanagement.msc','',$false),
    @('Printers & Devices','Printer Migration','Export or import printers and drivers','printbrmui.exe','',$false),
    @('Printers & Devices','Restart Print Spooler','Fixes most stuck printing problems','powershell.exe','-NoProfile -Command "Restart-Service Spooler -Force; Write-Host Spooler restarted; Start-Sleep 2"',$true),
    @('Printers & Devices','Clear Print Queue','Stops spooler, deletes stuck jobs, restarts it','powershell.exe','-NoProfile -Command "Stop-Service Spooler -Force; Remove-Item $env:SystemRoot\System32\spool\PRINTERS\* -Force -ErrorAction SilentlyContinue; Start-Service Spooler; Write-Host Queue cleared; Start-Sleep 2"',$true),
    @('Printers & Devices','Device Manager','Drivers and hardware status','devmgmt.msc','',$false),

    # System
    @('System','System Properties','Computer name, domain, hardware profile','sysdm.cpl','',$false),
    @('System','Advanced System Settings','Environment variables, startup and recovery','SystemPropertiesAdvanced.exe','',$false),
    @('System','Performance Options','Visual effects, virtual memory','SystemPropertiesPerformance.exe','',$false),
    @('System','Remote Settings','Remote Desktop and Remote Assistance','SystemPropertiesRemote.exe','',$false),
    @('System','System Information','Full hardware and software report','msinfo32.exe','',$false),
    @('System','Power Options','Classic power plans','powercfg.cpl','',$false),
    @('System','Date and Time','Clock, time zone, internet time','timedate.cpl','',$false),
    @('System','Region','Formats, locations, administrative language','intl.cpl','',$false),
    @('System','Fonts','Installed fonts','control.exe','fonts',$false),
    @('System','Disk Cleanup','Free up disk space','cleanmgr.exe','',$false),
    @('System','Troubleshooting','Built-in troubleshooters','control.exe','/name Microsoft.Troubleshooting',$false),

    # Network
    @('Network','Network Connections','Adapters - the old ncpa.cpl view','ncpa.cpl','',$false),
    @('Network','Network and Sharing Center','Classic network overview','control.exe','/name Microsoft.NetworkAndSharingCenter',$false),
    @('Network','Windows Firewall','Basic firewall settings','firewall.cpl','',$false),
    @('Network','Firewall (Advanced)','Inbound and outbound rules','wf.msc','',$false),
    @('Network','Internet Options','Proxy, security zones, certificates','inetcpl.cpl','',$false),
    @('Network','Remote Desktop Connection','Connect to another PC','mstsc.exe','',$false),
    @('Network','Shared Folders','Shares, sessions and open files','fsmgmt.msc','',$false),

    # Admin Tools
    @('Admin Tools','Computer Management','Everything in one console','compmgmt.msc','',$false),
    @('Admin Tools','Services','Start, stop and configure services','services.msc','',$false),
    @('Admin Tools','Event Viewer','System and application logs','eventvwr.msc','',$false),
    @('Admin Tools','Task Scheduler','Scheduled tasks','taskschd.msc','',$false),
    @('Admin Tools','Disk Management','Partitions and volumes','diskmgmt.msc','',$false),
    @('Admin Tools','Local Users and Groups','Local accounts (Pro/Enterprise)','lusrmgr.msc','',$false),
    @('Admin Tools','Group Policy Editor','Local policy (Pro/Enterprise)','gpedit.msc','',$false),
    @('Admin Tools','Local Security Policy','Password, audit and user rights policy','secpol.msc','',$false),
    @('Admin Tools','Resource Monitor','CPU, memory, disk, network in detail','resmon.exe','',$false),
    @('Admin Tools','Registry Editor','Edit the registry','regedit.exe','',$true),
    @('Admin Tools','ODBC Data Sources','64-bit ODBC administrator','odbcad32.exe','',$false),
    @('Admin Tools','Windows Tools','Administrative Tools folder','control.exe','admintools',$false),

    # Apps & Features
    @('Apps & Features','Programs and Features','Uninstall or change programs','appwiz.cpl','',$false),
    @('Apps & Features','Windows Features','Turn Windows features on or off','optionalfeatures.exe','',$false),
    @('Apps & Features','Mail (Outlook Profiles)','Classic Outlook mail profiles','control.exe','mlcfg32.cpl',$false),

    # Hardware & Sound
    @('Hardware & Sound','Sound','Playback, recording, sounds','mmsys.cpl','',$false),
    @('Hardware & Sound','Mouse','Pointer and button settings','main.cpl','',$false),
    @('Hardware & Sound','Keyboard','Repeat delay and rate','control.exe','keyboard',$false),
    @('Hardware & Sound','Game Controllers','Calibrate and test controllers','joy.cpl','',$false),
    @('Hardware & Sound','Color Management','Display color profiles','colorcpl.exe','',$false),

    # Accounts & Security
    @('Accounts & Security','User Accounts (netplwiz)','Classic user accounts and auto-logon','netplwiz.exe','',$false),
    @('Accounts & Security','Credential Manager','Saved Windows and web passwords','control.exe','/name Microsoft.CredentialManager',$false),
    @('Accounts & Security','Security and Maintenance','Classic action center','control.exe','/name Microsoft.ActionCenter',$false),
    @('Accounts & Security','Certificates (User)','Personal certificate store','certmgr.msc','',$false),
    @('Accounts & Security','Backup and Restore','Windows 7 style backup','control.exe','/name Microsoft.BackupAndRestore',$false),

    # Classic Panels
    @('Classic Panels','Classic Control Panel','The real one, as it used to be','control.exe','',$false),
    @('Classic Panels','All Items (God Mode)','Every Control Panel item in one list','explorer.exe','shell:::{ED7BA470-8E54-465E-825C-99712043E01C}',$false)
) | ForEach-Object {
    [pscustomobject]@{ Cat=$_[0]; Name=$_[1]; Desc=$_[2]; Exe=$_[3]; Args=$_[4]; Admin=$_[5] }
}

$Cats = @('All') + ($Items.Cat | Select-Object -Unique)
$script:Cat = 'All'
$script:Visible = @()

# ---------- launching ----------
function Open-Tool($it) {
    try {
        $p = @{ FilePath = $it.Exe }
        if ($it.Args) { $p.ArgumentList = $it.Args }
        if ($it.Admin -and -not $IsAdmin) { $p.Verb = 'RunAs' }
        Start-Process @p
    } catch {
        [void][System.Windows.Forms.MessageBox]::Show(
            "Could not open '$($it.Name)'.`n`n$($_.Exception.Message)`n`nSome tools need Windows Pro or specific Windows features.",
            'ClassicPanel', 'OK', 'Warning')
    }
}

# ---------- UI ----------
$form = New-Object System.Windows.Forms.Form
$form.Text = "ClassicPanel $Version"
$form.Size = New-Object System.Drawing.Size(1120, 720)
$form.MinimumSize = New-Object System.Drawing.Size(820, 520)
$form.StartPosition = 'CenterScreen'
$form.BackColor = $Bg
$form.ForeColor = $Text
$form.Font = New-Object System.Drawing.Font('Segoe UI', 9)
$form.KeyPreview = $true
try { $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon("$env:SystemRoot\System32\control.exe") } catch {}

$Flow = New-Object System.Windows.Forms.FlowLayoutPanel
$Flow.Dock = 'Fill'
$Flow.AutoScroll = $true
$Flow.BackColor = $Bg
$Flow.Padding = New-Object System.Windows.Forms.Padding(18, 14, 12, 12)

$Nav = New-Object System.Windows.Forms.FlowLayoutPanel
$Nav.Dock = 'Left'
$Nav.Width = 220
$Nav.BackColor = $Side
$Nav.FlowDirection = 'TopDown'
$Nav.WrapContents = $false
$Nav.Padding = New-Object System.Windows.Forms.Padding(10, 16, 10, 10)

$Head = New-Object System.Windows.Forms.Panel
$Head.Dock = 'Top'
$Head.Height = 84
$Head.BackColor = $Bg

$Title = New-Object System.Windows.Forms.Label
$Title.Text = 'ClassicPanel'
$Title.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 20)
$Title.AutoSize = $true
$Title.Location = New-Object System.Drawing.Point(238, 12)
$Title.ForeColor = $Text

$adminText = if ($IsAdmin) { 'Running as administrator' } else { 'Tools that need it will ask for admin' }
$Sub = New-Object System.Windows.Forms.Label
$Sub.Text = "The old Control Panel, back. $adminText."
$Sub.ForeColor = $Muted
$Sub.AutoSize = $true
$Sub.Location = New-Object System.Drawing.Point(242, 52)

$Search = New-Object System.Windows.Forms.TextBox
$Search.Width = 300
$Search.Font = New-Object System.Drawing.Font('Segoe UI', 11)
$Search.BackColor = $TileBg
$Search.ForeColor = $Text
$Search.BorderStyle = 'FixedSingle'
$Search.Anchor = 'Top,Right'
$Search.Location = New-Object System.Drawing.Point(($form.ClientSize.Width - 330), 28)

$Hint = New-Object System.Windows.Forms.Label
$Hint.Text = 'Search (Ctrl+F), Enter opens first result'
$Hint.ForeColor = $Muted
$Hint.Font = New-Object System.Drawing.Font('Segoe UI', 8)
$Hint.AutoSize = $true
$Hint.Anchor = 'Top,Right'
$Hint.Location = New-Object System.Drawing.Point(($form.ClientSize.Width - 330), 60)

$Head.Controls.AddRange(@($Title, $Sub, $Search, $Hint))

$form.Controls.Add($Flow)
$form.Controls.Add($Nav)
$form.Controls.Add($Head)

# ---------- tiles ----------
$TileClick = { param($s, $e) Open-Tool $s.Tag }
$TileEnter = {
    param($s, $e)
    $t = if ($s.Name -eq 'tile') { $s } else { $s.Parent }
    $t.BackColor = $TileHot
}
$TileLeave = {
    param($s, $e)
    $t = if ($s.Name -eq 'tile') { $s } else { $s.Parent }
    $t.BackColor = $TileBg
}

function New-Tile($it) {
    $tile = New-Object System.Windows.Forms.Panel
    $tile.Name = 'tile'
    $tile.Size = New-Object System.Drawing.Size(250, 80)
    $tile.Margin = New-Object System.Windows.Forms.Padding(6)
    $tile.BackColor = $TileBg
    $tile.Cursor = 'Hand'

    $bar = New-Object System.Windows.Forms.Panel
    $bar.Dock = 'Left'
    $bar.Width = 4
    $bar.BackColor = Get-Color $Accent[$it.Cat]

    $n = New-Object System.Windows.Forms.Label
    $n.Text = $it.Name
    $n.Font = New-Object System.Drawing.Font('Segoe UI Semibold', 10.5)
    $n.ForeColor = $Text
    $n.BackColor = [System.Drawing.Color]::Transparent
    $n.AutoEllipsis = $true
    $n.Location = New-Object System.Drawing.Point(16, 10)
    $n.Size = New-Object System.Drawing.Size(226, 22)

    $d = New-Object System.Windows.Forms.Label
    $d.Text = $it.Desc
    $d.Font = New-Object System.Drawing.Font('Segoe UI', 8.5)
    $d.ForeColor = $Muted
    $d.BackColor = [System.Drawing.Color]::Transparent
    $d.Location = New-Object System.Drawing.Point(16, 34)
    $d.Size = New-Object System.Drawing.Size(226, 38)

    $tile.Controls.AddRange(@($bar, $n, $d))
    foreach ($c in @($tile, $bar, $n, $d)) {
        $c.Tag = $it
        $c.Cursor = 'Hand'
        $c.Add_Click($TileClick)
        $c.Add_MouseEnter($TileEnter)
        $c.Add_MouseLeave($TileLeave)
    }
    return $tile
}

function Update-Tiles {
    $q = $Search.Text.Trim()
    $list = @($Items | Where-Object {
        ($script:Cat -eq 'All' -or $_.Cat -eq $script:Cat) -and
        ($q -eq '' -or "$($_.Name) $($_.Desc) $($_.Cat) $($_.Exe)" -like "*$q*")
    })
    $script:Visible = $list
    $Flow.SuspendLayout()
    foreach ($c in @($Flow.Controls)) { $c.Dispose() }
    foreach ($it in $list) { $Flow.Controls.Add((New-Tile $it)) }
    if ($list.Count -eq 0) {
        $l = New-Object System.Windows.Forms.Label
        $l.Text = 'Nothing matches your search.'
        $l.ForeColor = $Muted
        $l.AutoSize = $true
        $l.Margin = New-Object System.Windows.Forms.Padding(10)
        $Flow.Controls.Add($l)
    }
    $Flow.ResumeLayout()
}

# ---------- nav ----------
function Set-Nav {
    foreach ($b in $Nav.Controls) {
        if ($b.Tag -eq $script:Cat) { $b.BackColor = $TileHot; $b.ForeColor = $Text }
        else                        { $b.BackColor = $Side;    $b.ForeColor = $Muted }
    }
}
$NavClick = {
    param($s, $e)
    $script:Cat = $s.Tag
    Set-Nav
    Update-Tiles
}
foreach ($c in $Cats) {
    $b = New-Object System.Windows.Forms.Button
    $b.Text = "  $c"
    $b.Tag = $c
    $b.Size = New-Object System.Drawing.Size(198, 38)
    $b.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 4)
    $b.FlatStyle = 'Flat'
    $b.FlatAppearance.BorderSize = 0
    $b.FlatAppearance.MouseOverBackColor = $TileHot
    $b.TextAlign = 'MiddleLeft'
    $b.Font = New-Object System.Drawing.Font('Segoe UI', 10)
    $b.Cursor = 'Hand'
    $b.Add_Click($NavClick)
    $Nav.Controls.Add($b)
}

# ---------- events ----------
$Search.Add_TextChanged({ Update-Tiles })
$Search.Add_KeyDown({
    if ($_.KeyCode -eq 'Enter' -and $script:Visible.Count -gt 0) {
        Open-Tool $script:Visible[0]
        $_.SuppressKeyPress = $true
    }
})
$form.Add_KeyDown({
    if ($_.Control -and $_.KeyCode -eq 'F') { $Search.Focus(); $_.SuppressKeyPress = $true }
    elseif ($_.KeyCode -eq 'Escape') { $form.Close() }
})
$form.Add_Shown({ $Search.Focus() })

Set-Nav
Update-Tiles
[void]$form.ShowDialog()
