CREATE VIEW [dbo].[vyuSTRetailChangeReportViewer]
AS
	SELECT DISTINCT
		preview.intStoreId,
		preview.dtmEffectiveRetailPriceDateMin,
		preview.dtmEffectiveRetailPriceDateMax,
		preview.strCategoryDescription AS strCategoryDescription,
		preview.strLongUPCCode AS strLongUPCCode,
		preview.strDescription AS strItemDescription,
		preview.strUnitMeasure AS strUnitMeasure,
		CAST(preview.strOldData AS DECIMAL(9,2)) AS strOldData,
		CAST(preview.strNewData AS DECIMAL(9,2)) AS strNewData
	FROM
	(
		SELECT 
			st.intStoreId,
			et.dtmEffectiveRetailPriceDateMin,
			et.dtmEffectiveRetailPriceDateMax,
			cat.strDescription AS strCategoryDescription,
			itemUOM.strLongUPCCode,
			item.strDescription,
			unit.strUnitMeasure,
			et.strOldData,
			et.strNewData
		FROM (
			SELECT 
				te.intItemId, 
				te.intItemLocationId, 
				MAX(tblMaxRetail.dblRetailPrice) AS strNewData,  
				MIN(te.dblRetailPrice) AS strOldData,
				MIN(te.dtmEffectiveRetailPriceDate) AS dtmEffectiveRetailPriceDateMin,
				MAX(tblMaxRetail.dtmEffectiveRetailPriceDate) AS dtmEffectiveRetailPriceDateMax
			FROM (
					SELECT *
					FROM
					(
						SELECT ep.*, 
								COUNT(*) OVER ( PARTITION BY ep.intItemId, intItemLocationId) AS intCountItem,
								ROW_NUMBER() OVER(PARTITION BY ep.intItemId, ep.intItemLocationId
													ORDER BY ep.intItemId, ep.intItemLocationId, ep.dtmEffectiveRetailPriceDate DESC) ts 
						FROM
						(
							SELECT intItemId, intItemLocationId, dblRetailPrice, dtmEffectiveRetailPriceDate
							FROM tblICEffectiveItemPrice ep

							UNION

							SELECT ep.intItemId, ep.intItemLocationId, ep.dblSalePrice AS dblRetailPrice, '1900-01-01 00:00:00.000' AS dtmEffectiveRetailPriceDate
							FROM tblICItemPricing ep
								JOIN tblICEffectiveItemPrice eip 
								ON ep.intItemId = eip.intItemId AND ep.intItemLocationId = eip.intItemLocationId

						) ep
					) r
					WHERE r.ts <= 2  AND r.intCountItem > 1 AND r.ts = 2
				) te
				JOIN
				(
					SELECT *
					FROM
						(
							SELECT
								ep.*, 
								COUNT(*) OVER ( PARTITION BY ep.intItemId, intItemLocationId) AS intCountItem,
								ROW_NUMBER() OVER(PARTITION BY ep.intItemId, ep.intItemLocationId
													ORDER BY ep.intItemId, ep.intItemLocationId, ep.dtmEffectiveRetailPriceDate DESC) ts
							FROM tblICEffectiveItemPrice ep
					) r
					WHERE r.ts = 1
				) tblMaxRetail
				ON te.intItemId = tblMaxRetail.intItemId AND te.intItemLocationId = tblMaxRetail.intItemLocationId
				GROUP BY te.intItemId, te.intItemLocationId
			) et
			LEFT JOIN tblICItem item
				ON et.intItemId = item.intItemId
			LEFT JOIN tblICItemUOM itemUOM
				ON itemUOM.intItemId = item.intItemId AND itemUOM.ysnStockUnit = 1
			LEFT JOIN tblICUnitMeasure unit
				ON unit.intUnitMeasureId = itemUOM.intUnitMeasureId
			JOIN tblICCategory cat
				ON item.intCategoryId = cat.intCategoryId AND cat.ysnRetailValuation = 1
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = item.intItemId AND et.intItemLocationId = loc.intItemLocationId
			LEFT JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = loc.intLocationId
			LEFT JOIN tblSTStore st
				ON st.intCompanyLocationId = cl.intCompanyLocationId
	) preview
