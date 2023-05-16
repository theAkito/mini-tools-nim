## Retrieve Wakapi Heartbeats

### Build
```bash
cd generic/web/wakapiexporter
nimble install -d
nim c wakapiexporter.nim
```

#### Provide Wakapi Instance URL & API Key
```bash
./wakapiexporter -u:https://wakapi.dev/ -k:2ae7b097-959e-4dec-8921-e944d50bd554
```

### Output

`output_wakapiexporter/out_2023-05-16T15-31-24.csv`
```csv
branch,category,entity,is_write,language,project,time,type,user_id,machine_name_id,user_agent_id,created_at
super-branch,/path/to/file,false,Kotlin,proj,123456345,file,User,Machine-ID,wakatime,,2023-01-01T15:31:24.643Z
```