CREATE VIEW dbo.vyuSTPricebookMaster
AS
SELECT
    Item.intItemId
	, Item.strItemNo
	, Item.intCategoryId
	, Category.strCategoryCode
	, Item.strDescription
	, Uom.strLongUPCCode
	, Uom.strUpcCode
	, Item.intConcurrencyId
FROM dbo.tblICItem AS Item 
INNER JOIN dbo.tblICCategory Category
	ON Item.intCategoryId = Category.intCategoryId
LEFT JOIN dbo.tblICItemUOM Uom
	ON Item.intItemId = Uom.intItemId
WHERE Uom.ysnStockUnit = 1
