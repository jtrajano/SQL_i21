CREATE VIEW [dbo].[vyuTRGetLoadBlendIngredient]
	AS

SELECT LoadIngredient.intLoadBlendIngredientId
	, LoadIngredient.intLoadDistributionDetailId
	, intLoadDistributionItemId = LoadDetail.intItemId
	, dblLoadDistributionQty = LoadDetail.dblUnits
	, intIngredientItemId = LoadIngredient.intItemId
	, dblIngredientQty = LoadIngredient.dblQuantity
	, Recipe.dblLowerTolerance
	, Recipe.dblUpperTolerance
	, dblRecipeQty = Recipe.dblQuantity
	, dblActualQty = LoadDetail.dblUnits * Recipe.dblQuantity
FROM tblTRLoadBlendIngredient LoadIngredient
LEFT JOIN tblTRLoadDistributionDetail LoadDetail ON LoadDetail.intLoadDistributionDetailId = LoadIngredient.intLoadDistributionDetailId
LEFT JOIN vyuMFGetRecipeItem Recipe ON Recipe.intRecipeHeaderItemId = LoadDetail.intItemId
	AND Recipe.intRecipeIngredientItemId = LoadIngredient.intItemId