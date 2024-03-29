import
  meta,
  model,
  std/[
    segfaults,
    sequtils,
    strutils,
    strformat,
    json,
    htmlparser,
    xmltree,
    tables,
    sugar,
    streams,
    os,
    times,
    logging,
    random
  ],
  pkg/[
    puppy
  ]

randomize()

const maxCountBatch = 20

let logger = newConsoleLogger(defineLogLevel(), logMsgPrefix & logMsgInter & "master" & logMsgSuffix)

func first*(s: openArray[XmlNode], pred: proc(x: XmlNode): bool {.closure.}): XmlNode {.inline, effectsOf: pred.} =
  for i in 0..<s.len:
    if s[i].pred:
      return s[i]

func cleanURL(projectUrl: Url): Url =
  projectUrl.query = @[]
  projectUrl

func toCommentsUrl(projectUrl: Url): string =
  $projectUrl & "/comments"

func getProjectID(node: JsonNode): int =
  node.getFields["projectID"].getInt

func getCommentThreadID(node: JsonNode): int =
  node.getFields["props"].getFields["commentThreadID"].getInt

proc wait = sleep rand 12_231..19_121
proc waitLong = (1..5).toSeq.apply (i: int) => wait()

proc extractProjectContext(node: XmlNode): JsonNode =
  let
    txtScriptSubStartFragment = "projectContext: {"
    txtScript = node.findAll("script").first(
        (scriptNode: XmlNode) =>
          scriptNode.innerText.contains("window.__INITIAL_STATE__")
      ).innerText
    txtScriptSubStart = txtScript.find(txtScriptSubStartFragment)
    txtScriptSubEnd = txtScript.find("""},
                userContext:""")
    txtScriptSubContent = txtScript[txtScriptSubStart.succ(txtScriptSubStartFragment.len.pred)..txtScriptSubEnd]
  when meta.debug: writeFile debugDir / &"""extractProjectContextTxtScriptSubContent_{now().format("yyyy-MM-dd'T'HH-mm-ss")}.json""", txtScriptSubContent.parseJson.pretty
  txtScriptSubContent.parseJson

proc extractProjectCommentsBox(node: XmlNode): JsonNode =
  let
    txtScriptSubStartFragment = "Gamefound.Components.Projects.ProjectCommentsBox, {"
    txtScript = node.findAll("script").first(
        (scriptNode: XmlNode) =>
          scriptNode.innerText.contains(txtScriptSubStartFragment)
      ).innerText
    txtScriptSubStart = txtScript.find(txtScriptSubStartFragment)
    txtScriptSubEnd = txtScript.find(""");""", start = txtScriptSubStart)
    txtScriptSubContent = txtScript[txtScriptSubStart.succ(txtScriptSubStartFragment.len.pred)..txtScriptSubEnd.pred]
  when meta.debug: writeFile debugDir / &"""extractProjectCommentsBoxTxtScriptSubContent_{now().format("yyyy-MM-dd'T'HH-mm-ss")}.json""", txtScriptSubContent.parseJson.pretty
  txtScriptSubContent.parseJson

proc retrieveProjectContext(projectUrl: Url): XmlNode =
  let
    req = Request(
      url: projectUrl,
      headers: @[
        Header(key: headerKeyUserAgent, value: headerUserAgent)
      ],
      verb: "GET"
    )
    resp = req.fetch()
    xResp = resp.body.parseHtml
  xResp

proc retrieveCommentBatchAsJSON(projectUrl: Url = "https://gamefound.com/projects/boardcubator/kcdboardgame".parseUrl, commentThreadID: int, lastFetchedCommentID: int = 0): JsonNode =
  let
    headerValContentType = "application/json"
    req = Request(
      url: apiGetComments,
      headers: @[
        Header(key: headerKeyUserAgent, value: headerUserAgent),
        Header(key: "Accept", value: headerValContentType),
        Header(key: "Content-Type", value: headerValContentType),
        Header(key: "Referer", value: projectUrl.toCommentsUrl)
      ],
      verb: "POST",
      body: $ %* CommentRequest(
        commentThreadID: commentThreadID,
        lastFetchedCommentID: if lastFetchedCommentID == 0: newJNull() else: % lastFetchedCommentID,
        sortType: 0,
        lastScore: 0
      )
    )
    resp = req.fetch()
    jResp = resp.body.parseJson
  jResp

proc getLastFetchedCommentIDToCommentResponse(batch: JsonNode): (int, CommentResponse) =
  let
    response = batch.to(CommentResponse)
    lastFetchedCommentID = try:
        response.pagedItems[response.pagedItems.high].commentID
      except:
        logger.log lvlDebug, pretty(% response)
        logger.log lvlDebug, getCurrentExceptionMsg()
        logger.log lvlDebug, getCurrentException().getStackTrace()
        0
  (lastFetchedCommentID, response)

proc retrieveComments(rawProjectUrl: string = "https://gamefound.com/projects/boardcubator/kcdboardgame"): seq[CommentResponseItem] =
  let
    projectUrl = rawProjectUrl.parseUrl.cleanURL
    commentThreadID = projectUrl.toCommentsUrl.parseUrl.retrieveProjectContext.extractProjectCommentsBox.getCommentThreadID
    (lastFetchedCommentIDinit, batchFirst) =
      retrieveCommentBatchAsJSON(commentThreadID = commentThreadID)
        .getLastFetchedCommentIDToCommentResponse()
    batchTotalItemCount = batchFirst.totalItemCount
  var lastFetchedCommentID = lastFetchedCommentIDinit
  result = newSeqOfCap[CommentResponseItem](batchTotalItemCount)
  result.add batchFirst.pagedItems
  while result.len < batchTotalItemCount:
    wait()
    try:
      let (lastFetchedCommentIDcurrent, batchCurrent) =
        retrieveCommentBatchAsJSON(commentThreadID = commentThreadID, lastFetchedCommentID = lastFetchedCommentID)
          .getLastFetchedCommentIDToCommentResponse()
      if lastFetchedCommentIDcurrent == 0: break # Fallback, in case item count is incorrect.
      lastFetchedCommentID = lastFetchedCommentIDcurrent
      result.add batchCurrent.pagedItems
    except:
      logger.log lvlWarn,  """Exception occurred when trying to retrieve comments. Waiting and then trying again..."""
      logger.log lvlWarn,  """Exception Message: """ & getCurrentExceptionMsg()
      logger.log lvlDebug, """Stacktrace: """ & getCurrentException().getStackTrace()
      waitLong()

iterator retrieveComments(rawProjectUrl: string = "https://gamefound.com/projects/boardcubator/kcdboardgame"): seq[CommentResponseItem] =
  let
    projectUrl = rawProjectUrl.parseUrl.cleanURL
    commentThreadID = projectUrl.toCommentsUrl.parseUrl.retrieveProjectContext.extractProjectCommentsBox.getCommentThreadID
    (lastFetchedCommentIDinit, batchFirst) =
      retrieveCommentBatchAsJSON(projectUrl, commentThreadID = commentThreadID)
        .getLastFetchedCommentIDToCommentResponse()
    batchTotalItemCount = batchFirst.totalItemCount
  var
    lastFetchedCommentID = lastFetchedCommentIDinit
    count = 1
  yield batchFirst.pagedItems
  while count <= ((batchTotalItemCount div maxCountBatch) + ((batchTotalItemCount mod maxCountBatch) div maxCountBatch)):
    wait()
    try:
      let (lastFetchedCommentIDcurrent, batchCurrent) =
        retrieveCommentBatchAsJSON(commentThreadID = commentThreadID, lastFetchedCommentID = lastFetchedCommentID)
          .getLastFetchedCommentIDToCommentResponse()
      if lastFetchedCommentIDcurrent == 0: break # Fallback, in case item count is incorrect.
      lastFetchedCommentID = lastFetchedCommentIDcurrent
      yield batchCurrent.pagedItems
      count.inc
    except:
      logger.log lvlWarn,  """Exception occurred when trying to retrieve comments. Waiting and then trying again..."""
      logger.log lvlWarn,  """Exception Message: """ & getCurrentExceptionMsg()
      logger.log lvlDebug, """Stacktrace: """ & getCurrentException().getStackTrace()
      waitLong()

#TODO: Add Stopwatch.
#TODO: Add feature to query/group comments by nickname.
#TODO: Add feature to continue from last checkpoint.
block:
  discard outputDir.existsOrCreateDir
  when meta.debug: discard debugDir.existsOrCreateDir
  let
    currentDate = now().format(dateFormatFileName)
    outputFileName = outputDir / &"""out_{selectedOutputType}_{currentDate}.json"""
  case selectedOutputType:
    of jsonSingle:
      writeFile(outputFileName, pretty(% retrieveComments()))
    of jsonStream:
      let jStream = newFileStream(outputFileName, fmWrite)
      for comments in retrieveComments(gamefoundProjectURL):
        comments.apply (it: CommentResponseItem) => jStream.writeLine(% it)
  let outputFile = outputFileName.open
  defer: outputFile.close
  if outputFile.getFileSize == 0:
    discard outputFileName.tryRemoveFile