CREATE VIEW [dbo].[vyuTRGetLoadBlendIngredient]
	AS

SELECT LoadIngredient.intLoadBlendIngredientId
	, LoadIngredient.intLoadDistributionDetailId
	, LoadDetail.intLoadDistributionHeaderId
	, LoadIngredient.strReceiptLink
	, Recipe.intRecipeId
	, Recipe.strItemNo
	, Recipe.strDescription
	, intLoadDistributionItemId = LoadDetail.intItemId
	, dblLoadDistributionQty = LoadDetail.dblUnits
	, intIngredientItemId = Recipe.intRecipeIngredientItemId
	, LoadIngredient.dblQuantity
	, Recipe.dblLowerTolerance
	, Recipe.dblUpperTolerance
	, dblRecipeQty = Recipe.dblQuantity
	, dblDefaultQty = LoadDetail.dblUnits * Recipe.dblQuantity
	, LoadIngredient.ysnSubstituteItem
	, LoadIngredient.intSubstituteItemId
	, strSubstituteItemNo = Item.strItemNo
	, strSubstituteItemDescription = Item.strDescription
FROM tblTRLoadBlendIngredient LoadIngredient
LEFT JOIN tblTRLoadDistributionDetail LoadDetail ON LoadDetail.intLoadDistributionDetailId = LoadIngredient.intLoadDistributionDetailId
LEFT JOIN vyuMFGetRecipeItem Recipe ON Recipe.intRecipeItemId = LoadIngredient.intRecipeItemId
LEFT JOIN tblICItem Item ON LoadIngredient.intSubstituteItemId = Item.intItemId