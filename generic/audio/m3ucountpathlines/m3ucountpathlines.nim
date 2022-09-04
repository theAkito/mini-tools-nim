##[
  Checks, if paths inside M3U files start with `symbolToNot` & contain `symbolToYes`.
  Counts & prints occurrences.
]##

import
  os,
  strutils,
  sequtils,
  streams

const
  m3uDirectiveChar = '#'
  unicodeByteOrderMark = "\239\187\191"

let
  cwd = getCurrentDir()
  pathTarget = try: commandLineParams()[0] except: raiseOSError(22.OSErrorCode, "You must provide the path to a target directory as the first argument to this program."); ""
  symbolToNot = "[]"
  symbolToYes = r"\Users\Gustavo"

pathTarget.setCurrentDir

let
  strmOut = (cwd & DirSep & "out.txt").newFileStream(fmWrite)
  countLinesWithSymbolNoToSymbolYes = (
      var totalCountLinesPathAny = 0
      var totalCountLinesSymbolToNot = 0
      var totalCountLinesSymbolToYes = 0
      for content in "*.m3u".walkFiles.toSeq.mapIt(it.readFile):
        let strm = content.newStringStream
        defer: strm.close
        for line in strm.lines:
          if line.startsWith(m3uDirectiveChar) or line.startsWith(unicodeByteOrderMark): continue
          if line.startsWith(symbolToNot): totalCountLinesSymbolToNot.inc
          if line.contains(symbolToYes): totalCountLinesSymbolToYes.inc
          if not line.startsWith(symbolToNot) and not line.contains(symbolToYes):
            strmOut.writeLine(line)
            totalCountLinesPathAny.inc
      (totalCountLinesPathAny, totalCountLinesSymbolToNot, totalCountLinesSymbolToYes)
    )
strmOut.close

echo "totalCountLinesPathAny " & $countLinesWithSymbolNoToSymbolYes[0]
echo "totalCountSymbolToNot " & $countLinesWithSymbolNoToSymbolYes[1]
echo "totalCountSymbolToYes " & $countLinesWithSymbolNoToSymbolYes[2]
echo "Both match: " & $(countLinesWithSymbolNoToSymbolYes[1] == countLinesWithSymbolNoToSymbolYes[2])

cwd.setCurrentDir