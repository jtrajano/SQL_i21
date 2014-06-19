
/**
* This function will centralize the validation of CM record/s prior to unposting or voiding it. 
* 
* When unposting a transaction (ex. Pay Bill, Pay Check, or Misc Checks), call this function to validate the bank transaction. 
* It will check each record against all the possible errors. 
* All errors related to a specific record is returned in a table. A record can have multiple errors. 
* If nothing is returned, the record is safe for voiding and/or unposting. 
* 
* Sample usage: 
*
*	SELECT	B.*
*	FROM	tblCMBankTransaction A CROSS APPLY dbo.fnGetBankTransactionReversalErrors(A.intTransactionId) B
* 
*/
CREATE FUNCTION fnGetBankTransactionReversalErrors (@intId AS INT)
RETURNS TABLE 
AS
RETURN (
	
	SELECT * FROM (
		-- Check if the transaction still exists 
		SELECT	intBankTransactionId = @intId
				,strText = FORMATMESSAGE(50004)
				,intErrorCode = 50004
		WHERE	NOT EXISTS (SELECT TOP 1 1 FROM tblCMBankTransaction WHERE intTransactionId = @intId)	
		
		-- Check if the transaction is already cleared from the bank reconciliation 
		UNION ALL 
		SELECT	intBankTransactionId = @intId
				,strText = FORMATMESSAGE(50009)
				,intErrorCode = 50009
		WHERE	EXISTS (SELECT TOP 1 1 FROM tblCMBankTransaction WHERE intTransactionId = @intId AND ysnClr = 1)	
		
		-- Check if the transaction is already voided. 
		UNION ALL 
		SELECT	intBankTransactionId = @intId
				,strText = FORMATMESSAGE(50012)
				,intErrorCode = 50012
		WHERE	EXISTS (SELECT TOP 1 1 FROM tblCMBankTransaction WHERE intTransactionId = @intId AND ysnCheckVoid = 1)
		
		-- Check if the bank account is inactive
		UNION ALL 
		SELECT	intBankTransactionId = @intId
				,strText = FORMATMESSAGE(50010)
				,intErrorCode = 50010
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	tblCMBankTransaction a INNER JOIN tblCMBankAccount b
								ON a.intBankAccountId = b.intBankAccountId
					WHERE	a.intTransactionId = @intId 
							AND b.ysnActive = 0
				)
				
		-- Check if a check transaction is currently being printed. 
		UNION ALL 
		SELECT	intBankTransactionId = @intId
				,strText = FORMATMESSAGE(50025)
				,intErrorCode = 50025
		WHERE	EXISTS (
					SELECT	TOP 1 1 
					FROM	tblCMBankTransaction a INNER JOIN tblCMCheckPrintJobSpool b
								ON a.intBankAccountId = b.intBankAccountId
								AND a.intTransactionId = b.intTransactionId
					WHERE	a.intTransactionId = @intId 
				)			

	) AS Query		
)

GO