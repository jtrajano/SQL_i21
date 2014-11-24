CREATE PROCEDURE [dbo].[uspICIncreaseOnOrderQty]
	@ItemsToIncrease AS ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

-- Increase the On-Order Qty for the items
UPDATE	Stock 
SET		Stock.dblOnOrder = ISNULL(Stock.dblOnOrder, 0) + Items.Aggregrate_OnOrderQty
FROM	dbo.tblICItemStock Stock INNER JOIN (
			SELECT	intItemId
					,intLocationId
					,Aggregrate_OnOrderQty = SUM(ISNULL(dblUnitQty, 0) * ISNULL(dblUOMQty, 0))					
			FROM	@ItemsToIncrease
			GROUP BY intItemId, intLocationId
		) Items 
			ON Stock.intItemId = Items.intItemId
			AND Stock.intLocationId = Items.intLocationId
