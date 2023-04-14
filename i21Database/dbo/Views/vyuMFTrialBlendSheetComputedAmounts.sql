CREATE VIEW [dbo].[vyuMFTrialBlendSheetComputedAmounts]
AS
WITH CTE 
AS
(
	SELECT wo.intWorkOrderId
		, (woil.dblQuantity / dblTotalWeight.dblTotalWeight) * ISNULL((SELECT dblTrialBlendSheetSize FROM tblMFCompanyPreference), 0) [dblWeight]
		, b.dblTeaTaste [dblT]
		, b.dblTeaHue [dblH]
		, b.dblTeaIntensity [dblI]
		, b.dblTeaMouthFeel [dblM]
		, b.dblTeaAppearance [dblA]
		, ISNULL(b.dblTeaVolume, 0) [dblV]
		, woil.dblQuantity [dblQtyWeight]
		, woil.dblIssuedQuantity [dblParts]
		, lot.dblWeightPerQty [dblKgBags]
		, woil.dblIssuedQuantity [dblBags]
		, CAST((woil.dblQuantity / dblTotalWeight.dblTotalWeight) * 100 AS NUMERIC(38,1)) [dblPercentage]
		, wo.intTrialBlendSheetStatusId
		, b.dblLandedPrice
		, b.dblSellingPrice
	FROM tblMFWorkOrder wo
	INNER JOIN tblMFWorkOrderInputLot woil ON wo.intWorkOrderId = woil.intWorkOrderId
	INNER JOIN tblICLot lot ON lot.intLotId = woil.intLotId
	INNER JOIN tblMFBlendRequirement br ON br.intBlendRequirementId = wo.intBlendRequirementId
	INNER JOIN tblMFLotInventory loti ON loti.intLotId = woil.intLotId
	INNER JOIN tblMFBatch b ON b.intBatchId = loti.intBatchId
	LEFT JOIN tblQMGardenMark mark ON mark.intGardenMarkId = b.intGardenMarkId
	LEFT JOIN tblICItem item ON item.intItemId = woil.intItemId
	OUTER APPLY (SELECT SUM(dblQuantity) dblTotalWeight
				 FROM tblMFWorkOrderInputLot
				 WHERE intWorkOrderId = wo.intWorkOrderId) AS dblTotalWeight
)
SELECT SUM(dblWeight)															AS dblTotalWeight
	 , SUM(dblBags)																AS dblTotalBags
	 , ISNULL(SUM(dblWeight * dblSellingPrice) / NULLIF(SUM(dblWeight), 0), 0)	AS dblWAvgSellingPrice
	 , ISNULL(SUM(dblWeight * dblLandedPrice) / NULLIF(SUM(dblWeight), 0), 0)	AS dblWAvgLandedPrice
	 , ISNULL(SUM(dblWeight * dblT) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgT
	 , ISNULL(SUM(dblWeight * dblH) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgH
	 , ISNULL(SUM(dblWeight * dblI) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgI
	 , ISNULL(SUM(dblWeight * dblM) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgM
	 , ISNULL(SUM(dblWeight * dblA) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgA
	 , ISNULL(SUM(dblWeight * dblV) / NULLIF(SUM(dblWeight), 0), 0)				AS dblWAvgV
	 , intWorkOrderId
FROM CTE
GROUP BY intWorkOrderId