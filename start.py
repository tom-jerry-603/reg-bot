import subprocess
import time
from getpass import getpass

password = getpass("Enter your database password: ")

# List of scripts to run
netuid = "43"
coldkey="witt"
hotkeys = [
    "graph-1", "graph-2", "graph-3"
]

max_parallel = 30      # limit to 20 at once

processes = []
try:
    while True:
        for hotkey in hotkeys:
            # Start a new process
            p = subprocess.Popen(["expect", "sn-reg-2.sh", password, coldkey, hotkey, netuid])
            processes.append(p)

            # If we reached the max limit, wait until at least one finishes
        while len(processes) >= max_parallel:
            for proc in processes:
                if proc.poll() is not None:  # finished
                    processes.remove(proc)
            time.sleep(0.1)  # avoid busy loop
except:
    for p in processes:
        p.wait()

print("All scripts finished.")
