﻿CREATE PROCEDURE  [dbo].[uspMFGetBlendSheet]
(
	@intWorkOrderId INT
)
AS
SELECT WorkOrder.intWorkOrderId
	 , WorkOrder.strWorkOrderNo
	 , WorkOrder.intItemId
	 , Item.strItemNo
	 , WorkOrder.dblQuantity
	 , WorkOrder.dblPlannedQuantity
	 , WorkOrder.intItemUOMId
	 , UOM.strUnitMeasure AS strUOM
	 , WorkOrder.intStatusId
	 , WorkOrder.intManufacturingCellId
	 , WorkOrder.intMachineId
	 , WorkOrder.dtmCreated
	 , WorkOrder.intCreatedUserId
	 , WorkOrder.dtmLastModified
	 , WorkOrder.intLastModifiedUserId
	 , WorkOrder.dtmExpectedDate
	 , WorkOrder.dblBinSize
	 , WorkOrder.intBlendRequirementId
	 , WorkOrder.ysnUseTemplate
	 , WorkOrder.ysnKittingEnabled
	 , WorkOrder.ysnDietarySupplements
	 , WorkOrder.strComment
	 , WorkOrder.intLocationId
	 , CASE WHEN (BlendRequirement.dblQuantity - ISNULL(BlendRequirement.dblIssuedQty ,0)) <= 0 THEN WorkOrder.dblQuantity 
			ELSE (BlendRequirement.dblQuantity - ISNULL(BlendRequirement.dblIssuedQty ,0)) 
	   END AS dblBalancedQtyToProduce
	 , ManufacturingCell.strCellName
	 , Machine.strName AS strMachineName
	 , WorkOrder.intManufacturingProcessId
	 , WorkOrder.intPlannedShiftId
	 , ManufacturingShift.strShiftName AS strPlannedShiftName
	 , WorkOrder.intTrialBlendSheetStatusId
	 , WorkOrder.strERPOrderNo AS strERPOrderNo
	 , WorkOrder.intIssuedUOMTypeId
	 , IssuedUOMType.strName AS strIssuedUOMType
FROM tblMFWorkOrder AS WorkOrder 
JOIN tblICItem AS Item ON WorkOrder.intItemId = Item.intItemId
JOIN tblICItemUOM AS ItemUOM ON WorkOrder.intItemUOMId = ItemUOM.intItemUOMId
JOIN tblICUnitMeasure AS UOM ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
JOIN tblMFBlendRequirement AS BlendRequirement ON WorkOrder.intBlendRequirementId=  BlendRequirement.intBlendRequirementId
LEFT JOIN tblMFManufacturingCell AS ManufacturingCell ON WorkOrder.intManufacturingCellId = ManufacturingCell.intManufacturingCellId
LEFT JOIN tblMFMachine AS Machine ON WorkOrder.intMachineId = Machine.intMachineId
LEFT JOIN tblMFShift AS ManufacturingShift ON WorkOrder.intPlannedShiftId = ManufacturingShift.intShiftId
OUTER APPLY (SELECT strName
			 FROM tblMFMachineIssuedUOMType 
			 WHERE intIssuedUOMTypeId = WorkOrder.intIssuedUOMTypeId) AS IssuedUOMType
WHERE WorkOrder.intWorkOrderId = @intWorkOrderId