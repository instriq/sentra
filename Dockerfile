FROM ubuntu:latest

COPY . /usr/src/sentra
WORKDIR /usr/src/sentra

RUN apt-get update && apt-get install -y \
    cpanminus \
    libdatetime-perl \
    libssl-dev \
    libexpat1-dev \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

RUN cpanm --installdeps .

ENTRYPOINT [ "perl", "./sentra.pl" ]
