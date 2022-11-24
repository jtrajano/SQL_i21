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
	 , s.strName [strStatus]
from tblMFWorkOrder w 
Join tblICItem i on w.intItemId=i.intItemId 
Join tblICItemUOM iu on w.intItemUOMId=iu.intItemUOMId 
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
JOIN tblSMCompanyLocation AS CompanyLocation ON ISNULL(w.intCompanyId, intLocationId) = CompanyLocation.intCompanyLocationId
LEFT JOIN tblMFWorkOrderStatus s on s.intStatusId = w.intTrialBlendSheetStatusId