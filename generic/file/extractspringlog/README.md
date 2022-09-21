## Process Spring log collection for manual viewing

### Build
```bash
cd generic/file/extractspringlog
nimble install -d
nim c extractspringlog.nim
```

#### Provide Path to directory containing the target files
```bash
./extractspringlog '/path/to/target'
```

### Path structure
#### Before
```
/path/to/target
├── spring.log
├── spring.log.2022-09-19.0.gz
└── spring.log.2022-09-20.0.gz
```

#### After

```
/path/to/target
├── spring.log
├── spring.log.2022-09-19.0.log
└── spring.log.2022-09-20.0.log
```