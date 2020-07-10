IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostInventoryShipmentIntegrations')
	EXEC('DROP PROCEDURE uspICPostInventoryShipmentIntegrations')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustment2')
	EXEC('DROP PROCEDURE uspICPostCostAdjustment2')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICCreateGLEntriesOnCostAdjustment2')
	EXEC('DROP PROCEDURE uspICCreateGLEntriesOnCostAdjustment2')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnActualCosting')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnActualCosting')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCosting')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnAverageCosting')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCosting2')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnAverageCosting2')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCostingCBOut')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnAverageCostingCBOut')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCostingStockOut')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnAverageCostingStockOut')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnFIFOCosting')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnFIFOCosting')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnLIFOCosting')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnLIFOCosting')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnLotCosting')
	EXEC('DROP PROCEDURE uspICPostCostAdjustmentOnLotCosting')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICUnpostInventoryReceiptOtherCharges')
	EXEC('DROP PROCEDURE uspICUnpostInventoryReceiptOtherCharges')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICUnpostInventoryShipmentOtherCharges')
	EXEC('DROP PROCEDURE uspICUnpostInventoryShipmentOtherCharges')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICRebuildZeroCostReceipts')
	EXEC('DROP PROCEDURE uspICRebuildZeroCostReceipts')
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICIncreaseOnStorageQty')
	EXEC('DROP PROCEDURE uspICIncreaseOnStorageQty')
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.procedures WHERE NAME = 'uspICReverseInventoryShipment')
	EXEC('DROP PROCEDURE uspICReverseInventoryShipment')
GO
IF EXISTS(SELECT TOP 1 1 FROM sys.procedures WHERE NAME = 'uspICReverseInventoryReceipt')
	EXEC('DROP PROCEDURE uspICReverseInventoryReceipt')
GO
