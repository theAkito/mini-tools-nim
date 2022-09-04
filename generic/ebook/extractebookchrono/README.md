## Extract eBooks sorted by author in chronological order

### Build
```bash
cd generic/ebook/extractebookchrono
nimble install -d
nim c extractebookchrono.nim
```

#### Provide Path to directory containing m3u files
```bash
./extractebookchrono '/path/to/target'
```

### Path structure
#### Before
```
/path/to/target
├── Author Name 1
│   ├── Book Title 1 (260)
│   │   ├── Book Title 1 - Author Name 1.epub
│   │   └── cover.jpg
├── Author Name 2
│   ├── Book Title 2 (190)
│   │   ├── Book Title 2 - Author Name 2.epub
│   │   └── cover.jpg
├── Author Name 3
│   ├── Book Title 3 (11)
│   │   ├── Book Title 3 - Author Name 3.epub
│   │   └── cover.jpg
```

#### After

```
/path/to/target
├── 11_Book Title 3 - Author Name 3.epub
├── 190_Book Title 2 - Author Name 2.epub
├── 260_Book Title 1 - Author Name 1.epub
├── Author Name 1
│   ├── Book Title 1 (260)
│   │   ├── Book Title 1 - Author Name 1.epub
│   │   └── cover.jpg
├── Author Name 2
│   ├── Book Title 2 (190)
│   │   ├── Book Title 2 - Author Name 2.epub
│   │   └── cover.jpg
├── Author Name 3
│   ├── Book Title 3 (11)
│   │   ├── Book Title 3 - Author Name 3.epub
│   │   └── cover.jpg
```