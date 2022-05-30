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
	,dblNewStandardCost = items.dblStandardCost
	,dblDifference = 0.00
	,dblOldRetailPrice = items.dblSalePrice
	,dblNewRetailPrice = items.dblSalePrice
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
WHERE
	r.intRecostFormulationId = @intRecostFormulationId


RETURN 0
