## Retrieve whether a YouTube Channel currently has a Livestream running

### Build
```bash
cd generic/web/youtubestreamlive
nimble install -d
nim c youtubestreamlive.nim
```

#### Create file which contains one YouTube Tag per Line
##### `tags.txt`
```txt
@tag123
@tag321
@tag231
```

### Run
```bash
./youtubestreamlive
```

### Output

#### Output as JSON
```json
{
  "@tag123": true,
  "@tag321": false,
  "@tag231": false
}
```

### TODO
* Push to Gotify