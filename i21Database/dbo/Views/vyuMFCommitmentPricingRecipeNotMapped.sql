CREATE VIEW vyuMFCommitmentPricingRecipeNotMapped
AS
SELECT CPR.intCommitmentPricingRecipeId
	,VR.strName AS strVirtualOutputItemNo
	,AR.strName AS strActualOutputItemNo
	,VI.strItemNo AS strVirtualInputItemNo
	,AI.strItemNo AS strActualInputItemNo
FROM tblMFCommitmentPricingRecipe CPR
LEFT JOIN tblMFRecipe VR ON VR.intRecipeId = CPR.intVirtualRecipeId
LEFT JOIN tblMFRecipe AR ON AR.intRecipeId = CPR.intActualRecipeId
LEFT JOIN tblMFRecipeItem VRI ON VRI.intRecipeItemId = CPR.intVirtualRecipeItemId
LEFT JOIN tblMFRecipeItem ARI ON ARI.intRecipeItemId = CPR.intActualRecipeItemId
LEFT JOIN tblICItem VI ON VI.intItemId = VRI.intItemId
LEFT JOIN tblICItem AI ON AI.intItemId = ARI.intItemId
