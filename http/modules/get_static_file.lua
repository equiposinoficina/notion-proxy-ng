local lib = require( "lib")
local cache_file = '/notion-proxy-ng/cache/slugs.json'

local to_slugs = ngx.shared.to_slugs
local to_page = ngx.shared.to_page

function mysplit (inputstr, sep)
  if sep == nil then
          sep = "%s"
  end
  local t={}
  for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
          table.insert(t, str)
  end
  return t
end

function getEntryFromEnd(table, entry)
  local count = (table and #table or false)
  if (count) then
      return table[count-entry];
  end
  return false;
end

local path_n_file = 'index.html'
if ( ngx.var.path_n_file ~= '' and ngx.var.path_n_file ~= '/') then
  path_n_file = ngx.var.path_n_file
end

local cb = path_n_file:sub(2)
if ( to_slugs:get(cb) ~= nil ) then
  ngx.redirect("/" .. to_slugs:get(cb), ngx.HTTP_MOVED_PERMANENTLY)
end

if ( cb:sub(-5) == '.html') then
  local ext = cb:sub(1,-6)
  if ( to_slugs:get(ext) ~= nil ) then
    ngx.redirect("/" .. to_slugs:get(ext), ngx.HTTP_MOVED_PERMANENTLY)
  end
end

if ( to_page:get(cb) ~= nil ) then
  path_n_file = to_page:get(cb) .. '.html'
end

table_path_n_file = mysplit(path_n_file, '/')
path_n_file = table_path_n_file[#table_path_n_file]


-- ngx.log(ngx.ERR, "this is a test")
-- return file content
local real_path_n_file = lib.base_dir .. path_n_file
local fd = lib.get_file_descriptor( real_path_n_file)
lib.return_big_file_content(fd)
ngx.exit(0)
