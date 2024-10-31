import std/[os, strutils]
import iniplus
export iniplus

proc getConfigFilename*(): string =
  result = "yangtze.ini"
  if existsEnv("YANGTZE_CONFIG"):
    result = getEnv("YANGTZE_CONFIG")
  return result

proc getIntOrDefault*(config: ConfigTable, section, key: string, default: int): int =
  if config.exists(section, key):
    return config.getInt(section, key)
  return default

proc configValueToString*(val: ConfigValue): string =
  ## This converts an iniplus configuration value into a string.
  ## CVString's aren't converted at all, CVInt and CVBool are converted via a basic dollar sign.
  ## CVArray's are concatenated with a paragraph tag separating each one.
  ## 
  ## An empty string is returned for CVTable and CVNone
  case val.kind:
  of CVString: return val.stringVal
  of CVInt: return $(val.intVal)
  of CVBool: return $(val.boolVal)
  of CVArray:
    for item in val.arrayVal:
      result.add("<p>" & configValueToString(item) & "</p>\n")
    return result
  of CVNone, CVTable: return ""

proc configToTable*(cnf: ConfigTable): Table[string, string] =
  ## Converts a configuation table into a plain old string-only table.
  ## This is so that it can be passed on easily to temple's templateify() procedure.
  ## 
  ## And also, it has a couple of features embedded, such as the "readFile string" mechanism.
  for key,val in cnf.pairs:
    if key[0] == "custom" and val.kind != CVTable:
      # Check if this is a special "readFile string" or whatever
      if startsWith(val.stringVal, "$") and endsWith(val.stringVal, "$"):
        result[key[1]] = readFile(val.stringVal[1..^2])
      else:
        # Otherwise, just convert it into a string and add it into the table
        result[key[1]] = configValueToString(val)

proc trimCustom*(cnf: ConfigTable): ConfigTable =
  ## When given a configuration file, it will throw away everything in the "custom" section.
  for key,val in cnf.pairs:
    if key != "custom":
      result[key] = val
  return result