# Setup

## NGINX

* `$ brew install nginx --with-passenger` and follow the instructions (add passenger lines to nginx.conf)
* Create a file called `/usr/local/etc/nginx/servers/stash` with the following contents:
* `brew services [start|stop|restart] nginx`
```
upstream puma {
  server localhost:3000;
}

server {
  listen 4000 default;
  root **PATH_TO_STASH_APP_HERE**;
  try_files $uri/index.html $uri @puma;

  location /protected/ {
    internal;
    alias /$1/;
  }

  location @puma {
    proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    proxy_set_header HOST $http_host;
    proxy_set_header X-Sendfile-Type X-Accel-Redirect;
    proxy_set_header X-Accel-Mapping ^/*=/protected/$1;
    proxy_redirect off;
    proxy_pass http://localhost:3000;
  }

  error_page 500 502 503 504 /500.html;
  client_max_body_size 4G;
  keepalive_timeout 5;
}
```
