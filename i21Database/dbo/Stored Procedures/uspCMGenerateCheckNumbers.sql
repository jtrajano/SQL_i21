
CREATE PROCEDURE uspCMGenerateCheckNumbers
	@intBankAccountId INT = NULL,
	@intStartNumber INT = NULL,
	@intEndNumber INT = NULL,
	@intUserId INT = NULL,
	@isDuplicateFound BIT = 0 OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
-- SET NOCOUNT ON 
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOId AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6
		
		,@returnValue AS INT = 0

-- Validate the start and end numbers
IF (@intStartNumber IS NULL OR @intEndNumber IS NULL)
	GOTO uspCMGenerateCheckNumbers_Rollback
	
IF (@intStartNumber < 0 OR @intEndNumber < 0)
	GOTO uspCMGenerateCheckNumbers_Rollback

IF (@intStartNumber > @intEndNumber)
	GOTO uspCMGenerateCheckNumbers_Rollback

IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankAccount WHERE intBankAccountId = @intBankAccountId)
	GOTO uspCMGenerateCheckNumbers_Rollback

-- LOOP THRU THE NUMBERS 
DECLARE @intCheckNumber AS INT 
SET @intCheckNumber = @intStartNumber
IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback

-- Create temporary table to hold generated check numbers
CREATE TABLE #tmpChecks (
	strCheckNo NVARCHAR(20) COLLATE Latin1_General_CI_AS
)

WHILE (@intCheckNumber <= @intEndNumber)
BEGIN
	INSERT INTO #tmpChecks (strCheckNo) 
	SELECT dbo.fnAddZeroPrefixes(@intCheckNumber)
	SET @intCheckNumber = @intCheckNumber + 1
END
IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback

-- Determine if duplicates were found
SELECT @isDuplicateFound = (SELECT TOP 1 1 FROM dbo.tblCMCheckNumberAudit 
									WHERE intBankAccountId = @intBankAccountId 
									AND strCheckNo IN (SELECT strCheckNo FROM #tmpChecks))
IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback

-- INSERT THE CHECK NUMBER TO THE AUDIT TABLE ONLY IF IT DOES NOT EXISTS. 
INSERT INTO dbo.tblCMCheckNumberAudit(
		strCheckNo
		,intBankAccountId
		,intCheckNoStatus
		,strRemarks
		,intTransactionId
		,strTransactionId
		,intUserId
		,dtmCreated
		,dtmCheckPrinted
		,intConcurrencyId
)
SELECT	strCheckNo			= strCheckNo 
		,intBankAccountId	= @intBankAccountId
		,intCheckNoStatus	= @CHECK_NUMBER_STATUS_UNUSED
		,strRemarks			= NULL
		,intTransactionId	= NULL
		,strTransactionId	= NULL
		,intUserId			= @intUserId
		,dtmCreated			= GETDATE()
		,dtmCheckPrinted	= NULL
		,intConcurrencyId	= 1
FROM #tmpChecks WHERE strCheckNo NOT IN (SELECT strCheckNo FROM dbo.tblCMCheckNumberAudit WHERE intBankAccountId = @intBankAccountId)
IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback	

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
uspCMGenerateCheckNumbers_Commit:
	COMMIT TRANSACTION
	SET @returnValue = 1
	GOTO uspCMGenerateCheckNumbers_Exit
	
uspCMGenerateCheckNumbers_Rollback:
	ROLLBACK TRANSACTION 
	SET @returnValue = -1
	
uspCMGenerateCheckNumbers_Exit:	
	SET @isDuplicateFound = ISNULL(@isDuplicateFound, 0)

	-- Clean-up routines:
	-- Delete all temporary tables used. 
	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpChecks')) DROP TABLE #tmpChecks

	RETURN @returnValue