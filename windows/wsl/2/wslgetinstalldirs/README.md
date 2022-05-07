## Get Installation Directories of WSL2 Instances from the Windows Registry

### Build
```powershell
cd windows\wsl\2\wslgetinstalldirs
nimble install -d
nim c .\wslgetinstalldirs.nim
```

### Run
```powershell
.\wslgetinstalldirs.exe
```

### Output
```json
{
  "Debian": "C:\\Users\\User\\AppData\\Local\\Packages\\TheDebianProject.DebianGNULinux_ads7zasd978\\LocalState",
  "Alpine": "C:\\Users\\User\\AppData\\Local\\Packages\\fsdaoinnjsfd89fsdhj.AlpineWSL_lkj345hj435n\\LocalState",
  "docker-desktop": "C:\\Users\\User\\AppData\\Local\\Docker\\wsl\\distro",
  "docker-desktop-data": "C:\\Users\\User\\AppData\\Local\\Docker\\wsl\\data"
}
```

### Run
```powershell
.\wslgetinstalldirs.exe human
```

### Output
```text
DistributionName:        Debian
BasePath:                C:\Users\User\AppData\Local\Packages\TheDebianProject.DebianGNULinux_ads7zasd978\LocalState


DistributionName:        Alpine
BasePath:                C:\Users\User\AppData\Local\Packages\fsdaoinnjsfd89fsdhj.AlpineWSL_lkj345hj435n\LocalState


DistributionName:        docker-desktop
BasePath:                C:\Users\User\AppData\Local\Docker\wsl\distro


DistributionName:        docker-desktop-data
BasePath:                C:\Users\User\AppData\Local\Docker\wsl\data
```