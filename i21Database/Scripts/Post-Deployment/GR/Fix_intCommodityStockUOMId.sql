/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/
PRINT 'BEGIN UPDATING intCommodityStockUOMId in tblGRSettleStorage'
GO

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'dbo' AND  TABLE_NAME = 'tblGRSettleStorage')
BEGIN	
    UPDATE SS
	SET intCommodityStockUomId = CO_UOM.intCommodityUnitMeasureId
	FROM tblGRSettleStorage SS
	INNER JOIN tblICItemUOM ITEM_UOM
		ON ITEM_UOM.intItemUOMId = SS.intItemUOMId
	INNER JOIN tblICCommodityUnitMeasure CO_UOM
		ON CO_UOM.intCommodityId = SS.intCommodityId
			AND CO_UOM.intUnitMeasureId = ITEM_UOM.intUnitMeasureId
	WHERE SS.intCommodityStockUomId <> CO_UOM.intCommodityUnitMeasureId
		AND SS.intParentSettleStorageId IS NOT NULL
	
END

PRINT 'END UPDATING intCommodityStockUOMId in tblGRSettleStorage'
GO