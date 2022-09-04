## Transmute path lines in M3U files

### Build
```bash
cd generic/audio/m3utransmutepathlines
nimble install -d
nim c m3utransmutepathlines.nim
```

#### Provide Path to directory containing m3u files
```bash
./m3utransmutepathlines '/path/to/target'
```