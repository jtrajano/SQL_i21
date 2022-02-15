CREATE VIEW dbo.vyuSTItemHierarchyPricing
AS
SELECT 
	ip.intItemId,
	ip.intItemLocationId,
	UM.intItemUOMId,
		CASE
					WHEN (CAST(GETDATE() AS DATE) BETWEEN SplPrc.dtmBeginDate AND SplPrc.dtmEndDate)
						THEN SplPrc.dblUnitAfterDiscount 
					WHEN (CAST(GETDATE() AS DATE) >= effectivePrice.dtmEffectiveRetailPriceDate)
						THEN effectivePrice.dblRetailPrice --Effective Retail Price
					ELSE ip.dblSalePrice
				END AS dblSalePrice
FROM tblICItemPricing ip
JOIN tblICItemUOM UM
	ON ip.intItemId = UM.intItemId -- AND UM.ysnStockUnit = 1
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				intItemUOMId,
				dtmEffectiveRetailPriceDate,
				dblRetailPrice,
				ROW_NUMBER() OVER (PARTITION BY intItemId, intItemLocationId, intItemUOMId ORDER BY dtmEffectiveRetailPriceDate DESC) AS intRowNum
		FROM tblICEffectiveItemPrice
		WHERE CAST(GETDATE() AS DATE) >= dtmEffectiveRetailPriceDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS effectivePrice
	ON ip.intItemId = effectivePrice.intItemId
	AND ip.intItemLocationId = effectivePrice.intItemLocationId
	AND UM.intItemUOMId = effectivePrice.intItemUOMId
LEFT JOIN 
(
	SELECT * FROM (
		SELECT 
				intItemId,
				intItemLocationId,
				intItemUnitMeasureId AS intItemUOMId,
				dtmBeginDate,
				dtmEndDate,
				dblUnitAfterDiscount,
				dblCost,
				row_number() over (partition by intItemId, intItemLocationId, intItemUnitMeasureId order by intItemLocationId asc) as intRowNum
		FROM tblICItemSpecialPricing
		WHERE CAST(GETDATE() AS DATE) BETWEEN dtmBeginDate AND dtmEndDate
	) AS tblSTItemOnFirstLocation WHERE intRowNum = 1
) AS SplPrc
	ON ip.intItemId = SplPrc.intItemId
	AND ip.intItemLocationId = SplPrc.intItemLocationId
	AND UM.intItemUOMId = SplPrc.intItemUOMId