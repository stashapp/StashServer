gem 'dotenv'
require 'dotenv'
Dotenv.load

data = ENV['STASH_DATA']
metadata = ENV['STASH_METADATA']
cache = ENV['STASH_CACHE']

`docker run \
-d \
--name stash \
--env-file .env \
-v '#{data}':'#{data}':ro \
-v '#{metadata}':'#{metadata}' \
-v '#{cache}':'#{cache}' \
-p 3000:3000 \
-p 4000:4000 \
-p 4001:4001 \
-p 8008:8008 \
stashappdev/stash`
