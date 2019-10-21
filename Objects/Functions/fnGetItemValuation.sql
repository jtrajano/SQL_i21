CREATE FUNCTION dbo.fnGetItemValuation(@intItemId INT, @intItemLocationId INT, @strPeriod NVARCHAR(50))
RETURNS TABLE
AS
RETURN
(
	SELECT
		  intLocationId = ISNULL(it.intLocationId, il.intLocationId)
		, ysnInTransit = CASE WHEN il.intLocationId IS NULL THEN 1 ELSE 0 END
		, dblQuantity = SUM(ISNULL(t.dblQty, 0))
		, dblQuantityInStockUOM = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, im.intItemUOMId, t.dblQty))
		, dblValue = SUM(ROUND(ISNULL(t.dblQty, 0) * ISNULL(t.dblCost, 0) + ISNULL(t.dblValue, 0), 2))
	FROM tblICInventoryTransaction t
		INNER JOIN tblICItem i ON i.intItemId = t.intItemId
		INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
		LEFT JOIN tblICItemUOM im ON im.intItemId = t.intItemId
			AND im.ysnStockUnit = 1
		LEFT JOIN tblICItemLocation it ON it.intItemLocationId = t.intInTransitSourceLocationId
			AND t.intInTransitSourceLocationId IS NOT NULL
		INNER JOIN tblGLFiscalYearPeriod fyp ON dbo.fnDateLessThanEquals(t.dtmDate, fyp.dtmEndDate) = 1
	WHERE i.strType NOT IN ('Other Charge', 'Non-Inventory', 'Service', 'Software', 'Comment', 'Bundle')
		AND i.intItemId = @intItemId
		AND il.intItemLocationId = @intItemLocationId
		AND fyp.strPeriod = @strPeriod
		--AND fyp.ysnOpen = 1 -- Do not restrict on open fiscal periods. It should load any fiscal period. 
	GROUP BY ISNULL(it.intLocationId, il.intLocationId), CASE WHEN il.intLocationId IS NULL THEN 1 ELSE 0 END
)