import parser, strutils, math, os

type
  TInfo* = object
    total*: float # Total bandwidth usage in kB.
    visits*: seq[TLogEntry]

proc gatherInfo*(log: seq[TLogEntry]): TInfo =
  #result.perAgent = newHashTable[string, float]()
  
  result.visits = log
  for item in items(log):
    var currentSizeKB = (float(item.size) / 1024.0)
    result.total = result.total + currentSizeKB

    #if result.perAgent.hasKey(item.agent):
    #  result.perAgent[item.agent] = result.perAgent[item.agent] + currentSizeKB
    #else: result.perAgent[item.agent] = currentSizeKB

proc abbr(long: string, short: string): string =
  result = "<abbr title=\"" & long & "\">" & short & "</abbr>"

proc shorten(s: string, count: int): string =
  if s.len-1 > count:
    result = abbr(s, copy(s, 0, count) & "...")
  else:
    result = s

proc acronym(s: string, desc: string): string =
  result = "<acronym title=\"" & desc & "\">" & s & "</acronym>"

proc describeHTTPCode(code: string): string =
  case code
  of "100": result = "Continue"
  of "101": result = "Switching Protocols"
  of "200": result = "OK"
  of "201": result = "Created"
  of "202": result = "Accepted"
  of "203": result = "Non-Authoritative Information"
  of "204": result = "No Content"
  of "205": result = "Reset Content"
  of "206": result = "Partial Content"
  of "300": result = "Multiple Choices"
  of "301": result = "Moved Permanently"
  of "302": result = "Found"
  of "303": result = "See Other"
  of "304": result = "Not Modified"
  of "305": result = "Use Proxy"
  of "307": result = "Temporary Redirect"
  of "400": result = "Bad Request"
  of "401": result = "Unauthorized"
  of "403": result = "Forbidden"
  of "404": result = "Not found"
  of "405": result = "Method Not Allowed"
  of "406": result = "Not Acceptable"
  of "408": result = "Request Timeout"
  of "409": result = "Conflict"
  of "410": result = "Gone"
  of "500": result = "Internal Server Error"
  of "501": result = "Not Implemented"
  of "502": result = "Bad Gateway"
  of "503": result = "Service Unavailable"
  of "504": result = "Gateway Timeout"
  of "505": result = "HTTP Version Not Supported"
  else: result = "?"

proc formatSize(size: biggestInt): string =
  var kb = float(size) / 1024.0 
  if size < 1024:
    return $size & " bytes"
  else:
    return $round(kb) & " kb"  

proc shortenMiddle(s: string, count: int): string =
  var middleS = (s.len-1) / 2 # Middle of string
  var middleCount = (count/2)
  var start = middleS - middleCount
  if start < 0.0: start = 0.0
  var endIndex = middleS + middleCount
  if endIndex > float(s.len-1): endIndex = float(s.len-1)
  
  return "..." & copy(s, round(start), round(endIndex)) & "..."

proc formatAgent(agent: string, count: int): string =
  if agent.len-1 > count:
    if agent.startswith("Mozilla"):
      return abbr(agent, shortenMiddle(agent, count))
    else:
      return shorten(agent, count)
  else:
    return agent

proc insertBotTd(isBot: TBotEnum): string =
  case isBot:
  of googleBot:
    return "<td class=\"googlebot\">Google Bot</td>"
  of yahooBot:
    return "<td class=\"yahoobot\">Yahoo Bot</td>"
  of bingBot:
    return "<td class=\"bingbot\">Bing Bot</td>"
  of bot:
    return "<td>Bot</td>"
  of noBot: return ""

include "templ.html"

proc createReport*(file: string, output: string) =
  var log = parseCombined(file)
  
  var info = gatherInfo(log)
  
  var file: TFile
  if open(file, output, fmWrite):
    file.write(genHtml(info))
    echo("Processed ", info.visits.len(), " visits.")
    file.close()
  else:
    echo("Error: Unable to open output.html for writing.")
    OSError()

when isMainModule:
  var log = parseCombined("test.log")
  echo formatFloat(gatherInfo(log).total)
  
  var info = gatherInfo(log)
  
  var file: TFile
  echo open(file, "output.html", fmWrite)
  file.write(genHtml(info))
