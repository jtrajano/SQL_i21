CREATE VIEW [dbo].[vyuMFCustomTrialBlendSheetDetail]
AS 
/****************************************************************
	Title: Custom Trial Blend Sheet Detail
	Description: Custom Report Intended for Ekaterra Unilever
	JIRA: MFG-4572
	Created By: Jonathan Valenzuela
	Date: 10/26/2022
*****************************************************************/
SELECT ysnKeep											-- KEEP 
	 , WorkOrderInputLot.intLotId
	 , Lot.strLotNumber									-- Batch
	 , dblTBSQuantity									-- Weigh Up (Grams)
     , Batch.strERPPONumber								-- Purchase Order
	 , Batch.strTeaGardenChopInvoiceNumber				-- Chop
	 , GardenMark.strGardenMark							-- Mark
	 , Batch.strLeafGrade								-- Grade
	 , Item.strItemNo									-- Tea Item
	 , Batch.dblTeaTaste								-- T
	 , Batch.dblTeaHue									-- H
	 , Batch.dblTeaIntensity							-- I
	 , Batch.dblTeaMouthFeel							-- M
	 , Batch.dblTeaAppearance							-- A
	 , Batch.dblTeaVolume								-- V
	 , Batch.strLeafCategory							-- Leaf
	 , Batch.strTasterComments							-- Comments
	 , WorkOrderInputLot.dblQuantity					-- Wght
	 , WorkOrderInputLot.dblIssuedQuantity
FROM tblMFWorkOrderInputLot AS WorkOrderInputLot
LEFT JOIN tblICLot AS Lot ON WorkOrderInputLot.intLotId = Lot.intLotId
LEFT JOIN tblICItem AS Item ON WorkOrderInputLot.intItemId = Item.intItemId
LEFT JOIN tblMFLotInventory AS LotInventory ON WorkOrderInputLot.intLotId = LotInventory.intLotId
LEFT JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId 
LEFT JOIN tblQMGardenMark AS GardenMark ON Batch.intGardenMarkId = GardenMark.intGardenMarkId
