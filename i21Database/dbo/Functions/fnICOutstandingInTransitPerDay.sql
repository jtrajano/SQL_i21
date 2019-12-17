CREATE FUNCTION [dbo].[fnICOutstandingInTransitPerDay](
	@intItemId INT 
	,@intCommodityId INT
	,@dtmStartDate AS DATETIME 
	,@dtmEndDate AS DATETIME
)
RETURNS TABLE 
AS

RETURN 

WITH cte AS
(
  SELECT ROW_NUMBER() OVER (ORDER BY (SELECT 1)) - 1 AS [Incrementor]
  FROM  tblICItem i1 CROSS JOIN tblICItem i2
)
SELECT
	strItemNo			= i.strItemNo 
	,intItemId			= i.intItemId
	,intItemLocationId	= tblInTransit.intInTransitSourceLocationId
	,intItemUOMId		= stockUOM.intItemUOMId
	,strUnitMeasure		= stockUnit.strUnitMeasure 
	,strTransactionId	= tblInTransit.strTransactionId
	,intTransactionId	= tblInTransit.intTransactionId
	,intTransactionDetailId	= tblInTransit.intTransactionDetailId
	,tblInTransit.intInventoryTransactionId
	,dblInTransitQty	= tblInTransit.dblInTransitQtyInStockUOM
	,dtmDate			= dbo.fnRemoveTimeOnDate(tblInTransit.dtmDate) 
	,dtmDayInYear		= DATEADD(DAY, cte.[Incrementor], @dtmStartDate) 
FROM
	cte INNER JOIN tblICItem i 
		ON 1 = 1 
	INNER JOIN (
		tblICItemUOM stockUOM INNER JOIN tblICUnitMeasure stockUnit
			ON stockUOM.intUnitMeasureId = stockUnit.intUnitMeasureId
	)
		ON stockUOM.intItemId = i.intItemId
		AND stockUOM.ysnStockUnit = 1
	OUTER APPLY (
		SELECT 
			cb.strTransactionId
			,cb.intTransactionId
			,cb.intTransactionDetailId
			,cbt.intInventoryTransactionId
			,cb.dtmDate
			,cb.intItemUOMId
			-- In-Transit Qty using the transaction UOM
			,dblInTransitQty = 
				cb.dblStockIn - isnull(t.totalOut, 0) 
			-- In-Transit Qty converted to stock UOM
			,dblInTransitQtyInStockUOM =
				dbo.fnCalculateQtyBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblStockIn - isnull(t.totalOut, 0))				 
			,cbt.intInTransitSourceLocationId
		FROM	
			tblICInventoryActualCost cb CROSS APPLY (
				SELECT TOP 1 
					cbt.*
				FROM 
					tblICInventoryTransaction cbt
				WHERE	
					cbt.strTransactionId = cb.strTransactionId
					AND cbt.intItemId = cb.intItemId
					AND cbt.intItemLocationId = cb.intItemLocationId
					AND cbt.intItemUOMId = cb.intItemUOMId
					AND cbt.intTransactionDetailId = cb.intTransactionDetailId
					AND cbt.dblQty = cb.dblStockIn
					AND cbt.dblCost = cb.dblCost
					AND cbt.ysnIsUnposted = 0 	
			) cbt
			INNER JOIN tblICItemLocation il
				ON cb.intItemLocationId = il.intItemLocationId
				AND il.intLocationId IS NULL 
			OUTER APPLY (
				SELECT 
					totalOut = SUM(cbOut.dblQty)
				FROM 		
					tblICInventoryActualCostOut cbOut inner join tblICInventoryTransaction t
						ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId					
				WHERE
					cbOut.intInventoryActualCostId = cb.intInventoryActualCostId
					AND dbo.fnDateLessThanEquals(
						t.dtmDate
						, DATEADD(DAY, cte.[Incrementor], @dtmStartDate)
					) = 1
					AND t.ysnIsUnposted = 0 		
			) t	
		WHERE
			cb.intItemId = i.intItemId
			AND dbo.fnDateLessThanEquals(
				cb.dtmDate
				, DATEADD(DAY, cte.[Incrementor], @dtmStartDate)
			) = 1		
			AND (cb.dblStockIn - isnull(t.totalOut, 0)) > 0			
	) tblInTransit	
WHERE
	(i.intItemId = @intItemId OR @intItemId IS NULL)
	AND (i.intCommodityId = @intCommodityId OR @intCommodityId IS NULL) 
	AND i.strLotTracking NOT LIKE 'Yes%'		
	AND DATEADD(DAY, cte.[Incrementor], @dtmStartDate) < @dtmEndDate

UNION ALL 
SELECT
	strItemNo			= i.strItemNo 
	,intItemId			= i.intItemId
	,intItemLocationId	= tblInTransit.intInTransitSourceLocationId
	,intItemUOMId		= stockUOM.intItemUOMId
	,strUnitMeasure		= stockUnit.strUnitMeasure 
	,strTransactionId	= tblInTransit.strTransactionId
	,intTransactionId	= tblInTransit.intTransactionId
	,intTransactionDetailId		
						= tblInTransit.intTransactionDetailId
	,tblInTransit.intInventoryTransactionId
	,dblInTransitQty	= tblInTransit.dblInTransitQtyInStockUOM
	,dtmDate			= dbo.fnRemoveTimeOnDate(tblInTransit.dtmDate) 
	,dtmDayInYear		= DATEADD(DAY, cte.[Incrementor], @dtmStartDate) 
FROM
	cte INNER JOIN tblICItem i 
		ON 1 = 1 
	INNER JOIN (
		tblICItemUOM stockUOM inner join tblICUnitMeasure stockUnit
			ON stockUOM.intUnitMeasureId = stockUnit.intUnitMeasureId
	)
		ON stockUOM.intItemId = i.intItemId
		AND stockUOM.ysnStockUnit = 1
	OUTER APPLY (
		select 
			cb.strTransactionId
			,cb.intTransactionId
			,cb.intTransactionDetailId
			,cbt.intInventoryTransactionId
			,cb.dtmDate
			,cb.intItemUOMId
			-- In-Transit Qty using the transaction UOM
			,dblInTransitQty = 
				cb.dblStockIn - isnull(t.totalOut, 0) 
			-- In-Transit Qty converted to stock UOM
			,dblInTransitQtyInStockUOM =
				dbo.fnCalculateQtyBetweenUOM(cb.intItemUOMId, stockUOM.intItemUOMId, cb.dblStockIn)
				- isnull(t.totalOut, 0) 
			,cbt.intInTransitSourceLocationId
		FROM	
			tblICInventoryLot cb CROSS APPLY (
				SELECT TOP 1 
					cbt.*
				FROM 
					tblICInventoryTransaction cbt
				WHERE	
					cbt.strTransactionId = cb.strTransactionId
					AND cbt.intItemId = cb.intItemId
					AND cbt.intItemLocationId = cb.intItemLocationId
					AND cbt.intItemUOMId = cb.intItemUOMId
					AND cbt.intTransactionDetailId = cb.intTransactionDetailId
					AND cbt.intLotId = cb.intLotId
					AND cbt.dblQty = cb.dblStockIn
					AND cbt.dblCost = cb.dblCost
					AND cbt.ysnIsUnposted = 0 				
			) cbt
			INNER JOIN tblICItemLocation il
				ON cb.intItemLocationId = il.intItemLocationId
				AND il.intLocationId IS NULL 
			OUTER APPLY (
				SELECT 
					totalOut = SUM(cbOut.dblQty)
				FROM 		
					tblICInventoryLotOut cbOut INNER JOIN tblICInventoryTransaction t
						on t.intInventoryTransactionId = cbOut.intInventoryTransactionId					
				WHERE
					cbOut.intInventoryLotId = cb.intInventoryLotId
					AND dbo.fnDateLessThanEquals(
						t.dtmDate
						, DATEADD(DAY, cte.[Incrementor], @dtmStartDate)
					) = 1
					AND t.ysnIsUnposted = 0 		
			) t	
		WHERE
			cb.intItemId = i.intItemId
			AND dbo.fnDateLessThanEquals(
				cb.dtmDate
				, DATEADD(DAY, cte.[Incrementor], @dtmStartDate)
			) = 1		
			AND (cb.dblStockIn - isnull(t.totalOut, 0)) > 0				
	) tblInTransit	
WHERE
	(i.intItemId = @intItemId OR @intItemId IS NULL)
	AND (i.intCommodityId = @intCommodityId OR @intCommodityId IS NULL) 
	AND i.strLotTracking LIKE 'Yes%'		
	AND DATEADD(DAY, cte.[Incrementor], @dtmStartDate) < @dtmEndDate

