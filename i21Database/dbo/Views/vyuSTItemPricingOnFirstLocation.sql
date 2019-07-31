
CREATE VIEW dbo.vyuSTItemPricingOnFirstLocation
AS 
SELECT 
		tblICItem.intItemId,
		tblICItem.strItemNo,
		tblICItem.strDescription as strItemDescription,
		tblICItemUOM.intItemUOMId,
		tblICItemUOM.strLongUPCCode,
		tblICItemUOM.strUpcCode,
		tblICItemPricing.dblLastCost,
		tblICItemPricing.dblAverageCost,
		tblICItemPricing.dblStandardCost,
		tblICItemPricing.dblSalePrice,
		strItemNoAndDescription = ISNULL(tblICItem.strItemNo,'') + '-' + ISNULL(tblICItem.strDescription,''),
		tblICCategory.strCategoryCode,
		strCategoryDescription = tblICCategory.strDescription,
		tblICCategory.intCategoryId
	FROM 
	(
		SELECT * FROM (
		SELECT 
			 intItemId,
			 intItemLocationId,
			 dblLastCost,
			 dblAverageCost,
			 dblStandardCost,
			 dblSalePrice,
			 row_number() over (partition by intItemId order by intItemLocationId asc) as intRowNum
		FROM tblICItemPricing
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
	) AS tblICItemPricing
	INNER JOIN tblICItemLocation
		ON tblICItemPricing.intItemLocationId = tblICItemLocation.intItemLocationId
		AND tblICItemPricing.intItemId = tblICItemLocation.intItemId
	INNER JOIN tblICItem 
		ON tblICItem.intItemId = tblICItemPricing.intItemId
	LEFT JOIN tblICItemUOM 
		ON tblICItemUOM.intItemUOMId = tblICItemLocation.intIssueUOMId
	LEFT JOIN tblICCategory
		ON tblICCategory.intCategoryId = tblICItem.intCategoryId