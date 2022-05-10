import
  os,
  strutils

if paramCount() <= 0:
  raise OSError.newException "First parameter must be a valid absolute Windows or Linux path!"

const
  mountPrefix = "/mnt/"
  linDirSep = '/'
  winDirSep = '\\'
  winDirAbsPathInfix = r":\"

let
  path = paramStr(1)
  lineEnd = if defined(doslikeFileSystem): "\r\n" else: "\n"
  lineEndRequested = if paramCount() > 1: paramStr(2).parseBool else: true
  lineEndSelected = if lineEndRequested: lineEnd else: ""

func isLinuxPath(p: string): bool = p[1..2] != winDirAbsPathInfix
func toLinuxPath(p: string): string = p.replace(winDirSep, linDirSep)
func toWindowsPath(p: string): string = p.replace(linDirSep, winDirSep)

if path.isLinuxPath:
  if path.startsWith(mountPrefix):
    let
      pathPrefixless = path[mountPrefix.len..^1]
      pathDrive = pathPrefixless[0].toUpperAscii
      cleanPath = pathPrefixless[2..^1]
    stdout.write pathDrive & winDirAbsPathInfix & cleanPath.toWindowsPath & lineEndSelected
  else:
    raise OSError.newException "Detected Linux path, but it's not an absolute path. Please, provide an absolute path!"
else:
  stdout.write mountPrefix & path[0].toLowerAscii & path[2..^1].toLinuxPath & lineEndSelected