CREATE VIEW [dbo].[vyuICGetShiftPhysical]
AS 

SELECT 
	s.intInventoryShiftPhysicalCountId
	,c.strCountGroup
	,s.dtmDate
	,dblBegin = s.dblSystemCount
	,dblQtyReceived = s.dblQtyReceived
	,dblQtySold = s.dblQtySold
	,dblEnding = 
		ISNULL(s.dblSystemCount, 0) 
		+ ISNULL(s.dblQtyReceived, 0) 
		- ISNULL(s.dblQtySold, 0)
	,dblCalculated = s.dblPhysicalCount
	,dblDifference = 
		ISNULL(s.dblSystemCount, 0) 
		+ ISNULL(s.dblQtyReceived, 0) 
		- ISNULL(s.dblQtySold, 0)
		- ISNULL(s.dblPhysicalCount, 0)
	,dblPrice = CAST(0 AS NUMERIC(18, 6))
	,dblValue =  CAST(0 AS NUMERIC(18, 6))
	,cnt.strCountBy
FROM 
	tblICInventoryShiftPhysicalHistory s INNER JOIN tblICInventoryCount cnt
		ON s.intTransactionId = cnt.intInventoryCountId AND s.strTransactionId = cnt.strCountNo
	LEFT JOIN tblICCountGroup c
		ON s.intCountGroupId = c.intCountGroupId
WHERE
	s.ysnIsUnposted = 0 
	AND s.dblPhysicalCount IS NOT NULL 
	AND cnt.strCountBy = 'Item Group'