CREATE VIEW [dbo].[vyuLGGetReportRemark]

AS

SELECT RR.intReportRemarkId
	, RR.strType
	, RR.intValueId
	, strValue = CASE WHEN RR.strType = 'Item' THEN Item.strItemNo
					WHEN RR.strType = 'Entity' THEN Entity.strName
					ELSE '' END
	, RR.intLocationId
	, strLocation = CASE WHEN RR.strType = 'Item' THEN ItemLoc.strLocationName
						WHEN RR.strType = 'Entity' THEN EL.strLocationName
						ELSE '' END
	, RR.strRemarks
	, RR.intConcurrencyId
FROM tblLGReportRemark RR
LEFT JOIN tblICItem Item ON Item.intItemId = RR.intValueId AND RR.strType = 'Item'
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = RR.intValueId AND RR.strType = 'Entity'
LEFT JOIN tblICItemLocation IL ON IL.intItemLocationId = RR.intLocationId AND RR.strType = 'Item'
LEFT JOIN tblSMCompanyLocation ItemLoc ON ItemLoc.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = RR.intLocationId AND RR.strType = 'Entity'