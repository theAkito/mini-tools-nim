##[
  Retrieve Wakapi Heartbeats
  Translation of https://github.com/muety/wakapi/blob/1a6ee55d144574ef890d3de2825a9adac69a818e/scripts/download_heartbeats.py
]##

import
  std/[
    parseopt,
    strutils,
    strformat,
    times,
    os,
    base64,
    json,
    sugar
  ],
  pkg/[
    puppy,
    csvtable,
    # suru
  ]

type
  Arguments = object
    apiKey: string
    url: string
    since: DateTime
    upto: DateTime
    outputDirFileCSV: string

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
              echo docLink
              quit 1
          of "t", "to", "upto":
            try:
              args.upto = val.parse(dateFormat)
            except ValueError:
              echo docLink
              quit 1
          of "h", "help":
            echo docLink
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
  for date in dateRange:
    yield date.fetchHeartBeats

proc run(dateFrom, dateTo: DateTime, outputLoc: string) =
  var csvOut = newCSVTblWriter(outputLoc, @modelKeys)
  let (dateMin, dateMax) = fetchTotalRange(dateFrom, dateTo)
  for beats in dateMin.fetchAllHeartbeats(dateMax):
    for beat in beats:
      let row = block:
        let row = newTable[string, string]()
        row["branch"] = beat{"branch"}.getStr
        row["category"] = beat{"category"}.getStr
        row["entity"] = beat{"entity"}.getStr
        row["is_write"] = $beat{"is_write"}.getBool
        row["language"] = beat{"language"}.getStr
        row["project"] = beat{"project"}.getStr
        row["time"] = $beat{"time"}.getInt
        row["type"] = beat{"type"}.getStr
        row["user_id"] = beat{"user_id"}.getStr
        row["machine_name_id"] = beat{"machine_name_id"}.getStr
        row["user_agent_id"] = beat{"user_agent_id"}.getStr
        row["created_at"] = beat{"created_at"}.getStr
        row
      csvOut.writeRow(row)

when isMainModule:
  setOpts()
  let currentDate = now().format("yyyy-MM-dd'T'HH-mm-ss")
  discard args.outputDirFileCSV.existsOrCreateDir
  run(args.since, args.upto, args.outputDirFileCSV / &"""out_{currentDate}.csv""")