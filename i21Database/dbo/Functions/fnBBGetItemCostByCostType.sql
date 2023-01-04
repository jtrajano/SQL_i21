CREATE FUNCTION [dbo].[fnBBGetItemCostByCostType] (
    @strCostType NVARCHAR(50), 
    @intItemId INT, 
    @intItemLocationId INT, 
    @intItemUOMId INT,
    @dtmAsOfDate DATETIME)
RETURNS NUMERIC(18, 6)
BEGIN
    DECLARE @dblCost NUMERIC(18, 6) = 0.0
    IF (@dtmAsOfDate IS NULL)
        SET @dtmAsOfDate = GETDATE()

    IF (@strCostType = 'Current Cost')
    BEGIN
        SELECT @dblCost = dblCost
        FROM dbo.fnICGetItemCostByEffectiveDate(@dtmAsOfDate, @intItemId, @intItemLocationId, 1)
    END
    ELSE IF (@strCostType = 'Costing Method')
    BEGIN
        SELECT TOP 1 @dblCost = fifo.dblCost
        FROM tblICInventoryFIFO fifo
        JOIN tblICItemLocation il ON il.intItemLocationId = fifo.intItemLocationId
        JOIN tblICCostingMethod cm ON cm.intCostingMethodId = il.intCostingMethod
        WHERE fifo.intItemId = @intItemId
            AND fifo.dtmDate <= @dtmAsOfDate
            AND fifo.intItemLocationId = @intItemLocationId
            AND cm.strCostingMethod = 'FIFO'
            AND fifo.dblStockIn- fifo.dblStockOut > 0
        ORDER BY intInventoryFIFOId DESC

        SELECT TOP 1 @dblCost = lifo.dblCost
        FROM tblICInventoryLIFO lifo
        JOIN tblICItemLocation il ON il.intItemLocationId = lifo.intItemLocationId
        JOIN tblICCostingMethod cm ON cm.intCostingMethodId = il.intCostingMethod
        WHERE lifo.intItemId = @intItemId
            AND lifo.dtmDate <= @dtmAsOfDate
            AND lifo.intItemLocationId = @intItemLocationId
            AND lifo.dblStockIn- lifo.dblStockOut > 0
            AND cm.strCostingMethod = 'LIFO'
        
        SELECT TOP 1 @dblCost = dbo.fnGetItemAverageCost(il.intItemId, il.intItemLocationId, @intItemUOMId)
        FROM tblICItemLocation il
        JOIN tblICCostingMethod cm ON cm.intCostingMethodId = il.intCostingMethod
        WHERE il.intItemId = @intItemId
            AND il.intItemLocationId = @intItemLocationId
            AND cm.strCostingMethod = 'AVG'
    END
    ELSE
    BEGIN
        SELECT @dblCost = COALESCE(p.dblLastCost, p.dblStandardCost)
        FROM tblICItemPricing p
        WHERE p.intItemId = @intItemId
            AND p.intItemLocationId = @intItemLocationId
    END

    RETURN ISNULL(@dblCost, 0.0)
END
