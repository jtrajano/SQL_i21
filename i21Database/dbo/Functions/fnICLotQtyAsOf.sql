CREATE FUNCTION [dbo].[fnICLotQtyAsOf](
	@intItemId INT 
	,@dtmDate DATETIME 
)
RETURNS TABLE 
AS

RETURN 

SELECT
	intItemId			= i.intItemId
	,intItemLocationId	= l.intItemLocationId
	,l.intLotId
	,l.intItemUOMId
	,l.intWeightUOMId
	,dblQty				= ISNULL(tblLotOnHand.dblQty, 0)
	,dblWeight			= ISNULL(tblLotOnHand.dblWeight,0)
	,dtmDate			= dbo.fnRemoveTimeOnDate(tblLotOnHand.dtmDate) 
FROM

	tblICLot l INNER JOIN tblICItem i 
		ON l.intItemId = i.intItemId 
	INNER JOIN (
		tblICItemUOM stockUOM inner join tblICUnitMeasure stockUnit
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
			,cb.intItemLocationId 
			,dblQty = 
				CASE 
					WHEN 
						cb.intItemUOMId <> l.intItemUOMId 
						AND l.intWeightUOMId IS NOT NULL 
						AND ISNULL(l.dblWeightPerQty, 0) <> 0 THEN 
							dbo.fnDivide(cb.dblStockIn - isnull(t.totalOut, 0) , l.dblWeightPerQty) 
					ELSE 
						cb.dblStockIn - isnull(t.totalOut, 0) 
				END 
				
			,dblWeight = 
				CASE 
					WHEN 
						cb.intItemUOMId = l.intWeightUOMId
						AND l.intWeightUOMId IS NOT NULL THEN 
							cb.dblStockIn - isnull(t.totalOut, 0)								
					ELSE 
						0.00
				END 
		FROM	
			tblICInventoryLot cb INNER JOIN tblICInventoryTransaction cbt
				ON cbt.strTransactionId = cb.strTransactionId
				AND cbt.intItemId = cb.intItemId
				AND cbt.intItemLocationId = cb.intItemLocationId
				AND cbt.intItemUOMId = cb.intItemUOMId
				AND cbt.intLotId = cb.intLotId
				AND cbt.dblQty = cb.dblStockIn
				AND cbt.ysnIsUnposted = 0 				
			INNER JOIN tblICItemLocation il
				ON cb.intItemLocationId = il.intItemLocationId
				AND il.intLocationId IS NOT NULL 
			OUTER APPLY (
				SELECT 
					totalOut = SUM(cbOut.dblQty)
				FROM 		
					tblICInventoryLotOut cbOut INNER JOIN tblICInventoryTransaction t
						on t.intInventoryTransactionId = cbOut.intInventoryTransactionId					
				WHERE
					cbOut.intInventoryLotId = cb.intInventoryLotId
					AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmDate) = 1
					AND t.ysnIsUnposted = 0 		
			) t	
		WHERE
			cb.intItemId = i.intItemId
			AND cb.intLotId = l.intLotId 
			AND dbo.fnDateLessThanEquals(cb.dtmDate, @dtmDate) = 1
			AND (cb.dblStockIn - isnull(t.totalOut, 0)) > 0							
	) tblLotOnHand	
WHERE
	(i.intItemId = @intItemId OR @intItemId IS NULL)
	AND i.strLotTracking LIKE 'Yes%'		

