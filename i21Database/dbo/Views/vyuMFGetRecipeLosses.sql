CREATE VIEW vyuMFGetRecipeLosses
AS
SELECT RL.intRecipeLossesId
	,R.strName + ' - ' + LTRIM(R.intVersionNo) AS strRecipeName
	,R.intRecipeId
	,I.strItemNo
	,BI.strItemNo AS strComponent
	,RL.dblLoss1
	,RL.dblLoss2
FROM tblMFRecipeLosses RL
JOIN tblMFRecipe R ON R.intRecipeId = RL.intRecipeId
LEFT JOIN tblICItem I ON I.intItemId = RL.intItemId
	AND I.strType = 'Bundle'
LEFT JOIN tblICItem BI ON BI.intItemId = RL.intBundleItemId
