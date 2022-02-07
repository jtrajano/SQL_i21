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
		itemPricing.dblSalePrice as dblSalePrice,
		-- CASE
		-- 	WHEN (CAST(GETDATE() AS DATE) >= effectiveCost.dtmEffectiveCostDate)
		-- 		THEN effectiveCost.dblCost --Effective Cost
		-- 	ELSE tblICItemPricing.dblStandardCost
		-- END AS dblStandardCost,
		-- CASE
		-- 	WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
		-- 		THEN SplPrc.dblUnitAfterDiscount 
		-- 	WHEN (CAST(GETDATE() AS DATE) >= effectivePrice.dtmEffectiveRetailPriceDate)
		-- 		THEN effectivePrice.dblRetailPrice --Effective Retail Price
		-- 	ELSE tblICItemPricing.dblSalePrice
		-- END AS dblSalePrice,
		strItemNoAndDescription = ISNULL(tblICItem.strItemNo,'') + '-' + ISNULL(tblICItem.strDescription,''),
		tblICCategory.strCategoryCode,
		strCategoryDescription = tblICCategory.strDescription,
		tblICCategory.intCategoryId,
		tblEMEntity.strName as strVendorId,
		tblICItemLocation.intVendorId
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
	LEFT JOIN 
	(
		SELECT * FROM (
			SELECT 
				 intItemId,
				 intItemLocationId,
				 dtmBeginDate,
				 dtmEndDate,
				 dblUnitAfterDiscount,
				 dblCost,
				 row_number() over (partition by intItemId order by intItemLocationId asc) as intRowNum
			FROM tblICItemSpecialPricing
			WHERE CAST(GETDATE() AS DATE) BETWEEN dtmBeginDate AND dtmEndDate
		) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
	) AS SplPrc
		ON tblICItem.intItemId = SplPrc.intItemId
	LEFT JOIN 
	(
		SELECT * FROM (
			SELECT 
				 intItemId,
				 intItemLocationId,
				 dtmEffectiveCostDate,
				 dblCost,
				 ROW_NUMBER() OVER (PARTITION BY intItemId ORDER BY dtmEffectiveCostDate DESC) AS intRowNum
			FROM tblICEffectiveItemCost
			WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveCostDate
		) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
	) AS effectiveCost
		ON tblICItem.intItemId = effectiveCost.intItemId
		AND effectiveCost.intItemLocationId = tblICItemLocation.intItemLocationId
	LEFT JOIN tblICItemUOM 
		ON tblICItemUOM.intItemId = tblICItem.intItemId
	JOIN tblICUnitMeasure 
		ON tblICItemUOM.intUnitMeasureId = tblICUnitMeasure.intUnitMeasureId
	JOIN vyuSTItemHierarchyPricing itemPricing
		ON tblICItem.intItemId = itemPricing.intItemId
		AND tblICItemLocation.intItemLocationId = itemPricing.intItemLocationId
		AND tblICItemUOM.intItemUOMId = itemPricing.intItemUOMId
	LEFT JOIN tblICCategory
		ON tblICCategory.intCategoryId = tblICItem.intCategoryId
	LEFT JOIN tblEMEntity 
		ON tblEMEntity.intEntityId = tblICItemLocation.intVendorId
	--Price Hierarchy--
	INNER JOIN vyuSTItemHierarchyPricing itemPricing
	ON tblICItem.intItemId = itemPricing.intItemId
	AND tblICItemLocation.intItemLocationId = itemPricing.intItemLocationId
	AND tblICItemUOM.intItemUOMId = itemPricing.intItemUOMId

