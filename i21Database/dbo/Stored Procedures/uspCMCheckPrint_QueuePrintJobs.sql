﻿/*
	This stored procedure is used to Queue print jobs. 
	1. It assign check numbers to those transaction set as "To Be Printed". 
	2. It updates the Check Number Audit. 
	3. It creates new audit log records for manually entered check numbers. 
	4. It updates the next check number. 
*/
CREATE PROCEDURE [dbo].[uspCMCheckPrint_QueuePrintJobs]
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(max) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
	@intTransactionType INT,
	@intUserId	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
--SET NOCOUNT ON // This is commented out. We need the number rows of affected by this stored procedure. 
SET XACT_ABORT ON
--SET ANSI_WARNINGS OFF // Commented because it is causing CM-579

BEGIN TRANSACTION 
		
DECLARE -- Constant variables for bank account types:
		@BANK_DEPOSIT INT = 1
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
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21

		-- Constant variables for Check number status. 
		,@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6

		-- Constant variables for payment methods
		,@CASH_PAYMENT AS NVARCHAR(20) = 'Cash'

		-- Local variables
		,@strRecordNo AS NVARCHAR(40)
		,@strNextCheckNumber AS NVARCHAR(20)
		,@intCheckNoLength AS INT = 8

-- Clean the parameters
SELECT	@strTransactionIds = CASE WHEN LTRIM(RTRIM(@strTransactionIds)) = '' THEN NULL ELSE @strTransactionIds END
		,@strBatchId = CASE WHEN LTRIM(RTRIM(@strBatchId)) = '' THEN NULL ELSE @strBatchId END
		,@intTransactionType = ISNULL(@intTransactionType, @MISC_CHECKS)

-- Create the temporary print job table. 
SELECT * 
INTO	#tmpPrintJobSpoolTable
FROM	[dbo].[tblCMCheckPrintJobSpool]
WHERE	1 = 0 
IF @@ERROR <> 0 GOTO _ROLLBACK

-- Insert the 'check' transactions in the check print-job spool table. 
INSERT INTO #tmpPrintJobSpoolTable(
		intBankAccountId
		,intTransactionId
		,strTransactionId
		,intBankTransactionTypeId
		,strBatchId
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserId
		,ysnFail
		,strReason
)
-- Insert the records that: 
-- 1. Belongs to the bank account id
-- 2. Belongs to the specified transaction id
-- 3. Belongs to the specified batch id (strLink)
-- 4. Are posted, not cleared in the bank recon, amount is not zero, and never been printed. 
-- 5. The bank record for AP Payment is not paid thru a "Cash" payment method. 
SELECT	intBankAccountId	= F.intBankAccountId
		,intTransactionId	= F.intTransactionId
		,strTransactionId	= F.strTransactionId
		,intBankTransactionTypeId = F.intBankTransactionTypeId
		,strBatchId			= F.strLink
		,strCheckNo			= ISNULL(F.strReferenceNo,'')
		,dtmPrintJobCreated	= GETDATE()
		,dtmCheckPrinted	= NULL
		,intCreatedUserId	= @intUserId
		,ysnFail			= 0
		,strReason			= NULL
FROM	dbo.tblCMBankTransaction F
WHERE	F.intBankAccountId = @intBankAccountId
		AND F.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		AND ISNULL(F.strLink, '') = ISNULL(@strBatchId, ISNULL(F.strLink, ''))
		AND F.intBankTransactionTypeId IN (@MISC_CHECKS, @AP_PAYMENT, @PAYCHECK)
		AND F.ysnPosted = 1
		AND F.ysnClr = 0
		AND F.dblAmount <> 0
		--AND F.dtmCheckPrinted IS NULL
		AND F.ysnCheckToBePrinted = 1
		AND F.intBankTransactionTypeId = @intTransactionType
		AND ISNULL(F.strReferenceNo,'') != (@CASH_PAYMENT) 
IF @@ERROR <> 0 GOTO _ROLLBACK		

-- Check if there are transactions to queue a print job
IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpPrintJobSpoolTable)
BEGIN 
	GOTO _ROLLBACK;
END 

-- Get the next check number from the bank account table

DECLARE @strCheckStartingNo NVARCHAR(50), @strCheckEndingNo NVARCHAR(50)

SELECT @strCheckStartingNo = dbo.fnAddZeroPrefixes(CAST(intCheckStartingNo AS NVARCHAR(50)), intCheckNoLength),
@strCheckEndingNo = dbo.fnAddZeroPrefixes(CAST(intCheckEndingNo AS NVARCHAR(50)), intCheckNoLength),
@intCheckNoLength = intCheckNoLength,
@strNextCheckNumber = dbo.fnAddZeroPrefixes(intCheckNextNo,intCheckNoLength)	
from tblCMBankAccount where intBankAccountId = @intBankAccountId


IF @@ERROR <> 0 GOTO _ROLLBACK

-- Get the manually assigned check numbers 
SELECT	* 
INTO	#tmpManuallyAssignedCheckNumbers
FROM	#tmpPrintJobSpoolTable
WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) <> ''

IF @@ERROR <> 0 GOTO _ROLLBACK

DECLARE @loop_CheckNumber AS NVARCHAR(20)

-- The code below will assign the check numbers to the transaction that does not have the check number.
WHILE EXISTS (
	SELECT	TOP 1 1 
	FROM	#tmpPrintJobSpoolTable 
	WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) = ''
)
BEGIN 
	SELECT	TOP 1 
			@strRecordNo = strTransactionId
	FROM	#tmpPrintJobSpoolTable
	WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) = ''
	ORDER BY LEN(strTransactionId), strTransactionId

	IF @@ERROR <> 0 GOTO _ROLLBACK

	-- Get the next check number from the Check Number Audit table. 
	-- FYI. Start from the next check number. 
	SET @loop_CheckNumber = NULL
	
	SELECT	TOP 1 
			@loop_CheckNumber = strCheckNo
	FROM	dbo.tblCMCheckNumberAudit
	WHERE	intBankAccountId = @intBankAccountId			
			AND strCheckNo >= @strNextCheckNumber
			AND intCheckNoStatus = @CHECK_NUMBER_STATUS_UNUSED
			AND strCheckNo NOT IN (SELECT strCheckNo FROM #tmpManuallyAssignedCheckNumbers)
			AND strCheckNo BETWEEN @strCheckStartingNo AND @strCheckEndingNo
			AND ISNULL(strRemarks,'') <> 'Generated from origin.'
	ORDER BY strCheckNo
	
	IF @@ERROR <> 0 GOTO _ROLLBACK	

	-- If there is NO more available check numbers to complete the print job, abort the process. 
	IF (LTRIM(RTRIM(ISNULL(@loop_CheckNumber, ''))) = '')
	BEGIN 
		RAISERROR('Not enough check numbers. Please generate new check numbers.', 11, 1)
		
		GOTO _ROLLBACK
	END 
	ELSE 
	BEGIN 
		SET @strNextCheckNumber = @loop_CheckNumber
	END 
		
	-- Assign the check number
	UPDATE	#tmpPrintJobSpoolTable
	SET		strCheckNo = @strNextCheckNumber
	WHERE	strTransactionId = @strRecordNo
	IF @@ERROR <> 0 GOTO _ROLLBACK
	
	-- Update the check number audit and mark it as assigned for print check (for print check verification)
	UPDATE	dbo.tblCMCheckNumberAudit
	SET		intCheckNoStatus = @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION
	WHERE	intBankAccountId = @intBankAccountId
			AND strCheckNo = @strNextCheckNumber
	IF @@ERROR <> 0 GOTO _ROLLBACK
END 



-- Update the check numbers in the bank transaction screen. Use the check number from the print spool table. 
UPDATE	tblCMBankTransaction
SET		strReferenceNo = TMP.strCheckNo
FROM	tblCMBankTransaction f INNER JOIN #tmpPrintJobSpoolTable TMP
			ON f.intBankAccountId = TMP.intBankAccountId
			AND f.intTransactionId = TMP.intTransactionId

--Retrieve the next check number from the check number audit
DECLARE @strNextCheckNumberForBankAccount AS NVARCHAR(20)
SELECT	TOP 1 
		@strNextCheckNumberForBankAccount = strCheckNo
FROM	dbo.tblCMCheckNumberAudit
WHERE	intBankAccountId = @intBankAccountId			
		AND strCheckNo >= @strNextCheckNumber
		AND intCheckNoStatus = @CHECK_NUMBER_STATUS_UNUSED
		AND strCheckNo NOT IN (SELECT strCheckNo FROM #tmpManuallyAssignedCheckNumbers)
		AND strCheckNo BETWEEN @strCheckStartingNo AND @strCheckEndingNo
		AND ISNULL(strRemarks,'') <> 'Generated from origin.'
ORDER BY strCheckNo

-- Increment the next check number 
IF (@strNextCheckNumberForBankAccount IS NOT NULL)
BEGIN 
	-- Update the next check number 
	UPDATE	dbo.tblCMBankAccount
	SET		intCheckNextNo = CAST(@strNextCheckNumberForBankAccount AS INT)
	WHERE	intBankAccountId = @intBankAccountId
			AND ISNULL(@strNextCheckNumberForBankAccount, '') <> ''
			--AND intCheckNextNo <= CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber,intCheckNoLength) AS INT)
	IF @@ERROR <> 0 GOTO _ROLLBACK

	-- Update the next check number to the checkbook in origin.
	EXEC dbo.uspCMUpdateOriginNextCheckNo
		@strNextCheckNumberForBankAccount
		,@intBankAccountId
	IF @@ERROR <> 0 GOTO _ROLLBACK
END 

_COMMIT_TRANS:
	COMMIT TRANSACTION
	GOTO _EXIT

_ROLLBACK: 
	ROLLBACK TRANSACTION
	RETURN -1;
	
	GOTO _EXIT
_EXIT: