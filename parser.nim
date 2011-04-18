import parseutils, os, strutils
type
  TLogEntry* = object
    remoteHost*, serverName*, user*, time*: string
    rqMethod*, rqPath*, rqHTTPVer*: string
    code*, referrer*, agent*: String
    size*: biggestInt
    isBot*: TBotEnum
  
  TBotEnum* = enum
    googleBot, yahooBot, bingBot, bot, noBot
  
# REMEMBER: TODO: Combined doesn't support serverName, it's meant to be ident.

proc parseRequest(log: var TLogEntry, request: string) =
  log.rqMethod = "-"
  log.rqPath = "-"
  log.rqHTTPVer = "-"
  if request != "-":
    try:
      var i = 0
      i = request.parseToken(log.rqMethod, {'\1'..'\255'} - Whitespace) + 1
      i = i + request.parseToken(log.rqPath, {'\1'..'\255'} - Whitespace, i) + 1
      i = i + request.parseToken(log.rqHTTPVer, {'\1'..'\255'} - Whitespace, i) + 1
    except EInvalidIndex:
      quit("Unable to parse request: " & request)

proc isBot(referrer: string): TBotEnum =
  var norm = normalize(referrer)
  if "googlebot" in norm:
    return googleBot
  elif "slurp" in norm and "yahoo" in norm:
    return yahooBot
  elif "bingbot" in norm:
    return bingBot
  elif "bot" in norm or "spider" in norm:
    return bot
  else:
    return noBot

proc parseUntil*(s: string, token: var string, until: set[char], i: int): int =
  return s.parseToken(token, {'\1'..'\255'} - until, i)

proc parseCombined*(file: string): seq[TLogEntry] =
  result = @[]
  var log = readFile(file)
  if log == nil: OSError()

  var i = 0
  while log[i] != '\0':
    var logEntry: TLogEntry
    
    i = i + log.parseUntil(logEntry.remoteHost, Whitespace, i) + 1
    
    i = i + log.parseUntil(logEntry.serverName, Whitespace, i) + 1

    i = i + log.parseUntil(logEntry.user, Whitespace, i) + 1

    inc(i) # Skip [
    i = i + log.parseUntil(logEntry.time, {']'}, i) + 2

    inc(i) # Skip quotation mark.
    var request = ""
    i = i + log.parseUntil(request, {'"'}, i) + 2
    logEntry.parseRequest(request)
    
    i = i + log.parseUntil(logEntry.code, Whitespace, i) + 1

    var sizeLen = log.parseBiggestInt(logEntry.size, i)
    inc(i, sizeLen+1)
    
    inc(i) # Skip quotation mark.
    i = i + log.parseUntil(logEntry.referrer, {'"'}, i) + 2
    
    inc(i) # Skip quotation mark.
    i = i + log.parseUntil(logEntry.agent, {'"'}, i) + 1
    
    # Is bot?
    logEntry.isBot = isBot(logEntry.agent)
    
    result.add(logEntry)
    
    # Skip new line.
    if log[i] == '\c': inc(i)
    if log[i] == '\L': inc(i)
    
when isMainModule:
  discard parseCombined("test.log")
