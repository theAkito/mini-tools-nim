import os
from model import OutputType, toOutputType
from logging import Level
from urlly import parseUrl

const
  debug             * {.booldefine.} = false
  debugDir          * {.strdefine.}  = "debug"
  defaultMsg        * {.strdefine.}  = "Process Finished"
  defaultDateFormat * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'+02:00'"
  logMsgPrefix      * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter       * {.strdefine.}  = " ~ "
  logMsgSuffix      * {.strdefine.}  = " -> "
  appVersion        * {.strdefine.}  = "0.1.0"
  configName        * {.strdefine.}  = "gamefoundprojectcomments.json"
  configPath        * {.strdefine.}  = ""
  configIndentation * {.intdefine.}  = 2
  headerUserAgent * = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
  headerKeyUserAgent * = "user-agent"
  headerKeyCookie * = "Cookie"

let
  # apiGetProjectComments * = "https://gamefound.com/api/comments/getProjectComments".parseUrl
  apiGetProjectComments* = "https://gamefound.com/api/comments/getComments".parseUrl
  params* = commandLineParams()
  gamefoundProjectURL* = try: params[0] except: "https://gamefound.com/projects/boardcubator/kcdboardgame"
  selectedOutputType* = try: params[1].toOutputType except: jsonSingle
  outputDir* = try: params[2] except: "output_gamefoundprojectcomments"

func defineLogLevel*(): Level =
  if debug: lvlDebug else: lvlInfo