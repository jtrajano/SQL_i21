CREATE PROCEDURE [testi21Database].[test uspICPostInventoryShipmentIntegrations for calling uspSCShipped]
AS
BEGIN
	-- Setup the fake data
	BEGIN 
		-- Declare the constants 
		DECLARE	-- Order Types
				@STR_ORDER_TYPE_SALES_CONTRACT AS NVARCHAR(50) = 'Sales Contract'
				,@STR_ORDER_TYPE_SALES_ORDER AS NVARCHAR(50) = 'Sales Order'
				,@STR_ORDER_TYPE_TRANSFER_ORDER AS NVARCHAR(50) = 'Transfer Order'
				,@INT_ORDER_TYPE_SALES_CONTRACT AS INT = 1
				,@INT_ORDER_TYPE_SALES_ORDER AS INT = 2
				,@INT_ORDER_TYPE_TRANSFER_ORDER AS INT = 3

				-- Source Types
				,@STR_SOURCE_TYPE_NONE AS NVARCHAR(50) = 'None'
				,@STR_SOURCE_TYPE_SCALE AS NVARCHAR(50) = 'Scale'
				,@STR_SOURCE_TYPE_INBOUND_SHIPMENT AS NVARCHAR(50) = 'Inbound Shipment'
				,@STR_SOURCE_TYPE_TRANSPORT AS NVARCHAR(50) = 'Transport'

				,@INT_SOURCE_TYPE_NONE AS INT = 0
				,@INT_SOURCE_TYPE_SCALE AS INT = 1
				,@INT_SOURCE_TYPE_INBOUND_SHIPMENT AS INT = 2
				,@INT_SOURCE_TYPE_TRANSPORT AS INT = 3

		EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;

		-- Setup the fake Shipment data. 
		INSERT INTO tblICInventoryShipment (
				intOrderType
				,intSourceType
				,strShipmentNumber
		)
		SELECT	intOrderType = @INT_ORDER_TYPE_SALES_ORDER
				,intSourceType = @INT_SOURCE_TYPE_SCALE
				,strShipmentNumber = 'INVSHIP-1XXXX1'

		-- Add a spy for uspSCShipped
		EXEC tSQLt.SpyProcedure 'dbo.uspSCShipped';		
	END

	-- Arrange 
	BEGIN 
		DECLARE	@ysnPost BIT = 1 
				,@intTransactionId INT = 1
				,@intUserId  INT  = 1
				,@intEntityId INT  = 1
	END 
		
	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryShipmentIntegrations 
				@ysnPost
				,@intTransactionId
				,@intUserId
				,@intEntityId
	END 

	-- Assert 
	BEGIN 
		EXEC tSQLt.AssertObjectExists 'uspSCShipped_SpyProcedureLog'
		
		DECLARE @expectedCount AS INT = 1 
				,@actualCount AS INT

		SELECT @actualCount = COUNT(*) FROM uspSCShipped_SpyProcedureLog

		EXEC tSQLt.AssertEquals @expectedCount, @actualCount
	END 


	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('actual') IS NOT NULL 
		DROP TABLE actual

	IF OBJECT_ID('expected') IS NOT NULL 
		DROP TABLE dbo.expected
END
