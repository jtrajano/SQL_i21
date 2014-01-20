﻿
CREATE PROCEDURE CheckPrint_QueuePrintJobs
	@intBankAccountID INT = NULL,
	@strTransactionID NVARCHAR(40) = NULL,
	@strBatchID NVARCHAR(20) = NULL,
	@intUserID	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
--SET NOCOUNT ON // This is commented out. We need the number rows of affected by this stored procedure. 
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
		
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
SELECT	@strTransactionID = CASE WHEN LTRIM(RTRIM(@strTransactionID)) = '' THEN NULL ELSE @strTransactionID END
		,@strBatchID = CASE WHEN LTRIM(RTRIM(@strBatchID)) = '' THEN NULL ELSE @strBatchID END

-- Create the temporary print job table. 
SELECT * 
INTO	#tmpPrintJobSpoolTable
FROM	dbo.tblCMCheckPrintJobSpool
WHERE	1 = 0 

-- Insert the 'check' transactions in the check print-job spool table. 
INSERT INTO #tmpPrintJobSpoolTable(
		intBankAccountID
		,strTransactionID
		,strBatchID
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserID
		,ysnFail
		,strReason
)
-- Insert the records that: 
-- 1. Belongs to the bank account id
-- 2. Belongs to the specified transaction id
-- 3. Belongs to the specified batch id (strLink)
-- 4. Are posted, not cleared in the bank recon, amount is not zero, and never been printed. 
SELECT	intBankAccountID	= F.intBankAccountID
		,strTransactionID	= F.strTransactionID
		,strBatchID			= F.strLink
		,strCheckNo			= F.strReferenceNo
		,dtmPrintJobCreated	= GETDATE()
		,dtmCheckPrinted	= NULL
		,intCreatedUserID	= @intUserID
		,ysnFail			= 0
		,strReason			= NULL
FROM	dbo.tblCMBankTransaction F
WHERE	F.intBankAccountID = @intBankAccountID
		AND F.strTransactionID = ISNULL(@strTransactionID, F.strTransactionID)
		AND F.strLink = ISNULL(@strBatchID, F.strLink)
		AND F.intBankTransactionTypeID IN (@MISC_CHECKS, @AP_PAYMENT)
		AND F.ysnPosted = 1
		AND F.ysnClr = 0
		AND F.dblAmount <> 0
		AND F.dtmCheckPrinted IS NULL

-- Check if there are transactions to queue a print job
IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpPrintJobSpoolTable)
	RETURN -1; 

-- Get the next check number from the bank account table
SELECT TOP 1 
		@strNextCheckNumber = REPLICATE('0', 20 - LEN(CAST(intCheckNextNo AS NVARCHAR(20)))) + CAST(intCheckNextNo AS NVARCHAR(20))
FROM	dbo.tblCMBankAccount
WHERE	intBankAccountID = @intBankAccountID

-- Get the manually assigned check numbers 
SELECT	* 
INTO	#tmpManuallyAssignedCheckNumbers
FROM	#tmpPrintJobSpoolTable
WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) <> ''

-- The code below will assign the check numbers to the transaction that does not have the check number.
WHILE EXISTS (
	SELECT	TOP 1 1 
	FROM	#tmpPrintJobSpoolTable 
	WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) = ''
)
BEGIN 
	SELECT	TOP 1 
			@strRecordNo = strTransactionID
	FROM	#tmpPrintJobSpoolTable
	WHERE	LTRIM(RTRIM(ISNULL(strCheckNo, ''))) = ''

	-- Get the next check number from the Check Number Audit table. 
	-- FYI. Start from the next check number. 
	SELECT	TOP 1 
			@strNextCheckNumber = strCheckNo
	FROM	dbo.tblCMCheckNumberAudit
	WHERE	intBankAccountID = @intBankAccountID			
			AND strCheckNo >= @strNextCheckNumber
			AND intCheckNoStatus = @CHECK_NUMBER_STATUS_UNUSED
			AND strCheckNo NOT IN (SELECT strCheckNo FROM #tmpManuallyAssignedCheckNumbers)
	ORDER BY cntID

	-- If there is NO more available check numbers to complete the print job, abort the process. 
	IF (LTRIM(RTRIM(ISNULL(@strNextCheckNumber, ''))) = '')
		RETURN -1; 

	-- Assign the check number
	UPDATE	#tmpPrintJobSpoolTable
	SET		strCheckNo = @strNextCheckNumber
	WHERE	strTransactionID = @strRecordNo
	
	-- Update the check number audit and mark it as assigned for print check (for print check verification)
	UPDATE	dbo.tblCMCheckNumberAudit
	SET		intCheckNoStatus = @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION
	WHERE	intBankAccountID = @intBankAccountID
			AND strCheckNo = @strNextCheckNumber

END 

-- From here, temp print job table is now complete with information it needs to queue the print job. 
-- The system can now queue the print job. 
INSERT INTO tblCMCheckPrintJobSpool(
		intBankAccountID
		,strTransactionID
		,strBatchID
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserID
		,ysnFail
		,strReason
)
SELECT
		intBankAccountID
		,strTransactionID
		,strBatchID
		,strCheckNo
		,dtmPrintJobCreated
		,dtmCheckPrinted
		,intCreatedUserID
		,ysnFail
		,strReason
FROM	#tmpPrintJobSpoolTable

GO