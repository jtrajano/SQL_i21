CREATE FUNCTION [dbo].[fnGetItemAverageCostTable] (@intItemId INT, @dtmAsOfDate DATETIME)
RETURNS @AverageCostTable TABLE(dblCost DECIMAL(38, 20), dblQty DECIMAL(38, 20), dblRunningQty DECIMAL(38, 20), dblRunningValue DECIMAL(38, 20), dblAverageCost DECIMAL(38, 20))
BEGIN

WITH CTE_Avg (dblCost, dblQty, dblRunningQty, dblRunningValue)
AS
(
	SELECT fifo.dblCost, (fifo.dblStockIn - fifo.dblStockOut) dblQty, 
		SUM(fifo.dblStockIn) OVER (ORDER BY fifo.dtmDate) dblRunningQty,
		SUM(fifo.dblStockIn * dblCost) OVER (ORDER BY fifo.dtmDate) dblRunningValue
	FROM tblICInventoryFIFO fifo
	WHERE fifo.intItemId = @intItemId
		AND dbo.fnDateLessThanEquals(dtmDate, @dtmAsOfDate) = 1
	GROUP BY fifo.dblCost, fifo.dblStockIn, fifo.dblStockOut, fifo.dtmDate
	HAVING SUM(fifo.dblStockIn - fifo.dblStockOut) > 0
)
INSERT INTO @AverageCostTable(dblCost, dblQty, dblRunningQty, dblRunningValue, dblAverageCost)
SELECT dblCost, dblQty, dblRunningQty, dblRunningValue, dblRunningValue / dblRunningQty
FROM CTE_Avg

RETURN
END