CREATE VIEW [dbo].[vyuMFTrialBlendSheetDetail]
AS
SELECT wo.strWorkOrderNo
	,wo.intWorkOrderId
	,woil.intWorkOrderInputLotId
	,CAST(CASE 
			WHEN wo.intTrialBlendSheetStatusId IS NULL
				AND (
					CASE 
						WHEN lot.intWeightUOMId IS NOT NULL
							THEN lot.dblWeight
						ELSE lot.dblQty
						END
					) - ISNULL((
						SELECT SUM(dbo.fnMFConvertQuantityToTargetItemUOM(SR.intItemUOMId, ISNULL(L1.intWeightUOMId, L1.intItemUOMId), ISNULL(SR.dblQty, 0)))
						FROM tblICStockReservation SR
						JOIN dbo.tblICLot L1 ON SR.intLotId = L1.intLotId
						WHERE SR.intLotId = lot.intLotId
							AND ISNULL(ysnPosted, 0) = 0
						), 0)-IsNULL(woil.dblTBSQuantity,0)  > 0
				THEN 1
			ELSE ISNULL(woil.ysnKeep, 0)
			END AS BIT) [ysnKeep]
	,lot.strLotNumber [strLotNumber]
	,(woil.dblQuantity / dblTotalWeight.dblTotalWeight) * IsNULL((
				SELECT dblTrialBlendSheetSize
				FROM tblMFCompanyPreference
				), 0) [dblWeight]
	,br.strReferenceNo [strPurchaseOrder]
	,b.strTeaGardenChopInvoiceNumber [strChop]
	,mark.strGardenMark [strMark]
	,b.strLeafGrade [strGrade]
	,item.strItemNo [strItem]
	,b.dblTeaTaste [dblT]
	,b.dblTeaHue [dblH]
	,b.dblTeaIntensity [dblI]
	,b.dblTeaMouthFeel [dblM]
	,b.dblTeaAppearance [dblA]
	,ISNULL(b.dblTeaVolume, 0) [dblV]
	,b.strLeafSize + b.strLeafStyle [strLeaf]
	,b.strQualityComments [strComments]
	,woil.dblQuantity [dblQtyWeight]
	,woil.dblIssuedQuantity [dblParts]
	,lot.dblWeightPerQty [dblKgBags]
	,TC.strTINNumber [strTIN]
	,woil.dblIssuedQuantity [dblBags]
	,CAST((woil.dblQuantity / dblTotalWeight.dblTotalWeight) * 100 AS NUMERIC(38,1)) [dblPercentage]
	,DATEDIFF(DAY, lot.dtmDateCreated, GETDATE()) [intAge]
	,wo.intTrialBlendSheetStatusId
	,woil.strFW
	,b.dblLandedPrice
	,b.dblSellingPrice
FROM tblMFWorkOrder wo
INNER JOIN tblMFWorkOrderInputLot woil ON wo.intWorkOrderId = woil.intWorkOrderId
INNER JOIN tblICLot lot ON lot.intLotId = woil.intLotId
INNER JOIN tblMFBlendRequirement br ON br.intBlendRequirementId = wo.intBlendRequirementId
INNER JOIN tblMFLotInventory loti ON loti.intLotId = woil.intLotId
INNER JOIN tblMFBatch b ON b.intBatchId = loti.intBatchId
LEFT JOIN tblQMGardenMark mark ON mark.intGardenMarkId = b.intGardenMarkId
LEFT JOIN tblICItem item ON item.intItemId = woil.intItemId
LEFT JOIN tblQMTINClearance TC ON TC.intBatchId = b.intBatchId
OUTER APPLY (
	SELECT SUM(dblQuantity) dblTotalWeight
	FROM tblMFWorkOrderInputLot
	WHERE intWorkOrderId = wo.intWorkOrderId
	) dblTotalWeight
