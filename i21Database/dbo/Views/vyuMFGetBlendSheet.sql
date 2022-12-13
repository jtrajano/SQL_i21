CREATE VIEW [dbo].[vyuMFGetBlendSheet]
AS 
SELECT w.intWorkOrderId
	 , w.strWorkOrderNo
	 , i.strItemNo
	 , i.strDescription
	 , w.dblQuantity
	 , um.strUnitMeasure AS strUOM
	 , w.dtmExpectedDate
	 , w.intStatusId
	 , w.ysnUseTemplate
	 , CompanyLocation.strLocationName AS strCompanyLocationName
	 , CASE WHEN intTrialBlendSheetStatusId =17 THEN s.strName  ELSE 'Unapproved' END [strStatus]
	 , em.strName [strCreatedBy]
	 , w.dtmCreated
	 , em2.strName [strApprovedBy]
	 , w.dtmApprovedDate
	 , Printed.strName AS strPrintedBy
	 , w.dtmPrintedDate AS dtmPrintDate
	 , ws.strName AS strWorkOrderStatus
from tblMFWorkOrder w 
Join tblICItem i on w.intItemId=i.intItemId 
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId 
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
JOIN tblSMCompanyLocation AS CompanyLocation ON ISNULL(w.intCompanyId, intLocationId) = CompanyLocation.intCompanyLocationId
LEFT JOIN tblMFWorkOrderStatus s on s.intStatusId = w.intTrialBlendSheetStatusId
LEFT JOIN tblEMEntity em on em.intEntityId=w.intCreatedUserId
LEFT JOIN tblEMEntity em2 on em2.intEntityId=w.intApprovedBy
LEFT JOIN tblMFWorkOrderStatus ws on w.intStatusId = ws.intStatusId
OUTER APPLY (SELECT strName
			 FROM tblEMEntity
			 WHERE intEntityId = w.intPrintedBy) AS Printed