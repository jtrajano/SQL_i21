CREATE PROCEDURE uspARFixStartingNumbers	
	@intStartingNumberId INT = NULL
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

--IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;

-- 1 of 3: Fix the Receive Payments. 
IF(@intStartingNumberId IS NULL OR @intStartingNumberId = 17)
BEGIN 
	SET @strTransactionType = 'Receive Payments'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	intStartingNumberId = 17

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblARPayment WHERE strRecordNumber = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(CAST(REPLACE(strRecordNumber, @strPrefix, '') AS INT))			
		FROM	dbo.tblARPayment
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
			
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	intStartingNumberId = 17
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 
