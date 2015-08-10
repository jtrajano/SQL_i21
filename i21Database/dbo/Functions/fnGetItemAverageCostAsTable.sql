CREATE FUNCTION [dbo].[fnGetItemAverageCostAsTable]
(
	@intItemId INT
	,@intItemLocationId INT
	,@intItemUOMId INT 
)
RETURNS TABLE 
RETURN (
	-- Get the average cost of item per location
	SELECT	TOP 1 
			AverageCost = ISNULL(Pricing.dblAverageCost, 0) * ISNULL(ItemUOM.dblUnitQty, 0)
	FROM	dbo.tblICItemPricing Pricing LEFT JOIN dbo.tblICItemUOM ItemUOM
				ON Pricing.intItemId = ItemUOM.intItemId				
	WHERE	Pricing.intItemId = @intItemId
			AND Pricing.intItemLocationId = @intItemLocationId
			AND ItemUOM.intItemUOMId = @intItemUOMId
)
