CREATE FUNCTION [dbo].[fnMFGetLotUnitCost]
(
                @intLotId INT    
)
RETURNS NUMERIC(18,6)
WITH SCHEMABINDING
AS 
BEGIN 
                DECLARE @unitCost AS NUMERIC(18,6)

                SELECT  @unitCost = SUM(cb.dblStockIn * cb.dblCost) / SUM(cb.dblStockIn) 
                FROM   dbo.tblICLot l INNER JOIN dbo.tblICInventoryLot cb
                                                                on l.intLotId = cb.intLotId
                WHERE l.intLotId = @intLotId
                                                AND cb.dblStockIn <> 0 
                                                AND ISNULL(cb.ysnIsUnposted, 0) = 0 
                                                AND ROUND(cb.dblStockIn - cb.dblStockOut, 6) <> 0 

                RETURN ISNULL(@unitCost, 0)
END
