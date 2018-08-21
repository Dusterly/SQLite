FROM swift:4.1.3
RUN apt -y update
RUN apt install -y sqlite3 libsqlite3-dev
ADD . /src
WORKDIR /src
RUN swift test
