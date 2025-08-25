import subprocess
import time

password=input("Password: ")
# List of scripts to run
coldkey="baz"
hotkeys = [
    "zeus18", "zeus19", "zeus20"
]

max_parallel = 20      # limit to 20 at once

processes = []
try:
    while True:
        for hotkey in hotkeys:
            # Start a new process
            p = subprocess.Popen(["expect", "sn-reg-2.sh", password, coldkey, hotkey])
            processes.append(p)

            # If we reached the max limit, wait until at least one finishes
        while len(processes) >= max_parallel:
            for proc in processes:
                if proc.poll() is not None:  # finished
                    processes.remove(proc)
            time.sleep(0.2)  # avoid busy loop
except:
    for p in processes:
        p.wait()

print("All scripts finished.")
