CREATE VIEW [dbo].[vyuTRLoadBlendIngredient]
	AS
SELECT BI.intLoadBlendIngredientId
	, BI.intLoadDistributionDetailId
	, BI.intRecipeItemId
	, RI.intRecipeId
	, RI.strItemNo
	, RI.strDescription
	, intIngredientItemId = RI.intRecipeIngredientItemId
	, RI.dblLowerTolerance
	, RI.dblUpperTolerance
	, dblRecipeQty = RI.dblQuantity
	, dblDefaultQty = DD.dblUnits * RI.dblQuantity
	, intLoadDistributionItemId = DD.intItemId
	, dblLoadDistributionQty = DD.dblUnits	
	, BI.intSubstituteItemId
	, strSubstituteItemNo = I.strItemNo
	, strSubstituteItemDescription = I.strDescription
FROM tblTRLoadBlendIngredient BI
LEFT JOIN vyuMFGetRecipeItem RI ON RI.intRecipeItemId = BI.intRecipeItemId
LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionDetailId = BI.intLoadDistributionDetailId
LEFT JOIN tblICItem I ON I.intItemId = BI.intSubstituteItemId