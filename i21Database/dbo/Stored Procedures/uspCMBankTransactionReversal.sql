
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
	@intUserId INT,
	@dtmReverseDate DATETIME = NULL
	,@isSuccessful BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Local Variable for Reversing Date
DECLARE @dtmReversalDate AS DATETIME,
		@intTransactionId AS INT,
		@intVoidTransactionId AS INT

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
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@ACH AS INT = 22
		,@DIRECT_DEPOSIT AS INT = 23
		
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

/** Check if Reversing Date is specified. 
*	-If no Reversing Date specified, do the default Voiding procedure
*	-Otherwise, do the Void Check Reversal Procedure 
*   (This is temporary condition until reversal procedure is finalized)
*/
IF (@dtmReverseDate IS NULL)
	BEGIN
		/**
		* Void the "check" transactions
		* Conditions:
		*	1. Void only check transactions
		*	2. Applicable only on check transactions with printed check report.
		*	3. Void process is applicable for checks issued in AP Payment, Misc Checks, and from origin. 
		*/
		UPDATE	tblCMBankTransaction
		SET		ysnCheckVoid = 1
				,ysnPosted = 0
				,strReferenceNo = 'Voided' + (CASE WHEN ISNULL(F.strReferenceNo, '') = '' THEN '' ELSE '-' + F.strReferenceNo END)
				,dtmLastModified = GETDATE()
				,intLastModifiedUserId = @intUserId
		FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
					ON F.strTransactionId = TMP.strTransactionId
		WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS, @PAYCHECK)		
				-- Condition #1:
				AND F.strReferenceNo NOT IN (@CASH_PAYMENT) 
				-- Condition #2:		
				AND F.dtmCheckPrinted IS NOT NULL 

		--Remove transaction if its on check print spool
		IF EXISTS (SELECT * FROM tblCMCheckPrintJobSpool Spool INNER JOIN #tmpCMBankTransaction TMP ON Spool.strTransactionId = TMP.strTransactionId)
		BEGIN
			DELETE FROM tblCMCheckPrintJobSpool WHERE strTransactionId IN (SELECT strTransactionId FROM #tmpCMBankTransaction)
		END
		IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors
	END
ELSE
	BEGIN
		/**
		* Reverse the "check" transaction by creating a Void Check offset
		* Conditions:
		*	1. Reverse only check transactions
		*	2. Applicable only on check transactions with printed check report.
		*   3. (Temporary) Reverse only if Reversing Date is specified
		**/

		/** Clean-up Reversing Date parameter **/
		SELECT @dtmReversalDate = ISNULL(@dtmReverseDate, dtmDate), @intTransactionId = intTransactionId FROM tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP ON F.strTransactionId = TMP.strTransactionId
		WHERE F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS, @PAYCHECK, @DIRECT_DEPOSIT, @ACH) AND F.strReferenceNo NOT IN (@CASH_PAYMENT) AND F.dtmCheckPrinted IS NOT NULL 

		/** Insert Reversal Entry Header **/
		INSERT INTO tblCMBankTransaction
			(strTransactionId, intBankTransactionTypeId, intBankAccountId, intCurrencyId, dblExchangeRate, dtmDate, strPayee, intPayeeId, strAddress, 
			strZipCode, strCity, strState, strCountry, dblAmount, strAmountInWords, strMemo, strReferenceNo, dtmCheckPrinted, ysnCheckToBePrinted,
			ysnCheckVoid, ysnPosted, strLink, ysnClr, dtmDateReconciled, intBankStatementImportId, intBankFileAuditId, strSourceSystem, intEntityId, 
			intCreatedUserId, intCompanyLocationId, dtmCreated, intLastModifiedUserId)
		SELECT
			F.strTransactionId + 'V', intBankTransactionTypeId + 100, intBankAccountId, intCurrencyId, dblExchangeRate, @dtmReversalDate, strPayee, intPayeeId, strAddress, 
			strZipCode, strCity, strState, strCountry, dblAmount, strAmountInWords, 'Void Transaction for ' + F.strTransactionId, 'Voided-' + strReferenceNo, @dtmReversalDate, ysnCheckToBePrinted,
			1, 0, strLink, 0, @dtmReversalDate, intBankStatementImportId, intBankFileAuditId, strSourceSystem, intEntityId, 
			@intUserId, intCompanyLocationId, getdate(), @intUserId
		FROM tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
					ON F.strTransactionId = TMP.strTransactionId
		WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS, @PAYCHECK, @DIRECT_DEPOSIT, @ACH)		
				-- Condition #1:
				AND F.strReferenceNo NOT IN (@CASH_PAYMENT) 
				-- Condition #2:		
				AND F.dtmCheckPrinted IS NOT NULL 
		SELECT @intVoidTransactionId = @@IDENTITY

		IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

		/** Insert Reversal Entry Detail(s) **/
		INSERT INTO tblCMBankTransactionDetail 
			(intTransactionId, dtmDate, intGLAccountId, strDescription, dblDebit, dblCredit, intUndepositedFundId, 
			intEntityId, intCreatedUserId, dtmCreated, intLastModifiedUserId, dtmLastModified, intConcurrencyId)
		SELECT @intVoidTransactionId, @dtmReversalDate, intGLAccountId, strDescription, dblCredit, dblDebit, NULL, 
			intEntityId, @intUserId, getdate(), @intUserId, getdate(), 1
		FROM tblCMBankTransactionDetail D 
			LEFT JOIN (SELECT F.intTransactionId FROM tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
						ON F.strTransactionId = TMP.strTransactionId
						WHERE F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS)		
						AND F.strReferenceNo NOT IN (@CASH_PAYMENT) 
						AND F.dtmCheckPrinted IS NOT NULL
						) M ON D.intTransactionId = M.intTransactionId
						WHERE D.intTransactionId = @intTransactionId 
						
						
		IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

		/* Insert created Void Check Transaction Ids to #tmpCMBankTransactionReversal */
		SELECT strTransactionId, intEntityId, intBankTransactionTypeId INTO #tmpCMBankTransactionReversal FROM 
			(SELECT F.strTransactionId + 'V' AS strTransactionId, F.intEntityId, F.intBankTransactionTypeId FROM tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
				ON F.strTransactionId = TMP.strTransactionId
				WHERE F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS, @PAYCHECK, @DIRECT_DEPOSIT, @ACH)		
				AND F.strReferenceNo NOT IN (@CASH_PAYMENT)
				AND F.dtmCheckPrinted IS NOT NULL) X

		/* Execute Posting Procedure for each Void Check entry*/
		DECLARE @isPostingSuccessful BIT
		DECLARE @strVoidTransactionId NVARCHAR(40)
		DECLARE @intVoidBankTransactionTypeId INT
		DECLARE @intEntityId INT
		WHILE EXISTS (SELECT 1 FROM #tmpCMBankTransactionReversal) 
			BEGIN
				SELECT TOP 1 @strVoidTransactionId = strTransactionId
							,@intEntityId = intEntityId
							,@intVoidBankTransactionTypeId = intBankTransactionTypeId 
				FROM #tmpCMBankTransactionReversal

				IF (@intVoidBankTransactionTypeId = @AP_PAYMENT OR @intVoidBankTransactionTypeId = @PAYCHECK OR @intVoidBankTransactionTypeId = @DIRECT_DEPOSIT OR @intVoidBankTransactionTypeId = @ACH)
					BEGIN
						/* If Void Check entry for AP Payment, do not post the reversal*/
						UPDATE tblCMBankTransaction 
							SET ysnPosted = CASE WHEN intBankTransactionTypeId IN (122,123) THEN 1 ELSE 0 END, ysnCheckVoid = CASE WHEN intBankTransactionTypeId IN (122,123) THEN 0 ELSE 1 END, ysnClr = CASE WHEN intBankTransactionTypeId IN (122,123) THEN 0 ELSE 1 END, 
								dtmDateReconciled = CASE WHEN intBankTransactionTypeId IN (122,123) THEN NULL ELSE dtmDate END, dtmCheckPrinted = CASE WHEN intBankTransactionTypeId IN (122,123) THEN NULL ELSE dtmDate END, intBankFileAuditId = CASE WHEN intBankTransactionTypeId IN (122,123) THEN NULL ELSE intBankFileAuditId END, @isPostingSuccessful = 1 
						WHERE strTransactionId = @strVoidTransactionId --AND intBankTransactionTypeId = @VOID_CHECK
					END
				ELSE
					BEGIN
						/* Post the Void Check entry*/
						EXEC uspCMPostVoidCheck 1, 0, @strVoidTransactionId, @intUserId, @intEntityId, @isSuccessful = @isPostingSuccessful OUTPUT
					END

				/* Clear the Void Check entry if successfull posted*/
				IF (@isPostingSuccessful = 1) 
					BEGIN
						UPDATE tblCMBankTransaction SET ysnClr = 1 
						WHERE strTransactionId = @strVoidTransactionId --AND intBankTransactionTypeId = @VOID_CHECK
					END
				/* Otherwise Delete the Void Check entry and abort the reversal */
				ELSE 
					BEGIN
						DELETE FROM tblCMBankTransactionDetail WHERE intTransactionId = @intVoidTransactionId 
						DELETE FROM tblCMBankTransaction WHERE intTransactionId = @intVoidTransactionId 
						GOTO Exit_BankTransactionReversal_WithErrors
					END
			
				DELETE FROM #tmpCMBankTransactionReversal WHERE strTransactionId = @strVoidTransactionId 
			END
		IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors

		/* Void and Clear the Original Transactions */
		UPDATE	tblCMBankTransaction
		SET		ysnCheckVoid = 1
				,ysnClr = 1
				,strReferenceNo = 'Voided' + (CASE WHEN ISNULL(F.strReferenceNo, '') = '' THEN '' ELSE '-' + F.strReferenceNo END)
				,dtmLastModified = GETDATE()
				,dtmDateReconciled = @dtmReversalDate
				,intLastModifiedUserId = @intUserId
		FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
					ON F.strTransactionId = TMP.strTransactionId
		WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @MISC_CHECKS, @ORIGIN_CHECKS, @PAYCHECK, @DIRECT_DEPOSIT, @ACH)		
				-- Condition #1:
				AND F.strReferenceNo NOT IN (@CASH_PAYMENT) 
				-- Condition #2:		
				AND F.dtmCheckPrinted IS NOT NULL 
		IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors
	END

/** 
* Void "checks" from origin. 
*/
EXEC dbo.uspCMBankTransactionReversalOrigin @intUserId, @isSuccessful OUTPUT 
IF @@ERROR <> 0	GOTO Exit_BankTransactionReversal_WithErrors
IF @isSuccessful = 0 GOTO Exit_BankTransactionReversal_WithErrors

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
* Validation before deleting a transaction
* Conditions:
*	1. It is non-check transaction
*	2. If it is a check transaction, the check report was not yet printed.
*/
DECLARE @intPrintedTransaction AS INT

SELECT @intPrintedTransaction = COUNT(F.intTransactionId) 
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	F.intBankTransactionTypeId IN (@ACH)
		AND F.dtmCheckPrinted IS NOT NULL

IF @intPrintedTransaction > 0
BEGIN
	RAISERROR('Unable to unpost printed/commited transaction.', 11, 1)
	GOTO Exit_BankTransactionReversal_WithErrors
END

/**
* Delete the bank transactions
* Conditions:
*	1. It is non-check transaction
*	2. If it is a check transaction, the check report was not yet printed.
*/
DELETE tblCMBankTransaction
FROM	tblCMBankTransaction F INNER JOIN #tmpCMBankTransaction TMP
			ON F.strTransactionId = TMP.strTransactionId
WHERE	F.intBankTransactionTypeId IN (@AP_PAYMENT, @AR_PAYMENT, @AP_ECHECK, @ACH)		
		AND (
			-- Condition #1:
			F.strReferenceNo IN (@CASH_PAYMENT)
			-- Condition #2: 
			OR (
				ISNULL(F.strReferenceNo,'') NOT IN (@CASH_PAYMENT) 
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
	-- Clean-up routines:
	-- Delete all temporary tables used during the reversal procedure. 
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCMBankTransactionReversal')) DROP TABLE #tmpCMBankTransactionReversal