CREATE PROCEDURE [testi21Database].[test uspICAddInventoryTransfer for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @TransferEntries AS InventoryTransferStagingTable
				,@intUserId AS INT 
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.ExpectException
			@ExpectedMessage = 'Data not found. Unable to create the Inventory Transfer.';
	END

	-- Act 
	-- Try to use the SP with NULL arguments on all parameters
	BEGIN 
		EXEC dbo.uspICAddInventoryTransfer
			@TransferEntries
			,@intUserId
	END 

	-- Assert
	BEGIN
		EXEC tSQLt.AssertEqualsTable 'expected', 'actual';
	END 

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END 