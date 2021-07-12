local lib = require( "lib")

local signature, customer_id, expire_date, path_n_file = ngx.var.signature, ngx.var.customer_id, ngx.var.expire_date, ngx.var.path_n_file


-- validate URL signature
local real_signature = lib.get_signature( lib.secret, customer_id, expire_date, path_n_file)

if signature ~= real_signature then
  lib.return_not_found('Invalid signature')
end

-- validate expiration time
local date = lib.date_to_ts(expire_date)

if lib.valid_ts(date) then
  -- validate if file exists
  real_path_n_file = lib.base_dir .. path_n_file
  local fd = lib.get_file_descriptor( real_path_n_file)    

  lib.return_big_file_content(fd)
  
  ngx.exit(0)
else
  -- link expired
  lib.return_not_found('Link expired')
end