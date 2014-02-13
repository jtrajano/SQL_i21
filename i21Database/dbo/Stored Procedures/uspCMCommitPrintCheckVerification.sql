
CREATE PROCEDURE uspCMCommitPrintCheckVerification
	@intBankAccountId INT = NULL,
	@strTransactionId NVARCHAR(40) = NULL,
	@strBatchId NVARCHAR(20) = NULL,
	@intUserId INT,
	@intErrorCode INT OUTPUT
AS

SET QUOTED_IdENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE -- Constant variables for Check number status. 
		@CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOId AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6
		
		-- Local variables
		,@loop_strTransactionId AS NVARCHAR(40)
		,@strCheckNo AS NVARCHAR(20)
		,@intCheckNumberAuditId AS INT

-- Clean the parameters
SELECT	@strTransactionId = CASE WHEN LTRIM(RTRIM(@strTransactionId)) = '' THEN NULL ELSE @strTransactionId END
		,@strBatchId = CASE WHEN LTRIM(RTRIM(@strBatchId)) = '' THEN NULL ELSE @strBatchId END
IF @@ERROR <> 0 GOTO _ROLLBACK

-- Check if there are failed checks and the reason is missing. 
IF EXISTS (
	SELECT TOP 1 1 
	FROM	dbo.tblCMCheckPrintJobSpool B
	WHERE	B.ysnFail = 1
			AND LTRIM(RTRIM(ISNULL(B.strReason, ''))) = ''
			AND B.intBankAccountId = @intBankAccountId
			AND B.strTransactionId = ISNULL(@strTransactionId, B.strTransactionId)
			AND B.strBatchId = ISNULL(@strBatchId, B.strBatchId)
)
BEGIN 
	-- A failed check is misisng a reason.
	RAISERROR(50011, 11, 1)
	GOTO _ROLLBACK
END
		
-- Update the Bank Transaction table:
-- 1. Update the check printed date. 
-- 2. Assign the check number
UPDATE	dbo.tblCMBankTransaction 
SET		dtmCheckPrinted = CASE WHEN B.ysnFail = 0 THEN GETDATE() ELSE NULL END 
		,strReferenceNo = CASE WHEN B.ysnFail = 0 THEN B.strCheckNo ELSE '' END
FROM	dbo.tblCMBankTransaction A INNER JOIN dbo.tblCMCheckPrintJobSpool B
			ON A.strTransactionId = B.strTransactionId
			AND A.intBankAccountId = B.intBankAccountId
WHERE	A.dtmCheckPrinted IS NULL
		AND A.ysnClr = 0
		AND B.intBankAccountId = @intBankAccountId
		AND B.strTransactionId = ISNULL(@strTransactionId, B.strTransactionId)
		AND B.strBatchId = ISNULL(@strBatchId, B.strBatchId)
IF @@ERROR <> 0 GOTO _ROLLBACK
		
-- Create the temp table for processing the check number
SELECT	* 
INTO	#tmpCheckNumbers
FROM	dbo.tblCMCheckPrintJobSpool		
WHERE	intBankAccountId = @intBankAccountId
		AND strTransactionId = ISNULL(@strTransactionId, strTransactionId)
		AND strBatchId = ISNULL(@strBatchId, strBatchId)
IF @@ERROR <> 0 GOTO _ROLLBACK

-- Loop thru the print job spool table to update the Check Number Audit table 
WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCheckNumbers)
BEGIN 
	SELECT TOP 1 
			@loop_strTransactionId = strTransactionId,
			@strCheckNo = strCheckNo
	FROM	#tmpCheckNumbers
	IF @@ERROR <> 0 GOTO _ROLLBACK
	
	-- Inspect if the check number does not exist in the check number audit table
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblCMCheckNumberAudit 
		WHERE	strCheckNo = @strCheckNo 
				AND intBankAccountId = @intBankAccountId
				AND intCheckNoStatus IN (@CHECK_NUMBER_STATUS_UNUSED, @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION)
	)
	BEGIN 
		INSERT INTO dbo.tblCMCheckNumberAudit (
				intBankAccountId
				,strCheckNo
				,intCheckNoStatus
				,strRemarks
				,intTransactionId
				,strTransactionId
				,intUserId
				,dtmCreated
				,dtmCheckPrinted
		)
		SELECT	intBankAccountId	= A.intBankAccountId
				,strCheckNo			= A.strCheckNo
				,intCheckNoStatus	= CASE WHEN A.ysnFail = 1 THEN @CHECK_NUMBER_STATUS_WASTED ELSE @CHECK_NUMBER_STATUS_PRINTED END 
				,strRemarks			= CASE WHEN A.ysnFail = 1 THEN A.strReason ELSE '' END 
				,intTransactionId	= A.intTransactionId
				,strTransactionId	= A.strTransactionId
				,intUserId			= @intUserId
				,dtmCreated			= GETDATE()
				,dtmCheckPrinted	= GETDATE()
		FROM	#tmpCheckNumbers A
		WHERE	strTransactionId = @loop_strTransactionId	
		IF @@ERROR <> 0 GOTO _ROLLBACK
	END 
	
	-- If there is an unused check number, update that check number. 
	ELSE 
	BEGIN 
		SELECT TOP 1 @intCheckNumberAuditId = intCheckNumberAuditId
		FROM	dbo.tblCMCheckNumberAudit
		WHERE	strCheckNo = @strCheckNo 
				AND intBankAccountId = @intBankAccountId
				AND intCheckNoStatus IN (@CHECK_NUMBER_STATUS_UNUSED, @CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION)
				
		UPDATE	dbo.tblCMCheckNumberAudit
		SET		intCheckNoStatus	= CASE WHEN A.ysnFail = 1 THEN @CHECK_NUMBER_STATUS_WASTED ELSE @CHECK_NUMBER_STATUS_PRINTED END 
				,strRemarks			= CASE WHEN A.ysnFail = 1 THEN A.strReason ELSE '' END 
				,intTransactionId	= A.intTransactionId
				,strTransactionId	= A.strTransactionId
				,intUserId			= @intUserId
				,dtmCheckPrinted	= GETDATE()
		FROM	#tmpCheckNumbers A 
		WHERE	intCheckNumberAuditId = @intCheckNumberAuditId
				AND A.strTransactionId = @loop_strTransactionId	
		IF @@ERROR <> 0 GOTO _ROLLBACK			
	END 
	
	-- Delete the print job record. 
	DELETE FROM dbo.tblCMCheckPrintJobSpool
	WHERE strTransactionId = @loop_strTransactionId
	IF @@ERROR <> 0 GOTO _ROLLBACK
	
	-- Delete the record from the temp table
	DELETE FROM #tmpCheckNumbers
	WHERE strTransactionId = @loop_strTransactionId	
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