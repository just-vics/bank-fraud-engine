# Autonomous Multi-Bank Fraud Detection Engine
An end-to-end, autonomous banking simulation and fraud detection engine built using **Python** and **MySQL**. This project simulates real-world banking operations across three distinct banks, processes millions of transactions using triggers, and utilizes an ETL pipeline to export transaction histories to CSV files for Business Intelligence (BI) analysis.

## How it works
1. A background process constantly monitors the system time. During "peak banking hours" (07:00-09:00, 12:00-14:00, 19:00-21:00), it wakes up the engine. Outside these hours, it sleeps to conserve resources.
2. When triggered, it uses threads to run two operations simultaneously without blocking. 
    * *Thread 1* constantly generates synthetic users by sampling 14.3 million real names from the database, creating unique 13-digit IDs, and opening accounts at random banks.
    * *Thread 2* continuously selects random senders and receivers from the Global_accounts table and fires transactions between them.
3. Python sends the transaction request to MySQL. The database's triggers automatically verify if the sender has sufficient funds, deduct/add the money to the respective balances, and log the history for both parties.
4. Every Saturday, the system shuts down the simulation and runs the a pipeline script. It streams all transaction histories to CSV files and runs a complex SQL Window Function query that assigns a **Risk Score** to every account based on behavior. Allowing BI's to analyse the data using PowerBi

## Atom Engine
The core logic is separated into three files to ensure clean architecture:

* **`father.py` (The Scheduler):** It checks the system clock, enforces active banking hours, and triggers the weekend ETL pipeline. It also monitors for the `STOP.txt` kill switch.
* **`mother.py` (The Orchestrator):** The thread manager, it receives the order to run from the Father to run the generation and transaction loops simultaneously.
* **`child.py` (The Worker):** The heavy lifter, it contains the actual SQL logic for generating unique synthetic identities, inserting them into the correct banks, and executing random money transfers.

## Atom Features
* **Triggers:** Banking logic is offloaded to MySQL. Triggers handle sufficient fund checks, update balances instantly, and log historical data to `SENT` and `RECEIVED` tables.
* **Pipeline:** An automated script that loads millions of rows to CSV and runs` queries to detect fraud velocity, structuring, and account draining.
* **Automation:** Fully autonomous execution, the system runs on a schedule, processes transactions concurrently, and shuts down on weekends to run reports.
* **Threads:** Generates new users and processes transactions at the exact same time. 

## Stack
**Language:** Python 
**Database:** MySQL

## Setup
To run this project locally, you must set up the MySQL database.
### 1. Create the Database & Tables
1. Open MySQL Workbench.
2. Create a database named `banks`: `CREATE DATABASE banks;`
3. Run the provided **[schema.sql](schema.sql)** file (included in this repo) to automatically create all the tables, constraints, and triggers for the three banks (`CRM`, `UpDownBank`, `Bankcom`).

### 2. Generate the `users_ref` Table
The engine requires a massive dataset of names to sample from. Because the CSV is too large for GitHub, 
the `name_surname_sample.csv` is provided separately. 

CREATE TABLE IF NOT EXISTS users_ref (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    surname VARCHAR(50) NOT NULL
)

## How to Run 
1. Install the required dependencies:pip install -r requirements.txt

Got to your terminal and enter:
                               python -m Atom.father
To stop the engine:
                   Create a file named STOP.txt in the root folder or Ctrl+c in the terminal

# Note
Create a .env file in the root directory using .env.example as a template.(Add your MySQL credentials to the .env file)


