CREATE VIEW vyuMFWastageItem
AS
-- Item
SELECT DISTINCT 1 AS intTypeId
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,MAX(IP.dblStandardCost) AS dblStandardCost
	,MC.intManufacturingCellId
	,NULL AS intWorkOrderId
FROM tblICItemFactoryManufacturingCell MC
JOIN tblICItemFactory IFA ON IFA.intItemFactoryId = MC.intItemFactoryId
JOIN tblMFRecipe R ON R.intItemId = IFA.intItemId
	AND R.intLocationId = IFA.intFactoryId
	AND R.ysnActive = 1
JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
JOIN tblICItem I ON I.intItemId = RI.intItemId
	AND I.strStatus = 'Active'
JOIN tblICItemPricing IP ON IP.intItemId = I.intItemId
GROUP BY I.intItemId
	,I.strItemNo
	,I.strDescription
	,MC.intManufacturingCellId

UNION

-- Work Order's Item (Load Recipe Input Items)
SELECT DISTINCT 2 AS intTypeId
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,MAX(IP.dblStandardCost) AS dblStandardCost
	,NULL AS intManufacturingCellId
	,WO.intWorkOrderId
FROM tblMFWorkOrder WO
JOIN tblMFRecipe R ON R.intItemId = WO.intItemId
	AND R.intLocationId = WO.intLocationId
	AND R.ysnActive = 1
JOIN tblMFRecipeItem RI ON RI.intRecipeId = R.intRecipeId
JOIN tblICItem I ON I.intItemId = RI.intItemId
	AND I.strStatus = 'Active'
JOIN tblICItemPricing IP ON IP.intItemId = I.intItemId
GROUP BY I.intItemId
	,I.strItemNo
	,I.strDescription
	,WO.intWorkOrderId
