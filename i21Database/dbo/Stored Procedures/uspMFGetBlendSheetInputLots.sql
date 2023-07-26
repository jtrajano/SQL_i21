﻿CREATE PROCEDURE [dbo].[uspMFGetBlendSheetInputLots]
	@intWorkOrderId INT
AS

DECLARE @dblRecipeQty NUMERIC(18,6)
	  , @ysnEnableParentLot BIT=0
	  ,@ysnDisplayLandedPriceInBlendManagement	INT

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0), @ysnDisplayLandedPriceInBlendManagement=IsNULL(ysnDisplayLandedPriceInBlendManagement,0)
FROM tblMFCompanyPreference

SELECT TOP 1 @dblRecipeQty = r.dblQuantity 
FROM tblMFRecipe r 
JOIN tblMFRecipeItem ri ON r.intRecipeId = ri.intRecipeId 
JOIN tblMFWorkOrder w ON r.intItemId = w.intItemId AND r.intLocationId=w.intLocationId
WHERE r.ysnActive=1

IF @ysnEnableParentLot=0
BEGIN
	IF (SELECT COUNT(1) FROM tblMFWorkOrderInputLot WHERE intWorkOrderId=@intWorkOrderId) > 0
	BEGIN
		SELECT wi.intWorkOrderInputLotId
			 , wi.intWorkOrderId
			 , wi.intLotId
			 , wi.dblQuantity
			 , wi.intItemUOMId
			 , wi.dblIssuedQuantity
			 , wi.intItemIssuedUOMId
			 , Lot.dblWeightPerQty AS dblWeightPerUnit
			 , wi.intSequenceNo
			 , wi.dtmCreated
			 , wi.intCreatedUserId
			 , wi.dtmLastModified
			 , wi.intLastModifiedUserId
			 , CAST(0 AS BIT) AS ysnParentLot
			 , Lot.strLotNumber
			 , i.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , um.strUnitMeasure AS strUOM
			 , um1.strUnitMeasure AS strIssuedUOM
			 , wi.intRecipeItemId
			 , Case When @ysnDisplayLandedPriceInBlendManagement=1 Then IsNULL(Batch.dblLandedPrice,0) Else Lot.dblLastCost End AS dblUnitCost
			 , ISNULL(Lot.strLotAlias,'') AS strLotAlias
			 , Lot.strGarden AS strGarden
			 , Lot.intLocationId
			 , cl.strLocationName AS strLocationName
			 , sbl.strSubLocationName
			 , sl.strName AS strStorageLocationName
			 , Lot.strNotes AS strRemarks
			 , i.dblRiskScore
			 , ri.dblQuantity/@dblRecipeQty AS dblConfigRatio
			 , CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
			 , CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
			 , i.intCategoryId
			 , LS.strSecondaryStatus
			 , wi.intStorageLocationId
			 , wi.strFW
			 , MT.strDescription AS strProductType
			 , B.strBrandCode
			 , AuctionCenter.strLocationName AS strAuctionCenter
			 , Batch.intSalesYear AS intSaleYear
			 , Batch.intSales AS intSaleNo
			 , Batch.dblTeaTaste
			 , Batch.dblTeaHue
			 , Batch.dblTeaIntensity
			 , Batch.dblTeaMouthFeel
			 , SubCluster.strDescription	AS strSubCluster
			 , Batch.dblTeaAppearance
			 , ISNULL(Batch.dblTeaVolume, 0) AS dblTeaVolume
			 , DATEDIFF(DAY, IsNULL(Lot.dtmManufacturedDate ,Lot.dtmDateCreated), GETDATE()) AS intAge
			 , CASE WHEN (NULLIF(i.intUnitPerLayer,'') IS NULL OR i.intUnitPerLayer = 0) AND (NULLIF(i.intLayerPerPallet,'') IS NULL OR i.intLayerPerPallet = 0) THEN 0
					WHEN (CASE WHEN ISNULL(wi.dblIssuedQuantity,0) > 0 THEN wi.dblIssuedQuantity 
							   ELSE dbo.fnMFConvertQuantityToTargetItemUOM(wi.intItemUOMId, Lot.intItemUOMId, wi.dblIssuedQuantity) 
						  END) = 0 THEN 0
					ELSE CAST(wi.dblIssuedQuantity / (i.intUnitPerLayer * i.intLayerPerPallet) AS NUMERIC(18, 0))
			   END AS dblNoOfPallet
			 , Batch.strLeafGrade
			 , Garden.strGardenMark
			 , wi.dblQuantity  AS dblRequiredQtyPerSheet
		FROM tblMFWorkOrderInputLot wi 
		JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
		JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
		JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		JOIN tblICLot Lot ON wi.intLotId = Lot.intLotId
		JOIN tblICLotStatus LS ON Lot.intLotStatusId = LS.intLotStatusId
		JOIN tblICItem i ON Lot.intItemId = i.intItemId
		JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
		JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = Lot.intLocationId
		LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = Lot.intSubLocationId
		LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = Lot.intStorageLocationId
		LEFT JOIN vyuQMGetLotQuality q ON Lot.intLotId = q.intLotId
		LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
		LEFT JOIN tblICCommodityAttribute MT on MT.intCommodityAttributeId=i.intProductTypeId
		LEFT JOIN tblICBrand B on B.intBrandId=i.intBrandId
		LEFT JOIN tblMFLotInventory AS LotInventory ON LotInventory.intLotId = Lot.intLotId
		LEFT JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId
		LEFT JOIN tblSMCompanyLocation AS AuctionCenter ON Batch.intBuyingCenterLocationId = AuctionCenter.intCompanyLocationId
		LEFT JOIN tblICCommodityAttribute AS SubCluster ON i.intRegionId = SubCluster.intCommodityAttributeId
		LEFT JOIN tblQMGardenMark Garden ON Garden.intGardenMarkId = Batch.intGardenMarkId
		WHERE wi.intWorkOrderId = @intWorkOrderId
	END
	ELSE /* When blend sheet created from Sales Order, directly produced in blend production screen, then only consumed lot table will have the values, to show in blend management screen from traceability */
		SELECT wi.intWorkOrderConsumedLotId AS intWorkOrderInputLotId
			 , wi.intWorkOrderId
			 , wi.intLotId
			 , wi.dblQuantity
			 , wi.intItemUOMId
			 , wi.dblIssuedQuantity
			 , wi.intItemIssuedUOMId
			 , Lot.dblWeightPerQty AS dblWeightPerUnit
			 , wi.intSequenceNo
			 , wi.dtmCreated
			 , wi.intCreatedUserId
			 , wi.dtmLastModified
			 , wi.intLastModifiedUserId
			 , CAST(0 AS BIT) AS ysnParentLot
			 , Lot.strLotNumber
			 , i.intItemId
			 , i.strItemNo
			 , i.strDescription
			 , um.strUnitMeasure AS strUOM
			 , um1.strUnitMeasure AS strIssuedUOM
			 , wi.intRecipeItemId
			 , Lot.dblLastCost AS dblUnitCost
			 , ISNULL(Lot.strLotAlias, '') AS strLotAlias
			 , Lot.strGarden AS strGarden
			 , Lot.intLocationId
			 , cl.strLocationName AS strLocationName
			 , sbl.strSubLocationName
			 , sl.strName AS strStorageLocationName
			 , Lot.strNotes AS strRemarks
			 , i.dblRiskScore
			 , ri.dblQuantity/@dblRecipeQty AS dblConfigRatio
			 , CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
			 , CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
			 , i.intCategoryId
			 , LS.strSecondaryStatus
			 , wi.intStorageLocationId
			 , '' As strFW
			 , MT.strDescription AS strProductType
			 , B.strBrandCode
			 , AuctionCenter.strLocationName AS strAuctionCenter
			 , Batch.intSalesYear AS intSaleYear
			 , Batch.intSales
			 , Batch.dblTeaTaste
			 , Batch.dblTeaHue
			 , Batch.dblTeaIntensity
			 , Batch.dblTeaMouthFeel
			 , SubCluster.strDescription	AS strSubCluster
			 , Batch.dblTeaAppearance
			 , ISNULL(Batch.dblTeaVolume, 0) AS dblTeaVolume
			 , DATEDIFF(DAY, IsNULL(Lot.dtmManufacturedDate ,Lot.dtmDateCreated), GETDATE()) AS intAge
			 , CASE WHEN (NULLIF(i.intUnitPerLayer,'') IS NULL OR i.intUnitPerLayer = 0) AND (NULLIF(i.intLayerPerPallet,'') IS NULL OR i.intLayerPerPallet = 0) THEN 0
					WHEN (CASE WHEN ISNULL(wi.dblIssuedQuantity,0) > 0 THEN wi.dblIssuedQuantity 
							   ELSE dbo.fnMFConvertQuantityToTargetItemUOM(wi.intItemUOMId, Lot.intItemUOMId, wi.dblIssuedQuantity) 
						  END) = 0 THEN 0
					ELSE CAST(wi.dblIssuedQuantity / (i.intUnitPerLayer * i.intLayerPerPallet) AS NUMERIC(18, 0))
			   END AS dblNoOfPallet
			 , Batch.strLeafGrade
			 , Garden.strGardenMark
			 , wi.dblQuantity  AS dblRequiredQtyPerSheet
		 FROM tblMFWorkOrderConsumedLot wi 
		 JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
		 JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
		 JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
		 JOIN tblICLot Lot ON wi.intLotId = Lot.intLotId
		 JOIN tblICLotStatus LS ON Lot.intLotStatusId = LS.intLotStatusId
		 JOIN tblICItem i ON Lot.intItemId = i.intItemId
		 JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
		 JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
		 JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = Lot.intLocationId
		 LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = Lot.intSubLocationId
		 LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = Lot.intStorageLocationId
		 LEFT JOIN vyuQMGetLotQuality q ON Lot.intLotId = q.intLotId
		 LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
		 LEFT JOIN tblICCommodityAttribute MT on MT.intCommodityAttributeId=i.intProductTypeId
		 LEFT JOIN tblICBrand B on B.intBrandId=i.intBrandId
		 LEFT JOIN tblMFLotInventory AS LotInventory ON LotInventory.intLotId = Lot.intLotId
		 LEFT JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId
		 LEFT JOIN tblSMCompanyLocation AS AuctionCenter ON Batch.intBuyingCenterLocationId = AuctionCenter.intCompanyLocationId
		 LEFT JOIN tblICCommodityAttribute AS SubCluster ON i.intRegionId = SubCluster.intCommodityAttributeId
		 LEFT JOIN tblQMGardenMark Garden ON Garden.intGardenMarkId = Batch.intGardenMarkId
		 WHERE wi.intWorkOrderId = @intWorkOrderId
END
ELSE
BEGIN
	SELECT wi.intWorkOrderInputParentLotId AS intWorkOrderInputLotId
	, wi.intWorkOrderId
	, wi.intParentLotId AS intLotId
	, wi.dblQuantity
	, wi.intItemUOMId
	, wi.dblIssuedQuantity
	, wi.intItemIssuedUOMId
	, wi.dblWeightPerUnit
	, wi.intSequenceNo
	, wi.dtmCreated
	, wi.intCreatedUserId
	, wi.dtmLastModified
	, wi.intLastModifiedUserId
	, CAST(1 AS BIT) AS ysnParentLot
	, pl.strParentLotNumber AS strLotNumber
	, i.intItemId
	, i.strItemNo
	, i.strDescription
	, um.strUnitMeasure AS strUOM
	, um1.strUnitMeasure AS strIssuedUOM
	, wi.intRecipeItemId,CAST(0 AS NUMERIC(18,6)) AS dblUnitCost
	, ISNULL(pl.strParentLotAlias, '') AS strLotAlias
	, CONVERT(NVARCHAR(MAX),'') AS strGarden
	, wi.intLocationId
	, cl.strLocationName AS strLocationName
	, sbl.strSubLocationName
	, sl.strName AS strStorageLocationName
	, CONVERT(NVARCHAR(MAX),'') AS strRemarks
	, i.dblRiskScore
	, ri.dblQuantity / @dblRecipeQty AS dblConfigRatio
	, CAST(ISNULL(q.Density,0) AS DECIMAL) AS dblDensity
	, CAST(ISNULL(q.Score,0) AS DECIMAL) AS dblScore
	, i.intCategoryId
	, wi.intStorageLocationId 
    , LS.strSecondaryStatus
	, CAST((wi.dblIssuedQuantity) / (i.intUnitPerLayer * i.intLayerPerPallet) AS NUMERIC (18, 0)) AS dblNoOfPallet
	, '' As strFW
	, MT.strDescription AS strProductType
	, B.strBrandCode
	, wi.dblQuantity  AS dblRequiredQtyPerSheet

	INTO #tblWorkOrderInputParent
	FROM tblMFWorkOrderInputParentLot wi 
	JOIN tblMFWorkOrder w ON wi.intWorkOrderId = w.intWorkOrderId
	JOIN tblICItemUOM iu ON wi.intItemUOMId = iu.intItemUOMId
	JOIN tblICUnitMeasure um ON iu.intUnitMeasureId = um.intUnitMeasureId
	JOIN tblICParentLot pl ON wi.intParentLotId = pl.intParentLotId
	JOIN tblICLotStatus LS ON pl.intLotStatusId  =  LS.intLotStatusId
	JOIN tblICItem i ON pl.intItemId = i.intItemId
	JOIN tblICItemUOM iu1 ON wi.intItemIssuedUOMId = iu1.intItemUOMId
	JOIN tblICUnitMeasure um1 ON iu1.intUnitMeasureId = um1.intUnitMeasureId
	JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = wi.intLocationId
	LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = wi.intStorageLocationId
	LEFT JOIN tblSMCompanyLocationSubLocation sbl ON sbl.intCompanyLocationSubLocationId = sl.intSubLocationId
	LEFT JOIN vyuQMGetLotQuality q ON pl.intParentLotId = q.intLotId
	LEFT JOIN tblMFRecipeItem ri ON wi.intRecipeItemId = ri.intRecipeItemId
	LEFT JOIN tblICCommodityAttribute MT on MT.intCommodityAttributeId=i.intProductTypeId
	LEFT JOIN tblICBrand B on B.intBrandId=i.intBrandId
	WHERE wi.intWorkOrderId = @intWorkOrderId

	--Update wi Set wi.dblUnitCost=l.dblLastCost,wi.strGarden=ISNULL(l.strGarden,''),wi.strRemarks=l.strNotes
	--From #tblWorkOrderInputParent wi Join tblICLot l on wi.intLotId=l.intParentLotId

	UPDATE wi 
	SET wi.dblUnitCost = t.dblLastCost
	  , wi.strGarden   = ISNULL(t.strGarden, '')
	  , wi.strRemarks  = ISNULL(t.strNotes, '')
	FROM #tblWorkOrderInputParent wi
	OUTER APPLY (SELECT TOP 1 l.dblLastCost
							, l.strGarden
							, l.strNotes
				 FROM tblICLot l
				 WHERE l.intParentLotId = wi.intLotId
				 ORDER BY l.intLotId DESC) t
	SELECT * FROM #tblWorkOrderInputParent
END