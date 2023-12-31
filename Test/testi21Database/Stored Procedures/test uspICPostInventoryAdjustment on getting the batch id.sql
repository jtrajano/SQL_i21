﻿CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment on getting the batch id]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
		DECLARE @strBatchId AS NVARCHAR(40) 

		DECLARE @strexpectedBatchId AS NVARCHAR(40) = 'BATCH-9999'

		UPDATE dbo.tblSMStartingNumber
		SET intNumber = 9999
	END 

	-- Act
	BEGIN 
		-- Get the next batch number
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strexpectedBatchId OUTPUT   
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals @strexpectedBatchId, @strexpectedBatchId;
	END
END 