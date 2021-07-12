local lib = require( "lib")

local path_n_file = 'index.html'
if ( ngx.var.path_n_file ~= '' and ngx.var.path_n_file ~= '/') then
  path_n_file = ngx.var.path_n_file
end

-- lib.return_not_found('No ta!')
real_path_n_file = lib.base_dir .. path_n_file
local fd = lib.get_file_descriptor( real_path_n_file)

lib.return_big_file_content(fd)
-- lib.get_content(fd)
-- lib.get_file_content(fd)

ngx.exit(0)
