CREATE PROCEDURE [testIC].[Fake Shipment]
AS
BEGIN	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItemLot', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentCharge', @Identity = 1;;	
END