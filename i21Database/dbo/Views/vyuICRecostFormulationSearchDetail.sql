CREATE VIEW [dbo].[vyuICRecostFormulationSearchDetail]
AS 

SELECT 
	rd.intRecostFormulationDetailId
	,r.intRecostFormulationId
	,r.strRecostFormulationId
	,r.dtmDate
	,r.intRounding
	,r.strDescription
	,r.intLocationFromId
	,r.intLocationToId
	,r.intCategoryFromId
	,r.intCategoryToId
	,r.ysnPosted
	,strLocationFrom = fromLocation.strLocationName
	,strLocationTo = toLocation.strLocationName
	,strCategoryFrom = fromCategory.strCategoryCode
	,strCategoryTo = toCategory.strCategoryCode	
	,rd.intItemId
	,rd.intLocationId
	,rd.intRecipeId
	,rd.dblOldStandardCost
	,rd.dblNewStandardCost
	,rd.dblDifference
	,rd.dblOldRetailPrice
	,rd.dblNewRetailPrice
	,dblPriceDifference = ISNULL(rd.dblNewRetailPrice, 0) - ISNULL(rd.dblOldRetailPrice, 0) 
	,strItemNo = i.strItemNo
	,strRecipe = recipe.strName
	,strLocation = cl.strLocationName
	,dblCostDiffPercentage = CASE WHEN rd.dblOldStandardCost <> 0 THEN rd.dblDifference / rd.dblOldStandardCost * 100 ELSE rd.dblNewStandardCost END 
	,dblPriceDiffPercentage = CASE WHEN rd.dblOldRetailPrice <> 0 THEN (rd.dblNewRetailPrice - rd.dblOldRetailPrice) / rd.dblOldRetailPrice * 100 ELSE rd.dblNewRetailPrice END 
FROM 
	tblICRecostFormulation r 
	INNER JOIN tblICRecostFormulationDetail rd ON r.intRecostFormulationId = rd.intRecostFormulationId

	LEFT JOIN tblMFRecipe recipe ON rd.intRecipeId = recipe.intRecipeId
	LEFT JOIN tblICItem i ON rd.intItemId = i.intItemId
	LEFT JOIN tblSMCompanyLocation cl ON rd.intLocationId = cl.intCompanyLocationId 

	LEFT JOIN tblSMCompanyLocation fromLocation  ON r.intLocationFromId = fromLocation.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation toLocation  ON r.intLocationToId = toLocation.intCompanyLocationId
	LEFT JOIN tblICCategory fromCategory ON r.intCategoryFromId = fromCategory.intCategoryId
	LEFT JOIN tblICCategory toCategory ON r.intCategoryToId = toCategory.intCategoryId
