
CREATE PROCEDURE GenerateCheckNumbers
	@intBankAccountID INT = NULL,
	@intStartNumber INT = NULL,
	@intEndNumber INT = NULL,
	@intUserID INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
 --SET NOCOUNT ON // COMMENTED. WE NEED TO TRACK THE # OF RECORDS AFFECTED.
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @CHECK_NUMBER_STATUS_UNUSED AS INT = 1
		,@CHECK_NUMBER_STATUS_USED AS INT = 2
		,@CHECK_NUMBER_STATUS_PRINTED AS INT = 3
		,@CHECK_NUMBER_STATUS_VOID AS INT = 4
		,@CHECK_NUMBER_STATUS_WASTED AS INT = 5
		,@CHECK_NUMBER_STATUS_FOR_PRINT_VERIFICATION AS INT = 6

-- Validate the start and end numbers
IF (@intStartNumber IS NULL OR @intEndNumber IS NULL)
	RETURN -1;
	
IF (@intStartNumber < 0 OR @intEndNumber < 0)
	RETURN -1;
	
IF (@intStartNumber > @intEndNumber)
	RETURN -1;

IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankAccount WHERE intBankAccountID = @intBankAccountID)
	RETURN -1;

-- LOOP THRU THE NUMBERS 
DECLARE @intCheckNumber AS INT 
SET @intCheckNumber = @intStartNumber

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
	END
	
	SET @intCheckNumber = @intCheckNumber + 1

END