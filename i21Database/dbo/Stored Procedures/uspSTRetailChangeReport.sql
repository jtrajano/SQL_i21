CREATE PROCEDURE [dbo].[uspSTRetailChangeReport]
	@intStoreNo INT
	, @dtmBeginChange DATETIME
	, @dtmEndChange DATETIME
AS
BEGIN 

	DECLARE @dtmDateTimeBeginChangeFrom AS DATETIME
	DECLARE @dtmDateTimeBeginChangeTo AS DATETIME

	SELECT DISTINCT
		preview.strCategoryDescription AS strCategoryDescription,
		preview.intCategoryId,
		preview.intItemId,
		preview.strItemNo,
		preview.strDescription AS strItemDescription,
		preview.strOldData,
		preview.strNewData
	FROM
	(
		SELECT 
			cat.strDescription AS strCategoryDescription,
			item.intCategoryId,
			item.intItemId,
			item.strItemNo,
			item.strDescription,
			et.strOldData,
			et.strNewData
		FROM (
			SELECT 
				te.intItemId, 
				te.intItemLocationId, 
				MAX(tblMaxRetail.dblRetailPrice) AS strNewData,  
				MIN(te.dblRetailPrice) AS strOldData
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
							WHERE ep.dtmEffectiveRetailPriceDate < @dtmEndChange

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
						WHERE ep.dtmEffectiveRetailPriceDate BETWEEN @dtmBeginChange AND @dtmEndChange
					) r
					WHERE r.ts = 1
				) tblMaxRetail
				ON te.intItemId = tblMaxRetail.intItemId AND te.intItemLocationId = tblMaxRetail.intItemLocationId
				GROUP BY te.intItemId, te.intItemLocationId
		) et
		LEFT JOIN tblICItem item
			ON et.intItemId = item.intItemId
		JOIN tblICCategory cat
			ON item.intCategoryId = cat.intCategoryId AND cat.ysnRetailValuation = 1
		LEFT JOIN tblICItemLocation loc
			ON loc.intItemId = item.intItemId AND et.intItemLocationId = loc.intItemLocationId
		LEFT JOIN tblSMCompanyLocation cl
			ON cl.intCompanyLocationId = loc.intLocationId
		LEFT JOIN tblSTStore st
			ON st.intCompanyLocationId = cl.intCompanyLocationId
		WHERE st.intStoreId = @intStoreNo
	) preview
	WHERE preview.strOldData != preview.strNewData
END


