--liquibase formatted sql

-- changeset Von:vyuICGetInventoryValuationAsCommodityStockUOM.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW vyuICGetInventoryValuationAsCommodityStockUOM
AS
SELECT 
	[Extent1].*
	,[dblCommodityStockUOM] = 
		dbo.fnCalculateQtyBetweenUOM(
			transactionUOM.intItemUOMId
			,commodityStockUOM.intItemUOMId
			,[Extent1].dblQuantity
		)
FROM 
	[dbo].[vyuICGetInventoryValuation] AS [Extent1]
			
	OUTER APPLY (
		SELECT TOP 1 
			iu.* 
		FROM 
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE
			iu.intItemId = [Extent1].intItemId
			AND u.strUnitMeasure = [Extent1].strUOM	
	) transactionUOM	
	OUTER APPLY (
		SELECT TOP 1 
			cUom.intUnitMeasureId 
		FROM 
			tblICCommodity c INNER JOIN tblICCommodityUnitMeasure cUom
				ON c.intCommodityId = cUom.intCommodityId
		WHERE
			c.intCommodityId = [Extent1].intCommodityId
			AND cUom.ysnStockUnit = 1
	) commodity
	OUTER APPLY (
		SELECT TOP 1 
			iu.* 
		FROM 
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE
			iu.intItemId = [Extent1].intItemId
			AND u.intUnitMeasureId = commodity.intUnitMeasureId	
	) commodityStockUOM



