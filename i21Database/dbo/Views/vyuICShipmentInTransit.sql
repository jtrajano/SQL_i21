CREATE VIEW vyuICShipmentInTransit
AS 
SELECT 
	strShipmentNumber = cb.strTransactionId
	,cb.dtmDate
	,cb.dblStockIn
	,cb.dblStockOut
	,[dblInTransit] = cb.dblStockIn - isnull(t.totalOut, 0) 
FROM 
	tblICInventoryActualCost cb
	OUTER APPLY (
		SELECT 
			totalOut = SUM(cbOut.dblQty)
		FROM 		
			tblICInventoryActualCostOut cbOut inner join tblICInventoryTransaction t
				ON t.intInventoryTransactionId = cbOut.intInventoryTransactionId					
		WHERE
			cbOut.intInventoryActualCostId = cb.intInventoryActualCostId
			AND t.ysnIsUnposted = 0 		
	) t	