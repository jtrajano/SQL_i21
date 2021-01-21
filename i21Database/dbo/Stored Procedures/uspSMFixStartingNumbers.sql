CREATE PROCEDURE uspSMFixStartingNumbers	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Declare the variables
DECLARE @strTransactionId AS NVARCHAR(40)
DECLARE @strTransactionType AS NVARCHAR(20)
DECLARE @strPrefix AS NVARCHAR(50)
DECLARE @intNumber AS INT 


-- 1: Fix the Batch Posting. -> from uspGLFixStartingNumbers
BEGIN 
	SET @strTransactionType = 'Batch Post'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLDetail)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strBatchId, @strPrefix, '') AS INT))	
		FROM	dbo.tblGLDetail  WHERE strBatchId LIKE @strPrefix + '%'
		
		DECLARE @intSMNumber int = 0;
		SELECT	@intSMNumber = MAX(CAST(REPLACE(strBatchNo, 'BATCH-', '') AS INT))	
		FROM	dbo.tblSMBatchPostingLog

		IF (@intNumber IS NOT NULL AND ISNULL(@intSMNumber, 0) < @intNumber)	
		BEGIN 	
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	strTransactionType = @strTransactionType	
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 

-- 2: Fix the Debit Memo (Voucher/Ticket)
BEGIN 
	SET @strTransactionType = 'Debit Memo'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLDetail)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strBatchId, @strPrefix, '') AS INT))	
		FROM	dbo.tblGLDetail  WHERE strBatchId LIKE @strPrefix + '%'
		
		DECLARE @intAPNumber int = 0;
		SELECT	@intAPNumber = MAX(CAST(REPLACE(strBillId, 'DM-', '') AS INT))	
		FROM	dbo.tblAPBill
		WHERE strBillId like 'DM-%'

		IF (@intNumber IS NOT NULL AND ISNULL(@intAPNumber, 0) < @intNumber)	
		BEGIN 	
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	strTransactionType = @strTransactionType	
		END
		ELSE
		BEGIN
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intAPNumber + 1 
			WHERE	strTransactionType = @strTransactionType	
		END
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 