CREATE VIEW [dbo].[vyuICGetInventoryTradeFinanceLot]
AS

SELECT 
	tradeFinanceLot.intInventoryTradeFinanceLotId
	,tradeFinanceLot.intInventoryTradeFinanceId	
	,tradeFinanceLot.intLotId
	,tradeFinanceLot.strLotNumber
	,tradeFinanceLot.strLotAlias
	,tradeFinanceLot.intItemId
	,item.strItemNo
	,tradeFinanceLot.intSubLocationId
	,SubLocation.strSubLocationName
	,tradeFinanceLot.intStorageLocationId
	,strStorageLocationName = StorageLocation.strName
	,tradeFinanceLot.dblQuantity
	,tradeFinanceLot.dblGrossWeight
	,tradeFinanceLot.dblTareWeight
	,dblNetWeight = ISNULL(tradeFinanceLot.dblGrossWeight, 0) - ISNULL(tradeFinanceLot.dblTareWeight, 0)
	,tradeFinanceLot.dblTarePerQuantity
	,tradeFinanceLot.dblCost
	,tradeFinanceLot.intNoPallet
	,tradeFinanceLot.intUnitPallet
	,tradeFinanceLot.strContainerNo
	,tradeFinanceLot.strGarden
	,tradeFinanceLot.strMarkings
	,tradeFinanceLot.intOriginId
	,strOrigin = Origin.strCountry
	,tradeFinanceLot.intGradeId
	,strGrade = Grade.strDescription
	,tradeFinanceLot.intSeasonCropYear
	,tradeFinanceLot.dtmManufacturedDate
	,tradeFinanceLot.strCondition
	,tradeFinanceLot.dtmExpiryDate
	,tradeFinanceLot.intParentLotId
	,tradeFinanceLot.strParentLotNumber
	,tradeFinanceLot.strParentLotAlias
	,tradeFinanceLot.strCertificate
	,tradeFinanceLot.intProducerId
	,strProducer = Producer.strName	
	,tradeFinanceLot.strWarehouseRefNo
	,tradeFinanceLot.strCertificateId
	,tradeFinanceLot.strTrackingNumber
	,tradeFinanceLot.strCargoNo
	,tradeFinanceLot.strWarrantNo
	,tradeFinanceLot.intWarrantStatus
	,strWarrantStatus = warrantStatus.strWarrantStatus
	,tradeFinanceLot.intTradeFinanceId
	,tradeFinanceLot.strTradeFinanceNumber
	,tradeFinanceLot.intLotStatusId 
	,strLotStatus = lotStatus.strSecondaryStatus

	-- Lot Qty UOM
	,strItemUOM = ItemUOM.strUnitMeasure
	,tradeFinanceLot.intItemUOMId
	,ItemUOM.dblUnitQty	
	,ItemUOM.strUnitType
	,intQtyUOMDecimalPlaces = ItemUOM.intDecimalPlaces
	-- Lot Weight UOM
	,strWeightUOM = WeightUOM.strUnitMeasure
	,intWeightUOMId = tradeFinanceLot.intWeightUOMId	
	,dblWeightUnitQty = WeightUOM.dblUnitQty
	,strWeightUnitType = WeightUOM.strUnitType
	,intGrossUOMDecimalPlaces = WeightUOM.intDecimalPlaces

	,commodity.strCommodityCode
	,category.strCategoryCode
	,item.intCategoryId
	,item.intCommodityId

FROM 
	tblICInventoryTradeFinanceLot tradeFinanceLot INNER JOIN tblICInventoryTradeFinance tradeFinance 
		ON tradeFinance.intInventoryTradeFinanceId = tradeFinanceLot.intInventoryTradeFinanceId

	INNER JOIN tblICItem item
		ON item.intItemId = tradeFinanceLot.intItemId
	
	LEFT JOIN tblICLot lot
		ON lot.intLotId = tradeFinanceLot.intLotId		

	OUTER APPLY (
		SELECT TOP 1 
			ItemUOM.*
			,UOM.strUnitMeasure
			,UOM.strUnitType
			,UOM.intDecimalPlaces
		FROM 
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure UOM 
				ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE 
			ItemUOM.intItemUOMId = tradeFinanceLot.intItemUOMId
			AND ItemUOM.intItemId = tradeFinanceLot.intItemId
	) ItemUOM	

	OUTER APPLY (
		SELECT TOP 1 
			ItemUOM.*
			,UOM.strUnitMeasure
			,UOM.strUnitType
			,UOM.intDecimalPlaces
		FROM 
			tblICItemUOM ItemUOM INNER JOIN tblICUnitMeasure UOM 
				ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		WHERE 
			ItemUOM.intItemUOMId = tradeFinanceLot.intWeightUOMId
			AND ItemUOM.intItemId = tradeFinanceLot.intItemId
	) WeightUOM	

	LEFT JOIN tblICCategory category
		ON category.intCategoryId = item.intCategoryId

	LEFT JOIN tblICCommodity commodity
		ON commodity.intCommodityId = item.intCommodityId
	
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = tradeFinanceLot.intStorageLocationId

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = tradeFinanceLot.intSubLocationId

	LEFT JOIN tblSMCountry Origin 
		ON Origin.intCountryID = tradeFinanceLot.intOriginId

	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = tradeFinanceLot.intGradeId

	LEFT JOIN tblEMEntity Producer 
		ON Producer.intEntityId = tradeFinanceLot.intProducerId

	LEFT JOIN tblTRFTradeFinance tf
		ON tf.intTradeFinanceId = lot.intTradeFinanceId

	LEFT JOIN tblICWarrantStatus warrantStatus
		ON warrantStatus.intWarrantStatus = tradeFinanceLot.intWarrantStatus

	LEFT JOIN tblICLotStatus lotStatus
		ON lotStatus.intLotStatusId = tradeFinanceLot.intLotStatusId