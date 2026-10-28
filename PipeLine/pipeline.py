import csv
import os

from datetime import datetime
from Connection.config import get_connection

def export_to_csv(query, filename):
    print(f"Exporting {filename}...")
    conn = get_connection()

    cursor = conn.cursor()

    try:
        cursor.execute(query)
        
        with open(f"path/Reports/{filename}", 'w', newline='', encoding='utf-8') as f:
            writer = csv.writer(f)
            
            headers = [i[0] for i in cursor.description]
            writer.writerow(headers)
            
            while True:
                rows = cursor.fetchmany(10000)
                if not rows:
                    break
                writer.writerows(rows)
                
    except Exception as e:
        print(f"Error exporting {filename}: {e}")
    finally:
        cursor.close()
        conn.close()

def run_weekend_pipeline():
    os.makedirs("path/Reports", exist_ok=True)

    export_to_csv("SELECT * FROM users_ref", "new_users.csv")
    export_to_csv("SELECT * FROM Global_transaction", "global_transactions.csv")
    
    export_to_csv("SELECT * FROM CRM_HISTROY", "crm_history.csv")
    export_to_csv("SELECT * FROM UpDownBank_HISTROY", "udb_history.csv")
    export_to_csv("SELECT * FROM Bankcom_HISTROY", "bankcom_history.csv")

    fraud_query = """
    WITH RiskScores AS (
        SELECT 
            customer_id,
            account_number,
            CASE WHEN COUNT(*) OVER (PARTITION BY account_number ORDER BY created_at RANGE BETWEEN INTERVAL 1 MINUTE PRECEDING AND CURRENT ROW) >= 3 
                THEN 30 ELSE 0 END AS score_velocity,
                 
            CASE WHEN HOUR(created_at) >= 0 AND HOUR(created_at) <= 4 
                THEN 20 ELSE 0 END AS score_midnight,
                 
            CASE WHEN amount BETWEEN 4800 AND 4999 
                THEN 20 ELSE 0 END AS score_limit,
                 
            CASE WHEN balance_after = 0 AND transaction_type = 'SENT' 
                THEN 20 ELSE 0 END AS score_drained,
                 
            CASE WHEN amount IN (1000, 2000, 5000) 
                THEN 10 ELSE 0 END AS score_round,
                 
            created_at,
            amount,
            transaction_type
        FROM CRM_HISTROY

        UNION ALL

        SELECT customer_id, account_number, 
               CASE WHEN COUNT(*) OVER (PARTITION BY account_number ORDER BY created_at RANGE BETWEEN INTERVAL 1 MINUTE PRECEDING AND CURRENT ROW) >= 3 THEN 30 ELSE 0 END,
               CASE WHEN HOUR(created_at) >= 0 AND HOUR(created_at) <= 4 THEN 20 ELSE 0 END,
               CASE WHEN amount BETWEEN 4800 AND 4999 THEN 20 ELSE 0 END,
               CASE WHEN balance_after = 0 AND transaction_type = 'SENT' THEN 20 ELSE 0 END,
               CASE WHEN amount IN (1000, 2000, 5000) THEN 10 ELSE 0 END,
               created_at, amount, transaction_type
        FROM UpDownBank_HISTROY

        UNION ALL

        SELECT customer_id, account_number,
               CASE WHEN COUNT(*) OVER (PARTITION BY account_number ORDER BY created_at RANGE BETWEEN INTERVAL 1 MINUTE PRECEDING AND CURRENT ROW) >= 3 THEN 30 ELSE 0 END,
               CASE WHEN HOUR(created_at) >= 0 AND HOUR(created_at) <= 4 THEN 20 ELSE 0 END,
               CASE WHEN amount BETWEEN 4800 AND 4999 THEN 20 ELSE 0 END,
               CASE WHEN balance_after = 0 AND transaction_type = 'SENT' THEN 20 ELSE 0 END,
               CASE WHEN amount IN (1000, 2000, 5000) THEN 10 ELSE 0 END,
               created_at, amount, transaction_type
        FROM Bankcom_HISTROY
    )
    
    SELECT 
        customer_id, 
        account_number,
        SUM(score_velocity + score_midnight + score_limit + score_drained + score_round) AS total_fraud_score,
        COUNT(*) as total_transactions
    FROM RiskScores
    GROUP BY customer_id, account_number
    HAVING total_fraud_score >= 50
    ORDER BY total_fraud_score DESC;
    """
    
    export_to_csv(fraud_query, "suspected_fraudsters.csv")
    
    print("Weekend Pipeline Complete (Check Reports).")

if __name__ == "__main__":
    run_weekend_pipeline()
