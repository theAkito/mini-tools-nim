##[
  Appends specified extension to files which currently have another extension, as specified.
]##


import
  std/[
    os,
    sequtils,
    sugar
  ]

const
  prefixDot = "."
  prefixGlob = """*."""

let
  params = commandLineParams()
  dir = params[0]
  extCurrent = prefixGlob & params[1]
  extNext = prefixDot & params[2]

walkFiles(dir / extCurrent).toSeq.apply(
  (fileName: string) => (
    fileName.moveFile(fileName & extNext)
  )
)