CREATE VIEW [dbo].[vyuICSearchCountByCategoryDetail]
	AS 

SELECT 
	CountByCategory.intInventoryCountByCategoryId,
	CountByCategoryDetail.intInventoryCountByCategoryDetailId, 
	CountByCategory.strCountNo, 
	Location.strLocationName, 
	CountByCategory.dtmCountDate, 
	CountByCategory.ysnPosted,
	Category.strCategoryCode,
	Category.strDescription,
	CountByCategoryDetail.dblTargetMargin,
	CountByCategoryDetail.dblCurrentMargin,
	CountByCategoryDetail.dblCurrentRetail,
	CountByCategoryDetail.dblCurrentCost,
	CountByCategoryDetail.dblNewRetail,
	CountByCategoryDetail.dblNewCost,
	CountByCategoryDetail.dblNewMargin
FROM tblICInventoryCountByCategory CountByCategory
INNER JOIN (
	tblICInventoryCountByCategoryDetail CountByCategoryDetail 
	LEFT JOIN tblICCategory Category 
	ON 
	CountByCategoryDetail.intCategoryId = Category.intCategoryId
)
ON
CountByCategory.intInventoryCountByCategoryId = CountByCategoryDetail.intInventoryCountByCategoryId 
LEFT JOIN tblSMCompanyLocation Location 
ON 
Location.intCompanyLocationId = CountByCategory.intLocationId