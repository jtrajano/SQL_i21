CREATE PROCEDURE [dbo].[uspICUpdateRecostFormulationItems]
	@intRecostFormulationId INT 
AS

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICRecostFormulation r WHERE r.intRecostFormulationId = @intRecostFormulationId AND ISNULL(ysnPosted, 0) = 0) 
BEGIN 
	RETURN; -- Exits Immediately 
END 

UPDATE tblICRecostFormulation
SET 
	intConcurrencyId = ISNULL(intConcurrencyId, 0) + 1
WHERE 
	intRecostFormulationId = @intRecostFormulationId 

-- Update the Standard Cost
UPDATE p
SET
	p.dblStandardCost = ri.dblNewStandardCost 	
FROM 
	tblICRecostFormulation r INNER JOIN tblICRecostFormulationDetail ri
		ON r.intRecostFormulationId = ri.intRecostFormulationId
	INNER JOIN tblICItem i 
		ON i.intItemId = ri.intItemId
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId
		AND il.intLocationId = ri.intLocationId 
	INNER JOIN tblICItemPricing p
		ON p.intItemId = ri.intItemId
		AND p.intItemLocationId = il.intItemLocationId 		
WHERE 
	r.intRecostFormulationId = @intRecostFormulationId
	AND ISNULL(ri.dblNewStandardCost, 0) <> 0 
	AND p.dblStandardCost <> ri.dblNewStandardCost 

-- Update the Retail Price 
UPDATE p
SET
	dblSalePrice = ISNULL(NULLIF(ri.dblNewRetailPrice, 0), p.dblSalePrice) 
FROM 
	tblICRecostFormulation r INNER JOIN tblICRecostFormulationDetail ri
		ON r.intRecostFormulationId = ri.intRecostFormulationId
	INNER JOIN tblICItem i 
		ON i.intItemId = ri.intItemId
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId
		AND il.intLocationId = ri.intLocationId 
	INNER JOIN tblICItemPricing p
		ON p.intItemId = ri.intItemId
		AND p.intItemLocationId = il.intItemLocationId 		
WHERE 
	r.intRecostFormulationId = @intRecostFormulationId
	AND ISNULL(ri.dblNewRetailPrice, 0) <> 0 
	AND ri.dblNewRetailPrice <> p.dblSalePrice

-- Update the Pricing Levels
UPDATE	pl
SET		pl.dblUnitPrice = 
		CASE	

			WHEN pl.strPricingMethod = 'Percent of Margin (MSRP)' THEN 
				ROUND(
					((p.dblMSRPPrice - p.dblStandardCost) * (pl.dblAmountRate / 100)) + p.dblStandardCost
					,ISNULL(r.intRounding, 6)
				) 
			WHEN pl.strPricingMethod = 'Fixed Dollar Amount' THEN 
				dbo.fnCalculateCostBetweenUOM (
					stockUOM.intItemUOMId		
					,pl.intItemUnitMeasureId
					,ROUND(
						(p.dblStandardCost + pl.dblAmountRate) 
						,ISNULL(r.intRounding, 6)
					) 
				)
			WHEN pl.strPricingMethod = 'Markup Standard Cost Percentage ' THEN 
				ROUND(
					((p.dblStandardCost * pl.dblAmountRate) / 100) + p.dblStandardCost
					, ISNULL(r.intRounding, 6)
				) 

			WHEN pl.strPricingMethod = 'Percent of Margin' THEN 
				dbo.fnCalculateCostBetweenUOM (
					stockUOM.intItemUOMId		
					,pl.intItemUnitMeasureId
					,ROUND(
						(p.dblStandardCost / (1 - (pl.dblAmountRate / 100)))
						,ISNULL(r.intRounding, 6)
					) 
				)
				
			WHEN pl.strPricingMethod = 'Discount Retail Price' THEN 
				dbo.fnCalculateCostBetweenUOM (
					stockUOM.intItemUOMId		
					,pl.intItemUnitMeasureId
					,ROUND(
						(p.dblSalePrice - (p.dblSalePrice * pl.dblAmountRate / 100))
						,ISNULL(r.intRounding, 6)
					) 
				)		

			ELSE 
				pl.dblUnitPrice

		END 
FROM	
	tblICRecostFormulation r INNER JOIN tblICRecostFormulationDetail ri
		ON r.intRecostFormulationId = ri.intRecostFormulationId
	INNER JOIN tblICItem i 
		ON i.intItemId = ri.intItemId
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId
		AND il.intLocationId = ri.intLocationId 
	INNER JOIN tblICItemPricing p
		ON p.intItemId = ri.intItemId
		AND p.intItemLocationId = il.intItemLocationId 		
	INNER JOIN tblICItemPricingLevel pl 
		ON pl.intItemId = p.intItemId
		AND pl.intItemLocationId = p.intItemLocationId
	CROSS APPLY (
		SELECT TOP 1 
			iu.*
		FROM 
			tblICItemUOM iu
		WHERE 
			iu.intItemId = i.intItemId
			AND iu.ysnStockUnit = 1
	) stockUOM
WHERE 
	r.intRecostFormulationId = @intRecostFormulationId
	AND ISNULL(ri.dblNewStandardCost, 0) <> 0 
	AND ISNULL(ri.dblOldStandardCost, 0) <> ISNULL(ri.dblNewStandardCost, 0) 

UPDATE tblICRecostFormulation
SET 
	ysnPosted = 1 
WHERE 
	intRecostFormulationId = @intRecostFormulationId 

RETURN 0
