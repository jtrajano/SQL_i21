CREATE VIEW [dbo].[vyuMFApproveBlendSheet]  
AS    
SELECT WorkOrder.intWorkOrderId
	 , InputLot.intWorkOrderInputLotId
	 , WorkOrder.intTrialBlendSheetStatusId
	 , YEAR(WorkOrder.dtmApprovedDate)						AS intApproveYear
	 , MONTH(WorkOrder.dtmApprovedDate)						AS intApproveYearMonth
	 , CAST(YEAR(WorkOrder.dtmApprovedDate) AS VARCHAR(10)) + CAST(MONTH(WorkOrder.dtmApprovedDate) AS VARCHAR(10)) AS strMonthYear
	 , CAST(WorkOrder.dtmApprovedDate AS DATE)				AS dtmApprovedDate
	 , WorkOrder.strWorkOrderNo								AS strOrder
	 , Batch.strBatchId										AS strBatchId
	 , BlendItem.strItemNo								AS strBlendCode
	 , CAST(BlendRequirement.dblEstNoOfBlendSheet AS NUMERIC(18, 6)) AS dblNoOfMixes
	 , InputLotItem.strItemNo								AS strTeaItem
	 , CAST(InputLot.dblIssuedQuantity AS NUMERIC(18, 6))	AS dblNoOfPackages
	 , CAST(InputLot.dblQuantity AS NUMERIC(18, 6))			AS dblAllocQty
	 , CAST(Batch.dblSellingPrice AS NUMERIC(18, 6))		AS dblSellingPrice
	 , CAST((InputLot.dblQuantity * 1) AS NUMERIC(18, 6))	AS dblAllocQtyInUsd
	 , CAST(ISNULL((InputLotItem.intUnitPerLayer * InputLotItem.intLayerPerPallet), 0.000000) AS NUMERIC(18,6)) AS dblPackagesPerPaller
	 , BuyingCenterLocation.strLocationName			 AS strAuction
	 , Batch.strTeaOrigin							 AS strOrigin
	 , ISNULL(LocationPlant.strVendorRefNoPrefix, LocationPlant.strOregonFacilityNumber) AS strPlant
	 , BuyingCenterLocation.strLocationName			 AS strTBO
	 , InputLotItem.strModelNo						 AS	strMaterial
	 , ''											 AS strPurchasingDocument
	 , ''											 AS strProducer
	 , Batch.strSustainability						 AS strSustainability
	 , GardenMark.strGardenMark						 AS strTeaMark
	 , Batch.strLeafGrade							 AS strGrade
	 , Batch.strTeaGardenChopInvoiceNumber			 AS strChop
	 , Batch.strLeafSize							 AS strLeafSize
	 , CAST(0.000000 AS NUMERIC(18, 6))				 AS dblPurchasePrice
	 , CAST(0.000000 AS NUMERIC(18, 6))				 AS dblBasePrice
	 , CAST(Batch.dblLandedPrice  AS NUMERIC(18, 6)) AS dblLandedPrice
	 , WorkOrderItem.strDescription					 AS strMaterialDescription
	 , ''											 AS strUTK
	 , CAST(0.000000  AS NUMERIC(18, 6))			 AS dblActualQty
	 , CAST(0.000000  AS NUMERIC(18, 6))			 AS dblActualQtyInUSD
	 , Entity.strName								 AS strApprovedBy
	 , Batch.strTeaColour							 AS strColor
	 , ''											 AS strDustContent
	 , ''											 AS strFactoryConsumptionDate
	 , ''											 AS strLowCostCountry
	 , Batch.strLeafManufacturingType				 AS strManufacturingType
	 , Batch.strProductionSite						 AS strProductionSite
	 , Batch.strSupplierReference					 AS strReference
	 , Batch.strTeaColour							 AS strTeaColour
	 , Region.strDescription						 AS strTeaLingoSubCluster
	 , CAST(Batch.dblTeaVolume  AS NUMERIC(18, 6))	 AS dblTeaVolume
	 , BlendRequirement.strDemandNo					 AS strComment
	 , WorkOrder.strERPOrderNo						 AS strERPOrderNo
	 , WorkOrderStatus.strName						 AS strWorkOrderStatus
	 , InputLot.strFW								 
	 , CASE WHEN MarketZone.strMarketZoneCode = 'AUC' THEN 'Yes'
			ELSE 'No'
	   END AS strChannel
	 , ISNULL(WorkOrder.intCompanyId, WorkOrder.intLocationId) AS intCompanyLocationId
	 , Batch.intBuyingCenterLocationId
FROM tblMFWorkOrder AS WorkOrder
INNER JOIN tblMFWorkOrderInputLot AS InputLot ON WorkOrder.intWorkOrderId = InputLot.intWorkOrderId
INNER JOIN tblICLot AS Lot ON Lot.intLotId = InputLot.intLotId
INNER JOIN tblMFBlendRequirement AS BlendRequirement ON BlendRequirement.intBlendRequirementId = WorkOrder.intBlendRequirementId
INNER JOIN tblICItem AS BlendItem ON BlendRequirement.intItemId = BlendItem.intItemId
INNER JOIN tblMFLotInventory AS LotInventory ON LotInventory.intLotId = InputLot.intLotId
INNER JOIN tblMFBatch AS Batch ON Batch.intBatchId = LotInventory.intBatchId
INNER JOIN tblMFWorkOrderStatus AS WorkOrderStatus ON WorkOrder.intStatusId = WorkOrderStatus.intStatusId
LEFT JOIN tblARMarketZone AS MarketZone ON Batch.intMarketZoneId = MarketZone.intMarketZoneId
LEFT JOIN tblQMGardenMark AS GardenMark ON GardenMark.intGardenMarkId = Batch.intGardenMarkId
LEFT JOIN tblICItem AS InputLotItem ON InputLotItem.intItemId = InputLot.intItemId
LEFT JOIN tblICItem AS WorkOrderItem ON InputLotItem.intItemId = WorkOrder.intItemId
LEFT JOIN tblQMTINClearance AS TinClearance ON TinClearance.intBatchId = Batch.intBatchId
LEFT JOIN tblSMCompanyLocation AS BuyingCenterLocation ON Batch.intBuyingCenterLocationId = BuyingCenterLocation.intCompanyLocationId
--LEFT JOIN tblSMCompanyLocation AS BatchLocation ON Batch.intLocationId = BuyingCenterLocation.intCompanyLocationId
LEFT JOIN tblEMEntity AS Entity on Entity.intEntityId = WorkOrder.intApprovedBy
LEFT JOIN tblICCommodityAttribute AS Region ON InputLotItem.intRegionId = Region.intCommodityAttributeId
LEFT JOIN tblSMCompanyLocation AS LocationPlant ON ISNULL(WorkOrder.intCompanyId, WorkOrder.intLocationId) = LocationPlant.intCompanyLocationId 
GO