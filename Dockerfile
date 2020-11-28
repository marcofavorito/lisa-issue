FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get upgrade

RUN apt-get install -y \
  dialog \
  build-essential \
  make  \
  m4 \
  autotools-dev \
  automake \
  apt-utils \
  libtool \
  cmake \
  flex \
  bison \
  wget \
  curl \
  libboost-dev  \
  python3 \
  # the following are needed to build SPOT documentation,
  # which I wasn't able to disable
  pdf2svg \
  groff \
  latexmk \ 
  latex-mk \
  texlive \
  texlive-latex-extra \
  texlive-fonts-extra \
  texlive-science

ENV LD_LIBRARY_PATH="/usr/local/lib:${LD_LIBRARY_PATH}"

COPY . /build
WORKDIR /build

RUN ./scripts/install-dependencies.sh

