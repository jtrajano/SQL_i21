CREATE PROCEDURE [testi21Database].[test uspICAddSalesOrderToInventoryShipment in generating the correct starting number]
AS
BEGIN
	-- Arrange 
	BEGIN 	
		DECLARE @StartingNumberId_InventoryShipment AS INT = 31;
		DECLARE @actual AS NVARCHAR(20)
		DECLARE @expected AS NVARCHAR(20) = '(Test)INVSHIP-1'

		-- Modify the starting number table to perform the test. 
		UPDATE dbo.tblSMStartingNumber 
		SET		strPrefix = '(Test)INVSHIP-'
				,intNumber = 1
		WHERE	strTransactionType = 'Inventory Shipment'
	END
	
	-- Act
	BEGIN 
		-- Get the transaction id 
		EXEC dbo.uspSMGetStartingNumber @StartingNumberId_InventoryShipment, @actual OUTPUT 
	END 
	
	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEquals @expected, @actual 
	END
END
