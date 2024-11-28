FROM perl:5.40

COPY . /usr/src/sentra
WORKDIR /usr/src/sentra

RUN cpanm --installdeps .

ENTRYPOINT [ "perl", "./sentra.pl" ]