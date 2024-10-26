import iniplus, std/os, waterpark
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

type ConfigPool* = Pool[ConfigTable]

# Yup... cryptic code... my favorite
proc borrow*(pool: ConfigPool): ConfigTable {.inline, gcsafe.} = waterpark.borrow(pool)
proc recycle*(pool: ConfigPool, conn: ConfigTable) {.inline, gcsafe.} = waterpark.recycle(pool, conn)

proc newConfigPool*(size: int = 50): ConfigPool =
  result = newPool[ConfigTable]()
  for _ in 0 ..< size: result.recycle(parseFile(getConfigFilename()))

template withConnection*(pool: ConfigPool, config, body) =
  block:
    let config = pool.borrow()
    try:
      body
    finally:
      pool.recycle(config)