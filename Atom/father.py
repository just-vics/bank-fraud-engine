import time
import os
import random

from datetime import datetime
from Atom.mother import mother_run
from PipeLine.pipeline import run_weekend_pipeline

STOP_FILE = "path/STOP.txt" 

def is_working_hours():
    current_hour = datetime.now().hour
    if (7 <= current_hour < 9) or (12 <= current_hour < 14) or (19 <= current_hour < 21):
        return True
    return False

def father_run():
    
    print("FATHER started (Active hours: 07:00-09:00, 12:00-14:00, 19:00-21:00)")
    print("To stop the system, create a file named 'STOP.txt' in this folder.\n")

    pipeline_ran_this_weekend = False

    while True:
        if os.path.exists(STOP_FILE):
            print("STOP.txt detected, shutting down all operations.")
            break 

        now = datetime.now()

        if now.weekday() >= 5:
            if now.weekday() == 5 and not pipeline_ran_this_weekend:
                run_weekend_pipeline()
                pipeline_ran_this_weekend = True
                print("Pipeline complete sleeping until Monday.")

            print(f"[{now.strftime('%H:%M:%S')}] Its the weekend, sleeping.")
            time.sleep(3600)
            continue

        if now.weekday()==0:
            pipeline_ran_this_weekend = False

        if is_working_hours():
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Waking up Mother.")

            add = random.randint(1,10)
            trans = random.randint(1,100)

            mother_run(users_to_add=add, transactions_to_run=trans)
            time.sleep(5) 

        else:
            print(f"[{datetime.now().strftime('%H:%M:%S')}] Off-hours, resting")
            time.sleep(120)

if __name__ == "__main__":
    try:
        father_run()
    except KeyboardInterrupt:
        print("\nManual Override (Ctrl+C). Shutting down.")