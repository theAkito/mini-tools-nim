##[
  Retrieve Wakapi Heartbeats
  Based on a translation of https://github.com/muety/wakapi/blob/1a6ee55d144574ef890d3de2825a9adac69a818e/scripts/download_heartbeats.py
]##

import
  std/[
    parseopt,
    strutils,
    strformat,
    sequtils,
    enumutils,
    times,
    os,
    base64,
    json,
    sugar,
    streams,
    tables
  ],
  pkg/[
    puppy,
    csvtable,
    suru
  ]

type
  OutputMode = enum
    CSV, JSON
  Arguments = object
    apiKey: string
    url: string
    since: DateTime
    upto: DateTime
    outputDirFileCSV: string
    mode: OutputMode

const
  lineEnd = "\p"
  docLink = "https://github.com/muety/wakapi/blob/1a6ee55d144574ef890d3de2825a9adac69a818e/scripts/download_heartbeats.py#L62-L69"
  outDir = "output_wakapiexporter/"
  dateFormat = "yyyy-MM-dd"
  modelKeys = ["branch", "category", "entity", "is_write", "language", "project", "time", "type", "user_id", "machine_name_id", "user_agent_id", "created_at"]
  urlSuffixAllTime = "compat/wakatime/v1/users/current/all_time_since_today"
  urlSuffixHeartbeats = "compat/wakatime/v1/users/current/heartbeats"

var
  args = Arguments(
    since: "1970-01-01".parse(dateFormat),
    upto: now(),
    outputDirFileCSV: outDir
  )

template throwHttpErrorIfNot20x =
  if resp.code notin 200..299: raise PuppyError.newException &"""HTTP Request returned non 20x HTTP Code with the following body:{lineEnd}""" & resp.body

proc helpQuit = echo docLink; quit 1
proc genHeaderAuth: HttpHeaders = @[("Authorization", "Basic " & args.apiKey.encode(true))]

proc setOpts() =
  for kind, key, val in commandLineParams().getopt():
    case kind
      of cmdArgument: continue
      of cmdLongOption, cmdShortOption:
        case key
          of "k", "apikey", "api-key", "api_key":
            args.apiKey = val
          of "o", "output", "outputDirFileCSV":
            args.outputDirFileCSV = if val.endsWith "/":
              val
            else: val & "/"
          of "u", "url":
            args.url = if val.endsWith "/":
              val & "api/"
            else: val & "/api/"
          of "s", "since", "f", "from":
            try:
              args.since = val.parse(dateFormat)
            except ValueError:
              helpQuit()
          of "t", "to", "upto":
            try:
              args.upto = val.parse(dateFormat)
            except ValueError:
              helpQuit()
          of "m", "mode", "outputMode":
            try:
              args.mode = parseEnum[OutputMode](val.toUpperAscii)
            except ValueError:
              args.mode = CSV
          of "h", "help":
            helpQuit()
      of cmdEnd: assert(false)
  if args.url.isEmptyOrWhitespace: raiseOSError 22.OSErrorCode, "You need to provide a valid URL! Example: https://wakapi.dev"
  if args.apiKey.isEmptyOrWhitespace: raiseOSError 22.OSErrorCode, "You need to provide a valid API key! Example: 2ae7b097-959e-4dec-8921-e944d50bd554"

proc fetchTotalRange(dateMin, dateMax: DateTime): tuple[min: DateTime, max: DateTime] =
  let resp = get(&"{args.url}{urlSuffixAllTime}", genHeaderAuth())
  throwHttpErrorIfNot20x
  let
    jResp = try: resp.body.parseJson
    except CatchableError:
      echo resp.body
      raise getCurrentException()
    dateStart = jResp{"data"}{"range"}{"start_date"}.getStr.parse(dateFormat)
    dateEnd = jResp{"data"}{"range"}{"end_date"}.getStr.parse(dateFormat)
  (max(dateMin, dateStart), max(dateMax, dateEnd))

proc fetchHeartbeats(date: DateTime): JsonNode =
  let
    url = block:
      var url = parseUrl &"{args.url}{urlSuffixHeartbeats}"
      url.query["date"] = date.format(dateFormat)
      url
    resp = get($url, genHeaderAuth())
    jResp = try: resp.body.parseJson
    except CatchableError:
      echo resp.body
      raise getCurrentException()
  throwHttpErrorIfNot20x
  jResp{"data"}

iterator fetchAllHeartbeats(dateStart, dateEnd: DateTime): JsonNode =
  let dateRange = collect:
    for d in 0..(dateEnd - dateStart).inDays + 2:
      dateStart + initDuration(days = d)
  for date in suru(dateRange):
    yield date.fetchHeartBeats

proc writeBeatsJSON(beats: JsonNode, outputLoc: string, mode: OutputMode) =
  let fStream = outputLoc.newFileStream(fmAppend)
  defer: fStream.close
  for beat in beats:
    fStream.writeLine beat

proc writeBeatsCSV(csv: CSVTblWriter, beats: JsonNode, outputLoc: string, mode: OutputMode) =
  for beat in beats:
    let row = block:
      let row = beat.getFields.pairs.toSeq.map do (keyToVal: tuple[k: string, v: JsonNode]) -> tuple[k: string, v: string]:
        let v = case keyToVal.v.kind:
          of JString: keyToVal.v.getStr
          else: $keyToVal.v
        (keyToVal.k, v)
      newTable(row)
    csv.writeRow(row)

proc run(dateFrom, dateTo: DateTime, outputLoc: string, mode: OutputMode) =
  let (dateMin, dateMax) = fetchTotalRange(dateFrom, dateTo)
  case mode
    of CSV:
      var csv = newCSVTblWriter(outputLoc, @modelKeys)
      defer: csv.close
      for beats in dateMin.fetchAllHeartbeats(dateMax):
        csv.writeBeatsCSV beats, outputLoc, mode
    of JSON:
      for beats in dateMin.fetchAllHeartbeats(dateMax):
        writeBeatsJSON beats, outputLoc, mode

when isMainModule:
  setOpts()
  let currentDate = now().format("yyyy-MM-dd'T'HH-mm-ss")
  discard args.outputDirFileCSV.existsOrCreateDir
  run(args.since, args.upto, args.outputDirFileCSV / &"""out_{currentDate}.{toLowerAscii $args.mode}""", args.mode)