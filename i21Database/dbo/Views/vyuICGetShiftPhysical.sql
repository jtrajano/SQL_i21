CREATE VIEW [dbo].[vyuICGetShiftPhysical]
AS 

SELECT 
	s.intInventoryShiftPhysicalCountId
	,c.strCountGroup
	,i.strItemNo
	,i.strDescription
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
	,dblPrice = s.dblSalesPrice 
	,dblValue =  
		ROUND(
			dbo.fnMultiply(
				(
					ISNULL(s.dblSystemCount, 0) 
					+ ISNULL(s.dblQtyReceived, 0) 
					- ISNULL(s.dblQtySold, 0)
					- ISNULL(s.dblPhysicalCount, 0)		
				)
				,s.dblSalesPrice
			)
			,2
		)
	,cnt.strCountBy
FROM 
	tblICInventoryShiftPhysicalHistory s INNER JOIN tblICInventoryCount cnt
		ON s.intTransactionId = cnt.intInventoryCountId AND s.strTransactionId = cnt.strCountNo
	LEFT JOIN tblICCountGroup c
		ON s.intCountGroupId = c.intCountGroupId
	LEFT JOIN tblICItem i 
		ON i.intItemId = s.intItemId
WHERE
	s.ysnIsUnposted = 0 
	AND s.dblPhysicalCount IS NOT NULL 
	AND cnt.strCountBy = 'Retail Count'