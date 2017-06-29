CREATE VIEW vyuLGPickOpenInventoryLots
	AS 
SELECT *, (dblAllocatedQty + dblReservedQty) AS dblAllocReserved, (dblOriginalQty - (dblAllocatedQty + dblReservedQty)) AS dblBalance, 
CASE WHEN (((dblAllocatedQty + dblReservedQty) > 0) AND (dblUnPickedQty > (dblOriginalQty - (dblAllocatedQty + dblReservedQty)))) THEN (dblOriginalQty - (dblAllocatedQty + dblReservedQty))  ELSE dblUnPickedQty END AS dblAvailToSell,
dblNetWeight = (dblNetWeightFull / dblQty) * dblUnPickedQty,
dblGrossWeight = (dblGrossWeightFull / dblQty) * dblUnPickedQty,
dblTareWeight = (dblTareWeightFull / dblQty) * dblUnPickedQty
FROM (
SELECT Lot.intLotId
       , Lot.intItemId
	   , COM.intCommodityId
	   , COM.strCommodityCode AS strCommodity
       , Item.strItemNo
       , strItemDescription = Item.strDescription
       , Lot.intLocationId as intCompanyLocationId
       , Location.strLocationName
       , Lot.intItemLocationId
       , Lot.intItemUOMId
       , UOM.intUnitMeasureId
       , strItemUOM = UOM.strUnitMeasure
       , strItemUOMType = UOM.strUnitType
       , dblItemUOMConv = ItemUOM.dblUnitQty
       , Lot.strLotNumber
       , Lot.intSubLocationId
       , SubLocation.strSubLocationName
       , Lot.intStorageLocationId
       , strStorageLocation = StorageLocation.strName
       , Lot.dblQty
       , CASE WHEN Lot.dblQty > 0.0 THEN 
                           Lot.dblQty - IsNull((SELECT SUM (SR.dblQty) from tblICStockReservation SR Group By SR.intLotId, SR.ysnPosted Having Lot.intLotId = SR.intLotId AND SR.ysnPosted != 1), 0) 
                     ELSE 
                           0.0 END AS dblUnPickedQty
       , Lot.dblLastCost
       , Lot.dtmExpiryDate
       , Lot.strLotAlias
       , Lot.intLotStatusId
       , strLotStatus = LotStatus.strSecondaryStatus
       , strLotStatusType = LotStatus.strPrimaryStatus
       , Lot.intParentLotId
       , Lot.intSplitFromLotId
       , dblGrossWeightFull = IsNull((((ReceiptLot.dblTareWeight / ReceiptLot.dblQuantity) * Lot.dblQty) + Lot.dblWeight), 0.0)
       , dblTareWeightFull = IsNull(((ReceiptLot.dblTareWeight / ReceiptLot.dblQuantity) * Lot.dblQty), 0.0)
       , Lot.dblWeight as dblNetWeightFull
       , CASE WHEN isnull(Lot.intWeightUOMId,0) = 0 THEN Lot.intItemUOMId ELSE Lot.intWeightUOMId end intItemWeightUOMId
       , strWeightUOM = CASE WHEN isnull(Lot.intWeightUOMId,0) = 0 THEN UOM.strUnitMeasure ELSE WeightUOM.strUnitMeasure END
       , dblWeightUOMConv = ItemWeightUOM.dblUnitQty
       , Lot.dblWeightPerQty
       , OG.intCountryID intOriginId
       , Lot.strBOLNo
       , Lot.strVessel
       , Lot.strReceiptNumber
       , LC.strMarks as strMarkings
       , Lot.strNotes
       , Lot.intEntityVendorId
       , Lot.strVendorLotNo
       , Lot.strGarden
       , Lot.strContractNo
       , Lot.dtmManufacturedDate
       , Lot.ysnReleasedToWarehouse
       , Lot.ysnProduced
       , Lot.dtmDateCreated
       , Lot.intCreatedUserId
       , Lot.intConcurrencyId
       , Receipt.dtmReceiptDate
       , ReceiptLot.intInventoryReceiptItemLotId
       , ReceiptLot.strCondition
       , ReceiptItem.intSourceId
       , CTHeader.strContractNumber
       , CTDetail.intContractDetailId
       , CTDetail.intContractSeq
       , CTDetail.dblQuantity as dblOriginalQty
       , dblAllocatedQty = IsNull((SELECT SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL GROUP BY AL.intPContractDetailId HAVING AL.intPContractDetailId = CTDetail.intContractDetailId), 0)
       , dblReservedQty = IsNull((SELECT SUM(RS.dblReservedQuantity) FROM tblLGReservation RS GROUP BY RS.intContractDetailId HAVING RS.intContractDetailId = CTDetail.intContractDetailId), 0)
       , LC.strContainerNumber
       , L.strBLNumber
       , EY.strEntityName as strVendor
       , L.strLoadNumber
       , L.dtmPostedDate
       , Receipt.strWarehouseRefNo
	   , CTDetail.dblFutures
	   , CTDetail.dblBasis
	   , CTDetail.dblCashPrice
	   , CTDetail.intPriceItemUOMId
	   , CTDetail.dblTotalCost

FROM tblICLot Lot
JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
LEFT JOIN tblICInventoryReceiptItem      ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ReceiptItem.intSourceId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = ReceiptItem.intContainerId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId AND LDCL.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = LD.intPContractDetailId 
LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = CTDetail.intContractHeaderId
LEFT JOIN vyuCTEntity EY ON EY.intEntityId = CTHeader.intEntityId AND EY.strEntityType = (CASE WHEN CTHeader.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
LEFT JOIN tblICCommodity COM ON COM.intCommodityId = Item.intCommodityId
LEFT JOIN tblSMCompanyLocation Location ON Location.intCompanyLocationId = Lot.intLocationId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lot.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON	CA.intCommodityAttributeId	= Item.intOriginId	AND CA.strType = 'Origin'
LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
WHERE Lot.dblQty > 0 
) InvLots