FROM jetbrains/teamcity-agent

RUN git clone https://github.com/flutter/flutter.git -b dev --depth 1 ~/flutter
ENV PATH="${PATH}:~/flutter/bin"

USER root
RUN apt-get update -qq && apt-get install -qq clang cmake ninja-build pkg-config libgtk-3-dev libblkid-dev

USER buildagent
RUN ~/flutter/bin/flutter upgrade
RUN ~/flutter/bin/flutter config --enable-linux-desktop
RUN ~/flutter/bin/flutter doctor