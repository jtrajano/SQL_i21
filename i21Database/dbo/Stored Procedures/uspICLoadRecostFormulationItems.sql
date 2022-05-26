CREATE PROCEDURE [dbo].[uspICLoadRecostFormulationItems]
	@intRecostFormulationId INT 
AS

IF NOT EXISTS (SELECT TOP 1 1 FROM tblICRecostFormulation r WHERE r.intRecostFormulationId = @intRecostFormulationId AND ISNULL(ysnPosted, 0) = 0) 
BEGIN 
	RETURN; -- Exits Immediately 
END 

-- Clear the tblICRecostFormulationDetail
DELETE FROM tblICRecostFormulationDetail WHERE intRecostFormulationId = @intRecostFormulationId

INSERT INTO tblICRecostFormulationDetail(
	intRecostFormulationId
	,intItemId
	,intLocationId
	,intRecipeId
	,dblOldStandardCost
	,dblNewStandardCost
	,dblDifference
	,dblOldRetailPrice
	,dblNewRetailPrice
	,intConcurrencyId
)
SELECT 
	intRecostFormulationId = r.intRecostFormulationId
	,intItemId = items.intItemId 
	,intLocationId = items.intLocationId
	,intRecipeId = items.intRecipeId
	,dblOldStandardCost = items.dblStandardCost
	,dblNewStandardCost = 
		ISNULL(receiptOutputNewStandardCost.dblNewStandardCost, items.dblStandardCost) 
	,dblDifference = 		
		ISNULL(receiptOutputNewStandardCost.dblNewStandardCost, items.dblStandardCost) 
		- ISNULL(items.dblStandardCost, 0)
	,dblOldRetailPrice = items.dblSalePrice
	,dblNewRetailPrice = 
		ISNULL(pricing.dblNewSalePrice, items.dblSalePrice) 
	,intConcurrencyId = 1
FROM 
	tblICRecostFormulation r 
	LEFT JOIN tblSMCompanyLocation fromLocation
		ON r.intLocationFromId = fromLocation.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation toLocation
		ON r.intLocationToId = toLocation.intCompanyLocationId
	LEFT JOIN tblICCategory fromCategory 
		ON r.intCategoryFromId = fromCategory.intCategoryId
	LEFT JOIN tblICCategory toCategory
		ON r.intCategoryToId = toCategory.intCategoryId

	CROSS APPLY (
		SELECT 
			i.intItemId
			,il.intLocationId
			,il.intItemLocationId
			,recipe.intRecipeId
			,p.dblStandardCost
			,p.dblSalePrice
		FROM 
			tblICItem i INNER JOIN tblICItemLocation il
				ON i.intItemId = il.intItemId
			INNER JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = il.intLocationId
			INNER JOIN tblICCategory c
				ON c.intCategoryId = i.intCategoryId
			INNER JOIN tblICItemPricing p
				ON p.intItemId = i.intItemId
				AND p.intItemLocationId = il.intItemLocationId
			CROSS APPLY (			
				-- Get the first active recipe for the item within a location. 
				SELECT TOP 1 
					recipe.intRecipeId
				FROM
					tblMFRecipe recipe
				WHERE 
					recipe.intItemId = i.intItemId
					AND recipe.intLocationId = il.intLocationId
					AND recipe.ysnActive = 1
			) recipe 
		WHERE
			(
				(
					fromLocation.strLocationName IS NOT NULL 
					AND toLocation.strLocationName IS NOT NULL 
					AND cl.strLocationName BETWEEN fromLocation.strLocationName AND toLocation.strLocationName
				) 
				OR (
					fromLocation.strLocationName IS NOT NULL 
					AND toLocation.strLocationName IS NULL 
					AND fromLocation.strLocationName = cl.strLocationName
				)
			)
			AND (
				(
					fromCategory.strCategoryCode IS NULL 
					AND toCategory.strCategoryCode IS NULL 				
				)
				OR (
					fromCategory.strCategoryCode IS NOT NULL 
					AND toCategory.strCategoryCode IS NOT NULL 
					AND c.strCategoryCode BETWEEN fromCategory.strCategoryCode AND toCategory.strCategoryCode
				) 
				OR (
					fromCategory.strCategoryCode IS NOT NULL 
					AND toCategory.strCategoryCode IS NULL 
					AND c.strCategoryCode = fromCategory.strCategoryCode 
				)			
			
			)
	) items

	CROSS APPLY (
		SELECT 
			dblTotalInputCost = 
					SUM (
						dbo.fnMultiply (
							dbo.fnCalculateCostBetweenUOM (stockUOM.intItemUOMId, ri.intItemUOMId, p.dblStandardCost) 	
							,ri.dblQuantity
						)
					) 
			
		FROM 
			tblMFRecipeItem ri INNER JOIN tblICItem i
				ON ri.intItemId = i.intItemId
			INNER JOIN tblICItemLocation il
				ON il.intItemId = i.intItemId
			INNER JOIN tblICItemPricing p
				ON p.intItemId = i.intItemId
				AND p.intItemLocationId = il.intItemLocationId
			INNER JOIN tblICItemUOM stockUOM
				ON stockUOM.intItemId = i.intItemId
				AND stockUOM.ysnStockUnit = 1
		WHERE
			ri.intRecipeId = items.intRecipeId
			AND il.intLocationId = items.intLocationId	
			AND ri.intRecipeItemTypeId = 1 -- INPUT 
	) recipeInput

	CROSS APPLY (
		SELECT 
			ri.* 			
		FROM 
			tblMFRecipeItem ri INNER JOIN tblICItem i
				ON ri.intItemId = i.intItemId
			INNER JOIN tblICItemLocation il
				ON il.intItemId = i.intItemId
			INNER JOIN tblICItemPricing p
				ON p.intItemId = i.intItemId
				AND p.intItemLocationId = il.intItemLocationId
			INNER JOIN tblICItemUOM stockUOM
				ON stockUOM.intItemId = i.intItemId
				AND stockUOM.ysnStockUnit = 1
		WHERE
			ri.intRecipeId = items.intRecipeId
			AND ri.intItemId = items.intItemId
			AND il.intLocationId = items.intLocationId				
			AND ri.intRecipeItemTypeId = 2 -- OUTPUT
	) recipeOutput

	CROSS APPLY (
		SELECT 
			dblNewStandardCost = 			
			dbo.fnMultiply(
				ISNULL(recipeInput.dblTotalInputCost, 0)
				,dbo.fnDivide(ISNULL(recipeOutput.dblCostAllocationPercentage, 100), 100) 
			)	
	) receiptOutputNewStandardCost 

	CROSS APPLY (
		SELECT 
			dblNewSalePrice = 
				CASE	WHEN p.strPricingMethod = 'Markup Standard Cost' THEN 
							ROUND(
 								ISNULL(receiptOutputNewStandardCost.dblNewStandardCost, 0) 
								* (p.dblAmountPercent / 100) 
								+ ISNULL(receiptOutputNewStandardCost.dblNewStandardCost, 0) 
								, r.intRounding
							) 
						WHEN p.strPricingMethod = 'Markup Last Cost' THEN 
							ROUND(p.dblLastCost * p.dblAmountPercent / 100 + p.dblLastCost, r.intRounding) 
						WHEN p.strPricingMethod = 'Markup Avg Cost' THEN 
							ROUND(p.dblAverageCost * p.dblAmountPercent / 100 + p.dblAverageCost, r.intRounding) 
						ELSE 
							p.dblSalePrice
				END 
		FROM	
			tblICItemPricing p
		WHERE	
			p.intItemId = items.intItemId
			AND p.intItemLocationId = items.intItemLocationId
	) pricing 

WHERE
	r.intRecostFormulationId = @intRecostFormulationId

RETURN 0
