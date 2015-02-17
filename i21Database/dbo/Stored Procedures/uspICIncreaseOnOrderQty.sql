CREATE PROCEDURE [dbo].[uspICIncreaseOnOrderQty]
	@ItemsToIncrease AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Do an upsert for the Item Stock table when updating the On Order Qty
MERGE	
INTO	dbo.tblICItemStock 
WITH	(HOLDLOCK) 
AS		ItemStock	
USING (
		SELECT	intItemId
				,intItemLocationId
				,Aggregrate_OnOrderQty = SUM(ISNULL(dblUnitQty, 0) * ISNULL(dblUOMQty, 0))					
		FROM	@ItemsToIncrease
		GROUP BY intItemId, intItemLocationId
) AS Source_Query  
	ON ItemStock.intItemId = Source_Query.intItemId
	AND ItemStock.intItemLocationId = Source_Query.intItemLocationId


-- If matched, update the On-Order qty 
WHEN MATCHED THEN 
	UPDATE 
	SET		dblOnOrder = ISNULL(ItemStock.dblOnOrder, 0) + Source_Query.Aggregrate_OnOrderQty

-- If none is found, insert a new item stock record
WHEN NOT MATCHED THEN 
	INSERT (
		intItemId
		,intItemLocationId
		,intSubLocationId
		,dblUnitOnHand
		,dblOrderCommitted
		,dblOnOrder
		,dblLastCountRetail
		,intSort
		,intConcurrencyId
	)
	VALUES (
		Source_Query.intItemId
		,Source_Query.intItemLocationId
		,NULL 
		,0
		,0
		,Source_Query.Aggregrate_OnOrderQty -- dblOnOrder
		,0
		,NULL 
		,1	
	)		

;