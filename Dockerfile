FROM ruby:2.4.2
ENV APP_HOME /notes
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs
RUN mkdir $APP_HOME
WORKDIR $APP_HOME
ADD Gemfile $APP_HOME/Gemfile
ADD Gemfile.lock $APP_HOME/Gemfile.lock
RUN bundle install
ADD . $APP_HOME
CMD ["bundle", "exec", "puma"]
