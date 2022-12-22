﻿CREATE VIEW vyuMFGetWorkOrder
AS
SELECT C.intManufacturingCellId
	 , C.strCellName
	 , W.intWorkOrderId
	 , W.strWorkOrderNo
	 , W.strReferenceNo
	 , W.dblBatchSize
	 , MCUOM.strUnitMeasure AS strBatchSizeUOM
	 , W.dblQuantity
	 , W.dtmExpectedDate
	 , W.dblQuantity - W.dblProducedQuantity AS dblBalanceQuantity
	 , W.dblProducedQuantity
	 , W.strComment AS strWorkOrderComments
	 , W.dtmOrderDate
	 ,  WIPItemNo.strItemNo AS strWIPItemNo
	 , IC.intCategoryId
	 , IC.strCategoryCode
	 , IC.strDescription AS strCategoryDesc
	 , I.strType
	 , I.intItemId
	 , I.strItemNo
	 , I.strDescription
	 , IU.intItemUOMId
	 , U.intUnitMeasureId
	 , U.strUnitMeasure
	 , WS.intStatusId
	 , WS.strName AS strStatusName
	 , (CASE WHEN ISNULL(WS1.strName, 'New') = 'New' THEN 'Not Started'
			 ELSE WS1.strName
		END) AS strCountStatusName
	 , PT.intProductionTypeId
	 , PT.strName AS strProductionType
	 , W.dtmPlannedDate
	 , SH.intShiftId
	 , SH.strShiftName
	 , P.intPackTypeId
	 , P.strPackName
	 , W.dtmCreated
	 , W.intCreatedUserId
	 , US.strUserName
	 , W.dtmLastModified
	 , W.intLastModifiedUserId
	 , LM.strUserName AS strLastModifiedUser
	 , W.intExecutionOrder
	 , W.strVendorLotNo
	 , W.strLotNumber
	 , W.intLocationId
	 , W.strSalesOrderNo
	 , W.strCustomerOrderNo
	 , PW.intWorkOrderId AS intParentWorkOrderId
	 , PW.strWorkOrderNo AS strParentWorkOrderNo
	 , W.intManufacturingProcessId
	 , MP.strProcessName
	 , W.intSupervisorId
	 , SS.strUserName AS strSupervisor
	 , W.intBlendRequirementId
	 , MP.intAttributeTypeId
	 , W.dtmLastProducedDate
	 , SW.strComments AS strScheduleComment
	 , SL.intStorageLocationId
	 , SL.strName AS [strStorageLocation]
	 , CLSL.strSubLocationName AS strCompanySubLocationName
	 , WS.strBackColorName
	 , SL.intSubLocationId
	 , BR.strDemandNo
	 , W.intCountStatusId
	 , I.intLayerPerPallet
	 , I.intUnitPerLayer
	 , I.strLotTracking
	 , csl.strSubLocationName
	 , cs.strName AS strCustomerName
	 , d.strName AS strDepartmentName
	 , ISNULL(C.ysnIncludeSchedule, 0) AS ysnIncludeSchedule
	 , (CASE WHEN ISNULL(C.ysnIncludeSchedule, 0) = 0 THEN Schedule.intOrderHeaderId
			 ELSE NULL
		END) AS intOrderId
	 , W.dtmActualProductionStartDate
	 , W.dtmActualProductionEndDate
	 , SO.strSalesOrderNumber
	 , E.strName AS strSalesRepresentative
	 , L.strLoadNumber
	 , WRMH.strServiceContractNo
	 , W.strERPServicePONumber
	 , M.strName AS strMachineName
	 , E1.strName AS strVendorName
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderStatus WS ON WS.intStatusId = W.intStatusId
JOIN dbo.tblMFManufacturingCell C ON C.intManufacturingCellId = W.intManufacturingCellId
LEFT JOIN tblICUnitMeasure MCUOM ON MCUOM.intUnitMeasureId = C.intStdUnitMeasureId
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICCategory IC ON IC.intCategoryId = I.intCategoryId
LEFT JOIN dbo.tblMFPackType P ON P.intPackTypeId = I.intPackTypeId
JOIN dbo.tblICItemUOM IU ON IU.intItemUOMId = W.intItemUOMId
JOIN dbo.tblICUnitMeasure U ON U.intUnitMeasureId = IU.intUnitMeasureId
JOIN dbo.tblMFWorkOrderProductionType PT ON PT.intProductionTypeId = W.intProductionTypeId
LEFT JOIN dbo.tblMFShift SH ON SH.intShiftId = W.intPlannedShiftId
JOIN dbo.tblMFRecipe R ON R.intItemId = W.intItemId AND R.intLocationId = C.intLocationId AND R.ysnActive = 1
JOIN dbo.tblSMUserSecurity US ON US.[intEntityId] = W.intCreatedUserId
LEFT JOIN dbo.tblSMUserSecurity SS ON SS.[intEntityId] = W.intSupervisorId
JOIN dbo.tblSMUserSecurity LM ON LM.[intEntityId] = W.intLastModifiedUserId
JOIN dbo.tblMFManufacturingProcess MP ON MP.intManufacturingProcessId = W.intManufacturingProcessId
LEFT JOIN dbo.tblMFWorkOrder PW ON PW.intWorkOrderId = W.intParentWorkOrderId
LEFT JOIN dbo.tblICStorageLocation SL ON SL.intStorageLocationId = W.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = SL.intSubLocationId
LEFT JOIN tblMFBlendRequirement BR ON BR.intBlendRequirementId = W.intBlendRequirementId
LEFT JOIN dbo.tblMFScheduleWorkOrder SW ON SW.intWorkOrderId = W.intWorkOrderId AND EXISTS (SELECT *
																							FROM dbo.tblMFSchedule S
																							WHERE S.intScheduleId = SW.intScheduleId AND S.ysnStandard = 1)
LEFT JOIN tblSMCompanyLocationSubLocation csl ON W.intSubLocationId = csl.intCompanyLocationSubLocationId
LEFT JOIN vyuARCustomer cs ON W.intCustomerId = cs.intEntityId
LEFT JOIN tblMFDepartment d ON W.intDepartmentId = d.intDepartmentId
LEFT JOIN tblMFWorkOrderStatus WS1 ON WS1.intStatusId = W.intCountStatusId
LEFT JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = W.intSalesOrderLineItemId
LEFT JOIN tblSOSalesOrder SO ON SO.intSalesOrderId = SOD.intSalesOrderId
LEFT JOIN tblEMEntity E ON E.intEntityId = SO.intEntitySalespersonId
LEFT JOIN tblLGLoad L ON L.intLoadId = W.intLoadId
LEFT JOIN tblLGWarehouseRateMatrixHeader WRMH ON WRMH.intWarehouseRateMatrixHeaderId = W.intWarehouseRateMatrixHeaderId
LEFT JOIN tblMFMachine M ON M.intMachineId = W.intMachineId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = WRMH.intVendorEntityId
OUTER APPLY (SELECT TOP 1 strItemNo
			 FROM dbo.tblMFRecipeItem RI
			 JOIN dbo.tblICItem WI ON RI.intItemId = WI.intItemId
			 WHERE RI.intRecipeId = R.intRecipeId
			 AND WI.strType = 'Assembly/Blend') AS WIPItemNo
OUTER APPLY (SELECT TOP 1 intOrderHeaderId
			 FROM tblMFStageWorkOrder
			 WHERE intWorkOrderId = W.intWorkOrderId) AS Schedule
GROUP BY C.intManufacturingCellId
	   , C.strCellName
	   , W.intWorkOrderId
	   , W.strWorkOrderNo
	   , W.strReferenceNo
	   , W.dblBatchSize
	   , MCUOM.strUnitMeasure
	   , W.dblQuantity
	   , W.dtmExpectedDate
	   , W.dblQuantity - W.dblProducedQuantity 
	   , W.dblProducedQuantity
	   , W.strComment 
	   , W.dtmOrderDate
	   , WIPItemNo.strItemNo
	   , IC.intCategoryId
	   , IC.strCategoryCode
	   , IC.strDescription 
	   , I.strType
	   , I.intItemId
	   , I.strItemNo
	   , I.strDescription
	   , IU.intItemUOMId
	   , U.intUnitMeasureId
	   , U.strUnitMeasure
	   , WS.intStatusId
	   , WS.strName 
	   , (CASE WHEN ISNULL(WS1.strName, 'New') = 'New' THEN 'Not Started'
			   ELSE WS1.strName
		  END)
	   , PT.intProductionTypeId
	   , PT.strName 
	   , W.dtmPlannedDate
	   , SH.intShiftId
	   , SH.strShiftName
	   , P.intPackTypeId
	   , P.strPackName
	   , W.dtmCreated
	   , W.intCreatedUserId
	   , US.strUserName
	   , W.dtmLastModified
	   , W.intLastModifiedUserId
	   , LM.strUserName 
	   , W.intExecutionOrder
	   , W.strVendorLotNo
	   , W.strLotNumber
	   , W.intLocationId
	   , W.strSalesOrderNo
	   , W.strCustomerOrderNo
	   , PW.intWorkOrderId 
	   , PW.strWorkOrderNo
	   , W.intManufacturingProcessId
	   , MP.strProcessName
	   , W.intSupervisorId
	   , SS.strUserName
	   , W.intBlendRequirementId
	   , MP.intAttributeTypeId
	   , W.dtmLastProducedDate
	   , SW.strComments 
	   , SL.intStorageLocationId
	   , SL.strName 
	   , CLSL.strSubLocationName 
	   , WS.strBackColorName
	   , SL.intSubLocationId
	   , BR.strDemandNo
	   , W.intCountStatusId
	   , I.intLayerPerPallet
	   , I.intUnitPerLayer
	   , I.strLotTracking
	   , csl.strSubLocationName
	   , cs.strName 
	   , d.strName 
	   , ysnIncludeSchedule
	   , CASE WHEN ISNULL(C.ysnIncludeSchedule, 0) = 0 THEN Schedule.intOrderHeaderId
			  ELSE NULL
		 END
	   , W.dtmActualProductionStartDate
	   , W.dtmActualProductionEndDate
	   , SO.strSalesOrderNumber
	   , E.strName
	   , L.strLoadNumber
	   , WRMH.strServiceContractNo
	   , W.strERPServicePONumber
	   , M.strName 
	   , E1.strName