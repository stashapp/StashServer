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

* `$ brew install nginx` and follow the instructions
* Create a file called `/usr/local/etc/nginx/servers/stash` with the following contents (be sure to change "**PATH_TO_STASH_APP_PUBLIC_DIRCTORY_HERE**" to the path of the Stash rails app. Ex: `/Users/stashappdev/Documents/Stash/public`):

    ```
    server {
      listen 4000;
      root **PATH_TO_STASH_APP_HERE**;

      location /__send_file_accel {
        internal;
        alias /;
      }

      location / {
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header HOST $http_host;
        proxy_set_header X-Sendfile-Type X-Accel-Redirect;
        proxy_set_header X-Accel-Mapping /=/__send_file_accel/;
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

Run `rails s` or `passenger start` to boot the app running on port 3000, but don't use it on this port since that will bypass the NGINX reverse proxy we set up above.  Instead, goto http://YOUR_LOCAL_IP_HERE:4000 to visit through the proxy, you should see the web app with no content.

You're going to want to populate the database by running `rails metadata:scan`.  This will go through the stash folder you configured in the application.yml file and calculate MD5 checksums of everything and add the found scenes and galleries to the database.  This might take some time depending on how much content you have.

You should see stash fill up with your content as the scan continues.  Once it completes you should run `rails metadata:export` to export the contents of the database to JSON so you can import your data again in the future.

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
