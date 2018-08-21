FROM sqlite3_dev
ADD . /src
WORKDIR /src
RUN swift test
