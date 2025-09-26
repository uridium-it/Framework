# Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

$framework_root=${pwd} -replace '[\\/]', '/'
$tools_root="$ENV:APPDATA\Framework\tools"
$pwsh_root="${tools_root}\pwsh"
$msys_root="${tools_root}\msys" -replace '[\\/]', '/'
$vs_build_tools_root="${tools_root}\vs_build_tools" -replace '[\\/]', '/'

$vs_build_tools_filename="vs_BuildTools.exe"
$vs_build_tools_url="https://aka.ms/vs/17/release/${vs_build_tools_filename}"

$msys_filename="msys2-x86_64-latest.exe"
$msys_url="https://repo.msys2.org/distrib"
$msys_packages='jq zsh wget findutils git xz vim wget'

switch ($Env:PROCESSOR_ARCHITECTURE) {
    AMD64 {
        $powershell_filename = "PowerShell-7.5.2-win-x64.msi"
    }
    ARM64 {
        $powershell_filename = "PowerShell-7.5.2-win-arm64.msi"
    }
    x86 {
        $powershell_filename = "PowerShell-7.5.2-win-x86.msi"
    }
}
$powershell_url = "https://github.com/PowerShell/PowerShell/releases/download/v7.5.2/${powershell_filename}"

#----------------- msys2

if (-not (Test-Path -Path "${msys_root}/usr/bin/zsh.exe" ))
{
    if (-not (Test-Path -Path "$env:TEMP/${msys_filename}"))
    {
        Invoke-WebRequest "$msys_url/${msys_filename}" -outfile "$env:TEMP/${msys_filename}"
    }
    "Installing msys2"
    cmd /c "$env:TEMP/${msys_filename}" install --root "${msys_root}" --al --confirm-command

    "Updating msys2"
    'pacman --noconfirm -Syu' | Out-File -FilePath "${msys_root}/tmp/bootstrap.sh" -Encoding ascii -NoNewline
    & "${msys_root}/usr/bin/bash" --login /tmp/bootstrap.sh

    "Installing msys2 packages"
    "pacman --noconfirm --needed -S ${msys_packages}" | Out-File -FilePath "${msys_root}/tmp/bootstrap.sh" -Encoding ascii -NoNewline
    & "${msys_root}/usr/bin/bash" --login /tmp/bootstrap.sh

}
else
{
    "msys2 is already installed"
}

#----------------- Framework install

"cd '${framework_root}' && zsh ./install.sh" | Out-File -FilePath "${msys_root}/tmp/bootstrap.sh" -Encoding ascii -NoNewline
& "${msys_root}/usr/bin/zsh" --login /tmp/bootstrap.sh

#----------------- Desktop Icon

$wt=where.exe wt
$WshShell = New-Object -COMObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut([string][Environment]::GetFolderPath("Desktop")+"\Framework.lnk")
if (-not (Test-Path -Path "${wt}"))
{
    $Shortcut.TargetPath = [string]"${msys_root}/usr/bin/zsh.exe"
    $Shortcut.Arguments = [string]"--login"
}
else
{
    $Shortcut.TargetPath = [string]"$wt"
    $Shortcut.Arguments = [string]"${msys_root}/usr/bin/zsh.exe --login"
}
$Shortcut.IconLocation = [string]"${framework_root}/icons/freebsd.ico"
$Shortcut.Save()

#----------------- powershell 7

if (-not (Test-Path -Path "${pwsh_root}/7/pwsh.exe"))
{
    "Installing Powershell 7"
    Start-Process -Wait -FilePath C:\Windows\System32\msiexec.exe -ArgumentList INSTALLFOLDER="${pwsh_root}","/quiet","/passive","/package","${powershell_url}"
}
else
{
    "Powershell 7 is already installed"
}

#----------------- visual studio build tools

if (-not (Test-Path -Path "${vs_build_tools_root}/Common7/Tools/Launch-VsDevShell.ps1"))
{
   "Installing Visual Studio Build Tools"
    if (-not (Test-Path -Path "$env:TEMP/${vs_build_tools_filename}"))
    {
        Invoke-WebRequest "$vs_build_tools_url" -outfile "$env:TEMP/${vs_build_tools_filename}"
    }
   Start-Process -Wait -FilePath "$env:TEMP/$vs_build_tools_filename" -ArgumentList "--passive","--wait","--norestart","--includeRecommended","--add","Microsoft.VisualStudio.Workload.VCTools","--installPath","${vs_build_tools_root}"
}
else
{
    "Visual Studio Build Tools is already installed"
}
