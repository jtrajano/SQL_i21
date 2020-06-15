CREATE VIEW vyuSTItemRecipeAndStockQty
AS
-- Recipe Type Id's
-- 1 = Input Item
-- 2 = Output Item
SELECT 
	 -- Primary Id's
	 Recipe.intRecipeId
	 , RI.intRecipeItemId
	 , RI.intItemId
	 , ItemUOM.intItemUOMId
	 , IL.intItemLocationId
	 , ItemStock.intItemStockId
	 , CL.intCompanyLocationId
	 , Category.intCategoryId

	 -- Details
	 , ItemUOM.strLongUPCCode
	 , Recipe.strName
	 , CL.strLocationName
	 , RI.intRecipeItemTypeId
	 , CASE
		 WHEN RI.intRecipeItemTypeId = 1
			THEN 'Input Item'
		 WHEN RI.intRecipeItemTypeId = 2
			THEN 'Output Item'
	 END COLLATE Latin1_General_CI_AS AS strRecipeType
	 , Item.strItemNo
	 , Item.strDescription AS strItemDesciption
	 , ItemStock.dblUnitOnHand AS dblItemStockUnitOnHand
	 , RI.dblQuantity AS dblRecipeQuantity
	 , Category.strCategoryCode
	 , UOM.strUnitMeasure
	 , CASE 
		 WHEN ItemStock.intItemStockId IS NULL
			THEN CAST(0 AS BIT)
		 ELSE CAST(1 AS BIT)
	 END AS ysnHasItemStock
	 , Item.strLotTracking
	 , Item.ysnFuelItem
FROM tblMFRecipe Recipe
INNER JOIN tblSMCompanyLocation CL
	ON Recipe.intLocationId = CL.intCompanyLocationId
INNER JOIN tblMFRecipeItem RI
	ON Recipe.intRecipeId = RI.intRecipeId
INNER JOIN tblICItem Item
	ON RI.intItemId = Item.intItemId
INNER JOIN tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
INNER JOIN tblICItemUOM ItemUOM
    ON ItemUOM.intItemId = Item.intItemId
	-- AND Recipe.intItemUOMId = ItemUOM.intItemUOMId
INNER JOIN tblICItemLocation IL
    ON Item.intItemId = IL.intItemId
    AND Recipe.intLocationId = IL.intLocationId
INNER JOIN tblICUnitMeasure UOM
    ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemStock ItemStock
    ON Item.intItemId = ItemStock.intItemId
    AND IL.intItemLocationId = ItemStock.intItemLocationId