/*
	uspICIncreaseInTransitOutBoundQty
	Update the tblICItemStock and tblICItemStockUOM tables. 
	It will increase (or decrease) the dblInTransitOutBound qty if the FOB Point is 'Destination'. 	

*/
CREATE PROCEDURE [dbo].[uspICIncreaseInTransitOutBoundQty]
	@ItemsToIncreaseInTransitOutBound AS InTransitTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @FOB_ORIGIN AS INT = 1
		,@FOB_DESTINATION AS INT = 2
		
-- Do an upsert for the Item Stock table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,Aggregrate_InTransitOutboundQty = SUM(dbo.fnMultiply(ISNULL(dblQty, 0), ISNULL(tblICItemUOM.dblUnitQty, 0))) 	-- Convert the qty to stock unit. 			
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound LEFT JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
		WHERE	ISNULL(ItemsToIncreaseInTransitOutBound.intFOBPointId, @FOB_ORIGIN) = @FOB_DESTINATION
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStock.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,dblInTransitOutbound
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,CASE WHEN Source_Query.Aggregrate_InTransitOutboundQty < 0 THEN 0 ELSE Source_Query.Aggregrate_InTransitOutboundQty END -- dblInTransitOutbound
		,NULL 
		,1	
	)		
;

-- Do an upsert for the Item Stock UOM table when updating the In-Transit Outbound Qty
MERGE	
INTO	dbo.tblICItemStockUOM
WITH	(HOLDLOCK) 
AS		ItemStockUOM
USING (
		-- Update the stock as-is. 
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,ItemsToIncreaseInTransitOutBound.intItemUOMId
				,Aggregrate_InTransitOutboundQty = SUM(ISNULL(dblQty, 0))
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound INNER JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
		WHERE	ISNULL(ItemsToIncreaseInTransitOutBound.intFOBPointId, @FOB_ORIGIN) = @FOB_DESTINATION			
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
				, ItemsToIncreaseInTransitOutBound.intItemUOMId
		-- Update the stock unit. 
		UNION ALL 
		SELECT	ItemsToIncreaseInTransitOutBound.intItemId
				,ItemsToIncreaseInTransitOutBound.intItemLocationId
				,StockUOM.intItemUOMId
				,Aggregrate_InTransitOutboundQty = SUM(ISNULL(dbo.fnCalculateCostBetweenUOM(ItemsToIncreaseInTransitOutBound.intItemUOMId, StockUOM.intItemUOMId, dblQty) , 0)) -- Convert the qty to the stock unit. 
		FROM	@ItemsToIncreaseInTransitOutBound ItemsToIncreaseInTransitOutBound INNER JOIN dbo.tblICItemUOM 
					ON ItemsToIncreaseInTransitOutBound.intItemUOMId = tblICItemUOM.intItemUOMId
				INNER JOIN dbo.tblICItemUOM StockUOM
					ON StockUOM.intItemId = ItemsToIncreaseInTransitOutBound.intItemId 
					AND StockUOM.ysnStockUnit = 1
					AND StockUOM.intItemUOMId <> tblICItemUOM.intItemUOMId
		WHERE	ISNULL(ItemsToIncreaseInTransitOutBound.intFOBPointId, @FOB_ORIGIN) = @FOB_DESTINATION
		GROUP BY ItemsToIncreaseInTransitOutBound.intItemId
				, ItemsToIncreaseInTransitOutBound.intItemLocationId
				, StockUOM.intItemUOMId
) AS Source_Query  
	ON ItemStockUOM.intItemId = Source_Query.intItemId
	AND ItemStockUOM.intItemLocationId = Source_Query.intItemLocationId
	AND ItemStockUOM.intItemUOMId = Source_Query.intItemUOMId

-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblInTransitOutbound = ISNULL(ItemStockUOM.dblInTransitOutbound, 0) + Source_Query.Aggregrate_InTransitOutboundQty 

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intItemUOMId
		,dblInTransitOutbound
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,Source_Query.intItemUOMId
		,Source_Query.Aggregrate_InTransitOutboundQty 
		,1	
	)
;
