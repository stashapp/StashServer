# About

This isn't too user friendly for right now... Will improve in the future.

TODO

# Dependencies

* Ruby (Rails)
* NGINX (For handling video streams)
* FFMPEG
* ImageMagick

# Setup

## Stash

`$ bundle` to install the required gems.

Create a file called `application.yml` in the `config` directory with the following contents:

```
# The location of the stash
stash_directory: ''

# The location metadata should be exported to
stash_metadata_directory: ''

# The location to store cache files
stash_cache: ''
```

## NGINX

### macOS

* `$ brew install nginx --with-passenger` and follow the instructions (add passenger lines to nginx.conf)
* Create a file called `/usr/local/etc/nginx/servers/stash` with the following contents (be sure to change "**PATH_TO_STASH_APP_HERE**" to the path of the Stash rails app.):

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
* Use the following commands to manage NGINX `$ brew services [start|stop|restart] nginx`

# Usage

## Rake Tasks

The following rake tasks are included.

* `$ rails metadata:import`
  * This will drop the database and import from the metadata folder
* `$ rails metadata:export`
  * This will export to the metadata folder.  There is a dry run option: `noglob rails metadata:export[true]`
* `$ rails metadata:scan`
  * This will scan the stash for new content, generate checksums, add to database, and generate thumbnails.  This can take a while...
* `$ rails metadata:generate_sprites`
  * This will generate sprites and VTT files to provide video scrubbing previews.
