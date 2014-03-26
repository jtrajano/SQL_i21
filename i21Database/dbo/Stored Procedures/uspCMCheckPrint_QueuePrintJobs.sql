/*
	This stored procedure is used to Queue print jobs. 
	1. It assign check numbers to those transaction set as "To Be Printed". 
	2. It updates the Check Number Audit. 
	3. It creates new audit log records for manually entered check numbers. 
	4. It updates the next check number. 
*/
CREATE PROCEDURE uspCMCheckPrint_QueuePrintJobs
	@intBankAccountId INT = NULL,
	@strTransactionId NVARCHAR(40) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
	@intUserId	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
--SET NOCOUNT ON // This is commented out. We need the number rows of affected by this stored procedure. 
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

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

		-- Constant variables for Check number status. 
		,@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6

		-- Local variables
		,@strRecordNo AS NVARCHAR(40)
		,@strNextCheckNumber AS NVARCHAR(20)

-- Clean the parameters
SELECT	@strTransactionId = CASE WHEN LTRIM(RTRIM(@strTransactionId)) = '' THEN NULL ELSE @strTransactionId END
		,@strBatchId = CASE WHEN LTRIM(RTRIM(@strBatchId)) = '' THEN NULL ELSE @strBatchId END

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
SELECT	intBankAccountId	= F.intBankAccountId
		,intTransactionId	= F.intTransactionId
		,strTransactionId	= F.strTransactionId
		,strBatchId			= F.strLink
		,strCheckNo			= F.strReferenceNo
		,dtmPrintJobCreated	= GETDATE()
		,dtmCheckPrinted	= NULL
		,intCreatedUserId	= @intUserId
		,ysnFail			= 0
		,strReason			= NULL
FROM	dbo.tblCMBankTransaction F
WHERE	F.intBankAccountId = @intBankAccountId
		AND F.strTransactionId = ISNULL(@strTransactionId, F.strTransactionId)
		AND F.strLink = ISNULL(@strBatchId, F.strLink)
		AND F.intBankTransactionTypeId IN (@MISC_CHECKS, @AP_PAYMENT)
		AND F.ysnPosted = 1
		AND F.ysnClr = 0
		AND F.dblAmount <> 0
		AND F.dtmCheckPrinted IS NULL
		AND F.ysnCheckToBePrinted = 1
IF @@ERROR <> 0 GOTO _ROLLBACK		

-- Check if there are transactions to queue a print job
IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpPrintJobSpoolTable)
BEGIN 
	GOTO _ROLLBACK;
END 

-- Get the next check number from the bank account table
SELECT TOP 1 
		@strNextCheckNumber = dbo.fnAddZeroPrefixes(intCheckNextNo)		
FROM	dbo.tblCMBankAccount
WHERE	intBankAccountId = @intBankAccountId
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
	ORDER BY intCheckNumberAuditId
	IF @@ERROR <> 0 GOTO _ROLLBACK	

	-- If there is NO more available check numbers to complete the print job, abort the process. 
	IF (LTRIM(RTRIM(ISNULL(@loop_CheckNumber, ''))) = '')
	BEGIN 
		RAISERROR(50014, 11, 1)
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

-- From here, temp print job table is now complete with information it needs to queue the print job. 
-- The system can now queue the print job. 
INSERT INTO tblCMCheckPrintJobSpool(
		intBankAccountId
		,intTransactionId
		,strTransactionId
		,strBatchId
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserId
		,ysnFail
		,strReason
)
SELECT
		intBankAccountId
		,intTransactionId
		,strTransactionId
		,strBatchId
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserId
		,ysnFail
		,strReason
FROM	#tmpPrintJobSpoolTable
IF @@ERROR <> 0 GOTO _ROLLBACK

-- Retrieve the highest check number entered for the print queue. 
SET @strNextCheckNumber = NULL 
SELECT	TOP 1 
		@strNextCheckNumber = MAX(dbo.fnAddZeroPrefixes(strCheckNo))
FROM	#tmpPrintJobSpoolTable
WHERE	ISNUMERIC(strCheckNo) = 1

-- Increment the next check number 
IF (@strNextCheckNumber IS NOT NULL)
BEGIN 
	-- Update the next check number 
	UPDATE	dbo.tblCMBankAccount
	SET		intCheckNextNo = CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT) + 1
	WHERE	intBankAccountId = @intBankAccountId
			AND ISNULL(@strNextCheckNumber, '') <> ''
			AND intCheckNextNo <= CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT)
	IF @@ERROR <> 0 GOTO _ROLLBACK

	-- Update the next check number to the checkbook in origin.
	UPDATE	dbo.apcbkmst_origin
	SET		apcbk_next_chk_no = CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT) + 1
	FROM	dbo.apcbkmst_origin O INNER JOIN dbo.tblCMBankAccount f
				ON f.strCbkNo = O.apcbk_no COLLATE Latin1_General_CI_AS
	WHERE	f.intBankAccountId = @intBankAccountId
			AND ISNULL(@strNextCheckNumber, '') <> ''
			AND O.apcbk_next_chk_no <= CAST(dbo.fnAddZeroPrefixes(@strNextCheckNumber) AS INT)  
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