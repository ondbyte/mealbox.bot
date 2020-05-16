FROM google/dart-runtime

RUN pub global activate aqueduct
RUN aqueduct create mealbox_dart_bot

WORKDIR /mealbox_dart_bot

ADD pubspec.yaml /mealbox_dart_bot/
ADD pubspec.lock /mealbox_dart_bot/

RUN pub get --no-precompile


ADD bin /mealbox_dart_bot/bin
ADD lib /mealbox_dart_bot/lib
RUN pub get --offline --no-precompile
ADD start.sh /mealbox_dart_bot/

WORKDIR /mealbox_dart_bot

RUN curl -o /mealbox_dart_bot/redis.tar.gz http://download.redis.io/releases/redis-6.0.1.tar.gz
RUN tar xzf /mealbox_dart_bot/redis.tar.gz -C /mealbox_dart_bot/
RUN apt-get update && apt-get install -y make && apt-get install -y gcc
WORKDIR /mealbox_dart_bot/redis-6.0.1
RUN make
WORKDIR /mealbox_dart_bot
ADD redis.conf /mealbox_dart_bot/redis.conf
RUN chmod 755 /mealbox_dart_bot/start.sh


EXPOSE 8080

ENTRYPOINT [ "/mealbox_dart_bot/start.sh" ]