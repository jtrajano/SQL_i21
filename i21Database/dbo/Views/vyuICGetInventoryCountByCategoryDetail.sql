CREATE VIEW [dbo].[vyuICGetInventoryCountByCategoryDetail]
	AS 

SELECT 
	InventoryCountByCategoryDetail.*,
	Category.strCategoryCode,
	Category.strDescription
FROM tblICInventoryCountByCategoryDetail InventoryCountByCategoryDetail
	LEFT JOIN tblICCategory Category ON Category.intCategoryId = InventoryCountByCategoryDetail.intCategoryId