# Issue on DFA construction of Lisa

Link to the issue:
https://github.com/vardigroup/lisa/issues/2

This repository contains the scripts to reproduce an issue
I found on [Lisa](https://github.com/vardigroup/lisa),
a SOTA tool for LTLf synthesis. 

Lisa is a tool published
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

Now you can run the "Reproduce" section inside the Docker image.

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
  make sure the binary `ltlf2fol` is available in the path. That is the
  only one (no synthesis) we need to transform the `.ltlf` file into a `.mona` file.
- Install Lisa.
  Please follow Lisa project instructions, and use the cloned project in `third_party/lisa`.


## Reproduce

First, let's try some automaton manually; we will then run a script that will automate this part.

### Manual runs

#### Positive example

Let's take `datasets/ex_lisa/ltlf3377.ltlf` as first example.

To produce the automaton with Syft+MONA, run:
```
./ltlf2fol BNF datasets/ex_lisa/ltlf3377.ltlf > tmp.mona && mona -u tmp.mona
```
This command will print something like:

```
MONA v1.4-18 for WS1S/WS2S
Copyright (C) 1997-2016 Aarhus University

PARSING
Time: 00:00:00.01

CODE GENERATION
DAG hits: 4968, nodes: 110
Time: 00:00:00.00

REDUCTION
Projections removed: 1 (of 17)
Products removed: 4 (of 62)
Other nodes removed: 1 (of 30)
DAG nodes after reduction: 103
Time: 00:00:00.00

AUTOMATON CONSTRUCTION                
100% completed                                                                         
Time: 00:00:00.03

Automaton has 3377 states and 18454 BDD-nodes

ANALYSIS
A counter-example of least length (1) is:
...
```

To do the same with Lisa-explicit, run:
```
./bin/lisa -exp -ltlf datasets/ex_lisa/ltlf3377.ltlf
```
The output will be:
```
tarting the decomposition phase
Breaking formula into small pieces...
Starting the composition phase
Number of DFAs in the set: 3
Number of states or nodes in M1 and M2: 17,  17
Number of states in explicit product is: 227
Number of DFAs in the set: 2
Number of states or nodes in M1 and M2: 17,  227
Number of states in explicit product is: 3377
Finished constructing minimal dfa in 665.684ms ...
Number of states (or nodes) is: 3377
Final result (or number of nodes): 3377
```

As we can see, the number of states of the minimal DFA is `3377`, both in Syft+MONA and in Lisa-explicit.

#### Negative example

However, for other data, this is not the case.

Take `datasets/ex_lisa/cc.ltlf`.

With Syft+MONA:
```
./ltlf2fol BNF datasets/ex_lisa/cc.ltlf > tmp.mona && mona -u tmp.mona
```
You should see:
```
MONA v1.4-18 for WS1S/WS2S
Copyright (C) 1997-2016 Aarhus University

PARSING
Time: 00:00:00.00

CODE GENERATION
DAG hits: 1511, nodes: 80
Time: 00:00:00.00

REDUCTION
Projections removed: 1 (of 10)
Products removed: 4 (of 41)
Other nodes removed: 1 (of 28)
DAG nodes after reduction: 73
Time: 00:00:00.00

AUTOMATON CONSTRUCTION
100% completed                                                                         
Time: 00:00:00.00

Automaton has 7 states and 30 BDD-nodes

ANALYSIS
...
```
That is, the minimal automaton has `7` states.

Now, let's do the same with Lisa-explicit:
```
./bin/lisa -exp -ltlf datasets/ex_lisa/cc.ltlf
```

We get:
```
Starting the decomposition phase
Breaking formula into small pieces...
Starting the composition phase
Number of DFAs in the set: 3
Number of states or nodes in M1 and M2: 1,  3
Number of states in explicit product is: 1
Number of DFAs in the set: 2
Number of states or nodes in M1 and M2: 1,  4
Number of states in explicit product is: 1
Finished constructing minimal dfa in 16.425ms ...
Number of states (or nodes) is: 1
Final result (or number of nodes): 1
```

Where it computes a minimal DFA with a number of states equal to `1`.

The same happens for several examples (see below).

### Automated script

Run the script `print_states.py`: 
```
python scripts/print_states.py
```

It will run both MONA and Lisa for every dataset item in `datasets/`,
showing the number of states of the MONA and Lisa automata.
The script runs the same commands we showed in the previous section, plus
extracting via regex. the number of states from the output of both tools.

Ideally, these numbers should always be the same; however, this does not happen for several examples.


You will get a `.tsv` like:
```
dataset file	MONA command	Lisa command	MONA DFA #states	Lisa DFA #states
datasets/ex_lisa/cc.ltlf        	./ltlf2fol BNF datasets/ex_lisa/cc.ltlf > tmp.mona && mona -u tmp.mona          	./bin/lisa -exp -ltlf datasets/ex_lisa/cc.ltlf                	7	1
datasets/ex_lisa/counter_1.ltlf 	./ltlf2fol BNF datasets/ex_lisa/counter_1.ltlf > tmp.mona && mona -u tmp.mona   	./bin/lisa -exp -ltlf datasets/ex_lisa/counter_1.ltlf         	7	1
datasets/ex_lisa/counter_2.ltlf 	./ltlf2fol BNF datasets/ex_lisa/counter_2.ltlf > tmp.mona && mona -u tmp.mona   	./bin/lisa -exp -ltlf datasets/ex_lisa/counter_2.ltlf         	13	1
datasets/ex_lisa/counters_1.ltlf	./ltlf2fol BNF datasets/ex_lisa/counters_1.ltlf > tmp.mona && mona -u tmp.mona  	./bin/lisa -exp -ltlf datasets/ex_lisa/counters_1.ltlf        	13	1
datasets/ex_lisa/counters_2.ltlf	./ltlf2fol BNF datasets/ex_lisa/counters_2.ltlf > tmp.mona && mona -u tmp.mona  	./bin/lisa -exp -ltlf datasets/ex_lisa/counters_2.ltlf        	47	1
datasets/ex_lisa/ltlf3377.ltlf  	./ltlf2fol BNF datasets/ex_lisa/ltlf3377.ltlf > tmp.mona && mona -u tmp.mona    	./bin/lisa -exp -ltlf datasets/ex_lisa/ltlf3377.ltlf          	3377	3377
datasets/ex_lisa/req.ltlf       	./ltlf2fol BNF datasets/ex_lisa/req.ltlf > tmp.mona && mona -u tmp.mona         	./bin/lisa -exp -ltlf datasets/ex_lisa/req.ltlf               	17	17
datasets/ex_lisa/req1.ltlf      	./ltlf2fol BNF datasets/ex_lisa/req1.ltlf > tmp.mona && mona -u tmp.mona        	./bin/lisa -exp -ltlf datasets/ex_lisa/req1.ltlf              	8	6
datasets/ex_lisa/testcase.ltlf  	./ltlf2fol BNF datasets/ex_lisa/testcase.ltlf > tmp.mona && mona -u tmp.mona    	./bin/lisa -exp -ltlf datasets/ex_lisa/testcase.ltlf          	6	5
datasets/len_1/001.ltlf         	./ltlf2fol BNF datasets/len_1/001.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/001.ltlf                 	3	6
datasets/len_1/002.ltlf         	./ltlf2fol BNF datasets/len_1/002.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/002.ltlf                 	35	1
datasets/len_1/003.ltlf         	./ltlf2fol BNF datasets/len_1/003.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/003.ltlf                 	1	1
datasets/len_1/004.ltlf         	./ltlf2fol BNF datasets/len_1/004.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/004.ltlf                 	3	6
datasets/len_1/005.ltlf         	./ltlf2fol BNF datasets/len_1/005.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/005.ltlf                 	516	1
datasets/len_1/006.ltlf         	./ltlf2fol BNF datasets/len_1/006.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/006.ltlf                 	3	6
datasets/len_1/007.ltlf         	./ltlf2fol BNF datasets/len_1/007.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/007.ltlf                 	515	1
datasets/len_1/008.ltlf         	./ltlf2fol BNF datasets/len_1/008.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/008.ltlf                 	67	66
datasets/len_1/009.ltlf         	./ltlf2fol BNF datasets/len_1/009.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/009.ltlf                 	3	6
datasets/len_1/010.ltlf         	./ltlf2fol BNF datasets/len_1/010.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/010.ltlf                 	3	6
datasets/len_1/011.ltlf         	./ltlf2fol BNF datasets/len_1/011.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/011.ltlf                 	132	1
datasets/len_1/012.ltlf         	./ltlf2fol BNF datasets/len_1/012.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/012.ltlf                 	3	6
datasets/len_1/013.ltlf         	./ltlf2fol BNF datasets/len_1/013.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/013.ltlf                 	35	1
datasets/len_1/014.ltlf         	./ltlf2fol BNF datasets/len_1/014.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/014.ltlf                 	131	1
datasets/len_1/015.ltlf         	./ltlf2fol BNF datasets/len_1/015.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/015.ltlf                 	68	1
datasets/len_1/016.ltlf         	./ltlf2fol BNF datasets/len_1/016.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/016.ltlf                 	1	1
datasets/len_1/017.ltlf         	./ltlf2fol BNF datasets/len_1/017.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/017.ltlf                 	67	1
datasets/len_1/018.ltlf         	./ltlf2fol BNF datasets/len_1/018.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/018.ltlf                 	259	1
datasets/len_1/019.ltlf         	./ltlf2fol BNF datasets/len_1/019.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/019.ltlf                 	35	1
datasets/len_1/020.ltlf         	./ltlf2fol BNF datasets/len_1/020.ltlf > tmp.mona && mona -u tmp.mona           	./bin/lisa -exp -ltlf datasets/len_1/020.ltlf                 	132	1
```

An example of the truncated output is in `output-example.tsv`.
