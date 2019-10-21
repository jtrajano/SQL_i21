CREATE VIEW [dbo].[vyuICGetItemSubLocations]
AS 

SELECT	intId = CAST(ROW_NUMBER() OVER(ORDER BY i.intItemId, il.intLocationId, sub.intCompanyLocationSubLocationId) AS INT)
		,i.strItemNo
		,i.intItemId 
		,il.intLocationId
		,il.intItemLocationId
		,intSubLocationId = sub.intCompanyLocationSubLocationId
		,strSubLocationName = sub.strSubLocationName
		,intCountryId = i.intOriginId
FROM	tblICItem i INNER JOIN tblICItemLocation il
			ON i.intItemId = il.intItemId
		INNER JOIN tblSMCompanyLocation c
			ON c.intCompanyLocationId = il.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sub
			ON sub.intCompanyLocationId = c.intCompanyLocationId
WHERE	sub.intCompanyLocationSubLocationId IS NOT NULL 