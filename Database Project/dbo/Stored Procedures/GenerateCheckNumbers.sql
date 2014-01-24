
CREATE PROCEDURE GenerateCheckNumbers
	@intBankAccountID INT = NULL,
	@intStartNumber INT = NULL,
	@intEndNumber INT = NULL,
	@intUserID INT = NULL,
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
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6

-- Validate the start and end numbers
IF (@intStartNumber IS NULL OR @intEndNumber IS NULL)
	GOTO GenerateCheckNumbers_Rollback
	
IF (@intStartNumber < 0 OR @intEndNumber < 0)
	GOTO GenerateCheckNumbers_Rollback

IF (@intStartNumber > @intEndNumber)
	GOTO GenerateCheckNumbers_Rollback

IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankAccount WHERE intBankAccountID = @intBankAccountID)
	GOTO GenerateCheckNumbers_Rollback

-- LOOP THRU THE NUMBERS 
DECLARE @intCheckNumber AS INT 
SET @intCheckNumber = @intStartNumber
IF @@ERROR <> 0	GOTO GenerateCheckNumbers_Rollback

WHILE (@intCheckNumber <= @intEndNumber)
BEGIN

	-- INSERT THE CHECK NUMBER TO THE AUDIT TABLE ONLY IF IT DOES NOT EXISTS. 
	IF NOT EXISTS (
		SELECT	TOP 1 1 
		FROM	dbo.tblCMCheckNumberAudit 
		WHERE	intBankAccountID = @intBankAccountID 
				AND strCheckNo = REPLICATE('0', 20 - LEN(CAST(@intCheckNumber AS NVARCHAR(20)))) + CAST(@intCheckNumber AS NVARCHAR(20))
	)
	BEGIN 
		INSERT INTO dbo.tblCMCheckNumberAudit(
				strCheckNo
				,intBankAccountID
				,intCheckNoStatus
				,strRemarks
				,strTransactionID
				,intUserID
				,dtmCreated
				,dtmCheckPrinted
				,intConcurrencyID
		)
		SELECT	strCheckNo			= REPLICATE('0', 20 - LEN(CAST(@intCheckNumber AS NVARCHAR(20)))) + CAST(@intCheckNumber AS NVARCHAR(20))
				,intBankAccountID	= @intBankAccountID
				,intCheckNoStatus	= @CHECK_NUMBER_STATUS_UNUSED
				,strRemarks			= NULL
				,strTransactionID	= NULL
				,intUserID			= @intUserID
				,dtmCreated			= GETDATE()
				,dtmCheckPrinted	= NULL
				,intConcurrencyID	= 1	
		IF @@ERROR <> 0	GOTO GenerateCheckNumbers_Rollback				
	END
	ELSE 
	BEGIN 
		SET @isDuplicateFound = 1
		IF @@ERROR <> 0	GOTO GenerateCheckNumbers_Rollback
	END
	
	SET @intCheckNumber = @intCheckNumber + 1
	IF @@ERROR <> 0	GOTO GenerateCheckNumbers_Rollback	
END


--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
GenerateCheckNumbers_Commit:
	COMMIT TRANSACTION
	RETURN 1;
	GOTO GenerateCheckNumbers_Exit
	
GenerateCheckNumbers_Rollback:
	ROLLBACK TRANSACTION 
	RETURN -1;
	
GenerateCheckNumbers_Exit:	
	SET @isDuplicateFound = ISNULL(@isDuplicateFound, 0)