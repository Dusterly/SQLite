FROM swift:4.1.3
ADD . /src
WORKDIR /src
RUN swift test
