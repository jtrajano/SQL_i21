CREATE VIEW vyuMFCommitmentPricingRecipeNotMapped
AS
SELECT CPR.intCommitmentPricingRecipeId
	,CASE 
		WHEN VRI.intRecipeItemTypeId = 2
			THEN VRItem.strItemNo
		ELSE NULL
		END AS strVirtualOutputItemNo
	,CASE 
		WHEN VRI.intRecipeItemTypeId = 1
			THEN VI.strItemNo
		ELSE NULL
		END AS strVirtualInputItemNo
	,CASE 
		WHEN ARI.intRecipeItemTypeId = 2
			THEN ARItem.strItemNo
		ELSE NULL
		END AS strActualOutputItemNo
	,CASE 
		WHEN ARI.intRecipeItemTypeId = 1
			THEN AI.strItemNo
		ELSE NULL
		END AS strActualInputItemNo
	,VRI.intItemId AS intVirtualItemId
	,ARI.intItemId AS intActualItemId
	,CA.strDescription AS strItemProductType
	,VRM.intVirtualRecipeMapId
FROM tblMFCommitmentPricingRecipe CPR
LEFT JOIN tblMFRecipe VR ON VR.intRecipeId = CPR.intVirtualRecipeId
LEFT JOIN tblMFRecipe AR ON AR.intRecipeId = CPR.intActualRecipeId
LEFT JOIN tblICItem VRItem ON VRItem.intItemId = VR.intItemId
LEFT JOIN tblICItem ARItem ON ARItem.intItemId = AR.intItemId
LEFT JOIN tblMFRecipeItem VRI ON VRI.intRecipeItemId = CPR.intVirtualRecipeItemId
LEFT JOIN tblMFRecipeItem ARI ON ARI.intRecipeItemId = CPR.intActualRecipeItemId
LEFT JOIN tblMFVirtualRecipeMap VRM ON VRM.intRecipeId = CPR.intActualRecipeId
	AND VRM.intVirtualRecipeId = CPR.intVirtualRecipeId
LEFT JOIN tblICItem VI ON VI.intItemId = VRI.intItemId
LEFT JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityId = ISNULL(VI.intCommodityId,AI.intCommodityId )
AND CA.intCommodityAttributeId = ISNULL(VI.intProductTypeId,AI.intProductTypeId)
