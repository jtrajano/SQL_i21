CREATE VIEW [dbo].[vyuSCTicketInventoryTransferView]
	AS SELECT 
	SC.intTicketId
	, SC.strTicketNumber
	, SC.strLoadNumber
	, SC.intEntityId
	, ICTI.intInventoryTransferId
	, ICTI.intInventoryTransferDetailId
	, ICTI.intFromLocationId
	, ICTI.intToLocationId
	, ICTI.strTransferNo
	, ICTI.intSourceId
	, ICTI.strSourceNumber
	, ICTI.intItemId
	, ICTI.strItemNo
	, ICTI.strItemDescription
	, ICTI.strLotTracking
	, ICTI.intCommodityId
	, ICTI.strLotNumber
	, ICTI.intLifeTime
	, ICTI.strLifeTimeType
	, ICTI.intFromSubLocationId
	, ICTI.strFromSubLocationName
	, ICTI.intToSubLocationId
	, ICTI.strToSubLocationName
	, ICTI.intFromStorageLocationId
	, ICTI.strFromStorageLocationName
	, ICTI.intToStorageLocationId
	, ICTI.strToStorageLocationName
	, ICTI.intItemUOMId
	, ICTI.strUnitMeasure
	, ICTI.dblItemUOMCF
	, ICTI.intWeightUOMId
	, ICTI.strWeightUOM
	, ICTI.dblWeightUOMCF
	, ICTI.strTaxCode
	, ICTI.strAvailableUOM
	, ICTI.dblLastCost
	, ICTI.dblOnHand
	, ICTI.dblOnOrder
	, ICTI.dblReservedQty
	, ICTI.dblAvailableQty
	, ICTI.dblQuantity
	, ICTI.intOwnershipType
	, ICTI.strOwnershipType
	, ICTI.ysnPosted
	FROM tblSCTicket SC 
	INNER JOIN tblICInventoryTransfer ICT ON SC.intInventoryTransferId = ICT.intInventoryTransferId
	INNER JOIN vyuICGetInventoryTransferDetail ICTI ON SC.strTicketNumber = ICTI.strSourceNumber
	LEFT JOIN tblGRStorageType GRST ON GRST.strStorageTypeCode = SC.strDistributionOption