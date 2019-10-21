CREATE FUNCTION [dbo].[fnGetLotUnitCost]
(
	@intLotId INT	
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE @unitCost AS NUMERIC(18,6)

	SELECT	@unitCost = SUM(cb.dblStockIn * cb.dblCost) / SUM(cb.dblStockIn) 
	FROM	tblICLot l INNER JOIN tblICInventoryLot cb
				on l.intLotId = cb.intLotId
	WHERE	l.intLotId = @intLotId
			AND cb.dblStockIn <> 0 
			AND ISNULL(cb.ysnIsUnposted, 0) = 0 
			AND ROUND(cb.dblStockIn - cb.dblStockOut, 6) <> 0 

	RETURN ISNULL(@unitCost, 0)
END