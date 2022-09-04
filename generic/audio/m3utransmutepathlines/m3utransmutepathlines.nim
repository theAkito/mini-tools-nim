##[
  Checks, if paths inside M3U files start with `symbolToNot` & contain `symbolToYes`.
  Counts & prints occurrences.
]##

import
  os,
  strutils,
  sequtils,
  tables,
  times

const
  m3uRootPath = "/home/hyde/Documents/Music/"
  m3uObsoleteRootPaths = @[
    r"[]\Users\Gustavo\Documents\Music\",
    r"[OS]\Users\Red\Documents\Music\",
  ]

let
  cwd = getCurrentDir()
  pathTarget = try: commandLineParams()[0] except: raiseOSError(22.OSErrorCode, "You must provide the path to a target directory as the first argument to this program."); ""
  pathDirOut = pathTarget & DirSep & r"out_" & $now().format("yyyy-MM-dd'T'HH-mm-ss")

pathTarget.setCurrentDir

pathDirOut.createDir

let multiReplaceArgs = m3uObsoleteRootPaths.mapIt((it, m3uRootPath))
for path, content in "*.m3u".walkFiles.toSeq.mapIt((it, it.readFile)).toTable:
  (pathDirOut & DirSep & path.extractFilename).writeFile(content.multiReplace(multiReplaceArgs & (r"\", "/")))

cwd.setCurrentDir