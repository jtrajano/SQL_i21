CREATE PROCEDURE uspGLFixStartingNumbers	
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

-- 1 of 6: Fix the Audit Adjustment. 
BEGIN 
	SET		@strTransactionType = 'Audit Adjustment'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLJournal WHERE strJournalId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strJournalId, @strPrefix, '') AS INT))			
		FROM	dbo.tblGLJournal 
		WHERE	strTransactionType = @strTransactionType
		
		IF (@intNumber IS NOT NULL)	
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

-- 2 of 6: Fix the General Journal. 
BEGIN 
	SET @strTransactionType = 'General Journal'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLJournal WHERE strJournalId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strJournalId, @strPrefix, '') AS INT))			
		FROM	dbo.tblGLJournal 
		WHERE	strTransactionType = @strTransactionType AND strJournalType NOT IN ('Reversal Journal','Recurring Journal')
		
		IF (@intNumber IS NOT NULL)	
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


-- 3 of 6: Fix the Recurring Journal. 
BEGIN 
	SET @strTransactionType = 'Recurring Journal'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLJournal WHERE strJournalId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strJournalId, @strPrefix, '') AS INT))			
		FROM	dbo.tblGLJournal 
		WHERE	strJournalType = @strTransactionType
		
		IF (@intNumber IS NOT NULL)	
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

-- 4 of 6: Fix the Reversal Journal. 
BEGIN 
	SET @strTransactionType = 'General Journal Reversal'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLJournal WHERE strJournalId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strJournalId, @strPrefix, '') AS INT))			
		FROM	dbo.tblGLJournal 
		WHERE	strJournalType = 'Reversal Journal'
		
		IF (@intNumber IS NOT NULL)	
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

-- 5 of 6: Fix the Misc Checks. 
BEGIN 
	SET @strTransactionType = 'COA Adjustment'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblGLCOAAdjustment WHERE strCOAAdjustmentId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @intNumber = NULL
		
		-- Retrieve the highest number part in the transaction id. 
		SELECT	@intNumber = MAX(CAST(REPLACE(strCOAAdjustmentId, @strPrefix, '') AS INT))			
		FROM	dbo.tblGLCOAAdjustment 
		
		IF (@intNumber IS NOT NULL)	
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

-- 6 of 6: Fix the Batch Posting. 
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
		FROM	dbo.tblGLDetail
		
		IF (@intNumber IS NOT NULL)	
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