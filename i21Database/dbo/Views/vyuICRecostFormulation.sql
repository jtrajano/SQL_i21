CREATE VIEW [dbo].[vyuICRecostFormulation]
AS 
SELECT 
	r.* 
	,strLocationFrom = fromLocation.strLocationName
	,strLocationTo = toLocation.strLocationName
	,strCategoryFrom = fromCategory.strCategoryCode
	,strCategoryTo = toCategory.strCategoryCode
FROM 
	tblICRecostFormulation r
	LEFT JOIN tblSMCompanyLocation fromLocation  ON r.intLocationFromId = fromLocation.intCompanyLocationId
	LEFT JOIN tblSMCompanyLocation toLocation  ON r.intLocationToId = toLocation.intCompanyLocationId
	LEFT JOIN tblICCategory fromCategory ON r.intCategoryFromId = fromCategory.intCategoryId
	LEFT JOIN tblICCategory toCategory ON r.intCategoryFromId = toCategory.intCategoryId