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
@KlangKuenstler
@HBzMusic
@durdenhauer55
```

### Run
```bash
./youtubestreamlive
```

### Output

#### Output as JSON
```json
{
  "@KlangKuenstler": true,
  "@HBzMusic": false,
  "@durdenhauer55": false
}
```