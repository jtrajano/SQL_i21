/*
	This stored procedure will update the Sales Price in the Item Pricing and Item Pricing Level. 
*/
CREATE PROCEDURE [dbo].[uspICUpdateItemPricing]
	@intItemId AS INT
	,@intItemLocationId AS INT
	,@forceUpdate AS BIT = 0
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

----------------------------------------------------------
-- Update the pricing level
----------------------------------------------------------
BEGIN 
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(p.dblStandardCost * pl.dblAmountRate / 100 + p.dblStandardCost) * pl.dblUnit 
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Markup Standard Cost' 
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)
		
	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(p.dblLastCost * pl.dblAmountRate / 100 + p.dblLastCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Markup Last Cost'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(p.dblAverageCost * pl.dblAmountRate / 100 + p.dblAverageCost) * pl.dblUnit 
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Markup Avg Cost'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
					((p.dblMSRPPrice - p.dblStandardCost) * (pl.dblAmountRate / 100) + p.dblStandardCost) * pl.dblUnit
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Percent of Margin (MSRP)'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND(
				(p.dblStandardCost / (1 - pl.dblAmountRate/100)) * pl.dblUnit 
				, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Fixed Dollar Amount'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	pl
	SET		pl.dblUnitPrice = ROUND((p.dblStandardCost + pl.dblAmountRate) * pl.dblUnit, 6) 
	FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
				ON pl.intItemId = p.intItemId
				AND pl.intItemLocationId = p.intItemLocationId
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND pl.strPricingMethod = 'Percent of Margin'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)
END 

----------------------------------------------------------
-- Update the item pricing
----------------------------------------------------------
BEGIN 
	UPDATE	p
	SET		p.dblSalePrice = ROUND(p.dblStandardCost * p.dblAmountPercent / 100 + p.dblStandardCost, 6) 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND p.strPricingMethod = 'Markup Standard Cost'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	p
	SET		p.dblSalePrice = ROUND(p.dblLastCost * p.dblAmountPercent / 100 + p.dblLastCost, 6) 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND p.strPricingMethod = 'Markup Last Cost'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	p
	SET		p.dblSalePrice = ROUND(p.dblAverageCost * p.dblAmountPercent / 100 + p.dblAverageCost, 6) 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND p.strPricingMethod = 'Markup Avg Cost'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	p
	SET		p.dblSalePrice = ROUND(p.dblStandardCost + p.dblAmountPercent, 6) 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND p.strPricingMethod = 'Fixed Dollar Amount'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)

	UPDATE	p
	SET		p.dblSalePrice = ROUND((p.dblStandardCost / (1 - p.dblAmountPercent/100)), 6) 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId
			AND p.strPricingMethod = 'Percent of Margin'
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)
END 

-- Mark those that is finished with the updating. 
BEGIN
	UPDATE	p
	SET		ysnIsPendingUpdate = 0 
	FROM	tblICItemPricing p
	WHERE	p.intItemId = @intItemId
			AND p.intItemLocationId = @intItemLocationId			
			AND (p.ysnIsPendingUpdate = 1 OR ISNULL(@forceUpdate, 0) = 1)
END 