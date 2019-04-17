CREATE PROCEDURE uspCMRecalcBankAccountRegister
(
	@intBankAccountId INT
)
AS
MERGE
	INTO	dbo.[tblCMBankAccountRegisterRunningBalance]
	WITH	(HOLDLOCK)
	AS		CM_Table
USING(
select row_number() over(order by intTransactionId,  dtmDate) 
rowId, 
dblAmount , 
intTransactionId,
intBankAccountId,
dtmDate 
from tblCMBankTransaction where ysnPosted = 1 
and intBankAccountId = @intBankAccountId
) AS Query_Order
ON Query_Order.rowId = CM_Table.rowId
AND Query_Order.intBankAccountId = CM_Table.intBankAccountId

WHEN MATCHED THEN
UPDATE 
SET
dblAmount = Query_Order.dblAmount,
intTransactionId =Query_Order.intTransactionId,
dtmDate = Query_Order.dtmDate,
intConcurrencyId = intConcurrencyId + 1
WHEN NOT MATCHED  THEN 
		INSERT (
		intBankAccountId,
		rowId,
		dtmDate,
		intTransactionId,
		dblAmount,
		intConcurrencyId
		)
		values(
			Query_Order.intBankAccountId,
			Query_Order.rowId,
			Query_Order.dtmDate,
			Query_Order.intTransactionId,
			Query_Order.dblAmount,
			1
)
WHEN NOT MATCHED BY SOURCE THEN
	DELETE;

		