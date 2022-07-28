CREATE VIEW vyuMFGetRecipeInputItem
AS
SELECT RI.intRecipeItemId
	,RI.intRecipeId
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,I.strType
	,'1' COLLATE Latin1_General_CI_AS AS strIndicator
	,I.intItemId AS intBundleItemId
	,I.strItemNo AS strComponent
FROM tblMFRecipeItem RI
JOIN tblICItem I ON I.intItemId = RI.intItemId
	AND intRecipeItemTypeId = 1

UNION ALL

SELECT RI.intRecipeItemId
	,RI.intRecipeId
	,IB.intItemId
	,'' AS strItemNo
	,I.strDescription
	,I.strType
	,'2' COLLATE Latin1_General_CI_AS AS strIndicator
	,IB.intBundleItemId
	,I.strItemNo AS strComponent
FROM tblMFRecipeItem RI
JOIN tblICItemBundle IB ON IB.intItemId = RI.intItemId
	AND intRecipeItemTypeId = 1
JOIN tblICItem I ON I.intItemId = IB.intBundleItemId
