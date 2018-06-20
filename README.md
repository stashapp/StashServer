# About

**Stash is a rails app which organizes and serves your porn.**

See a demo [here](https://vimeo.com/275537038) (password is stashapp).

I built this as an alternative to "pornganizer".  Pornganizer is great, and I recommend you check it out, it just didn't meet *my* needs.

So what does stash do?

* Acts as a server which provides a web interface to stream your porn
  - MP4 video previews
  - VTT generation for scrubbing thumbnails
* Allows exporting your metadata into JSON

In the future:

* Mobile App

That's it, pretty simple.  Right now all metadata must be input manually, but in the future I hope to build a scraper to make input less tedious.

# Docker Install

1) Download / clone this repository
2) Install [docker](https://store.docker.com/search?offering=community&type=edition)
3) Create a file named ".env" with the following contents and edit the paths:
```
STASH_DATA=/path/to/media
STASH_METADATA=/path/to/save/metadata
STASH_CACHE=/path/for/cache/files
STASH_DOWNLOADS=/path/to/downloads
```
4) Run the `start_docker.rb` ruby script
5) Visit *server ip*:8008 in your browser

To run the rake tasks use this command to log into the docker container `docker exec -it stash /bin/bash` and then you should be able to run the tasks you want.

## Slack

I created a Slack channel to discuss the project.  [Click here to join.](https://join.slack.com/stash-project/shared_invite/MTc2Nzg0NjAyNzg4LTE0OTM1ODU4MTgtNDcwODRiMGIwYQ)

# Dependencies

* Ruby (Rails)
* NGINX (For handling video streams)
* FFMPEG (Compiled with some extra flags)
  - macOS: `brew install ffmpeg --with-libvpx --with-opus --with-x265 --with-webp`
* ImageMagick
* libmagic
  - macOS: `brew install libmagic`

### Optional for scraping

* chromedriver
  - macOS: `brew install chromedriver`
* aria2
  - macOS: `brew install aria2`
* curl

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
stash_cache_directory: ''

# The location to store scraped downloads
stash_downloads_directory: ''
```

### Frontend

Be sure to compile and expose the frontend as well.  It can be found [here](https://github.com/StashApp/StashFrontend).

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

        if ($http_origin) {
          add_header 'Access-Control-Allow-Origin' "$http_origin";
          add_header 'Access-Control-Allow-Methods' 'GET';
          add_header 'Access-Control-Allow-Headers' 'Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type';
        }
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

Run `rails s` to boot the app running on port 3000, but don't use it on this port since that will bypass the NGINX reverse proxy we set up above.  Instead, goto http://YOUR_LOCAL_IP_HERE:4000 to visit through the proxy, you should see the web app with no content.

You're going to want to populate the database by running `rails metadata:scan`.  This will go through the stash folder you configured in the application.yml file and calculate MD5 checksums of everything and add the found scenes and galleries to the database.  This might take some time depending on how much content you have.

You should see stash fill up with your content as the scan continues.  Once it completes you should run `rails metadata:export` to export the contents of the database to JSON so you can import your data again in the future.

## Rake Tasks

The following rake tasks are included.

* `$ rails metadata:import`
  * This will drop the database and import from the metadata folder
* `$ rails metadata:export`
  * This will export to the metadata folder.
* `$ rails metadata:scan`
  * This will scan the stash for new content, generate checksums, add to database, and generate thumbnails.  This can take a while...
* `$ rails metadata:generate_sprites`
  * This will generate sprites and VTT files to provide video scrubbing previews.
* `$ rails metadata:generate_previews`
  * This will generate mp4 preview files
* `$ rails metadata:generate_marker_previews`
  * This will generate mp4 preview files for scene markers
* `$ rails metadata:generate_transcodes`
  * This will create mp4 transcodes of files not compatible with HTML5 video.  (ex. wmv)
* `$ rails metadata:generate_all`
  * This generates all of the above in one command.

# Questions

### What's with the JSON?

When thinking about my metadata, I wanted something I could store in git.  JSON files are great for this, I can easily diff changes and have a backup in the cloud.

In the metadata directory after an export you'll see various files and folders...

* `scenes/#{MD5_HASH}.json`
  * Metadata for this particular scene.
* `performers/#{MD5_HASH}.json`
  * Ditto for performers
* `mappings.json`
  * This is used to map scene /gallery MD5 hashes to file paths (so you don't have to recalculate the hash on import) and performer hashes to a name.

I should note that the hash for performers is the MD5 hash of whatever image you used for the performer.

# Docker Commands for the developer

* `docker rm /stash`
* `docker build [--no-cache] -t stash .`
* `docker tag IMAGE_ID stashappdev/stash:latest`
* `docker images`

*Debug failing build*
`docker run --rm -it IMAGE_ID /bin/bash`

*Remove all images*
`docker rmi -f $(docker images -q)`
