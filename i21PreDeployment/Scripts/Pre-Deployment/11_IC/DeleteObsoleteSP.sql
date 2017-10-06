IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostInventoryShipmentIntegrations')
	DROP PROCEDURE uspICPostInventoryShipmentIntegrations
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustment2')
	DROP PROCEDURE uspICPostCostAdjustment2
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICCreateGLEntriesOnCostAdjustment2')
	DROP PROCEDURE uspICCreateGLEntriesOnCostAdjustment2
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnActualCosting')
	DROP PROCEDURE uspICPostCostAdjustmentOnActualCosting
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCosting')
	DROP PROCEDURE uspICPostCostAdjustmentOnAverageCosting
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCosting2')
	DROP PROCEDURE uspICPostCostAdjustmentOnAverageCosting2
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCostingCBOut')
	DROP PROCEDURE uspICPostCostAdjustmentOnAverageCostingCBOut
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnAverageCostingStockOut')
	DROP PROCEDURE uspICPostCostAdjustmentOnAverageCostingStockOut
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnFIFOCosting')
	DROP PROCEDURE uspICPostCostAdjustmentOnFIFOCosting
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnLIFOCosting')
	DROP PROCEDURE uspICPostCostAdjustmentOnLIFOCosting
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspICPostCostAdjustmentOnLotCosting')
	DROP PROCEDURE uspICPostCostAdjustmentOnLotCosting
GO
