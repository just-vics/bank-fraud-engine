USE banks;

-- 1. CREATE TABLES

CREATE TABLE IF NOT EXISTS CRM(
    id varchar(13) PRIMARY KEY, 
    first_name varchar(50) not null,
    surname varchar(50) not null,
    accountnumber varchar(12) Unique not null,
    branchcode int GENERATED ALWAYS AS (123) STORED,
    Bankname varchar(50) NOT NULL DEFAULT 'CRM', 
    balance decimal(9,2) not null default 0.00,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_id_format_crm CHECK (id REGEXP '^[0-9]{13}$'),
    CONSTRAINT ck_acc_format_crm CHECK (accountnumber REGEXP '^[0-9]{12}$')
);

CREATE TABLE IF NOT EXISTS CRM_HISTROY( 
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(13) NOT NULL,          
    account_number VARCHAR(12) NOT NULL,
    transaction_type ENUM('SENT', 'RECEIVED') NOT NULL,
    counterparty_account VARCHAR(12) NOT NULL,
    counterparty_bank VARCHAR(50) NOT NULL,
    amount DECIMAL(9,2) NOT NULL,
    balance_before DECIMAL(9,2) NOT NULL,
    balance_after DECIMAL(9,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_customer_crm FOREIGN KEY (customer_id) REFERENCES CRM (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS CRM_Only_Transactions(
    transaction_id BIGINT auto_increment PRIMARY KEY,
    senderaccount varchar(12) not null,
    recieveraccount varchar(12) not null,
    amount decimal(9,2) not null check(amount>0),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sender_crm FOREIGN KEY (senderaccount) REFERENCES CRM (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT fk_receiver_crm FOREIGN KEY (recieveraccount) REFERENCES CRM (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT ck_diff_acc_crm CHECK (senderaccount <> recieveraccount)
);

CREATE TABLE IF NOT EXISTS UpDownBank(
    id varchar(13) PRIMARY KEY, 
    first_name varchar(50) not null,
    surname varchar(50) not null,
    accountnumber varchar(12) Unique not null,
    branchcode int GENERATED ALWAYS AS (246) STORED,
    Bankname varchar(50) NOT NULL DEFAULT 'UDB', 
    balance decimal(9,2) not null default 0.00,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_id_format_udb CHECK (id REGEXP '^[0-9]{13}$'),
    CONSTRAINT ck_acc_format_udb CHECK (accountnumber REGEXP '^[0-9]{12}$')
);

CREATE TABLE IF NOT EXISTS UpDownBank_HISTROY( 
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(13) NOT NULL,          
    account_number VARCHAR(12) NOT NULL,
    transaction_type ENUM('SENT', 'RECEIVED') NOT NULL,
    counterparty_account VARCHAR(12) NOT NULL,
    counterparty_bank VARCHAR(50) NOT NULL,
    amount DECIMAL(9,2) NOT NULL,
    balance_before DECIMAL(9,2) NOT NULL,
    balance_after DECIMAL(9,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_customer_udb FOREIGN KEY (customer_id) REFERENCES UpDownBank (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS UpDownBank_Only_Transactions(
    transaction_id BIGINT auto_increment PRIMARY KEY,
    senderaccount varchar(12) not null,
    recieveraccount varchar(12) not null,
    amount decimal(9,2) not null check(amount>0),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sender_udb FOREIGN KEY (senderaccount) REFERENCES UpDownBank (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT fk_receiver_udb FOREIGN KEY (recieveraccount) REFERENCES UpDownBank (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT ck_diff_acc_udb CHECK (senderaccount <> recieveraccount)
);

CREATE TABLE IF NOT EXISTS Bankcom(
    id varchar(13) PRIMARY KEY, 
    first_name varchar(50) not null,
    surname varchar(50) not null,
    accountnumber varchar(12) Unique not null,
    branchcode int GENERATED ALWAYS AS (369) STORED,
    Bankname varchar(50) NOT NULL DEFAULT 'BC', 
    balance decimal(9,2) not null default 0.00,
    updated TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_id_format_bc CHECK (id REGEXP '^[0-9]{13}$'),
    CONSTRAINT ck_acc_format_bc CHECK (accountnumber REGEXP '^[0-9]{12}$')
);

CREATE TABLE IF NOT EXISTS Bankcom_HISTROY( 
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    customer_id VARCHAR(13) NOT NULL,          
    account_number VARCHAR(12) NOT NULL,
    transaction_type ENUM('SENT', 'RECEIVED') NOT NULL,
    counterparty_account VARCHAR(12) NOT NULL,
    counterparty_bank VARCHAR(50) NOT NULL,
    amount DECIMAL(9,2) NOT NULL,
    balance_before DECIMAL(9,2) NOT NULL,
    balance_after DECIMAL(9,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_history_customer_bc FOREIGN KEY (customer_id) REFERENCES Bankcom (id) ON DELETE RESTRICT
);

CREATE TABLE IF NOT EXISTS Bankcom_Only_Transactions(
    transaction_id BIGINT auto_increment PRIMARY KEY,
    senderaccount varchar(12) not null,
    recieveraccount varchar(12) not null,
    amount decimal(9,2) not null check(amount>0),
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_sender_bc FOREIGN KEY (senderaccount) REFERENCES Bankcom (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT fk_receiver_bc FOREIGN KEY (recieveraccount) REFERENCES Bankcom (accountnumber) ON DELETE RESTRICT,
    CONSTRAINT ck_diff_acc_bc CHECK (senderaccount <> recieveraccount)  
);

CREATE TABLE IF NOT EXISTS Global_accounts(
    accountnumber varchar(12) primary key,
    bank_name varchar(50) not null,
    customer_id varchar(13) not null,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT ck_acc_format_global CHECK (accountnumber REGEXP '^[0-9]{12}$'),
    CONSTRAINT ck_id_format_global CHECK (customer_id REGEXP '^[0-9]{13}$')
); 

CREATE TABLE IF NOT EXISTS Global_transaction(
    transaction_id BIGINT auto_increment PRIMARY KEY,
    senderaccount varchar(12) not null,
    sender_bankname varchar(50) not null,
    recieveraccount varchar(12) not null,
    reciever_bankname varchar(50) not null,
    amount decimal(9,2) not null check(amount>0),
    trancation_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_global_sender FOREIGN KEY (senderaccount) REFERENCES Global_accounts(accountnumber) ON DELETE RESTRICT,
    CONSTRAINT fk_global_receiver FOREIGN KEY (recieveraccount) REFERENCES Global_accounts(accountnumber) ON DELETE RESTRICT,
    CONSTRAINT ck_global_diff_acc CHECK (senderaccount <> recieveraccount)
);


-- 2.TRIGGERS

DELIMITER //

-- TRIGGER: CRM
CREATE TRIGGER after_crm_internal_transaction
BEFORE INSERT ON CRM_Only_Transactions
FOR EACH ROW
BEGIN
    DECLARE v_sender_id VARCHAR(13);
    DECLARE v_sender_balance DECIMAL(9,2);
    DECLARE v_receiver_id VARCHAR(13);
    DECLARE v_receiver_balance DECIMAL(9,2);

    SELECT id, balance INTO v_sender_id, v_sender_balance FROM CRM WHERE accountnumber = NEW.senderaccount;
    SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM CRM WHERE accountnumber = NEW.recieveraccount;

    IF v_sender_balance < NEW.amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed: Insufficient funds in CRM.';
    END IF;

    UPDATE CRM SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
    INSERT INTO CRM_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, 'CRM', NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));

    UPDATE CRM SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
    INSERT INTO CRM_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, 'CRM', NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
END//

--TRIGGER: UpDownBank
CREATE TRIGGER after_udb_internal_transaction
BEFORE INSERT ON UpDownBank_Only_Transactions
FOR EACH ROW
BEGIN
    DECLARE v_sender_id VARCHAR(13);
    DECLARE v_sender_balance DECIMAL(9,2);
    DECLARE v_receiver_id VARCHAR(13);
    DECLARE v_receiver_balance DECIMAL(9,2);

    SELECT id, balance INTO v_sender_id, v_sender_balance FROM UpDownBank WHERE accountnumber = NEW.senderaccount;
    SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM UpDownBank WHERE accountnumber = NEW.recieveraccount;

    IF v_sender_balance < NEW.amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed: Insufficient funds in UpDownBank.';
    END IF;

    UPDATE UpDownBank SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
    INSERT INTO UpDownBank_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, 'UDB', NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));

    UPDATE UpDownBank SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
    INSERT INTO UpDownBank_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, 'UDB', NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
END//

-- TRIGGER: Bankcom
CREATE TRIGGER after_bc_internal_transaction
BEFORE INSERT ON Bankcom_Only_Transactions
FOR EACH ROW
BEGIN
    DECLARE v_sender_id VARCHAR(13);
    DECLARE v_sender_balance DECIMAL(9,2);
    DECLARE v_receiver_id VARCHAR(13);
    DECLARE v_receiver_balance DECIMAL(9,2);

    SELECT id, balance INTO v_sender_id, v_sender_balance FROM Bankcom WHERE accountnumber = NEW.senderaccount;
    SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM Bankcom WHERE accountnumber = NEW.recieveraccount;

    IF v_sender_balance < NEW.amount THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Transaction failed: Insufficient funds in Bankcom.';
    END IF;

    UPDATE Bankcom SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
    INSERT INTO Bankcom_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, 'BC', NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));

    UPDATE Bankcom SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
    INSERT INTO Bankcom_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
    VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, 'BC', NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
END//

-- TRIGGER: Global_transaction
CREATE TRIGGER after_global_transaction
BEFORE INSERT ON Global_transaction
FOR EACH ROW
BEGIN
    DECLARE v_sender_id VARCHAR(13);
    DECLARE v_sender_balance DECIMAL(9,2);
    DECLARE v_receiver_id VARCHAR(13);
    DECLARE v_receiver_balance DECIMAL(9,2);

    IF NEW.sender_bankname = 'CRM' THEN
        SELECT id, balance INTO v_sender_id, v_sender_balance FROM CRM WHERE accountnumber = NEW.senderaccount;
        IF v_sender_balance < NEW.amount THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Global transfer failed: Insufficient CRM funds.'; END IF;
        UPDATE CRM SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
        INSERT INTO CRM_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, NEW.reciever_bankname, NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));
    ELSEIF NEW.sender_bankname = 'UDB' THEN
        SELECT id, balance INTO v_sender_id, v_sender_balance FROM UpDownBank WHERE accountnumber = NEW.senderaccount;
        IF v_sender_balance < NEW.amount THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Global transfer failed: Insufficient UpDownBank funds.'; END IF;
        UPDATE UpDownBank SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
        INSERT INTO UpDownBank_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, NEW.reciever_bankname, NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));
    ELSEIF NEW.sender_bankname = 'BC' THEN
        SELECT id, balance INTO v_sender_id, v_sender_balance FROM Bankcom WHERE accountnumber = NEW.senderaccount;
        IF v_sender_balance < NEW.amount THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Global transfer failed: Insufficient Bankcom funds.'; END IF;
        UPDATE Bankcom SET balance = balance - NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.senderaccount;
        INSERT INTO Bankcom_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_sender_id, NEW.senderaccount, 'SENT', NEW.recieveraccount, NEW.reciever_bankname, NEW.amount, v_sender_balance, (v_sender_balance - NEW.amount));
    END IF;

    IF NEW.reciever_bankname = 'CRM' THEN
        SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM CRM WHERE accountnumber = NEW.recieveraccount;
        UPDATE CRM SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
        INSERT INTO CRM_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, NEW.sender_bankname, NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
    ELSEIF NEW.reciever_bankname = 'UDB' THEN
        SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM UpDownBank WHERE accountnumber = NEW.recieveraccount;
        UPDATE UpDownBank SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
        INSERT INTO UpDownBank_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, NEW.sender_bankname, NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
    ELSEIF NEW.reciever_bankname = 'BC' THEN
        SELECT id, balance INTO v_receiver_id, v_receiver_balance FROM Bankcom WHERE accountnumber = NEW.recieveraccount;
        UPDATE Bankcom SET balance = balance + NEW.amount, updated = CURRENT_TIMESTAMP WHERE accountnumber = NEW.recieveraccount;
        INSERT INTO Bankcom_HISTROY (customer_id, account_number, transaction_type, counterparty_account, counterparty_bank, amount, balance_before, balance_after)
        VALUES (v_receiver_id, NEW.recieveraccount, 'RECEIVED', NEW.senderaccount, NEW.sender_bankname, NEW.amount, v_receiver_balance, (v_receiver_balance + NEW.amount));
    END IF;
END//

DELIMITER ;