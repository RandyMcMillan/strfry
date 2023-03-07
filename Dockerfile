FROM ubuntu:jammy as build
ENV TZ=Europe/London
VOLUME /tmp
WORKDIR /tmp
RUN apt update && apt install -y --no-install-recommends \
    git g++ make pkg-config libtool ca-certificates \
    libyaml-perl libtemplate-perl libssl-dev zlib1g-dev \
    liblmdb-dev libflatbuffers-dev libsecp256k1-dev libb2-dev \
    libzstd-dev cpanminus libflatbuffers-dev liblmdb-dev \
	liblmdb++-dev liblmdb-file-perl \
	zlib1g-dev sudo liblmdb-dev

COPY . .
RUN git init
RUN git submodule update --init --recursive
RUN make setup-golpe
RUN make -j4

FROM ubuntu:jammy as runner
VOLUME /app
WORKDIR /app

RUN apt update && apt install -y --no-install-recommends \
    liblmdb0 libflatbuffers1 libsecp256k1-0 libb2-1 libzstd1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/strfry strfry
ENTRYPOINT ["/app/strfry"]
CMD ["relay"]
