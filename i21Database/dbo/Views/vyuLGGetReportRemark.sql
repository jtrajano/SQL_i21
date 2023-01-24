CREATE VIEW [dbo].[vyuLGGetReportRemark]

AS

SELECT RR.intReportRemarkId
	, RR.strType
	, RR.intValueId
	, strValue = CASE WHEN RR.strType = 'Item' THEN Item.strItemNo
					WHEN RR.strType = 'Entity' THEN Entity.strName
					WHEN RR.strType = 'Borrowing Facility' THEN VRR.strValue
					ELSE '' END
	, RR.intLocationId
	, strLocation = CASE WHEN RR.strType = 'Item' THEN ItemLoc.strLocationName
						WHEN RR.strType = 'Entity' THEN EL.strLocationName
						WHEN RR.strType = 'Borrowing Facility' THEN SM.strLocationName
						ELSE '' END
	, RR.strRemarks
	, RR.intConcurrencyId
FROM tblLGReportRemark RR
LEFT JOIN tblICItem Item ON Item.intItemId = RR.intValueId AND RR.strType = 'Item'
LEFT JOIN tblEMEntity Entity ON Entity.intEntityId = RR.intValueId AND RR.strType = 'Entity'
LEFT JOIN tblICItemLocation IL ON IL.intLocationId = RR.intLocationId AND RR.strType = 'Item' AND IL.intItemId = RR.intValueId
LEFT JOIN tblSMCompanyLocation ItemLoc ON ItemLoc.intCompanyLocationId = IL.intLocationId
LEFT JOIN tblEMEntityLocation EL ON EL.intEntityLocationId = RR.intLocationId AND RR.strType = 'Entity'
LEFT JOIN vyuLGGetReportRemarkValue VRR ON VRR.intValueId = RR.intValueId AND VRR.strType = 'Borrowing Facility'
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = RR.intLocationId