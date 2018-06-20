FROM phusion/passenger-full:0.9.30

# Set correct environment variables.
ENV HOME /root
ENV APP_HOME /home/app/stash
ENV APP_FRONTEND_HOME /home/app/frontend

# Add startup scripts
RUN mkdir -p /etc/my_init.d
ADD docker/setup_stash.rb /etc/my_init.d/setup_stash.rb
RUN chmod +x /etc/my_init.d/setup_stash.rb

# Use baseimage-docker's init process.
CMD ["/sbin/my_init"]

# ...put your own build instructions here...

# Setup yarn for apt
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list

# Install dependencies from apt-get
RUN add-apt-repository -y ppa:mc3man/xerus-media && apt-get update -qq \
  && apt-get install -y --no-install-recommends ffmpeg imagemagick libmagic-dev yarn \
  && rm -rf /var/lib/apt/lists/*

# Install global node modules
RUN yarn global add gulp
RUN yarn global add @angular/cli

# Set the newest ruby version
RUN bash -lc 'rvm --default use ruby-2.4.4'

# Fix broken bundler
RUN gem install bundler

# Expose Nginx HTTP service
EXPOSE 80 3000 4000 4001 8008

# Start Nginx / Passenger
RUN rm -f /etc/service/nginx/down
RUN rm -f /etc/service/redis/down

# Remove the default site
RUN rm /etc/nginx/sites-enabled/default

# Add the nginx site and config
ADD docker/nginx.conf /etc/nginx/sites-enabled/stash.conf
ADD docker/nginx_frontend.conf /etc/nginx/sites-enabled/stash_frontend.conf
ADD docker/rails-env.conf /etc/nginx/main.d/rails-env.conf

# Install bundle of gems
WORKDIR /tmp
ADD Gemfile* /tmp/
RUN bundle install

# Install the frontend
RUN git clone https://github.com/StashApp/StashFrontend.git
RUN cd StashFrontend && yarn install
RUN cd StashFrontend \
    && ng build --prod \
    && mv dist/* $APP_FRONTEND_HOME \
    && chown -R app:app $APP_FRONTEND_HOME

# Clean up packages that aren't needed
RUN apt-get purge -y libmagic-dev gcc g++ gcc-5 x11-common openjdk-8-jre-headless memcached \
  mysql-common openssh-sftp-server openssh-server openssh-client passenger-doc m4 git-man bison \
  && apt-get autoremove -y

# Add the Rails app
ADD . $APP_HOME
RUN chown -R app:app $APP_HOME

# Change the working directory to where it makes sense
WORKDIR $APP_HOME

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
