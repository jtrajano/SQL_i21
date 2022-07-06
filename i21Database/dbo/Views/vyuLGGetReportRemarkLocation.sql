CREATE VIEW [dbo].[vyuLGGetReportRemarkLocation]

AS

SELECT intRowId = ROW_NUMBER() OVER (ORDER BY strType, intLocationId) 
	, *
FROM (
	SELECT intLocationId = IL.intItemLocationId
		, strLocation = CL.strLocationName
		, intReferenceId = IL.intItemId
		, strType = 'Item'
	FROM tblICItemLocation IL
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId 

	UNION ALL SELECT intLocationId = EL.intEntityLocationId
		, strLocation = EL.strLocationName
		, intReferenceId = EL.intEntityId
		, strType = 'Entity'
	FROM tblEMEntityLocation EL
	WHERE EL.intEntityId IN (
		SELECT intEntityId FROM tblEMEntityType WHERE strType IN ('Vendor', 'Customer')
	)
) tbl