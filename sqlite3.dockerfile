FROM swift:4.2
RUN apt -y update
RUN apt install -y sqlite3 libsqlite3-dev
