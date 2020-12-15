PRINT 'Locking AVG cost for items with existing transactions...'

UPDATE i
SET i.ysnAvgLocked = 1
FROM (
	SELECT DISTINCT intItemId
	FROM tblICInventoryTransaction t
) xt
INNER JOIN tblICItem i ON i.intItemId = xt.intItemId

PRINT 'End of locking AVG cost for items with existing transactions'