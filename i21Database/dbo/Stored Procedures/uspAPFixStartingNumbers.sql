﻿CREATE PROCEDURE uspAPFixStartingNumbers	
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

IF(OBJECT_ID('tempdb..#tblTempAPByPassFixStartingNumber') IS NOT NULL) RETURN;

-- 1 of 3: Fix the Bill Batch. 
IF(@intStartingNumberId IS NULL OR @intStartingNumberId = 7)
BEGIN 
	SET @strTransactionType = 'Bill Batch'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	intStartingNumberId = 7

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblAPBillBatch WHERE strBillBatchNumber = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(CASE WHEN ISNUMERIC(REPLACE(strBillBatchNumber, @strPrefix, '')) = 1
											THEN CAST(REPLACE(strBillBatchNumber, @strPrefix, '') AS INT)
											ELSE NULL END)		
		FROM	dbo.tblAPBillBatch
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CASE WHEN ISNUMERIC(REPLACE(@strTransactionId, @strPrefix, '')) = 1
							THEN CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT)
							ELSE NULL END
			
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	intStartingNumberId = 7
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 

-- 2 of 6: Fix the Bill. 
IF(@intStartingNumberId IS NULL OR @intStartingNumberId = 9)
BEGIN 
	SET @strTransactionType = 'Bill'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	intStartingNumberId = 9

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblAPBill WHERE strBillId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(CASE WHEN ISNUMERIC(REPLACE(strBillId, @strPrefix, '')) = 1 THEN CAST(REPLACE(strBillId, @strPrefix, '') AS INT)
									ELSE NULL END)			
		FROM	dbo.tblAPBill
		WHERE intTransactionType = 1
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CASE WHEN ISNUMERIC(REPLACE(@strTransactionId, @strPrefix, '')) = 1 THEN CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
								ELSE NULL END
			
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	intStartingNumberId = 9	
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 

-- 3 of 6: Fix the Payment. 
IF(@intStartingNumberId IS NULL OR @intStartingNumberId = 8)
BEGIN 
	SET @strTransactionType = 'Payable'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	intStartingNumberId = 8

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblAPPayment WHERE strPaymentRecordNum = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(CASE WHEN ISNUMERIC(REPLACE(REPLACE(strPaymentRecordNum, @strPrefix, ''),'V','')) = 1 THEN CAST(REPLACE(REPLACE(strPaymentRecordNum, @strPrefix, ''),'V','') AS INT)
									ELSE NULL END)			
		FROM	dbo.tblAPPayment
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CASE WHEN ISNUMERIC(REPLACE(@strTransactionId, @strPrefix, '')) = 1 THEN CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
								ELSE NULL END
			
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	intStartingNumberId = 8	
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 

-- 2 of 6: Fix the 1099 Adjustment. 
IF(@intStartingNumberId IS NULL OR @intStartingNumberId = 77)
BEGIN 
	SET @strTransactionType = '1099 Adjustment'
	SELECT	@strTransactionId = strPrefix + CAST(intNumber AS NVARCHAR(20)) 
			,@intNumber = intNumber
			,@strPrefix = strPrefix
	FROM	dbo.tblSMStartingNumber
	WHERE	intStartingNumberId = 77

	IF EXISTS (SELECT TOP 1 1 FROM dbo.tblAPBill WHERE strBillId = @strTransactionId)
	BEGIN 
		-- Retrieve the Max transaction id. 
		SET @strTransactionId = NULL
		SELECT	@strTransactionId = MAX(CASE WHEN ISNUMERIC(REPLACE(strBillId, @strPrefix, '')) = 1 THEN CAST(REPLACE(strBillId, @strPrefix, '') AS INT)
									ELSE NULL END)			
		FROM	dbo.tblAPBill
		WHERE intTransactionType = 9
		
		IF (@strTransactionId IS NOT NULL)	
		BEGIN 	
			-- Extract the number part in the transaction id. 
			SET @intNumber = CASE WHEN ISNUMERIC(REPLACE(@strTransactionId, @strPrefix, '')) = 1 THEN CAST(REPLACE(@strTransactionId, @strPrefix, '') AS INT) 
								ELSE NULL END
			
			-- Update the next transaction id. 
			UPDATE	dbo.tblSMStartingNumber
			SET		intNumber = @intNumber + 1 
			WHERE	intStartingNumberId = 77
		END 
	END 

	-- Clean-up 
	SET @strTransactionId = NULL
	SET @strTransactionType = NULL 
	SET @strPrefix = NULL 
	SET @intNumber = NULL 
END 