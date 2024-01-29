### Problem Statement
Write DEPOSIT_VOID required for the TRANSACTION_TABLE:

1. Write a business function to correctly insert the green record(104) here. The business use case is that the user of the application made a mistake and would like to "Void" one of the existing transactions they just made in the system
2. Make sure to provide ample exception handling for any incoming parameters you request.

## Design Approach

### DEPOSIT_VOID Transaction:

1. Verify Input Parameters are passed correctly in the correct format (Data type validation).
2. Verify if PERSON exists in the system by using PERSON_ID in PERSON_TABLE.
3. Verify TRANSACTION_TYPE by Transaction Name in TRANSACTION_TYPE_TABLE if the user is trying to perform a valid transaction.
4. Verify if the Person has access to perform the transaction in PERSON_CAN_DO_TABLE.
5. Verify if the Unique Transaction Sequence exists in history by checking sequence number, DEPOSIT transaction type, and amount.
6. If all conditions are met, proceed with Inserting DEPOSIT_VOID Transaction.
