CREATE PROCEDURE uspCMFixStartingNumbers	
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

-- 1 of 6: Fix the Bank Deposits. 
BEGIN 
	SET @strTransactionType = 'Bank Deposit'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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

-- 2 of 6: Fix the Bank Withdrawal. 
BEGIN 
	SET @strTransactionType = 'Bank Withdrawal'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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


-- 3 of 6: Fix the Bank Transfer. 
BEGIN 
	SET @strTransactionType = 'Bank Transfer'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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

-- 4 of 6: Fix the Bank Transaction. 
BEGIN 
	SET @strTransactionType = 'Bank Transaction'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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
	SET @strTransactionType = 'Misc Checks'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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

-- 6 of 6: Fix the Bank Stmt Import. 
BEGIN 
	SET @strTransactionType = 'Bank Stmt Import'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	strTransactionType = @strTransactionType

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblCMBankTransaction WHERE strTransactionId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(strTransactionId)			
		FROM	dbo.tblCMBankTransaction t INNER JOIN dbo.tblCMBankTransactionType t_type
					ON t.intBankTransactionTypeId = t_type.intBankTransactionTypeId
		WHERE	t_type.strBankTransactionTypeName = @strTransactionType
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
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