server {
  server_name downloads.local;
  listen  55080;

  location ~ ^/(?<signature>[^/]+)/(?<customer_id>[^/]+)/(?<expire_date>[^/]+)/(?<path_n_file>.*)$ {
     #lua_code_cache off;
     content_by_lua_file "lua/get_file.lua";
  }

  location / {
     return 403;
  }

  access_log /var/log/nginx/downloads.access.log;
  error_log /var/log/nginx/downloads.error.log;
}