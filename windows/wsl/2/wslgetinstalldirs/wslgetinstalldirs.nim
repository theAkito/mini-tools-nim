import
  winregistry,
  strutils,
  strtabs,
  json

from os import paramStr, paramCount, sleep

var h: RegHandle = open(HKEY_CURRENT_USER, r"SOFTWARE\Microsoft\Windows\CurrentVersion\Lxss", samAll)

func toJson(sTable: StringTableRef): JsonNode =
  result = newJObject()
  for name, path in sTable:
    result[name] = path.newJString

var
  subkeys: seq[string] = @[]
  nameToPath = newStringTable(StringTableMode.modeCaseInsensitive)

proc showResult() =
  if paramCount() > 0 and paramStr(1) == "human":
    for name, path in nameToPath:
      echo ""
      echo "DistributionName:        " & name
      echo "BasePath:                " & path
      echo ""
  else:
    echo nameToPath.toJson.pretty

try:
  for key in h.enumSubkeys:
    subkeys.add key
  for key in subkeys:
    let
      distro = h.open(key & r"\", samAll)
    var
      name = $distro.readString("DistributionName")
      path = $distro.readString("BasePath")
    path.removePrefix(r"\\?\")
    nameToPath[name] = path
    distro.close
except:
  echo "Excepted!"
  echo getCurrentExceptionMsg()
finally:
  h.close

showResult()
