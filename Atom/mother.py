import os
import time

from concurrent.futures import ThreadPoolExecutor
from Atom.child import atom_child_generate, atom_insert_table,atom_operations

STOP_FILE = "path/STOP.txt"

def use_child_generate():
    data = atom_child_generate()

    atom_insert_table(*data)

def transact():
    atom_operations()

def generate_loop(count):
    print(f"[THREAD 1] Starting generation of {count} users.")
    for i in range(count):
        if os.path.exists(STOP_FILE): return
        use_child_generate()
        if (i + 1) % 10 == 0:
            print(f"[THREAD 1] Generated {i + 1}/{count} users.")
    print(f"[THREAD 1] Finished generating {count} users.")

def transact_loop(count):
    print(f"[THREAD 2] Starting {count} transactions.")
    for i in range(count):
        if os.path.exists(STOP_FILE): return
        transact()
        if (i + 1) % 100 == 0:
            print(f"[THREAD 2] Completed {i + 1}/{count} transactions.")
    print(f"[THREAD 2] Finished {count} transactions.")


def mother_run(users_to_add, transactions_to_run):
    print(f"\nMOTHER Initiated")
    
    start_time = time.time()

    with ThreadPoolExecutor(max_workers=2) as executor:
        future_generate = executor.submit(generate_loop, users_to_add)
        future_transact = executor.submit(transact_loop, transactions_to_run)

        future_generate.result()
        future_transact.result()

    end_time = time.time()
    total_time = round(end_time - start_time, 2)
    
    print(f"\n MOTHER Complete in {total_time} seconds")




