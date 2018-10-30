CREATE FUNCTION [dbo].[fnGetItemAverageCostTable] (@intItemId INT, @dtmAsOfDate DATETIME)
RETURNS @AverageCostTable TABLE(dblCost DECIMAL(38, 20), dblQty DECIMAL(38, 20), dblRunningQty DECIMAL(38, 20), dblRunningValue DECIMAL(38, 20), dblAverageCost DECIMAL(38, 20))
BEGIN

-- SQL Server 2012 and up
--WITH CTE_Avg (dblCost, dblQty, dblRunningQty, dblRunningValue)
--AS
--(
--	SELECT fifo.dblCost, (fifo.dblStockIn - fifo.dblStockOut) dblQty, 
--		SUM(fifo.dblStockIn) OVER (ORDER BY fifo.dtmDate) dblRunningQty,
--		SUM(fifo.dblStockIn * dblCost) OVER (ORDER BY fifo.dtmDate) dblRunningValue
--	FROM tblICInventoryFIFO fifo
--	WHERE fifo.intItemId = @intItemId
--		AND dbo.fnDateLessThanEquals(dtmDate, @dtmAsOfDate) = 1
--	GROUP BY fifo.dblCost, fifo.dblStockIn, fifo.dblStockOut, fifo.dtmDate
--	HAVING SUM(fifo.dblStockIn - fifo.dblStockOut) > 0
--)
--INSERT INTO @AverageCostTable(dblCost, dblQty, dblRunningQty, dblRunningValue, dblAverageCost)
--SELECT dblCost, dblQty, dblRunningQty, dblRunningValue, dblRunningValue / dblRunningQty
--FROM CTE_Avg

-- SQL Server 2008R2 backwards compatible
INSERT INTO @AverageCostTable(dblCost, dblQty, dblRunningQty, dblRunningValue, dblAverageCost)
SELECT
	fifo.dblCost, 
	(fifo.dblStockIn - fifo.dblStockOut) dblQty,
	SUM(totals.dblQty) dblRunningQty,
	SUM(totals.dblValue) dblRunningValue,
	CAST(SUM(totals.dblValue) / SUM(totals.dblQty) AS NUMERIC(38,20)) dblAverageCost
FROM tblICInventoryFIFO fifo
	LEFT OUTER JOIN (
		SELECT
			fifoTotals.intItemId,
			fifoTotals.dblCost, 
			(fifoTotals.dblStockIn - fifoTotals.dblStockOut) dblQty,
			(fifoTotals.dblStockIn * fifoTotals.dblCost) dblValue
		FROM tblICInventoryFIFO fifoTotals
		WHERE fifoTotals.intItemId = @intItemId
			AND dbo.fnDateLessThanEquals(fifoTotals.dtmDate, @dtmAsOfDate) = 1
			AND (fifoTotals.dblStockIn - fifoTotals.dblStockOut) > 0
		GROUP BY fifoTotals.intItemId, fifoTotals.dblCost, fifoTotals.dblStockIn, fifoTotals.dblStockOut
	) totals ON totals.intItemId = fifo.intItemId
WHERE fifo.intItemId = @intItemId
	AND dbo.fnDateLessThanEquals(fifo.dtmDate, @dtmAsOfDate) = 1
	AND (fifo.dblStockIn - fifo.dblStockOut) > 0
GROUP BY fifo.dblCost, fifo.dblStockIn, fifo.dblStockOut

RETURN
END