
CREATE PROCEDURE CommitPrintCheckVerification
	@intBankAccountID INT = NULL,
	@strTransactionID NVARCHAR(40) = NULL,
	@strBatchID NVARCHAR(20) = NULL,
	@intUserID INT,
	@intErrorCode INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE -- Constant variables for Check number status. 
		@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6
		
		-- Local variables
		,@loop_strTransactionID AS NVARCHAR(40)
		,@strCheckNo AS NVARCHAR(20)
		,@cntID AS INT

-- Clean the parameters
SELECT	@strTransactionID = CASE WHEN LTRIM(RTRIM(@strTransactionID)) = '' THEN NULL ELSE @strTransactionID END
		,@strBatchID = CASE WHEN LTRIM(RTRIM(@strBatchID)) = '' THEN NULL ELSE @strBatchID END
IF @@ERROR <> 0 GOTO _ROLLBACK
		
-- Update the Bank Transaction table:
-- 1. Update the check printed date. 
-- 2. Assign the check number
UPDATE	dbo.tblCMBankTransaction 
SET		dtmCheckPrinted = CASE WHEN B.ysnFail = 0 THEN GETDATE() ELSE NULL END 
		,strReferenceNo = CASE WHEN B.ysnFail = 0 THEN B.strCheckNo ELSE '' END
FROM	dbo.tblCMBankTransaction A INNER JOIN dbo.tblCMCheckPrintJobSpool B
			ON A.strTransactionID = B.strTransactionID
			AND A.intBankAccountID = B.intBankAccountID
WHERE	A.dtmCheckPrinted IS NULL
		AND A.ysnClr = 0
		AND B.intBankAccountID = @intBankAccountID
		AND B.strTransactionID = ISNULL(@strTransactionID, B.strTransactionID)
		AND B.strBatchID = ISNULL(@strBatchID, B.strBatchID)
IF @@ERROR <> 0 GOTO _ROLLBACK
		
-- Create the temp table for processing the check number
SELECT	* 
INTO	#tmpCheckNumbers
FROM	dbo.tblCMCheckPrintJobSpool		
WHERE	intBankAccountID = @intBankAccountID
		AND strTransactionID = ISNULL(@strTransactionID, strTransactionID)
		AND strBatchID = ISNULL(@strBatchID, strBatchID)
IF @@ERROR <> 0 GOTO _ROLLBACK

-- Loop thru the print job spool table to update the Check Number Audit table 
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCheckNumbers)
BEGIN 
	SELECT TOP 1 
			@loop_strTransactionID = strTransactionID,
			@strCheckNo = strCheckNo
	FROM	#tmpCheckNumbers
	IF @@ERROR <> 0 GOTO _ROLLBACK
	
	-- Inspect if the check number does not exist in the check number audit table
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblCMCheckNumberAudit 
		WHERE	strCheckNo = @strCheckNo 
				AND intBankAccountID = @intBankAccountID
				AND intCheckNoStatus IN (@CHECK_NUMBER_STATUS_UNUSED, @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION)
	)
	BEGIN 
		INSERT INTO dbo.tblCMCheckNumberAudit (
				intBankAccountID
				,strCheckNo
				,intCheckNoStatus
				,strRemarks
				,strTransactionID
				,intUserID
				,dtmCreated
				,dtmCheckPrinted
		)
		SELECT	intBankAccountID	= A.intBankAccountID
				,strCheckNo			= A.strCheckNo
				,intCheckNoStatus	= CASE WHEN A.ysnFail = 1 THEN @CHECK_NUMBER_STATUS_WASTED ELSE @CHECK_NUMBER_STATUS_PRINTED END 
				,strRemarks			= CASE WHEN A.ysnFail = 1 THEN A.strReason ELSE '' END 
				,strTransactionID	= A.strTransactionID
				,intUserID			= @intUserID
				,dtmCreated			= GETDATE()
				,dtmCheckPrinted	= GETDATE()
		FROM	#tmpCheckNumbers A
		WHERE	strTransactionID = @loop_strTransactionID	
		IF @@ERROR <> 0 GOTO _ROLLBACK
	END 
	
	-- If there is an unused check number, update that check number. 
	ELSE 
	BEGIN 
		SELECT TOP 1 @cntID = cntID
		FROM	dbo.tblCMCheckNumberAudit
		WHERE	strCheckNo = @strCheckNo 
				AND intBankAccountID = @intBankAccountID
				AND intCheckNoStatus IN (@CHECK_NUMBER_STATUS_UNUSED, @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION)
				
		UPDATE	dbo.tblCMCheckNumberAudit
		SET		intCheckNoStatus	= CASE WHEN A.ysnFail = 1 THEN @CHECK_NUMBER_STATUS_WASTED ELSE @CHECK_NUMBER_STATUS_PRINTED END 
				,strRemarks			= CASE WHEN A.ysnFail = 1 THEN A.strReason ELSE '' END 
				,strTransactionID	= A.strTransactionID
				,intUserID			= @intUserID
				,dtmCheckPrinted	= GETDATE()
		FROM	#tmpCheckNumbers A 
		WHERE	cntID = @cntID
				AND A.strTransactionID = @loop_strTransactionID	
		IF @@ERROR <> 0 GOTO _ROLLBACK			
	END 
	
	-- Delete the print job record. 
	DELETE FROM dbo.tblCMCheckPrintJobSpool
	WHERE strTransactionID = @loop_strTransactionID
	IF @@ERROR <> 0 GOTO _ROLLBACK
	
	-- Delete the record from the temp table
	DELETE FROM #tmpCheckNumbers
	WHERE strTransactionID = @loop_strTransactionID	
	IF @@ERROR <> 0 GOTO _ROLLBACK
END 

_COMMIT:
	COMMIT 
	SET @intErrorCode = 0
	GOTO _EXIT

_ROLLBACK: 
	ROLLBACK
	SET @intErrorCode = -1 
	GOTO _EXIT

_EXIT: