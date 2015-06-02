CREATE PROCEDURE [testi21Database].[test uspICPostInventoryTransfer on getting the batch id]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @STARTING_NUMBER_BATCH AS INT = 3  
		DECLARE @strBatchId AS NVARCHAR(40) 

		DECLARE @strExpectedBatchId AS NVARCHAR(40) = 'BATCH-9999'

		UPDATE dbo.tblSMStartingNumber
		SET intNumber = 9999
	END 

	-- Act
	BEGIN 
		-- Get the next batch number
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strExpectedBatchId OUTPUT   
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals @strExpectedBatchId, @strExpectedBatchId;
	END
END 
GO
