##[
  Searches for eBooks inside folders, extracts & orders eBooks in chronological order by count and
  copies them to the root of the provide target directory, with the count prefixed to the ebook file name.
]##


import
  std/[
    os,
    algorithm,
    sequtils,
    strutils,
    re,
    sugar
  ]

const
  extDotEpub = ".epub"

let
  cwd = try: commandLineParams()[0] except: raiseOSError(22.OSErrorCode, "You must provide the path to a target directory as the first argument to this program."); ""
  reContainsCounter = """(?<=\()([\d]{1,3})(?=\))""".re
  allPathsWithCounter = collect:
    for path in cwd.walkDirRec(yieldFilter = { pcDir }):
      let counter = try: path.findAll(reContainsCounter)[0].parseInt except: continue
      (counter, path)
  sortedPathsWithCounter = allPathsWithCounter.sorted do (x, y: (int, string)) -> int: cmp(x[0], y[0])

for (counter, path) in sortedPathsWithCounter:
  let
    pathEpub = try: walkFiles(path / "*" & extDotEpub).toSeq[0] except: continue
    nameEpub = pathEpub.extractFilename
  pathEpub.copyFile(cwd / $counter & "_" & nameEpub)
