-- author: oriol@joor.net - license: MIT license
local puremagic = require('puremagic')
local lib = {}

lib.base_dir = "/notion-proxy-ng/html/static_files/"

function lib.set_header(path_n_file)
  local type = puremagic.via_path(path_n_file)
  
  if ( type == 'application/octet-stream' ) then
    if ( path_n_file:match("^.+/(.+)$") == 'jpg' ) then
      type = 'image/jpeg'
    end
  end

  ngx.header['Content-Type'] = type
end

function lib.get_file_descriptor(path_n_file)
  local f = io.open(path_n_file,'rb')
  if not f then
    lib.return_not_found('File NOT found.')
  else
    lib.set_header(path_n_file)
  end

  return f
end

function lib.return_big_file_content(fd)
  local size = fd:seek("end")
  fd:seek("set", 0)
  ngx.header['Content-Length'] = size
  
  while true do
    -- read in blocks of 10MB
    local bytes = fd:read( 10485760)
    if not bytes then break end
    ngx.print( bytes)
    ngx.flush(true)
  end
  fd:close()
  ngx.flush(true)
  
end

function lib.return_not_found(msg)
  ngx.status = ngx.HTTP_NOT_FOUND
  ngx.header["Content-type"] = "text/html"
  ngx.say(msg or "not found")
  ngx.exit(0)
end

return lib