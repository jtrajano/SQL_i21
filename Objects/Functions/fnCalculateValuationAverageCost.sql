CREATE FUNCTION [dbo].[fnCalculateValuationAverageCost]
(
	@intItemId AS INT 
	,@intItemLocation AS INT 
	,@dtmAsOfDate DATETIME
)
RETURNS NUMERIC(38,20)
AS
BEGIN 

	DECLARE 
		@dblAverageCost AS NUMERIC(38, 20) 
		,@dblQty AS NUMERIC(38, 20)
		,@dblValue AS NUMERIC(38, 20)
		,@intStockUOM AS INT 

	SELECT 
		@intStockUOM = iu.intItemUOMId
	FROM tblICItemUOM iu
	WHERE 
		iu.intItemId = @intItemId
		AND iu.ysnStockUnit = 1

	SELECT 
		@dblQty = SUM(dbo.fnCalculateQtyBetweenUOM(t.intItemUOMId, @intStockUOM, t.dblQty)) 
		,@dblValue = SUM(t.dblQty * t.dblCost + t.dblValue) 
	FROM tblICInventoryTransaction t
	WHERE 
		t.intItemId = @intItemId
		AND t.intItemLocationId = @intItemLocation 
		AND dbo.fnDateLessThanEquals(t.dtmDate, @dtmAsOfDate) = 1

	SELECT @dblAverageCost =  CASE WHEN @dblQty <> 0 THEN dbo.fnDivide(@dblValue, @dblQty) ELSE 0 END 

	RETURN @dblAverageCost
END 
