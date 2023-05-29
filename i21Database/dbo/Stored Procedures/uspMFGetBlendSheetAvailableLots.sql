CREATE PROCEDURE [dbo].[uspMFGetBlendSheetAvailableLots]
	@intItemId				INT = NULL
  , @intLocationId			INT
  , @intRecipeItemId		INT = NULL
  , @intWorkOrderId			INT = NULL
  , @intBlendRequirementId	INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @intRecipeId							INT
	  , @dblRecipeQty							NUMERIC(38, 20)
	  , @intManufacturingProcessId				INT
	  , @ysnShowOtherFactoryLots				BIT
	  , @ysnShowAvailableLotsByStorageLocation	BIT
	  , @ysnEnableParentLot						BIT = 0
	  , @strLotStatusIds						NVARCHAR(50)
	  , @index									INT
	  , @id										INT
	  , @intManufacturingCellId					INT
	  , @ysnDisplayLandedPriceInBlendManagement	INT


DECLARE @tblSourceSubLocation AS TABLE 
(
	intRecordId			INT IDENTITY(1, 1)
  , intSubLocationId	INT
);

DECLARE @tblLotStatus AS TABLE
(
	intLotStatusId INT
);

DECLARE @tblReservedQty TABLE
(
	intLotId	   INT
  , dblReservedQty NUMERIC(38, 20)
);

/* Get Value of Enable Parent Lot from Manufacturing Configuration. */
SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0) ,@ysnDisplayLandedPriceInBlendManagement=IsNULL(ysnDisplayLandedPriceInBlendManagement,0)
FROM tblMFCompanyPreference;

/* Get Manufacturing Process ID where Attribute is Blending (2). */
SELECT TOP 1 @intManufacturingProcessId = intManufacturingProcessId 
FROM tblMFManufacturingProcess 
WHERE intAttributeTypeId = 2;

/* Get Show Other Factory Lots value from Manufacturing Process. */
SELECT @ysnShowOtherFactoryLots = CASE WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE' THEN 1 ELSE 0 END 
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute 
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId AND intLocationId=@intLocationId AND Attribute.strAttributeName = 'Show Other Factory Lots';

/* Get Show Available Lots By Storage Location value from Manufacturing Process. */
SELECT @ysnShowAvailableLotsByStorageLocation = CASE WHEN UPPER(ProcessAttribute.strAttributeValue) = 'TRUE' THEN 1 ELSE 0 END 
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute 
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId AND intLocationId=@intLocationId AND Attribute.strAttributeName = 'Show Available Lots By Storage Location';

/* Get Blend Sheet Available Lots Status value from Manufacturing Process. */
SELECT @strLotStatusIds = ProcessAttribute.strAttributeValue 
FROM tblMFManufacturingProcessAttribute AS ProcessAttribute 
JOIN tblMFAttribute AS Attribute ON ProcessAttribute.intAttributeId = Attribute.intAttributeId
WHERE intManufacturingProcessId = @intManufacturingProcessId AND intLocationId = @intLocationId AND Attribute.strAttributeName = 'Blend Sheet Available Lots Status';
	
	SELECT @intManufacturingCellId = intManufacturingCellId
	FROM tblMFBlendRequirement AS BlendRequirement
	WHERE BlendRequirement.intBlendRequirementId = @intBlendRequirementId;

	IF NOT EXISTS (
			SELECT *
			FROM tblMFManufacturingCellSubLocation
			WHERE intManufacturingCellId = @intManufacturingCellId
			) OR @intBlendRequirementId is NULL
	BEGIN
		INSERT INTO @tblSourceSubLocation (intSubLocationId)
		SELECT intCompanyLocationSubLocationId
		FROM tblSMCompanyLocationSubLocation
		WHERE intCompanyLocationId = @intLocationId

	END
	ELSE
	BEGIN
		INSERT INTO @tblSourceSubLocation (intSubLocationId)
		SELECT SL.intCompanyLocationSubLocationId
		FROM dbo.tblMFManufacturingCellSubLocation SL
		WHERE intManufacturingCellId = @intManufacturingCellId
		ORDER BY SL.intManufacturingCellSubLocationId
	END

/* Create Lot Status. */
IF ISNULL(@strLotStatusIds, '') <> ''
	BEGIN
		/* Get the Comma Separated Lot Status Ids into a table. */
		SET @index = CharIndex(',', @strLotStatusIds);

		WHILE @index > 0
			BEGIN
				SET @id = SUBSTRING(@strLotStatusIds, 1, @index - 1);
				SET @strLotStatusIds = SUBSTRING(@strLotStatusIds, @index + 1, LEN(@strLotStatusIds) - @index);

				INSERT INTO @tblLotStatus(intLotStatusId) VALUES (@id);

				SET @index = CharIndex(',', @strLotStatusIds);
			END

		SET @id = @strLotStatusIds;

		INSERT INTO @tblLotStatus(intLotStatusId) VALUES (@id);
	END
ELSE
	BEGIN
		INSERT INTO @tblLotStatus(intLotStatusId) VALUES (1);
	END
/* End of Create Lot Status. */

/* Get Recipe ID based on Location, Active and Item selected. */
IF @intItemId IS NOT NULL
BEGIN
	SELECT TOP 1 @intRecipeId  = Recipe.intRecipeId 
			   , @dblRecipeQty = Recipe.dblQuantity 
	FROM tblMFRecipe AS Recipe 
	JOIN tblMFRecipeItem AS RecipeItem ON Recipe.intRecipeId = RecipeItem.intRecipeId
	WHERE RecipeItem.intItemId = @intItemId AND RecipeItem.intRecipeItemId = @intRecipeItemId AND Recipe.intLocationId = @intLocationId AND Recipe.ysnActive = 1;
END
ELSE
BEGIN
	SELECT TOP 1 @intRecipeId  = NULL 
		   , @dblRecipeQty = 1
END
/* Create Reserved Quantity based on Manufacturing Configuration Enable Parent Lot. */
INSERT INTO @tblReservedQty
SELECT CASE WHEN @ysnEnableParentLot = 0 THEN intLotId ELSE intParentLotId END 
	 , SUM(dblQty) AS dblReservedQty 
FROM tblICStockReservation 
WHERE intItemId = (CASE WHEN @intItemId IS NOT NULL THEN @intItemId ELSE intItemId END) AND ISNULL(ysnPosted, 0) = 0
GROUP BY CASE WHEN @ysnEnableParentLot = 0 THEN intLotId ELSE intParentLotId END;
	

/* Set Temporary lot data. */
SELECT Lot.intLotId
	 , Lot.strLotNumber
	 , Lot.intItemId
	 , Item.strItemNo
	 , Item.strDescription
	 , ISNULL(Lot.strLotAlias, '')	AS strLotAlias
	 , CASE WHEN ISNULL(Lot.dblWeight,0) > 0 THEN Lot.dblWeight ELSE dbo.fnMFConvertQuantityToTargetItemUOM(Lot.intItemUOMId, RecipeItem.intItemUOMId, Lot.dblQty) END AS dblPhysicalQty
	 , ISNULL(Lot.intWeightUOMId, RecipeItemUOM.intItemUOMId)						AS intItemUOMId 
	 , ISNULL(UnitOfMeasure.strUnitMeasure, RecipeItemUnitOfMeasure.strUnitMeasure) AS strUOM
	 , Case When @ysnDisplayLandedPriceInBlendManagement=1 Then IsNULL(Batch.dblLandedPrice,0) Else Lot.dblLastCost End									AS dblUnitCost
	 , CASE WHEN ISNULL(Lot.dblWeight,0) > 0 THEN Lot.dblWeightPerQty ELSE LotItemUOM.dblUnitQty / RecipeItemUOM.dblUnitQty END AS dblWeightPerUnit
	 , UnitOfMeasure.strUnitMeasure						AS strWeightPerUnitUOM
	 , Lot.intItemUOMId									AS intPhysicalItemUOMId
	 , Lot.dtmDateCreated								AS dtmReceiveDate
	 , Lot.dtmExpiryDate
	 , ISNULL(' ', '')									AS strVendorId
	 , ISNULL(Lot.strVendorLotNo, '')					AS strVendorLotNo
	 , Lot.strGarden									AS strGarden
	 , Lot.intLocationId
	 , CompanyLocation.strLocationName					AS strLocationName
	 , CompanySubLocation.strSubLocationName
	 , StorageLocation.strName							AS strStorageLocationName
	 , Lot.strNotes										AS strRemarks
	 , Item.dblRiskScore
	 , RecipeItem.dblQuantity / @dblRecipeQty			AS dblConfigRatio
	 , CAST(ISNULL(0, 0) AS DECIMAL)	AS dblDensity
	 , CAST(ISNULL(0, 0) AS DECIMAL)	AS dblScore
	 , Lot.intParentLotId
	 , StorageLocation.intStorageLocationId
	 , LotUnitMeasure.strUnitMeasure					AS strPhysicalItemUOM
	 , Item.intCategoryId
	 , LotStatus.strSecondaryStatus
	 , LotInventory.dblReservedQtyInTBS					AS dblReservedQtyInTBS
	 , CASE WHEN (NULLIF(Item.intUnitPerLayer, '') IS NULL OR Item.intUnitPerLayer = 0)
         AND (NULLIF(Item.intLayerPerPallet, '') IS NULL OR Item.intLayerPerPallet = 0)
         THEN 0 WHEN (CASE WHEN ISNULL(Lot.dblQty, 0) > 0 THEN Lot.dblQty
              ELSE dbo.fnMFConvertQuantityToTargetItemUOM(Lot.intItemUOMId, RecipeItem.intItemUOMId, Lot.dblQty)
				  END) = 0 THEN 0WHEN Item.intUnitPerLayer * Item.intLayerPerPallet = 0 THEN 0
					ELSE CAST(Lot.dblQty / (Item.intUnitPerLayer * Item.intLayerPerPallet) AS NUMERIC(18, 2))
		END AS dblNoOfPallet
	 , AuctionCenter.strLocationName AS strAuctionCenter
	 , ISNULL(SaleYear.strSaleYear, Batch.intSalesYear) AS strSaleYear
	 , Batch.intSales
	 , Batch.dblTeaTaste
	 , Batch.dblTeaHue
	 , Batch.dblTeaIntensity
	 , Batch.dblTeaMouthFeel
	 , SubCluster.strDescription	 AS strSubCluster
	 , Batch.dblTeaAppearance
	 , Batch.dblTeaVolume
	 , DATEDIFF(DAY, Lot.dtmDateCreated, GETDATE()) AS intAge
	 , MT.strDescription AS strProductType
	 , B.strBrandCode
	 , Batch.strTasterComments
	 , Garden.strGardenMark
	 , Batch.strLeafGrade
	 , Batch.strTeaOrigin
	 , Batch.strVendorLotNumber
	 , Item.intUnitPerLayer
	 , Item.intLayerPerPallet
	 , ISNULL(0.0, 0) AS dblPickedQty
	 , Item.strShortName
INTO #tempLot
FROM tblICLot AS Lot
JOIN tblICItem AS Item ON Lot.intItemId = Item.intItemId
JOIN tblICLotStatus AS LotStatus ON Lot.intLotStatusId = LotStatus.intLotStatusId
JOIN tblSMCompanyLocation AS CompanyLocation ON CompanyLocation.intCompanyLocationId = Lot.intLocationId
JOIN tblICItemUOM AS LotItemUOM on Lot.intItemUOMId = LotItemUOM.intItemUOMId
JOIN tblICUnitMeasure AS LotUnitMeasure on LotItemUOM.intUnitMeasureId = LotUnitMeasure.intUnitMeasureId
JOIN @tblSourceSubLocation SubLoc ON SubLoc.intSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICItemUOM AS LotItemWeightUOM ON Lot.intWeightUOMId = LotItemWeightUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure AS UnitOfMeasure ON LotItemWeightUOM.intUnitMeasureId = UnitOfMeasure.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation AS CompanySubLocation ON CompanySubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICStorageLocation AS StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
LEFT JOIN tblICStorageUnitType AS StorageUnitType ON StorageLocation.intStorageUnitTypeId = StorageUnitType.intStorageUnitTypeId AND StorageUnitType.strInternalCode <> 'PROD_STAGING'
LEFT JOIN tblMFWorkOrderRecipeItem AS WorkOrderRecipeItem ON WorkOrderRecipeItem.intItemId = Item.intItemId AND WorkOrderRecipeItem.intWorkOrderId = @intWorkOrderId AND  WorkOrderRecipeItem.intRecipeItemTypeId = 1 AND WorkOrderRecipeItem.intRecipeItemId = @intRecipeItemId
LEFT JOIN tblMFRecipeItem AS RecipeItem ON RecipeItem.intItemId = Item.intItemId AND RecipeItem.intRecipeItemId = @intRecipeItemId
LEFT JOIN tblICItemUOM AS RecipeItemUOM ON IsNULL(WorkOrderRecipeItem.intItemUOMId,RecipeItem.intItemUOMId) = RecipeItemUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure AS RecipeItemUnitOfMeasure ON RecipeItemUOM.intUnitMeasureId = RecipeItemUnitOfMeasure.intUnitMeasureId 
--LEFT JOIN vyuQMGetLotQuality AS LotQuality ON (CASE WHEN (SELECT TOP 1 ISNULL(ysnEnableParentLot, 0) FROM tblMFCompanyPreference) = 1 THEN Lot.intParentLotId ELSE Lot.intLotId END) = LotQuality.intLotId
LEFT JOIN tblMFLotInventory AS LotInventory ON LotInventory.intLotId = Lot.intLotId
LEFT JOIN tblMFBatch AS Batch ON LotInventory.intBatchId = Batch.intBatchId
LEFT JOIN tblSMCompanyLocation AS AuctionCenter ON Batch.intBuyingCenterLocationId = AuctionCenter.intCompanyLocationId
LEFT JOIN tblQMSaleYear AS SaleYear ON Batch.intSalesYear = SaleYear.intSaleYearId
LEFT JOIN tblICCommodityAttribute AS SubCluster ON Item.intRegionId = SubCluster.intCommodityAttributeId
LEFT JOIN tblQMGardenMark AS GardenMark ON Batch.intGardenMarkId = GardenMark.intGardenMarkId
LEFT JOIN tblICCommodityAttribute MT on MT.intCommodityAttributeId=Item.intProductTypeId
LEFT JOIN tblICBrand B on B.intBrandId=Item.intBrandId
LEFT JOIN tblQMGardenMark Garden ON Garden.intGardenMarkId = Batch.intGardenMarkId
--OUTER APPLY (SELECT ISNULL(WorkOrderInput.dblQuantity, 0) AS dblPickedQty
--			 FROM tblMFWorkOrderInputLot AS WorkOrderInput
--			 WHERE intRecipeItemId = @intRecipeItemId AND intItemId = @intItemId AND WorkOrderInput.intLotId = Lot.intLotId) AS InputLot
WHERE Lot.intItemId = (CASE WHEN @intItemId IS NOT NULL THEN @intItemId ELSE Lot.intItemId END) AND Lot.dblQty > 0 AND LotStatus.intLotStatusId IN (SELECT intLotStatusId FROM @tblLotStatus)
  And Lot.intLocationId = (CASE WHEN @ysnShowOtherFactoryLots = 1 THEN Lot.intLocationId ELSE @intLocationId END)
ORDER BY Lot.dtmExpiryDate
	   , Lot.dtmDateCreated;



/* Enable Parent Lot Configure is true/checked from Configuration. */
IF @ysnEnableParentLot = 0
	BEGIN
		SELECT TemporaryLot.intLotId
			 , TemporaryLot.strLotNumber
			 , TemporaryLot.intItemId
			 , TemporaryLot.strItemNo
			 , TemporaryLot.strDescription
			 , TemporaryLot.strLotAlias
			 , TemporaryLot.dblPhysicalQty
			 , ISNULL(TemporaryLot.dblReservedQtyInTBS, 0) AS dblReservedQtyInTBS
			 , ISNULL(ReservedQty.dblReservedQty, 0)		 AS dblReservedQty
			 , ISNULL((ISNULL(TemporaryLot.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(TemporaryLot.dblReservedQtyInTBS, 0)), 0) AS dblAvailableQty
			 , ROUND((ISNULL((ISNULL(TemporaryLot.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(TemporaryLot.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(TemporaryLot.dblWeightPerUnit, 0) = 0 THEN 1 ELSE TemporaryLot.dblWeightPerUnit END), 0) AS dblAvailableUnit
			 , TemporaryLot.intItemUOMId
			 , TemporaryLot.strUOM
			 , TemporaryLot.dblUnitCost
			 , TemporaryLot.dblWeightPerUnit
			 , TemporaryLot.strWeightPerUnitUOM
			 , TemporaryLot.intPhysicalItemUOMId
			 , TemporaryLot.dtmReceiveDate
			 , TemporaryLot.dtmExpiryDate
			 , TemporaryLot.strVendorId
			 , TemporaryLot.strVendorLotNo
			 , TemporaryLot.strGarden
			 , TemporaryLot.intLocationId
			 , TemporaryLot.strLocationName
			 , TemporaryLot.strSubLocationName
			 , TemporaryLot.strStorageLocationName
			 , TemporaryLot.intStorageLocationId
			 , TemporaryLot.strRemarks
			 , TemporaryLot.dblRiskScore
			 , TemporaryLot.dblConfigRatio
			 , TemporaryLot.dblDensity
			 , TemporaryLot.dblScore
			 , TemporaryLot.intParentLotId
			 , CAST(0 AS BIT) AS ysnParentLot
			 , TemporaryLot.strPhysicalItemUOM
			 , TemporaryLot.intCategoryId
			 , TemporaryLot.strSecondaryStatus 
			 , TemporaryLot.dblNoOfPallet
			 , TemporaryLot.strAuctionCenter
			 , TemporaryLot.strSaleYear
			 , TemporaryLot.intSales
			 , TemporaryLot.dblTeaTaste
			 , TemporaryLot.dblTeaHue
			 , TemporaryLot.dblTeaIntensity
			 , TemporaryLot.dblTeaMouthFeel
			 , TemporaryLot.strSubCluster
			 , TemporaryLot.dblTeaAppearance
			 , TemporaryLot.dblTeaVolume
			 , TemporaryLot.intAge
			 , TemporaryLot.strProductType
			 , TemporaryLot.strBrandCode
			 , TemporaryLot.strTasterComments
			 , TemporaryLot.strGardenMark
			 , TemporaryLot.strLeafGrade
			 , TemporaryLot.strTeaOrigin
			 , TemporaryLot.strVendorLotNumber
			 , TemporaryLot.intSales
			 , ROUND((ISNULL((ISNULL(TemporaryLot.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(TemporaryLot.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(TemporaryLot.dblWeightPerUnit, 0) = 0 THEN 1 ELSE TemporaryLot.dblWeightPerUnit END), 0) AS dblSelectedQty
			 , TemporaryLot.intUnitPerLayer
			 , TemporaryLot.intLayerPerPallet
			 , TemporaryLot.dblPickedQty 
			 , TemporaryLot.strShortName 
			 , (TemporaryLot.dblReservedQtyInTBS / ISNULL(NULLIF(TemporaryLot.dblWeightPerUnit, 0), 1)) AS dblReservedQtyInTBSUnit
		FROM #tempLot AS TemporaryLot 
		LEFT JOIN @tblReservedQty AS ReservedQty ON TemporaryLot.intLotId = ReservedQty.intLotId
	END
ELSE
	BEGIN
		/* Available Lot by Storage Location is true/checked from Configuration. */
		IF @ysnShowAvailableLotsByStorageLocation = 1
			BEGIN
				SELECT ParentLot.intParentLotId				AS intLotId
					 , ParentLot.strParentLotNumber			AS strLotNumber
					 , TemporaryLot.intItemId
					 , TemporaryLot.strItemNo
					 , TemporaryLot.strDescription
					 , MAX(TemporaryLot.strLotAlias)		AS strLotAlias
					 , SUM(TemporaryLot.dblPhysicalQty)		AS dblPhysicalQty
					 , TemporaryLot.intItemUOMId
					 , TemporaryLot.strUOM
					 , MAX(TemporaryLot.dblUnitCost)		AS dblUnitCost
					 , AVG(TemporaryLot.dblWeightPerUnit)	AS dblWeightPerUnit
					 , TemporaryLot.strWeightPerUnitUOM
					 , TemporaryLot.intPhysicalItemUOMId
					 , MAX(TemporaryLot.dtmReceiveDate)		AS dtmReceiveDate
					 , MAX(TemporaryLot.dtmExpiryDate)		AS dtmExpiryDate
					 , MAX(TemporaryLot.strVendorId)		AS strVendorId
					 , MAX(TemporaryLot.strVendorLotNo)		AS strVendorLotNo
					 , MAX(TemporaryLot.strGarden)			AS strGarden
					 , TemporaryLot.intLocationId, TemporaryLot.strLocationName
					 , MAX(TemporaryLot.strSubLocationName) AS strSubLocationName
					 , TemporaryLot.strStorageLocationName  AS strStorageLocationName
					 , TemporaryLot.intStorageLocationId
					 , MAX(TemporaryLot.strRemarks)			AS strRemarks
					 , MAX(TemporaryLot.dblRiskScore)		AS dblRiskScore
					 , MAX(TemporaryLot.dblConfigRatio)		AS dblConfigRatio
					 , MAX(TemporaryLot.dblDensity)			AS dblDensity
					 , MAX(TemporaryLot.dblScore)			AS dblScore
					 , CAST(1 AS bit) AS ysnParentLot
					 , MAX(TemporaryLot.intCategoryId)		AS intCategoryId
					 , TemporaryLot.strPhysicalItemUOM
					 , MAX(TemporaryLot.strSecondaryStatus)	AS strSecondaryStatus
					 , ISNULL(SUM(TemporaryLot.dblReservedQtyInTBS), 0) AS dblReservedQtyInTBS
					 , TemporaryLot.dblNoOfPallet
					 , TemporaryLot.strAuctionCenter
					 , TemporaryLot.strSaleYear
					 , TemporaryLot.intSales
					 , TemporaryLot.dblTeaTaste
					 , TemporaryLot.dblTeaHue
					 , TemporaryLot.dblTeaIntensity
					 , TemporaryLot.dblTeaMouthFeel
					 , TemporaryLot.strSubCluster
					 , TemporaryLot.dblTeaAppearance
					 , TemporaryLot.dblTeaVolume
					 , TemporaryLot.intAge
					 , TemporaryLot.strProductType
					 , TemporaryLot.strBrandCode
					 , TemporaryLot.strTasterComments
					 , TemporaryLot.strGardenMark
					 , TemporaryLot.strLeafGrade
					 , TemporaryLot.strTeaOrigin
					 , TemporaryLot.strVendorLotNumber
					 , TemporaryLot.intUnitPerLayer
					 , TemporaryLot.intLayerPerPallet
					 , TemporaryLot.dblPickedQty
					 , TemporaryLot.strShortName
				INTO #tempParentLotByStorageLocation
				FROM #tempLot AS TemporaryLot 
				JOIN tblICParentLot AS ParentLot on TemporaryLot.intParentLotId = ParentLot.intParentLotId 
				GROUP BY ParentLot.intParentLotId
					   , ParentLot.strParentLotNumber
					   , TemporaryLot.intItemId
					   , TemporaryLot.strItemNo
					   , TemporaryLot.strDescription
					   , TemporaryLot.intItemUOMId
					   , TemporaryLot.strUOM
					   , TemporaryLot.strWeightPerUnitUOM
					   , TemporaryLot.intPhysicalItemUOMId
					   , TemporaryLot.intLocationId
					   , TemporaryLot.strLocationName
					   , TemporaryLot.strStorageLocationName
					   , TemporaryLot.intStorageLocationId
					   , TemporaryLot.strPhysicalItemUOM
					   , TemporaryLot.dblNoOfPallet
					   , TemporaryLot.strAuctionCenter
					   , TemporaryLot.strSaleYear
					   , TemporaryLot.intSales
					   , TemporaryLot.dblTeaTaste
					   , TemporaryLot.dblTeaHue
					   , TemporaryLot.dblTeaIntensity
					   , TemporaryLot.dblTeaMouthFeel
					   , TemporaryLot.strSubCluster
					   , TemporaryLot.dblTeaAppearance
					   , TemporaryLot.dblTeaVolume
					   , TemporaryLot.intAge


				SELECT ParentLotStorageLocation.*
					 , ISNULL(ReservedQty.dblReservedQty, 0) AS dblReservedQty
					 , ISNULL((ISNULL(ParentLotStorageLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - IsNULL(ParentLotStorageLocation.dblReservedQtyInTBS, 0)), 0) AS dblAvailableQty
					 , ROUND((ISNULL((ISNULL(ParentLotStorageLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - IsNULL(ParentLotStorageLocation.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(ParentLotStorageLocation.dblWeightPerUnit,0) = 0 THEN 1 ELSE ParentLotStorageLocation.dblWeightPerUnit END), 0) AS dblAvailableUnit
					 , ROUND((ISNULL((ISNULL(ParentLotStorageLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - IsNULL(ParentLotStorageLocation.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(ParentLotStorageLocation.dblWeightPerUnit,0) = 0 THEN 1 ELSE ParentLotStorageLocation.dblWeightPerUnit END), 0) AS dblSelectedQty
					 , (ParentLotStorageLocation.dblReservedQtyInTBS / ISNULL(NULLIF(ParentLotStorageLocation.dblWeightPerUnit, 0), 1)) AS dblReservedQtyInTBSUnit
				FROM #tempParentLotByStorageLocation AS ParentLotStorageLocation 
				LEFT JOIN @tblReservedQty AS ReservedQty on ParentLotStorageLocation.intLotId = ReservedQty.intLotId	
			END
		/* End of Available Lot by Storage Location is true/checked from Configuration. */
		ELSE
			BEGIN
				SELECT ParentLot.intParentLotId AS intLotId
					 , ParentLot.strParentLotNumber AS strLotNumber
					 , TemporaryLot.intItemId
					 , TemporaryLot.strItemNo
					 , TemporaryLot.strDescription
					 , TemporaryLot.strLotAlias
					 , SUM(TemporaryLot.dblPhysicalQty) AS dblPhysicalQty
					 , TemporaryLot.intItemUOMId
					 , TemporaryLot.strUOM, MAX(TemporaryLot.dblUnitCost) AS dblUnitCost
					 , AVG(TemporaryLot.dblWeightPerUnit) AS dblWeightPerUnit
					 , TemporaryLot.strWeightPerUnitUOM
					 , TemporaryLot.intPhysicalItemUOMId
					 , MAX(TemporaryLot.dtmReceiveDate) AS dtmReceiveDate
					 , MAX(TemporaryLot.dtmExpiryDate) AS dtmExpiryDate
					 , MAX(TemporaryLot.strVendorId) AS strVendorId
					 , MAX(TemporaryLot.strVendorLotNo) AS strVendorLotNo
					 , MAX(TemporaryLot.strGarden) AS strGarden
					 , TemporaryLot.intLocationId
					 , TemporaryLot.strLocationName
					 , '' AS strSubLocationName
					 , '' AS strStorageLocationName
					 , 0 AS intStorageLocationId
					 , MAX(TemporaryLot.strRemarks) AS strRemarks
					 , MAX(TemporaryLot.dblRiskScore) AS dblRiskScore
					 , MAX(TemporaryLot.dblConfigRatio) AS dblConfigRatio
					 , MAX(TemporaryLot.dblDensity) AS dblDensity
					 , MAX(TemporaryLot.dblScore) AS dblScore
					 , CAST(1 AS bit) AS ysnParentLot
					 , MAX(TemporaryLot.intCategoryId) AS intCategoryId 
					 , TemporaryLot.strPhysicalItemUOM
					 , MAX(TemporaryLot.strSecondaryStatus) strSecondaryStatus
					 , ISNULL(SUM(TemporaryLot.dblReservedQtyInTBS),0) AS dblReservedQtyInTBS
					 , TemporaryLot.dblNoOfPallet
					 , TemporaryLot.strAuctionCenter
					 , TemporaryLot.strSaleYear
					 , TemporaryLot.intSales
					 , TemporaryLot.dblTeaTaste
					 , TemporaryLot.dblTeaHue
					 , TemporaryLot.dblTeaIntensity
					 , TemporaryLot.dblTeaMouthFeel
					 , TemporaryLot.strSubCluster
					 , TemporaryLot.dblTeaAppearance
					 , TemporaryLot.dblTeaVolume
					 , TemporaryLot.intAge
					 , TemporaryLot.strProductType
					 , TemporaryLot.strBrandCode
					 , TemporaryLot.strTasterComments
					 , TemporaryLot.strGardenMark
					 , TemporaryLot.strLeafGrade
					 , TemporaryLot.strTeaOrigin
					 , TemporaryLot.strVendorLotNumber
					 , TemporaryLot.intUnitPerLayer
					 , TemporaryLot.intLayerPerPallet
					 , TemporaryLot.dblPickedQty
					 , TemporaryLot.strShortName
				INTO #tempParentLotByLocation
				FROM #tempLot AS TemporaryLot
				JOIN tblICParentLot AS ParentLot ON TemporaryLot.intParentLotId = ParentLot.intParentLotId 
				GROUP BY ParentLot.intParentLotId
					   , ParentLot.strParentLotNumber
					   , TemporaryLot.intItemId
					   , TemporaryLot.strItemNo
					   , TemporaryLot.strDescription
					   , TemporaryLot.strLotAlias
					   , TemporaryLot.intItemUOMId
					   , TemporaryLot.strUOM
					   , TemporaryLot.strWeightPerUnitUOM
					   , TemporaryLot.intPhysicalItemUOMId
					   , TemporaryLot.intLocationId
					   , TemporaryLot.strLocationName
					   , TemporaryLot.strPhysicalItemUOM
					   , TemporaryLot.dblNoOfPallet
					   , TemporaryLot.strAuctionCenter
					   , TemporaryLot.strSaleYear
					   , TemporaryLot.intSales
					   , TemporaryLot.dblTeaTaste
					   , TemporaryLot.dblTeaHue
					   , TemporaryLot.dblTeaIntensity
					   , TemporaryLot.dblTeaMouthFeel
					   , TemporaryLot.strSubCluster
					   , TemporaryLot.dblTeaAppearance
					   , TemporaryLot.dblTeaVolume
					   , TemporaryLot.intAge

				SELECT ParentLotLocation.*
					 , ISNULL(ReservedQty.dblReservedQty,0) AS dblReservedQty
					 , ISNULL((ISNULL(ParentLotLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(ParentLotLocation.dblReservedQtyInTBS, 0)), 0) AS dblAvailableQty
					 , ROUND((ISNULL((ISNULL(ParentLotLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(ParentLotLocation.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(ParentLotLocation.dblWeightPerUnit, 0) = 0 THEN 1 ELSE ParentLotLocation.dblWeightPerUnit END), 0) AS dblAvailableUnit
					 , ROUND((ISNULL((ISNULL(ParentLotLocation.dblPhysicalQty, 0) - ISNULL(ReservedQty.dblReservedQty, 0) - ISNULL(ParentLotLocation.dblReservedQtyInTBS, 0)), 0) / CASE WHEN ISNULL(ParentLotLocation.dblWeightPerUnit, 0) = 0 THEN 1 ELSE ParentLotLocation.dblWeightPerUnit END), 0) AS dblSelectedQty
					 , (ParentLotLocation.dblReservedQtyInTBS / ISNULL(NULLIF(ParentLotLocation.dblWeightPerUnit, 0), 1)) AS dblReservedQtyInTBSUnit
				FROM #tempParentLotByLocation AS ParentLotLocation 
				LEFT JOIN @tblReservedQty AS ReservedQty ON ParentLotLocation.intLotId = ReservedQty.intLotId
			END
	END