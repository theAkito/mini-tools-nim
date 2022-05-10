## Convert between Windows and Linux paths when switching from or to WSL2

### Build
```powershell
cd windows\wsl\2\wslconvertwintolinuxpath
nimble install -d
nim c .\wslconvertwintolinuxpath.nim
```

### Run

#### Provide Windows Path
```powershell
.\wslconvertwintolinuxpath.exe 'C:\Program Files'
```

### Output
```
/mnt/c/Program Files
```

#### Provide Linux Path
```powershell
.\wslconvertwintolinuxpath.exe '/mnt/c/Program Files'
```

### Output
```
C:\Program Files
```