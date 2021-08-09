PRINT 'Locking AVG cost for items with existing transactions in specific locations...'

UPDATE i
SET i.ysnAvgLocked = 1
FROM (
	SELECT DISTINCT intItemId, intItemLocationId
	FROM tblICInventoryTransaction t
) xt
INNER JOIN tblICItemPricing i ON i.intItemId = xt.intItemId
	AND i.intItemLocationId = xt.intItemLocationId

PRINT 'End of locking AVG cost for items with existing transactions in specific locations'