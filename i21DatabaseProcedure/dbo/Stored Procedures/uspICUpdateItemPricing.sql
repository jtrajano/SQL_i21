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
SET ANSI_WARNINGS OFF

UPDATE	pl
SET		pl.dblUnitPrice = 
			CASE	WHEN pl.strPricingMethod = 'Markup Standard Cost' THEN 
						ROUND(p.dblStandardCost * pl.dblAmountRate / 100 + p.dblStandardCost, 6) 
					WHEN pl.strPricingMethod = 'Markup Last Cost' THEN 
						ROUND(p.dblLastCost * pl.dblAmountRate / 100 + p.dblLastCost, 6) 
					WHEN pl.strPricingMethod = 'Markup Avg Cost' THEN 
						ROUND(p.dblAverageCost * pl.dblAmountRate / 100 + p.dblAverageCost, 6) 
					ELSE 
						pl.dblUnitPrice
			END 
FROM	tblICItemPricingLevel pl INNER JOIN tblICItemPricing p
			ON pl.intItemId = p.intItemId
			AND pl.intItemLocationId = p.intItemLocationId
WHERE	p.intItemId = @intItemId
		AND p.intItemLocationId = @intItemLocationId
		AND (
			p.ysnIsPendingUpdate = 1 
			OR ISNULL(@forceUpdate, 0) = 1
		)

UPDATE	p
SET		p.dblSalePrice = 
			CASE	WHEN p.strPricingMethod = 'Markup Standard Cost' THEN 
						ROUND(p.dblStandardCost * p.dblAmountPercent / 100 + p.dblStandardCost, 6) 
					WHEN p.strPricingMethod = 'Markup Last Cost' THEN 
						ROUND(p.dblLastCost * p.dblAmountPercent / 100 + p.dblLastCost, 6) 
					WHEN p.strPricingMethod = 'Markup Avg Cost' THEN 
						ROUND(p.dblAverageCost * p.dblAmountPercent / 100 + p.dblAverageCost, 6) 
					ELSE 
						p.dblSalePrice
			END 
		,ysnIsPendingUpdate = 0 
FROM	tblICItemPricing p
WHERE	p.intItemId = @intItemId
		AND p.intItemLocationId = @intItemLocationId
		AND (
			p.ysnIsPendingUpdate = 1 
			OR ISNULL(@forceUpdate, 0) = 1
		)