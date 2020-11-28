# Issue on DFA construction of Lisa

This repository contains the scripts to reproduce an issue
I found on [Lisa](https://github.com/vardigroup/lisa),
a SOTA tool for LTLf synthesis. It has been published
in the following publication:

[Hybrid Compositional Reasoning for Reactive Synthesisfrom Finite-Horizon Specifications](https://arxiv.org/pdf/1911.08145.pdf)

The datasets used are:
- Lisa examples in the project repositor: https://github.com/vardigroup/lisa/tree/master/examples
- Syft examples `len_1`, `len_2` etc., stored on Dropbox: https://www.dropbox.com/sh/qygqhuv2rjr0r98/AAC9usaPAkqbxkBfHTIPDwPta?dl=0

All datasets can be found in `datasets/`.

## Preliminaries

First of all, clone this repository:
```
git clone https://github.com/marcofavorito/lisa-issue.git --recursive
```
The `--recursive` flag is important to also clone the submodules in `third_party`.

Depending on your current development setup, you might need 
to install other libraries and tools (e.g. the compilers at the right version etc.).
To overcome these issues, we provide a Docker image (more in next sections),
and we recommend to use it.

### Install dependencies

The scripts are tested on Ubuntu 20.04, but
should be relatively easy to reproduce on MacOS too.

We support three ways to reproduce the issue:

1. (recommended) use the provided Docker image 
   (requires [Docker](https://docs.docker.com/get-docker/) installed).
2. run the installation script we provided (might not work straight-away in other platforms)
3. install dependencies manually (more instructions below)

#### Use the Docker image (recommended)

Build the Docker image:

```
docker build -t lisa-issue-test .
```

Then, to drop a shell into the image:
```
docker run -it lisa-issue-test /bin/bash
```

Now yoyu 

#### Run installation script

Run the script:
```
./scripts/install-dependencies.sh
```

#### Install dependencies manually

Dependencies:

- Install SPOT. The version used is the latest release `2.9.5`. Please
  follow Lisa project instructions, and use the cloned project in `third_party/spot`.
- Install CUDD.
  Please follow Lisa project instructions, and use the cloned project in `third_party/cudd`.
- Install MONA. I used version `1.4-18` instead of `1.4.17` as stated in 
  Lisa project's README, but I checked manually that there aren't 
  changes to the code, but just on the build configuration files.
  Also, change the macro `#define BDD_MAX_TOTAL_TABLE_SIZE 0x1000000000`
  as stated in the README.
  The change has been already made in [whitemech/MONA](https://github.com/whitemech/MONA.git),
  which is cloned in `third_party/MONA`.
- Install [Syft](https://github.com/Shufang-Zhu/Syft). In particular,
  make sure the binary `ltlf2fol` is available in the path.
- Install Lisa.
  Please follow Lisa project instructions, and use the cloned project in `third_party/lisa`.


## Reproduce

Run the script `print_states.py`. It will run both MONA and Lisa for every dataset item in `datasets/`,
showing the number of states of the MONA and Lisa automata.

Ideally, these numbers should be the same; however, this does not happen for several examples.


```
python scripts/print_states.py
```

You will get something like:
```

```
