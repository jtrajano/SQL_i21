CREATE VIEW [dbo].[vyuTRGetLoadBlendIngredient]
	AS

SELECT LoadIngredient.intLoadBlendIngredientId
	, LoadIngredient.intLoadDistributionDetailId
	, intLoadDistributionItemId = LoadDetail.intItemId
	, dblLoadDistributionQty = LoadDetail.dblUnits
	, intIngredientItemId = Recipe.intRecipeIngredientItemId
	, dblIngredientQty = LoadIngredient.dblQuantity
	, Recipe.dblLowerTolerance
	, Recipe.dblUpperTolerance
	, dblRecipeQty = Recipe.dblQuantity
	, dblDefaultQty = LoadDetail.dblUnits * Recipe.dblQuantity
FROM tblTRLoadBlendIngredient LoadIngredient
LEFT JOIN tblTRLoadDistributionDetail LoadDetail ON LoadDetail.intLoadDistributionDetailId = LoadIngredient.intLoadDistributionDetailId
LEFT JOIN vyuMFGetRecipeItem Recipe ON Recipe.intRecipeItemId = LoadIngredient.intRecipeItemId