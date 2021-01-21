CREATE PROCEDURE [dbo].[uspSTRetailChangeReport]
	@intStoreNo INT
	, @dtmBeginChange DATETIME
	, @dtmEndChange DATETIME
	--, @sqlResultSuccess NVARCHAR(1000) OUTPUT
	--, @strResultMsg NVARCHAR(1000) OUTPUT
AS
BEGIN 

	DECLARE @dtmDateTimeBeginChangeFrom AS DATETIME
	DECLARE @dtmDateTimeBeginChangeTo AS DATETIME

	SELECT 
		preview.strCategoryDescription AS strCategoryDescription,
		preview.strItemNo,
		preview.strDescription AS strItemDescription,
		preview.strOldData,
		preview.strNewData
	FROM
	(
		SELECT 
			cat.strDescription AS strCategoryDescription,
			item.strItemNo,
			item.strDescription,
			et.strOldData,
			et.strNewData
		FROM (
			SELECT te.intItemId, te.intItemLocationId, MAX(te.dblRetailPrice) AS strNewData,  MIN(te.dblRetailPrice) AS strOldData
				FROM (
					SELECT *
					FROM
					(
						SELECT
							ep.*, COUNT(*) OVER ( PARTITION BY ep.intItemId) AS intCountItem,
							ROW_NUMBER() OVER(PARTITION BY ep.intItemId, ep.intItemLocationId
											  ORDER BY ep.dtmEffectiveRetailPriceDate DESC) ts
						FROM tblICEffectiveItemPrice ep
						WHERE ep.dtmEffectiveRetailPriceDate BETWEEN @dtmBeginChange AND @dtmEndChange
					) r
					WHERE r.ts <= 2  AND r.intCountItem > 1
				) te
				GROUP BY te.intItemId, te.intItemLocationId
			) et
			LEFT JOIN tblICItem item
				ON et.intItemId = item.intItemId
			LEFT JOIN tblICCategory cat
				ON item.intCategoryId = cat.intCategoryId
			LEFT JOIN tblICItemLocation loc
				ON loc.intItemId = item.intItemId AND et.intItemLocationId = loc.intItemLocationId
			LEFT JOIN tblSMCompanyLocation cl
				ON cl.intCompanyLocationId = loc.intLocationId
			LEFT JOIN tblSTStore st
				ON st.intCompanyLocationId = cl.intCompanyLocationId
		WHERE st.intStoreNo = @intStoreNo
	) preview

END 
GO
