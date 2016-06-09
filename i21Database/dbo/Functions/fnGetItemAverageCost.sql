CREATE FUNCTION [dbo].[fnGetItemAverageCost]
(
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE @AverageCost AS NUMERIC(18,6)

	-- Get the average cost of item per location. Must adjusted to the UOM
	SELECT	TOP 1 
			@AverageCost = dbo.fnMultiply(ISNULL(Pricing.dblAverageCost, 0), ISNULL(ItemUOM.dblUnitQty, 0)) 
	FROM	dbo.tblICItemPricing Pricing LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Pricing.intItemId = ItemUOM.intItemId				
	WHERE	Pricing.intItemId = @intItemId
			AND Pricing.intItemLocationId = @intItemLocationId
			AND ItemUOM.intItemUOMId = @intItemUOMId

	RETURN ISNULL(@AverageCost, 0)
END
GO