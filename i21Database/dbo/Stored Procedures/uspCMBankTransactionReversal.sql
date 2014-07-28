
/**Standard temporary table to use: 
* 
* 	CREATE TABLE #tmpCMBankTransaction (
* 		[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL,
* 		UNIQUE (strTransactionId)
* 	)
* 
*/
GO 
CREATE PROCEDURE uspCMBankTransactionReversal
	@intUserId INT  
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Constant variables for payment methods
DECLARE @CASH_PAYMENT AS NVARCHAR(20) = 'Cash'

-- Constant variables for bank account types:
DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
		
-- Constant variables for Check number status. 
DECLARE	@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6		
		
--=====================================================================================================================================
-- 	REVERSAL PROCESS 
---------------------------------------------------------------------------------------------------------------------------------------

/**
* If the transaction has a check number in the check audit table, update the check number status. 
* Conditions:
*	1. If it is a "check" record. Cash payments are not logged. 
*	2. If check is already printed. 
*	3. Update only the unused check numbers. 
*	4. Audit record is not assigned to any other transaction. 
*	5. Check number is not an empty string. 
*/
UPDATE	tblCMCheckNumberAudit
SET		intCheckNoStatus = @CHECK_NUMBER_STATUS_VOID
		,intTransactionId = F.intTransactionId
		,strTransactionId = F.strTransactionId
		,strRemarks = ''
		,intUserId = @intUserId
		,intConcurrencyId += 1 
FROM	tblCMCheckNumberAudit AUDIT INNER JOIN tblCMBankTransaction F
			ON AUDIT.intBankAccountId = F.intBankAccountId
			AND AUDIT.strCheckNo = F.strReferenceNo
		INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	-- Condition #1:
		F.strReferenceNo NOT IN (@CASH_PAYMENT)	
		-- Condition #2:
		AND F.dtmCheckPrinted IS NOT NULL 
		-- Condition #3:
		AND AUDIT.intCheckNoStatus NOT IN (
			@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION
			,@CHECK_NUMBER_STATUS_PRINTED
			,@CHECK_NUMBER_STATUS_VOID
			,@CHECK_NUMBER_STATUS_WASTED
		)
		-- Condition #4:
		AND AUDIT.intTransactionId IS NULL 
		-- Condition #5:
		AND ISNULL(F.strReferenceNo, '') <> ''
IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors		

/**
* If check number audit record is NOT found, create it. 
* Conditions:
*	1. None was updated from the existing check audit records. 
*	2. It is a 'check' transaction. 
*	3. It is a valid check number (not an empty string)
*	4. Check report has been printed on it. 
*/
INSERT INTO tblCMCheckNumberAudit (
		intBankAccountId
		,strCheckNo
		,intCheckNoStatus
		,strRemarks
		,strTransactionId
		,intTransactionId
		,intUserId
		,dtmCreated
		,dtmCheckPrinted
)
SELECT	intBankAccountId = F.intBankAccountId
		,strCheckNo = F.strReferenceNo
		,intCheckNoStatus = @CHECK_NUMBER_STATUS_VOID
		,strRemarks = ''
		,strTransactionId = F.strTransactionId
		,intTransactionId = F.intTransactionId
		,intUserId = @intUserId
		,dtmCreated = GETDATE()
		,dtmCheckPrinted = NULL 
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	NOT EXISTS (
			SELECT	TOP 1 1
			FROM	tblCMCheckNumberAudit AUDIT
			WHERE	AUDIT.intBankAccountId = F.intBankAccountId
					AND AUDIT.strCheckNo = F.strReferenceNo
					AND AUDIT.intTransactionId = F.intTransactionId
					AND AUDIT.intCheckNoStatus = @CHECK_NUMBER_STATUS_VOID
		)
		AND F.strReferenceNo NOT IN (@CASH_PAYMENT)		
		AND ISNULL(F.strReferenceNo, '') <> ''
		AND F.dtmCheckPrinted IS NOT NULL 
IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

/**
* Void the "check" transactions
* Conditions:
*	1. Void only check transactions
*	2. Applicable only on check transactions with printed check report.
*/
UPDATE	tblCMBankTransaction
SET		ysnCheckVoid = 1
		,strReferenceNo = 'Voided' + (CASE WHEN ISNULL(F.strReferenceNo, '') = '' THEN '' ELSE '-' + F.strReferenceNo END)
		,dtmLastModified = GETDATE()
		,intLastModifiedUserId = @intUserId
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT)		
		-- Condition #1:
		AND F.strReferenceNo NOT IN (@CASH_PAYMENT) 
		-- Condition #2:		
		AND F.dtmCheckPrinted IS NOT NULL 
IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

/**
* Delete the bank transactions
* Conditions:
*	1. It is non-check transaction
*	2. If it is a check transaction, the check report was not yet printed.
*/
DELETE tblCMBankTransaction
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT)		
		AND (
			-- Condition #1:
			F.strReferenceNo IN (@CASH_PAYMENT)
			-- Condition #2: 
			OR (
				F.strReferenceNo NOT IN (@CASH_PAYMENT)
				AND F.dtmCheckPrinted IS NULL 		
			)
		)
IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

Exit_Successfully:
	SET @isSuccessful = 1
	GOTO Exit_BankTransactionReversal
	
Exit_BankTransactionReversal_WithErrors:
	SET @isSuccessful = 0		
	GOTO Exit_BankTransactionReversal
	
Exit_BankTransactionReversal: