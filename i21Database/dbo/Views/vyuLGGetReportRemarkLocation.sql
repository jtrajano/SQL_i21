CREATE VIEW [dbo].[vyuLGGetReportRemarkLocation]

AS

SELECT intRowId = ROW_NUMBER() OVER (ORDER BY strType, intLocationId) 
	, *
FROM (
	SELECT intLocationId = IL.intLocationId
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

	UNION ALL SELECT intLocationId = intCompanyLocationId
		, strLocation = strLocationName
		, intReferenceId = NULL
		, strType = 'Borrowing Facility'
	FROM tblSMCompanyLocation
) tbl