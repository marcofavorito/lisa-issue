"""Run this script from the repository root directory."""

from pathlib import Path
from typing import List, Tuple
import subprocess
import tempfile
import re

regex_mona = re.compile("(?<=Automaton has )([0-9]+)")
regex_lisa = re.compile("Final result.*: ([0-9]+)")

TIMEOUT = 10
# to taularize correctly
MIN_FILENAME_PADDING = 32
LONG_CMD_PADDING = 80
SHORT_CMD_PADDING = 62

default_subprocess_config = dict(
stdout=subprocess.PIPE, stderr=subprocess.PIPE, encoding="utf-8"
)

def get_mona_states(file: Path) -> Tuple[int, List[str]]:
    cmd_1 = ["./ltlf2fol", "BNF", str(file)]
    proc = subprocess.Popen(cmd_1, **default_subprocess_config)
    output, err = proc.communicate()
    name = "tmp.mona"
    temp_path = Path(name)
    temp_path.write_text(output)

    cmd_2 = ["mona", "-u", str(temp_path)]
    proc = subprocess.Popen(cmd_2, **default_subprocess_config)
    output, _ = proc.communicate()
    search = regex_mona.search(output)
    assert search is not None
    
    nb_states = search.group(0)
    command_to_reproduce = cmd_1 + ["&&"] + cmd_2
    return nb_states, command_to_reproduce


def get_lisa_explicit_states(file: Path):
    command = ["./bin/lisa", "-exp", "-ltlf", str(file)]
    proc = subprocess.Popen(command, **default_subprocess_config)
    output, err = proc.communicate()
    search = regex_lisa.search(output)
    assert search is not None
    
    nb_states = search.group(1)
    return nb_states, command


def main():
    header = ["dataset file", "MONA command", "Lisa command", "MONA DFA #states", "Lisa DFA #states"]
    datasets = Path("datasets")
    print("\t".join(header))
    for dataset_path in sorted(datasets.iterdir()):
        files = dataset_path.glob("*.ltlf")
        for ltlf_file in sorted(files):
            mona_nb_states, mona_command = get_mona_states(ltlf_file)
            lisa_nb_states, lisa_command = get_lisa_explicit_states(ltlf_file)

            padded_file = str(ltlf_file).ljust(MIN_FILENAME_PADDING)
            padded_mona_cmd = (" ".join(mona_command)).replace("&& mona", "> tmp.mona && mona").ljust(LONG_CMD_PADDING)
            padded_lisa_cmd = (" ".join(lisa_command)).ljust(SHORT_CMD_PADDING)
            print("\t".join([padded_file, padded_mona_cmd,  padded_lisa_cmd, mona_nb_states, lisa_nb_states]))


if __name__ == "__main__":
    main()    
