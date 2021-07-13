local cjson = require "cjson"
local cache_file = '/notion-proxy-ng/cache/slugs.json'

local to_slugs = ngx.shared.to_slugs
local to_page = ngx.shared.to_page

local f = io.open(cache_file,'rb')
local content = f:read("*all")
f:close()

local value = cjson.decode(content)

-- ngx.log(ngx.ERR, "Free memory:" .. to_page:free_space())

for k,v in pairs(value["page_slug"]) do
  to_slugs:set(v["perma_link"], v["slug"])
  to_slugs:set(v["page"], v["slug"])
  to_page:set(v["slug"], v["page"])
end

-- ngx.log(ngx.ERR, "Free memory:" .. to_page:free_space())
