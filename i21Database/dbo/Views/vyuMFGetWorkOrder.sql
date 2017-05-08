CREATE VIEW vyuMFGetWorkOrder
AS
SELECT C.intManufacturingCellId
	,C.strCellName
	,W.intWorkOrderId
	,W.strWorkOrderNo
	,W.strReferenceNo
	,W.dblQuantity
	,W.dtmExpectedDate
	,W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	,W.dblProducedQuantity
	,W.strComment AS strWorkOrderComments
	,W.dtmOrderDate
	,(
		SELECT TOP 1 strItemNo
		FROM dbo.tblMFRecipeItem RI
		JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
		WHERE RI.intRecipeId = R.intRecipeId
			AND WI.strType = 'Assembly/Blend'
		) AS strWIPItemNo
	,IC.intCategoryId
	,IC.strCategoryCode
	,IC.strDescription AS strCategoryDesc
	,I.strType
	,I.intItemId
	,I.strItemNo
	,I.strDescription
	,IU.intItemUOMId
	,U.intUnitMeasureId
	,U.strUnitMeasure
	,WS.intStatusId
	,WS.strName AS strStatusName
	,PT.intProductionTypeId
	,PT.strName AS strProductionType
	,W.dtmPlannedDate
	,SH.intShiftId
	,SH.strShiftName
	,P.intPackTypeId
	,P.strPackName
	,W.dtmCreated
	,W.intCreatedUserId
	,US.strUserName
	,W.dtmLastModified
	,W.intLastModifiedUserId
	,LM.strUserName AS strLastModifiedUser
	,W.intExecutionOrder
	,W.strVendorLotNo
	,W.strLotNumber
	,W.intLocationId
	,W.strSalesOrderNo
	,W.strCustomerOrderNo
	,PW.intWorkOrderId AS intParentWorkOrderId
	,PW.strWorkOrderNo AS strParentWorkOrderNo
	,W.intManufacturingProcessId
	,MP.strProcessName
	,W.intSupervisorId
	,SS.strUserName AS strSupervisor
	,W.intBlendRequirementId
	,MP.intAttributeTypeId
	,W.dtmLastProducedDate
	,SW.strComments AS strScheduleComment
	,SL.intStorageLocationId
	,SL.strName AS [strStorageLocation]
	,WS.strBackColorName
	,SL.intSubLocationId 
	,BR.strDemandNo
	,W.intCountStatusId
	,I.intLayerPerPallet
	,I.intUnitPerLayer
	,csl.strSubLocationName
	,cs.strName AS strCustomerName
	,d.strName AS strDepartmentName
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICCategory IC ON IC.intCategoryId = I.intCategoryId
LEFT JOIN dbo.tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId
	AND R.intLocationId = C.intLocationId
	AND R.ysnActive = 1
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
JOIN dbo.tblSMUserSecurity SS ON SS.[intEntityId] = W.intSupervisorId
JOIN dbo.tblSMUserSecurity LM ON LM.[intEntityId] = W.intLastModifiedUserId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFWorkOrder PW ON PW.intWorkOrderId = W.intParentWorkOrderId
LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
LEFT JOIN tblMFBlendRequirement BR ON BR.intBlendRequirementId=W.intBlendRequirementId
LEFT JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId
	AND EXISTS (
		SELECT *
		FROM dbo.tblMFSchedule S
		WHERE S.intScheduleId = SW.intScheduleId
			AND S.ysnStandard = 1
		)
LEFT JOIN tblSMCompanyLocationSubLocation csl on W.intSubLocationId=csl.intCompanyLocationSubLocationId
LEFT JOIN vyuARCustomer cs on W.intCustomerId=cs.intEntityId
LEFT JOIN tblMFDepartment d on W.intDepartmentId=d.intDepartmentId