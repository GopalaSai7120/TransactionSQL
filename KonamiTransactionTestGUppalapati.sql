
/**
     *PROBLEM STATEMENT:
     * Given Sample Input Tables-
     * PERSON_TABLE:
     * _______________________________
     * | PERSON_ID    | PERSON_NAME  |
     * |--------------|--------------|
     * | 1            | Joe          |
     * | 2            | Tom          |
     * | 3            | Steve        |
     * -------------------------------
     * TRANSACTION_TYPE_TABLE:
     * ______________________________________________
     * | TRANSACTION_TYPE_ID    | TRANSACTION_NAME  |
     * |------------------------|-------------------|
     * | 1                      | DEPOSIT           |
     * | 2                      | WITHDRAWAL        |
     * | 3                      | ADJUST            |
     * | 4                      | DEPOSIT_VOID      |
     * ----------------------------------------------
     * PERSON_CAN_DO_TABLE:
     * ______________________________________
     * | PERSON_ID    | TRANSACTION_TYPE_ID |
     * |--------------|---------------------|
     * | 1            | 1                   |
     * | 1            | 2                   |
     * | 1            | 3                   |
     * --------------------------------------
     * Write funtions required for TRANSACTION_TABLE
     * 1) Write a business function to correctly insert the green record(104) here.
     *    The business use case is that the user of the application made a mistake and
     *    would like to "Void" one of the existing transactions they just made in the system
     * 2) Make sure to provide ample exception handling for any incoming parameters you request.
     * __________________________________________________________________________________________
     * | Transaction ID  | Transaction Name  | Amount | Person ID | Unique Transaction Sequence |
     * |-----------------|-------------------|--------|-----------|-----------------------------|
     * | 100             | DEPOSIT           | 100    | 1         | 1                           |
     * | 101             | DEPOSIT           | 120    | 2         | 2                           |
     * | 102             | ADJUST            |  50    | 1         | 1                           |
     * | 103             | WITHDRAW          | 1000   | 3         | 1                           |
     * | 104             | DEPOSIT_VOID      | 120    | 2         | 2                           |
     * ------------------------------------------------------------------------------------------
     *
     * DESIGN APPROACH:
     * DEPOSIT_VOID Transaction:
     * 1)Verify Input Parameters are passed correctly in CORRECT format (Data type validation)
     * 2)Verify if PERSON exists in the system by using PERSON_ID in PERSON_TABLE
     * 3)Verify TRANSACTION_TYPE by Transaction Name in TRANSACTION_TYPE_TABLE
     *   if User is trying to perform valid transaction
     * 4)Verify if Person has access to perform transaction in PERSON_CAN_DO Table
     * 5)Verify if Unique Transaction Sequence exists in history by checking
     *   sequence number , DEPOSIT transaction type and amount
     * 6)if all conditions are met proceed with Inserting DEPOSIT_VOID Transaction
    * */

-- Create PERSON_TABLE
CREATE TABLE PERSON_TABLE (
    PERSON_ID INT PRIMARY KEY,
    PERSON_NAME NVARCHAR(255) NOT NULL
);

-- Create TRANSACTION_TYPE_TABLE
CREATE TABLE TRANSACTION_TYPE_TABLE (
    TRANSACTION_TYPE_ID INT PRIMARY KEY,
    TRANSACTION_NAME NVARCHAR(255) NOT NULL
);

-- Create PERSON_CAN_DO_TABLE
CREATE TABLE PERSON_CAN_DO_TABLE (
    PERSON_ID INT,
    TRANSACTION_TYPE_ID INT,
    FOREIGN KEY (PERSON_ID) REFERENCES PERSON_TABLE(PERSON_ID),
    FOREIGN KEY (TRANSACTION_TYPE_ID) REFERENCES TRANSACTION_TYPE_TABLE(TRANSACTION_TYPE_ID)
);

-- Create TRANSACTION_TABLE
CREATE TABLE TRANSACTION_TABLE (
    TransactionID INT PRIMARY KEY,
    TransactionName NVARCHAR(255) NOT NULL,
    Amount INT NOT NULL,
    PersonID INT,
    UniqueTransactionSequence INT,
    FOREIGN KEY (PersonID) REFERENCES PERSON_TABLE(PERSON_ID)
);


---USER DEFINED STORE PROC

CREATE PROCEDURE InsertDepositVoidTransaction
    @TransactionID INT,
    @TransactionName NVARCHAR(255),
    @Amount INT,  -- Modified to INT
    @PersonID INT,
    @UniqueTransactionSequence INT
AS
BEGIN
    -- Step 1: Verify Input Parameters
    IF @TransactionName <> 'DEPOSIT_VOID'
    BEGIN
        -- Invalid Transaction Name
        THROW 50001, 'Invalid Transaction Name for DEPOSIT_VOID', 1;
        RETURN;
    END

    -- Step 2: Verify if PERSON exists
    IF NOT EXISTS (SELECT 1 FROM PERSON_TABLE WHERE PERSON_ID = @PersonID)
    BEGIN
        -- Person not found
        THROW 50002, 'Person not found in the system', 1;
        RETURN;
    END

    -- Step 3: Verify TRANSACTION_TYPE
    IF NOT EXISTS (SELECT 1 FROM TRANSACTION_TYPE_TABLE WHERE TRANSACTION_NAME = @TransactionName)
    BEGIN
        -- Invalid Transaction Type
        THROW 50003, 'Invalid Transaction Type for DEPOSIT_VOID', 1;
        RETURN;
    END

    -- Step 4: Verify if Person has access to perform transaction
    IF NOT EXISTS (SELECT 1 FROM PERSON_CAN_DO_TABLE WHERE PERSON_ID = @PersonID AND TRANSACTION_TYPE_ID = (SELECT TRANSACTION_TYPE_ID FROM TRANSACTION_TYPE_TABLE WHERE TRANSACTION_NAME = @TransactionName))
    BEGIN
        -- Person does not have access
        THROW 50004, 'Person does not have access to perform DEPOSIT_VOID transaction', 1;
        RETURN;
    END

    -- Step 5: Verify if Unique Transaction Sequence exists in history
    IF NOT EXISTS (SELECT 1 FROM TRANSACTION_TABLE WHERE TransactionID = @UniqueTransactionSequence AND TransactionName = 'DEPOSIT' AND Amount = @Amount)
    BEGIN
        -- Unique Transaction Sequence not found
        THROW 50005, 'Unique Transaction Sequence not found in history for DEPOSIT_VOID', 1;
        RETURN;
    END

    -- Step 6: Insert DEPOSIT_VOID Transaction
    INSERT INTO TRANSACTION_TABLE (TransactionID, TransactionName, Amount, PersonID, UniqueTransactionSequence)
    VALUES (@TransactionID, @TransactionName, @Amount, @PersonID, @UniqueTransactionSequence);
END;



