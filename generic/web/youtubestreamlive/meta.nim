from logging import Level

const
  debug              * {.booldefine.} = false
  debugDir           * {.strdefine.}  = "debug"
  defaultDateFormat  * {.strdefine.}  = "yyyy-MM-dd'T'HH:mm:ss'.'fffffffff'+02:00'"
  dateFormatFileName * {.strdefine.}  = "yyyy-MM-dd'T'HH-mm-ss"
  logMsgPrefix       * {.strdefine.}  = "[$levelname]:[$datetime]"
  logMsgInter        * {.strdefine.}  = " ~ "
  logMsgSuffix       * {.strdefine.}  = " -> "
  appVersion         * {.strdefine.}  = "0.1.0"
  configName         * {.strdefine.}  = "tags.txt"
  configPath         * {.strdefine.}  = ""
  configIndentation  * {.intdefine.}  = 2
  headerUserAgent    * = "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:103.0) Gecko/20100101 Firefox/103.0"
  headerKeyUserAgent * = "user-agent"
  headerKeyCookie    * = "Cookie"
  headerKeyEncoding  * = "Accept-Encoding"
  outputDir          * = "output_youtubestreamlive"

func defineLogLevel*(): Level =
  if debug: lvlDebug else: lvlInfo