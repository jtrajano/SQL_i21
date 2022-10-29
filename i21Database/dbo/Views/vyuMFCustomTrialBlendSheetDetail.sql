CREATE VIEW [dbo].[vyuMFCustomTrialBlendSheetDetail]
AS 
/****************************************************************
	Title: Custom Trial Blend Sheet Detail
	Description: Custom Report Intended for Ekaterra Unilever
	JIRA: MFG-4572
	Created By: Jonathan Valenzuela
	Date: 10/26/2022
*****************************************************************/
SELECT (CASE WHEN ysnKeep = 1 THEN 'KEEP'
			ELSE ''
		END) AS ysnKeep																		-- KEEP 
	 , WorkOrderInputLot.intLotId
	 , Lot.strLotNumber																		-- Batch
	 , dblTBSQuantity		= CAST(WorkOrderInputLot.dblTBSQuantity AS NUMERIC(38,2))		-- Weigh Up (Grams)
     , Batch.strERPPONumber																	-- Purchase Order
	 , Batch.strTeaGardenChopInvoiceNumber													-- Chop
	 , GardenMark.strGardenMark																-- Mark
	 , Batch.strLeafGrade																	-- Grade
	 , Item.strItemNo																		-- Tea Item
	 , dblTeaTaste			= CAST(Batch.dblTeaTaste AS NUMERIC(38,1))						-- T
	 , dblTeaHue			= CAST(Batch.dblTeaHue AS NUMERIC(38,1))						-- H
	 , dblTeaIntensity		= CAST(Batch.dblTeaIntensity AS NUMERIC(38,1))					-- I
	 , dblTeaMouthFeel		= CAST(Batch.dblTeaMouthFeel AS NUMERIC(38,1))					-- M
	 , dblTeaAppearance		= CAST(Batch.dblTeaAppearance AS NUMERIC(38,1)) 				-- A
	 , dblTeaVolume			= CAST(Batch.dblTeaVolume AS NUMERIC(38,1))						-- V
	 , Batch.strLeafCategory 																-- Leaf
	 , Batch.strTasterComments																-- Comments
	 , dblQuantity			= CAST(WorkOrderInputLot.dblQuantity AS NUMERIC(38,2))			-- Wght
	 , dblIssuedQuantity	= CAST(WorkOrderInputLot.dblIssuedQuantity AS NUMERIC(38,2))
	 , WorkOrderInputLot.intWorkOrderId
	 , dblSellingPrice		= CAST(Batch.dblSellingPrice AS NUMERIC(38,0)) 					-- Sell
	 , dblLandedPrice		= CAST(Batch.dblLandedPrice AS NUMERIC(38,0)) 					-- Land
	 , dblEstNoOfBlendSheet = CAST(BlendRequirementSheet.dblEstNoOfBlendSheet AS NUMERIC(38,0)) 	
	 , dblWeightPerQty		= CAST(Lot.dblWeightPerQty AS NUMERIC(38,0))					-- Weight Per Qty
	 , strFW				= ISNULL(strFW, '')												-- FW
	 , dblSumQuantity		= CAST(WorkOrderInputLotQty.dblSumQuantity AS NUMERIC(38,0))	-- Sum Qty ***
	 , strTIN = ''
	 , dblWorkOrderQty		= CAST(WorkOrder.dblQuantity AS NUMERIC(38,0))					-- Work Order Quantity
	 , intAge				= DATEDIFF(DD, WorkOrderInputLot.dtmCreated, GETDATE())			-- Age
FROM tblMFWorkOrderInputLot AS WorkOrderInputLot
LEFT JOIN tblICLot AS Lot ON WorkOrderInputLot.intLotId = Lot.intLotId
LEFT JOIN tblICItem AS Item ON WorkOrderInputLot.intItemId = Item.intItemId
LEFT JOIN tblMFLotInventory AS LotInventory ON WorkOrderInputLot.intLotId = LotInventory.intLotId
LEFT JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId 
LEFT JOIN tblQMGardenMark AS GardenMark ON Batch.intGardenMarkId = GardenMark.intGardenMarkId
LEFT JOIN tblMFWorkOrder AS WorkOrder ON WorkOrderInputLot.intWorkOrderId = WorkOrder.intWorkOrderId
OUTER APPLY (SELECT TOP 1 dblEstNoOfBlendSheet
			 FROM tblMFBlendRequirement
			 WHERE intBlendRequirementId = WorkOrder.intBlendRequirementId) AS BlendRequirementSheet
OUTER APPLY (SELECT TOP 1 SUM(dblQuantity) AS dblSumQuantity
			 FROM tblMFWorkOrderInputLot
			 WHERE intWorkOrderId = WorkOrderInputLot.intWorkOrderId) AS WorkOrderInputLotQty