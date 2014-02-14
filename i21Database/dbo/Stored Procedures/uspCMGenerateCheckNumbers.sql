
CREATE PROCEDURE uspCMGenerateCheckNumbers
	@intBankAccountId INT = NULL,
	@intStartNumber INT = NULL,
	@intEndNumber INT = NULL,
	@intUserId INT = NULL,
	@isDuplicateFound BIT = 0 OUTPUT
AS

SET QUOTED_IdENTIFIER OFF
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

WHILE (@intCheckNumber <= @intEndNumber)
BEGIN

	-- INSERT THE CHECK NUMBER TO THE AUDIT TABLE ONLY IF IT DOES NOT EXISTS. 
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblCMCheckNumberAudit 
		WHERE	intBankAccountId = @intBankAccountId 
				AND strCheckNo = REPLICATE('0', 20 - LEN(CAST(@intCheckNumber AS NVARCHAR(20)))) + CAST(@intCheckNumber AS NVARCHAR(20))
	)
	BEGIN 
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
		SELECT	strCheckNo			= REPLICATE('0', 20 - LEN(CAST(@intCheckNumber AS NVARCHAR(20)))) + CAST(@intCheckNumber AS NVARCHAR(20))
				,intBankAccountId	= @intBankAccountId
				,intCheckNoStatus	= @CHECK_NUMBER_STATUS_UNUSED
				,strRemarks			= NULL
				,intTransactionId	= NULL
				,strTransactionId	= NULL
				,intUserId			= @intUserId
				,dtmCreated			= GETDATE()
				,dtmCheckPrinted	= NULL
				,intConcurrencyId	= 1	
		IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback				
	END
	ELSE 
	BEGIN 
		SET @isDuplicateFound = 1
		IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback
	END
	
	SET @intCheckNumber = @intCheckNumber + 1
	IF @@ERROR <> 0	GOTO uspCMGenerateCheckNumbers_Rollback	
END


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
	RETURN @returnValue