##[
  Process Spring log collection for manual viewing.
]##


import
  std/[
    os,
    sequtils,
    sugar
  ],
  pkg/[
    zippy
  ]

walkFiles(commandLineParams()[0] / "*.gz").toSeq.apply(
  (filePath: string) => (
    let filePathWithoutGZ = filePath.changeFileExt("")
    filePathWithoutGZ.writeFile(filePath.readFile.uncompress(dfGzip))
    filePathWithoutGZ.moveFile(filePathWithoutGZ & ".log")
    discard filePath.tryRemoveFile
  )
)