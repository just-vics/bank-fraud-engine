import random
import mysql.connector

from mysql.connector import Error
from Connection.config import get_connection

def atom_child_generate():
    conn = get_connection()
    cursor = conn.cursor()

    try:

            random_id_1 = random.randint(1, 14323332)
            random_id_2 = random.randint(1, 14323332)

            cursor.execute("SELECT name FROM users_ref WHERE id = %s", (random_id_1,))
            first_name = cursor.fetchone()[0]

            cursor.execute("SELECT surname FROM users_ref WHERE id = %s", (random_id_2,))
            surname = cursor.fetchone()[0]

            random_id_id=random.randint(1111111111111,9999999999999)

            acc_crm=random.randint(111111111111,333333333333) 
            acc_up=random.randint(444444444444,666666666666)
            acc_com=random.randint(777777777777,999999999999)

            amount=round(random.uniform(100.0, 50000.0),2)

            return first_name, surname, random_id_id,acc_crm, acc_up, acc_com,amount

    finally:
        cursor.close()
        conn.close()

def atom_insert_table(first_name, surname, random_id_id,acc_crm, acc_up, acc_com,amount):
    
    try:
        conn = get_connection()
        cursor = conn.cursor()

        selection=random.randint(1,3)

        if selection == 1:
            cursor.execute("Select count(*) as ID from CRM where id =%s",(random_id_id,))
            if cursor.fetchone()[0] == 0:
                    while True:
                        cursor.execute("Select count(*) as acc from CRM where accountnumber=%s",(acc_crm,))
                        if cursor.fetchone()[0]==0:
                            break
                        else:
                            acc_crm = random.randint(111111111111,333333333333)

                    sql=""" 
                    insert into CRM (id, first_name, surname, accountnumber, balance) 
                    VALUES (%s, %s, %s, %s, %s)
                    """
                    cursor.execute(sql,(random_id_id, first_name, surname, acc_crm, amount))
                    cursor.execute("INSERT INTO Global_accounts (accountnumber, bank_name, customer_id) VALUES (%s, %s, %s)", (acc_crm, 'CRM', random_id_id))
                    conn.commit()
                    print(f"Success {first_name} added to CRM.")
            else:
                print(f"User {random_id_id} already has a CRM account...skipping")
            return

        elif selection == 2:
            cursor.execute("Select count(*) as ID from UpDownBank where id =%s",(random_id_id,))
            if cursor.fetchone()[0]==0:
                while True:
                    cursor.execute("Select count(*) as acc from UpDownBank where accountnumber=%s",(acc_up,))

                    if cursor.fetchone()[0]==0:
                        break
                    else:
                        acc_up=random.randint(444444444444,666666666666)

                sql=""" 
                insert into UpDownBank (id, first_name, surname, accountnumber, balance) 
                VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(sql,(random_id_id, first_name, surname, acc_up, amount))
                cursor.execute("INSERT INTO Global_accounts (accountnumber, bank_name, customer_id) VALUES (%s, %s, %s)", (acc_up, 'UDB', random_id_id))
                conn.commit()
            else:
                print(f"User {random_id_id} already has an UpDownBank account...skipping")
            return


        elif selection == 3:
            cursor.execute("Select count(*) as ID from Bankcom where id =%s", (random_id_id,))
            if cursor.fetchone()[0]==0:
                while True:
                    cursor.execute("Select count(*) as acc from Bankcom where accountnumber=%s",(acc_com,))
                    if cursor.fetchone()[0]==0:
                        break
                    else:
                        acc_com=random.randint(777777777777,999999999999)

                sql=""" 
                insert into Bankcom (id, first_name, surname, accountnumber, balance) 
                VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(sql,(random_id_id, first_name, surname, acc_com, amount))
                cursor.execute("INSERT INTO Global_accounts (accountnumber, bank_name, customer_id) VALUES (%s, %s, %s)", (acc_com, 'BC', random_id_id))
                conn.commit()
            else:
                print(f"User {random_id_id} already has a Bankcom account...skipping")
            return
            
    finally:
        cursor.close()
        conn.close()

def atom_operations():
    conn = get_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        cursor.execute("SELECT accountnumber, bank_name, customer_id FROM Global_accounts ORDER BY RAND() LIMIT 1")
        sender = cursor.fetchone()

        if not sender:
            print("Not enough users to send")
            return

        cursor.execute("""SELECT accountnumber, bank_name, customer_id FROM Global_accounts WHERE accountnumber != %s  ORDER BY RAND() LIMIT 1
        """, (sender['accountnumber'],))
        receiver = cursor.fetchone()

        if not receiver:
            print("Not enough users to transact.")
            return

        print("\n--- TRANSACTION DETAILS ---")
        print(f"Sender: {sender['accountnumber']} ({sender['bank_name']})")
        print(f"Receiver: {receiver['accountnumber']} ({receiver['bank_name']})")

        amount = round(random.uniform(1000.0, 5000.0), 2)
        print(f"Amount:  R{amount}\n") 

        try:
            if sender['bank_name'] == receiver['bank_name']:
                if sender['bank_name'] == 'CRM':
                    table_name = "CRM_Only_Transactions"
                elif sender['bank_name'] == 'UDB': 
                    table_name = "UpDownBank_Only_Transactions"
                else: 
                    table_name = "Bankcom_Only_Transactions"

                sql = f"""
                    INSERT INTO {table_name} (senderaccount, recieveraccount, amount) 
                    VALUES (%s, %s, %s)
                """
                cursor.execute(sql, (sender['accountnumber'], receiver['accountnumber'], amount))
                conn.commit()
                print(f"Internal transfer completed in {sender['bank_name']}.")

            else:
                sql = """
                    INSERT INTO Global_transaction 
                    (senderaccount, sender_bankname, recieveraccount, reciever_bankname, amount) 
                    VALUES (%s, %s, %s, %s, %s)
                """
                cursor.execute(sql, (sender['accountnumber'],sender['bank_name'],receiver['accountnumber'],receiver['bank_name'], amount))
                conn.commit()
                print(f"Global transfer completed from {sender['bank_name']} to {receiver['bank_name']}.")

        except mysql.connector.Error as err:
            print(f"Transaction Failed: {err}")
            
    finally:
        cursor.close()
        conn.close()