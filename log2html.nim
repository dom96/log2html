# Parses the "Combined Log Format" -- http://httpd.apache.org/docs/current/logs.html --
# and translates it to html.
# It also supports the lighttpd format, which uses server-name instead of ident
# in its second field.
import os, parseutils, parseopt, report
const help = """Usage: log2html [options] logfile
  -v --version            Show the version number
  -h --help               Show this message"""

const version = "log2html 0.1 - Compiled on: " & compileDate & " " & compileTime

var logfile = ""
var outFile = "output.html"

for kind, key, val in getopt():
  case kind
  of cmdArgument:
    logfile = key
  of cmdLongOption, cmdShortOption:
    case key
    of "help", "h":
      echo(help)
      quit(quitSuccess)
    of "version", "v": 
      echo(version)
      quit(quitSuccess)
  else: nil

if existsFile(logfile):
  createReport(logfile, outfile)
else:
  quit("Error: " & logfile & " doesn't exist.")
