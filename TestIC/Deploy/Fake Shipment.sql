if exists (select * from sys.procedures where object_id = object_id('testIC.Fake Shipment'))
	drop procedure [testIC].[Fake Shipment];
GO
CREATE PROCEDURE [testIC].[Fake Shipment]
AS
BEGIN	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipment', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItem', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentItemLot', @Identity = 1;;	
	EXEC tSQLt.FakeTable 'dbo.tblICInventoryShipmentCharge', @Identity = 1;;	


END