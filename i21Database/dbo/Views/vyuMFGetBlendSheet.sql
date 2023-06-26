CREATE VIEW [dbo].[vyuMFGetBlendSheet]
AS 
SELECT WorkOrder.intWorkOrderId
	 , WorkOrder.strWorkOrderNo
	 , Item.strItemNo
	 , Item.strDescription
	 , WorkOrder.dblQuantity
	 , UnitMeasure.strUnitMeasure		AS strUOM
	 , WorkOrder.dtmExpectedDate
	 , WorkOrder.intStatusId
	 , WorkOrder.ysnUseTemplate
	 , CompanyLocation.strLocationName	AS strCompanyLocationName
	 , CASE WHEN intTrialBlendSheetStatusId = 17 THEN TrialBlendSheetStatus.strName  
			ELSE '' 
	   END AS strStatus
	 , WorkOrderCreate.strName			AS strCreatedBy
	 , WorkOrder.dtmCreated
	 , WorkOrderApprove.strName			AS strApprovedBy
	 , WorkOrder.dtmApprovedDate
	 , Printed.strName					AS strPrintedBy
	 , WorkOrder.dtmPrintedDate			AS dtmPrintDate
	 , WorkOrderStatus.strName			AS strWorkOrderStatus
	 , WorkOrder.dtmReleasedDate
	 , ReleasedBy.strName				As strReleasedBy
	 , WorkOrder.strERPOrderNo			AS strERPOrderNo
	 , WorkOrder.strERPComment			AS strERPComment
	  , WorkOrder.strERPComment			AS strComment
	 , ISNULL(WorkOrder.intCompanyId, WorkOrder.intLocationId) AS intCompanyLocationId
	 , WorkOrderRecipe.intRecipeId
	 , WorkOrder.intItemId
	 , WorkOrder.dblPlannedQuantity
FROM tblMFWorkOrder AS WorkOrder 
JOIN tblICItem AS Item ON WorkOrder.intItemId = Item.intItemId 
JOIN tblICItemUOM AS ItemUOM ON WorkOrder.intItemUOMId = ItemUOM.intItemUOMId 
JOIN tblICUnitMeasure AS UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
JOIN tblSMCompanyLocation AS CompanyLocation ON ISNULL(WorkOrder.intCompanyId, intLocationId) = CompanyLocation.intCompanyLocationId
LEFT JOIN tblMFWorkOrderStatus AS TrialBlendSheetStatus ON TrialBlendSheetStatus.intStatusId = WorkOrder.intTrialBlendSheetStatusId
LEFT JOIN tblEMEntity AS WorkOrderCreate ON WorkOrderCreate.intEntityId = WorkOrder.intCreatedUserId
LEFT JOIN tblEMEntity AS WorkOrderApprove ON WorkOrderApprove.intEntityId = WorkOrder.intApprovedBy
LEFT JOIN tblEMEntity AS ReleasedBy ON ReleasedBy.intEntityId=WorkOrder.intSupervisorId
LEFT JOIN tblMFWorkOrderStatus AS WorkOrderStatus ON WorkOrder.intStatusId = WorkOrderStatus.intStatusId
LEFT JOIN tblMFWorkOrderRecipe AS WorkOrderRecipe ON WorkOrder.intWorkOrderId = WorkOrderRecipe.intWorkOrderId
OUTER APPLY (SELECT strName
			 FROM tblEMEntity
			 WHERE intEntityId = WorkOrder.intPrintedBy) AS Printed
GO