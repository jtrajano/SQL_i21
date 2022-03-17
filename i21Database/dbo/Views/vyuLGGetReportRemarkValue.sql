CREATE VIEW [dbo].[vyuLGGetReportRemarkValue]

AS

SELECT intValueId = intItemId
	, strValue = strItemNo
	, strType = 'Item'
FROM tblICItem I

UNION ALL SELECT intValueId = EL.intEntityId
	, strValue = EL.strName
	, strType = 'Entity'
FROM tblEMEntity EL
WHERE EL.intEntityId IN (
	SELECT intEntityId FROM tblEMEntityType WHERE strType IN ('Vendor', 'Customer')
)