## Appends specified extension to files

### Build
```bash
cd generic/file/appendextension
nimble install -d
nim c appendextension.nim
```

#### Provide Path to directory containing the target files
```bash
./appendextension '/path/to/target' '0' 'log'
```

### Path structure
#### Before
```
/path/to/target
├── spring.log
├── spring.log.2022-09-14.0
├── spring.log.2022-09-15.0
├── spring.log.2022-09-16.0
├── spring.log.2022-09-17.0
└── spring.log.2022-09-18.0
```

#### After

```
/path/to/target
├── spring.log
├── spring.log.2022-09-14.0.log
├── spring.log.2022-09-15.0.log
├── spring.log.2022-09-16.0.log
├── spring.log.2022-09-17.0.log
└── spring.log.2022-09-18.0.log
```