# About

**Stash is a rails app which organizes and serves your porn.**

I built this as an alternative to "pornganizer".  Pornganizer is great, and I recommend you check it out, it just didn't meet *my* needs.

So what does stash do?

* Acts as a server which provides a web interface to stream your porn
  - Webm video previews
  - VTT generation for scrubbing
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
```
4) Run the `start_docker.rb` ruby script
5) Visit *server ip*:8008 in your browser

Right now scanning and importing isn't build into the UI, so you will still need to use the rake tasks described below.  Use this command to log into the docker container `docker exec -it stash /bin/bash` and then you should be able to run the rake tasks.

## Slack

I created a Slack channel to discuss the project.  [Click here to join.](https://join.slack.com/stash-project/shared_invite/MTc2Nzg0NjAyNzg4LTE0OTM1ODU4MTgtNDcwODRiMGIwYQ)

# Dependencies

* Ruby (Rails)
* NGINX (For handling video streams)
* FFMPEG (Compiled with libvpx for mouse over previews)
  - macOS: `brew install ffmpeg --with-libvpx --with-opus --with-x265 --with-webp`
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
stash_cache_directory: ''
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
* `$ rails metadata:generate_previews`
  * This will generate webm preview files

# Questions

### What's with the JSON?

When thinking about my metadata, I wanted something I could store in git.  JSON files are great for this, I can easily diff changes and have a backup in the cloud.

In the metadata directory after an export you'll see various files and folders...

* `scenes/#{MD5_HASH}.json`
  * Metadata for this particular scene.
* `performers/#{MD5_HASH}.json`
  * Ditto for performers
* `mappings.json`
  * This is used to map scene MD5 hashes to file paths (so you don't have to recalculate the hash on import), performer hashes to a name (so we can keep hashes out of the file content), and gallery hashes for file paths.

I should note that the hash for performers is the MD5 hash of whatever image you used for the performer.

### What's with performer images?

I haven't gotten around to allow remote upload.  Instead stash will look for JPG's in the root or one level deep inside of your stash directory and present those for use.  Just put any images you want to expose to the add / edit screen in a folder called performers or whatever other name you like.
