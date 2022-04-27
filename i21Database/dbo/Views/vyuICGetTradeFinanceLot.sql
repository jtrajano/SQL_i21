CREATE VIEW [dbo].[vyuICGetTradeFinanceLot]
AS

SELECT 
	lot.intLotId
	,lot.strLotNumber
	,lot.strLotAlias
	,lot.intItemId
	,item.strItemNo
	,lot.intSubLocationId
	,SubLocation.strSubLocationName
	,lot.intStorageLocationId
	,strStorageLocationName = StorageLocation.strName
	,dblQuantity = lot.dblQty
	,dblGrossWeight =  ISNULL(lot.dblWeight, 0) + ISNULL(lot.dblTare, 0) --lot.dblGrossWeight
	,dblTareWeight = lot.dblTare
	,dblNetWeight = lot.dblWeight --ISNULL(lot.dblGrossWeight, 0) - ISNULL(lot.dblTare, 0)
	,dblTarePerQuantity = lot.dblTarePerQty
	,dblCost = lot.dblLastCost
	,lot.intNoPallet
	,lot.intUnitPallet
	,lot.strContainerNo
	,lot.strGarden
	,lot.strMarkings
	,lot.intOriginId
	,strOrigin = Origin.strCountry
	,lot.intGradeId
	,strGrade = Grade.strDescription
	,lot.intSeasonCropYear
	,lot.dtmManufacturedDate
	,lot.strCondition
	,lot.dtmExpiryDate
	,lot.intParentLotId
	,parentLot.strParentLotNumber
	,parentLot.strParentLotAlias
	,lot.strCertificate
	,lot.intProducerId
	,strProducer = Producer.strName	
	,lot.strWarehouseRefNo
	,lot.strCertificateId
	,lot.strTrackingNumber
	,lot.strCargoNo
	,lot.strWarrantNo
	,lot.intWarrantStatus
	,strWarrantStatus = warrantStatus.strWarrantStatus
	,lot.intTradeFinanceId
	,tf.strTradeFinanceNumber
	,lot.intLotStatusId 
	,strLotStatus = lotStatus.strSecondaryStatus

	-- Lot Qty UOM
	,strItemUOM = ItemUOM.strUnitMeasure
	,lot.intItemUOMId
	,ItemUOM.dblUnitQty	
	,ItemUOM.strUnitType
	,intQtyUOMDecimalPlaces = ItemUOM.intDecimalPlaces
	-- Lot Weight UOM
	,strWeightUOM = WeightUOM.strUnitMeasure
	,intWeightUOMId = lot.intWeightUOMId	
	,dblWeightUnitQty = WeightUOM.dblUnitQty
	,strWeightUnitType = WeightUOM.strUnitType
	,intGrossUOMDecimalPlaces = WeightUOM.intDecimalPlaces

	,commodity.strCommodityCode
	,category.strCategoryCode
	,item.intCategoryId
	,item.intCommodityId

	,lot.intOwnershipType
FROM 
	tblICItem item

	INNER JOIN tblICLot lot
		ON lot.intItemId = item.intItemId 

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
			ItemUOM.intItemUOMId = lot.intItemUOMId
			AND ItemUOM.intItemId = lot.intItemId
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
			ItemUOM.intItemUOMId = lot.intWeightUOMId
			AND ItemUOM.intItemId = lot.intItemId
	) WeightUOM	

	LEFT JOIN tblICCategory category
		ON category.intCategoryId = item.intCategoryId

	LEFT JOIN tblICCommodity commodity
		ON commodity.intCommodityId = item.intCommodityId
	
	LEFT JOIN tblICStorageLocation StorageLocation 
		ON StorageLocation.intStorageLocationId = lot.intStorageLocationId

	LEFT JOIN tblSMCompanyLocationSubLocation SubLocation 
		ON SubLocation.intCompanyLocationSubLocationId = lot.intSubLocationId

	LEFT JOIN tblSMCountry Origin 
		ON Origin.intCountryID = lot.intOriginId

	LEFT JOIN tblICCommodityAttribute Grade 
		ON Grade.intCommodityAttributeId = lot.intGradeId

	LEFT JOIN tblEMEntity Producer 
		ON Producer.intEntityId = lot.intProducerId

	LEFT JOIN tblTRFTradeFinance tf
		ON tf.intTradeFinanceId = lot.intTradeFinanceId

	LEFT JOIN tblICWarrantStatus warrantStatus
		ON warrantStatus.intWarrantStatus = lot.intWarrantStatus

	LEFT JOIN tblICLotStatus lotStatus
		ON lotStatus.intLotStatusId = lot.intLotStatusId

	LEFT JOIN tblICParentLot parentLot
		ON parentLot.intParentLotId = lot.intParentLotId