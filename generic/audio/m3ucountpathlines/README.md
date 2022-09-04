## Count path lines in M3U files

### Build
```bash
cd generic/audio/m3ucountpathlines
nimble install -d
nim c m3ucountpathlines.nim
```

#### Provide Path to directory containing m3u files
```bash
./m3ucountpathlines '/path/to/target'
```