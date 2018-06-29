CREATE VIEW [dbo].[vyuPATSetupItem]
	AS
SELECT	intItemId						= Item.intItemId,
		strItemNo						= Item.strItemNo,
		strDescription					= Item.strDescription,
		strStatus						= Item.strStatus,
		intCategoryId					= Item.intCategoryId,
		strCategory						= Category.strCategoryCode,
		intCommodityId					= Item.intCommodityId,
		strCommodityCode				= Commodity.strCommodityCode,
		intPatronageCategoryId			= Item.intPatronageCategoryId,
		strPatronageCategory			= PatCat.strCategoryCode,
		intPatronageCategoryDirectId	= Item.intPatronageCategoryDirectId,
		strPatronageDirect				= DirectSale.strCategoryCode
FROM tblICItem Item
LEFT JOIN tblICCommodity Commodity
	ON Commodity.intCommodityId = Item.intCommodityId
LEFT JOIN tblICCategory Category
	ON Category.intCategoryId = Item.intCategoryId
LEFT JOIN tblPATPatronageCategory PatCat
	ON PatCat.intPatronageCategoryId = Item.intPatronageCategoryId
LEFT JOIN tblPATPatronageCategory DirectSale
	ON DirectSale.intPatronageCategoryId = Item.intPatronageCategoryDirectId