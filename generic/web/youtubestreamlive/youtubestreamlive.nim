##[
  Retrieve, whether a YouTube channel currently has a livestream running.

  * https://stackoverflow.com/questions/32454238/how-to-check-if-youtube-channel-is-streaming-live
]##

import
  meta,
  std/[
    segfaults,
    sequtils,
    strutils,
    strformat,
    json,
    htmlparser,
    xmltree,
    tables,
    strtabs,
    sugar,
    os,
    times,
    logging,
    random
  ],
  pkg/[
    puppy
  ]

randomize()

const
  headerCookie     = "CONSENT=PENDING+634;"
  keywordLink      = "link"
  keywordRel       = "rel"
  keywordHref      = "href"
  keywordCanonical = "canonical"
  keywordWatch     = "/watch?v="

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)

func first*(s: openArray[XmlNode], pred: proc(x: XmlNode): bool {.closure.}): XmlNode {.inline, effectsOf: pred.} =
  for i in 0..<s.len:
    if s[i].pred:
      return s[i]

func constructURL(tag: string): Url =
  parseUrl(&"""https://www.youtube.com/{tag}/live""")

proc wait = sleep rand 2_231..5_121
proc waitLong = (1..5).toSeq.apply (i: int) => wait()

proc retrieveYouTubeChannelAsXML(channelURL: Url): XmlNode =
  let
    req = Request(
      url: channelURL,
      headers: @[
        Header(key: headerKeyUserAgent, value: headerUserAgent),
        Header(key: headerKeyCookie, value: headerCookie)
      ],
      verb: "GET"
    )
    resp = req.fetch()
    xResp = resp.body.parseHtml
  xResp

func isLive(nodeChannel: XmlNode): bool =
  let canonicalLink = nodeChannel.findAll(keywordLink).first (nodeLink: XmlNode) => nodeLink.attrs.contains(keywordRel) and nodeLink.attr(keywordRel) == keywordCanonical
  if canonicalLink != nil: canonicalLink.attr(keywordHref).contains(keywordWatch) else: false

iterator retrieveChannelTagToLive(tags = @["@KlangKuenstler"]): (string, bool) =
  for tag in tags:
    wait()
    try:
      yield (tag, tag.constructURL.retrieveYouTubeChannelAsXML.isLive)
    except:
      logger.log lvlWarn,  """Exception occurred when trying to retrieve comments. Waiting and then trying again..."""
      logger.log lvlWarn,  """Exception Message: """ & getCurrentExceptionMsg()
      logger.log lvlDebug, """Stacktrace: """ & getCurrentException().getStackTrace()
      waitLong()

when isMainModule:
  discard outputDir.existsOrCreateDir
  let
    currentDate = now().format(dateFormatFileName)
    outputFileName = outputDir / &"""out_{currentDate}.json"""
    outTxt = pretty %retrieveChannelTagToLive(configName.readLines(3).mapIt(it)).toSeq.toTable
  writeFile(outputFileName, outTxt)
  echo outTxt