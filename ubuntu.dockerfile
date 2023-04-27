ARG UBUNTU_VERSION=${UBUNTU_VERSION}
FROM perl:devel-threaded-bullseye
FROM neomantra/flatbuffers
FROM ubuntu:${UBUNTU_VERSION} as header
RUN apt install -y apt
RUN apt-get -y update
ARG DEBIAN_FRONTEND=noninteractive
ENV DEBIAN_FRONTEND=noninteractive
RUN export DEBIAN_FRONTEND=noninteractive
FROM header as install
RUN apt-get install -y --no-install-recommends \
git g++ make pkg-config libtool ca-certificates \
libyaml-perl libtemplate-perl libssl-dev zlib1g-dev \
liblmdb-dev libflatbuffers-dev libsecp256k1-dev libb2-dev \
libzstd-dev cpanminus libflatbuffers-dev liblmdb-dev \
liblmdb++-dev liblmdb-file-perl

RUN apt-get install --no-install-recommends -y \
	zlib1g-dev \
	adduser automake \
    bash bash-completion binutils bsdmainutils build-essential \
    ca-certificates cmake curl doxygen \
    g++-multilib \
	git \
    #libffi6 \
    libtool libffi-dev lbzip2 libssl-dev \
    make \
	nsis \
	openssh-client openssh-server \
    patch pkg-config \
    python3 python3-pip \
    python3-setuptools \
    vim virtualenv \
    xz-utils \
	zlib1g-dev sudo \
	liblmdb-dev \
	quilt parted qemu-user-static debootstrap zerofree zip dosfstools libcap2-bin libarchive-tools rsync kmod bc qemu-utils kpartx libssl-dev sudo
RUN apt-get install debconf --reinstall
FROM install as user
ARG PASSWORD=${PASSWORD}
ENV GIT_DISABLE_UNTRACKED_CACHE=true
ARG HOST_UID=${HOST_UID:-4000}
ARG HOST_USER=${HOST_USER:-nodummy}
USER root
RUN chmod 640 /etc/shadow
RUN chmod 4511 /usr/bin/passwd
RUN mkdir -p /var/cache/debconf

RUN mkdir -p /home/${HOST_USER}
COPY whatami /usr/local/bin/

RUN [[ "string1" == "string2" ]] && echo "Equal" || echo "Not equal"
#RUN user_password=$(openssl passwd -1 ${PASSWORD})
#RUN export user_password
RUN if [[  "${HOST_UID}" == "0"  ]]; then \
echo "test" || adduser --system --disabled-password --ingroup sudo --home /home/${HOST_USER} --uid ${HOST_UID} ${HOST_USER}; \
fi

#RUN echo "${HOST_USER}:$user_password" | chpasswd
#RUN [[  "${HOST_UID}" == "0"  ]] && echo "test" || useradd -m -p ${PASSWORD} -s /bin/bash -U ${HOST_USER}
#RUN [[  "${HOST_UID}" == "0"  ]] && echo "test" || useradd -m -p ${PASSWORD}
#RUN echo "${HOST_USER}:${PASSWORD}" | sudo chpasswd
RUN echo root:${PASSWORD} | chpasswd
RUN echo ${HOST_USER}:${PASSWORD} | chpasswd
#RUN echo "${HOST_USER} ALL=(ALL) ALL" >> /etc/sudoers
#RUN bash echo "root ALL=(ALL) ALL" >> /etc/sudoers
RUN echo "Set disable_coredump false" >> /etc/sudo.conf

RUN mkdir -p /home/${HOST_USER}/.ssh &&  chmod 700 /home/${HOST_USER}/.ssh
RUN touch  /home/${HOST_USER}/.ssh/id_rsa
RUN echo -n ${SSH_PRIVATE_KEY} | base64 --decode >  /home/${HOST_USER}/.ssh/id_rsa
RUN  chown -R "${HOST_UID}:${HOST_UID}" /home/${HOST_USER}/.ssh
RUN chmod 600 /home/${HOST_USER}/.ssh/id_rsa

USER ${HOST_USER}
WORKDIR /home/${HOST_USER}

FROM user as build
ENV TZ=Europe/London
VOLUME /tmp
WORKDIR /tmp
RUN apt update && apt install -y --no-install-recommends \
    git g++ make pkg-config libtool ca-certificates \
    libyaml-perl libtemplate-perl libssl-dev zlib1g-dev \
    liblmdb-dev libflatbuffers-dev libsecp256k1-dev libb2-dev \
    libzstd-dev cpanminus libflatbuffers-dev liblmdb-dev \
	liblmdb++-dev liblmdb-file-perl

COPY . .
RUN git init
RUN git submodule update --init --recursive
RUN make setup-golpe
RUN make -j4

FROM ubuntu:jammy as runner
VOLUME /app
WORKDIR /app

RUN apt update && apt install -y --no-install-recommends \
    liblmdb0 libflatbuffers1 libsecp256k1-0 libb2-1 libzstd1 #\
    #&& rm -rf /var/lib/apt/lists/*

COPY --from=build /tmp/strfry strfry
COPY --from=neomantra/flatbuffers /usr/local/bin/flatc /usr/local/bin/flatc
COPY --from=neomantra/flatbuffers /usr/local/include/flatbuffers /usr/local/include/flatbuffers
COPY --from=neomantra/flatbuffers /usr/local/lib/libflatbuffers.a /usr/local/lib/libflatbuffers.a
COPY --from=neomantra/flatbuffers /usr/local/lib/cmake/flatbuffers /usr/local/lib/cmake/flatbuffers


COPY --from=neomantra/flatbuffers /usr/local/bin/flatcc /usr/local/bin/flatcc
COPY --from=neomantra/flatbuffers /usr/local/include/flatcc /usr/local/include/flatcc
COPY --from=neomantra/flatbuffers /usr/local/lib/libflatcc.a /usr/local/lib/libflatccrt.a /usr/local/lib/

ENTRYPOINT ["/app/strfry"]
CMD ["relay"]
