CREATE VIEW [dbo].[vyuICItemAxxisSync]
AS
SELECT 
	i.intItemId 
	,[strItemNo] = i.strItemNo 
	,[strStatus] = ISNULL(i.strStatus, '')
	,[strCommodity] = ISNULL(com.strCommodityCode, '')
	,[strBrand] = ISNULL(b.strBrandCode, '')
	,[strShortName] = ISNULL(i.strShortName, '') 
	,[strCategory] = ISNULL(cat.strCategoryCode, '') 
	,[strModelNo] = ISNULL(i.strModelNo, '') 
	,[strDescription] = ISNULL(i.strDescription, '') 
	,[strUnitofMeasure] = ISNULL(iu.strUnitMeasure, '') 
FROM 
	tblICItem i LEFT JOIN tblICCommodity com
		ON i.intCommodityId = com.intCommodityId 
	LEFT JOIN tblICBrand b
		ON b.intBrandId = i.intBrandId
	LEFT JOIN tblICCategory cat 
		ON cat.intCategoryId = i.intCategoryId
	OUTER APPLY (
		-- Get the stock unit of the item. 
		SELECT TOP 1 
			u.strUnitMeasure
		FROM 
			tblICItemUOM iu INNER JOIN tblICUnitMeasure u
				ON iu.intUnitMeasureId = u.intUnitMeasureId
		WHERE
			iu.intItemId = i.intItemId
			AND iu.ysnStockUnit = 1
	) iu	