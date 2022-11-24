CREATE VIEW [dbo].[vyuMFApproveBlendSheet]  
AS  
  
SELECT 
	   wo.intWorkOrderId
	  ,woil.intWorkOrderInputLotId
	  ,wo.intTrialBlendSheetStatusId
	  ,YEAR(wo.dtmApprovedDate) [intApproveYear]
	  ,MONTH(wo.dtmApprovedDate) [intApproveYearMonth]
	  ,CAST(YEAR(wo.dtmApprovedDate) AS VARCHAR(10)) + CAST(MONTH(wo.dtmApprovedDate) AS VARCHAR(10))[strMonthYear]
	  ,CAST(wo.dtmApprovedDate AS DATE)[dtmApprovedDate]
	  ,wo.strWorkOrderNo [strOrder]
	  ,b.strBatchId [strBatchId]
	  ,itemwork.strItemNo [strBlendCode]
	  ,CAST(br.dblEstNoOfBlendSheet AS NUMERIC(18,6)) [dblNoOfMixes]
	  ,item.strItemNo [strTeaItem]
	  ,CAST(woil.dblIssuedQuantity AS NUMERIC(18,6)) [dblNoOfPackages]
	  ,CAST(woil.dblQuantity AS NUMERIC(18,6)) [dblAllocQty]
	  ,CAST(b.dblSellingPrice AS NUMERIC(18,6)) [dblSellingPrice]
	  ,CAST((woil.dblQuantity * 1) AS NUMERIC(18,6)) [dblAllocQtyInUsd]
	  ,CAST(ISNULL((item.intUnitPerLayer * item.intLayerPerPallet), 0.000000) AS NUMERIC(18,6)) [dblPackagesPerPaller]
	  ,loc.strLocationName [strAuction]
	  ,b.strTeaOrigin [strOrigin]
	  ,plantloc.strLocationName[strPlant]
	  ,loc.strLocationName [strTBO]
	  ,item.strModelNo [strMaterial]
	  ,'' [strPurchasingDocument]
	  ,'' [strProducer]
	  ,b.strSustainability [strSustainability]
	  ,mark.strGardenMark [strTeaMark]
	  ,b.strLeafGrade [strGrade]
	  ,b.strTeaGardenChopInvoiceNumber [strChop]
	  ,b.strLeafSize [strLeafSize] 
	  ,CAST(0.000000 AS NUMERIC(18,6)) [dblPurchasePrice]
	  ,CAST(0.000000 AS NUMERIC(18,6)) [dblBasePrice]
	  ,CAST(b.dblLandedPrice  AS NUMERIC(18,6)) [dblLandedPrice]
	  ,itemwork.strDescription [strMaterialDescription]
	  ,'' strUTK
	  ,CAST(0.000000  AS NUMERIC(18,6)) dblActualQty
	  ,CAST(0.000000  AS NUMERIC(18,6)) dblActualQtyInUSD
	  ,em.strName [strApprovedBy]
	  ,b.strTeaColour [strColor]
	  ,'' [strDustContent]
	  ,'' [strFactoryConsumptionDate]
	  ,'' [strLowCostCountry]
	  ,b.strLeafManufacturingType [strManufacturingType]
	  ,b.strProductionSite [strProductionSite]
	  ,b.strSupplierReference [strReference]
	  ,b.strTeaColour [strTeaColour]
	  ,b.strTeaLingoSubCluster [strTeaLingoSubCluster]
	  ,CAST(b.dblTeaVolume  AS NUMERIC(18,6)) [dblTeaVolume]
FROM tblMFWorkOrder wo
INNER JOIN tblMFWorkOrderInputLot woil ON wo.intWorkOrderId = woil.intWorkOrderId
INNER JOIN tblICLot lot ON lot.intLotId = woil.intLotId
INNER JOIN tblMFBlendRequirement br ON br.intBlendRequirementId = wo.intBlendRequirementId
INNER JOIN tblMFLotInventory loti ON loti.intLotId = woil.intLotId
INNER JOIN tblMFBatch b ON b.intBatchId = loti.intBatchId
LEFT JOIN tblQMGardenMark mark ON mark.intGardenMarkId = b.intGardenMarkId
LEFT JOIN tblICItem item ON item.intItemId = woil.intItemId
LEFT JOIN tblICItem itemwork ON item.intItemId = wo.intItemId
LEFT JOIN tblQMTINClearance TC ON TC.intBatchId = b.intBatchId
LEFT JOIN tblSMCompanyLocation loc ON b.intBuyingCenterLocationId = loc.intCompanyLocationId
LEFT JOIN tblSMCompanyLocation plantloc ON b.intLocationId= loc.intCompanyLocationId
LEFT JOIN tblEMEntity em on em.intEntityId=wo.intApprovedBy
  