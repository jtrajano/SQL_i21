CREATE VIEW vyuLGPickOpenInventoryLots
AS 
SELECT *, 
	dblAllocReserved = (dblAllocatedQty + dblReservedQty),
	dblBalance = (dblOriginalQty - (dblAllocatedQty + dblReservedQty)), 
	dblAvailToSell = CASE WHEN (((dblAllocatedQty + dblReservedQty) > 0) AND (dblUnPickedQty > (dblOriginalQty - (dblAllocatedQty + dblReservedQty)))) 
						THEN (dblOriginalQty - (dblAllocatedQty + dblReservedQty)) ELSE dblUnPickedQty END,
	dblNetWeight = (dblNetWeightFull / dblQty) * dblUnPickedQty,
	dblGrossWeight = (dblGrossWeightFull / dblQty) * dblUnPickedQty,
	dblTareWeight = (dblTareWeightFull / dblQty) * dblUnPickedQty
FROM (
	SELECT 
		intLotId = Lot.intLotId
       ,intItemId = Lot.intItemId
	   ,intCommodityId = COM.intCommodityId
	   ,strCommodity = COM.strCommodityCode
       ,strItemNo = Item.strItemNo
       ,strItemDescription = Item.strDescription
	   ,strItemType = Item.strType
	   ,strItemSpecification = CTDetail.strItemSpecification
	   ,strGrade = CG.strDescription
       ,intCompanyLocationId = Lot.intLocationId
       ,strLocationName = LOC.strLocationName
       ,intItemLocationId = Lot.intItemLocationId
       ,intItemUOMId = Lot.intItemUOMId
       ,intUnitMeasureId = UOM.intUnitMeasureId
       ,strItemUOM = UOM.strUnitMeasure
       ,strItemUOMType = UOM.strUnitType
       ,dblItemUOMConv = ItemUOM.dblUnitQty
       ,strLotNumber = Lot.strLotNumber
       ,intSubLocationId = Lot.intSubLocationId
       ,strSubLocationName = SubLocation.strSubLocationName
       ,intStorageLocationId = Lot.intStorageLocationId
       ,strStorageLocation = StorageLocation.strName
       ,dblQty = Lot.dblQty
       ,dblUnPickedQty = CASE WHEN Lot.dblQty > 0.0 THEN 
							  Lot.dblQty - IsNull((SELECT SUM (SR.dblQty) from tblICStockReservation SR 
													Group By SR.intLotId, SR.ysnPosted Having Lot.intLotId = SR.intLotId AND SR.ysnPosted != 1), 0) 
						 ELSE 0.0 END
       ,dblLastCost = Lot.dblLastCost
       ,dtmExpiryDate = Lot.dtmExpiryDate
       ,strLotAlias = Lot.strLotAlias
       ,intLotStatusId = Lot.intLotStatusId
       ,strLotStatus = LotStatus.strSecondaryStatus
       ,strLotStatusType = LotStatus.strPrimaryStatus
       ,intParentLotId = Lot.intParentLotId
       ,intSplitFromLotId = Lot.intSplitFromLotId
       ,dblGrossWeightFull = CASE WHEN Lot.ysnProduced <> 1 THEN
                                                       IsNull((((ReceiptLot.dblTareWeight / ReceiptLot.dblQuantity) * Lot.dblQty) + Lot.dblWeight), 0.0) 
                                                  ELSE
                                                       ISNULL(Lot.dblGrossWeight, ISNULL(Lot.dblWeight, 0.0))
                                                  END
       ,dblTareWeightFull = CASE WHEN Lot.ysnProduced <> 1 THEN
                                                      IsNull(((ReceiptLot.dblTareWeight / ReceiptLot.dblQuantity) * Lot.dblQty), 0.0)
                                               ELSE
                                                      0.0
                                               END
       ,dblNetWeightFull = Lot.dblWeight
       ,intItemWeightUOMId = CASE WHEN isnull(Lot.intWeightUOMId,0) = 0 THEN Lot.intItemUOMId ELSE Lot.intWeightUOMId END
       ,strWeightUOM = CASE WHEN isnull(Lot.intWeightUOMId,0) = 0 THEN UOM.strUnitMeasure ELSE WeightUOM.strUnitMeasure END
       ,dblWeightUOMConv = ItemWeightUOM.dblUnitQty
       ,dblWeightPerQty = Lot.dblWeightPerQty
       ,intOriginId = OG.intCountryID
	   ,strOrigin = OG.strCountry
       ,strBOLNo = Lot.strBOLNo
       ,strVessel = Lot.strVessel
	   ,strDestinationCity = L.strDestinationCity
	   ,dtmETAPOL = L.dtmETAPOL
	   ,dtmETAPOD = L.dtmETAPOD
       ,strReceiptNumber = Lot.strReceiptNumber
       ,strMarkings = LC.strMarks
       ,strNotes = Lot.strNotes
       ,intEntityVendorId = Lot.intEntityVendorId
       ,strVendorLotNo = Lot.strVendorLotNo
       ,strGarden = Lot.strGarden
       ,strContractNo = Lot.strContractNo
       ,dtmManufacturedDate = Lot.dtmManufacturedDate
       ,ysnReleasedToWarehouse = Lot.ysnReleasedToWarehouse
       ,ysnProduced = Lot.ysnProduced
       ,dtmDateCreated = Lot.dtmDateCreated
       ,intCreatedUserId = Lot.intCreatedUserId
       ,intConcurrencyId = Lot.intConcurrencyId
       ,dtmReceiptDate = Receipt.dtmReceiptDate
       ,intInventoryReceiptItemLotId = ReceiptLot.intInventoryReceiptItemLotId
       ,strCondition = Lot.strCondition
       ,intSourceId = ReceiptItem.intSourceId
       ,strContractNumber = CTHeader.strContractNumber
	   ,strContractBasis = CB.strContractBasis
	   ,strPricingType = PT.strPricingType
       ,intContractDetailId = CTDetail.intContractDetailId
       ,intContractSeq = CTDetail.intContractSeq
       ,dblOriginalQty = CTDetail.dblQuantity
	   ,strOriginalQtyUOM = UOM2.strUnitMeasure
       ,dblAllocatedQty = IsNull((SELECT SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL GROUP BY AL.intPContractDetailId HAVING AL.intPContractDetailId = CTDetail.intContractDetailId), 0)
       ,dblReservedQty = IsNull((SELECT SUM(RS.dblReservedQuantity) FROM tblLGReservation RS GROUP BY RS.intContractDetailId HAVING RS.intContractDetailId = CTDetail.intContractDetailId), 0)
	   ,strContainerNumber = LC.strContainerNumber
       ,strBLNumber = L.strBLNumber
       ,strVendor = EY.strName 
       ,strLoadNumber = L.strLoadNumber
       ,dtmPostedDate = L.dtmPostedDate
       ,strWarehouseRefNo = ISNULL(Receipt.strWarehouseRefNo,Lot.strWarehouseRefNo)
	   ,dblFutures = CTDetail.dblFutures
	   ,dblBasis = CTDetail.dblBasis
	   ,dblCashPrice = CTDetail.dblCashPrice
	   ,intPriceItemUOMId = CTDetail.intPriceItemUOMId
	   ,strPriceBasis = CAST(BC.strCurrency as VARCHAR(100)) + '/' + CAST(BUM.strUnitMeasure as VARCHAR(100))
	   ,dblTotalCost = CTDetail.dblTotalCost
	   ,intWeightItemUOMId = COALESCE(Lot.intWeightUOMId, LD.intWeightItemUOMId, dbo.fnGetMatchingItemUOMId(LD.intItemId, L.intWeightUnitMeasureId), CTDetail.intNetWeightUOMId)
	   ,strPosition = PO.strPosition
	   ,intBookId = CTDetail.intBookId
	   ,strBook = BO.strBook COLLATE Latin1_General_CI_AS
	   ,intSubBookId = CTDetail.intSubBookId
	   ,strSubBook = SB.strSubBook COLLATE Latin1_General_CI_AS 
	   ,intCropYear = CAST (0 AS int)
	   ,intFutureMarketId = FM.intFutureMarketId
	   ,intDefaultCurrencyId = C.intCurrencyID
	   ,strDefaultCurrency = C.strCurrency
	   ,intDefaultUOMId = UM.intUnitMeasureId
	   ,strDefaultUOM = UM.strUnitMeasure
	   ,intDefaultItemUOMId = IU.intItemUOMId
	   ,strCropYear = '' COLLATE Latin1_General_CI_AS 
	   ,strProducer = '' COLLATE Latin1_General_CI_AS
	   ,strCertification = '' COLLATE Latin1_General_CI_AS
	   ,strCertificationId = '' COLLATE Latin1_General_CI_AS
	   ,intCustomerEntityId = LD.intCustomerEntityId
	   ,strCustomer = Customer.strName
	FROM tblICLot Lot
		LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
		LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
		LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ReceiptItem.intLineNo 
		LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = ReceiptItem.intOrderId
		LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ReceiptItem.intSourceId
		LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = ReceiptItem.intContainerId AND ISNULL(LC.ysnRejected, 0) <> 1
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId AND LDCL.intLoadContainerId = LC.intLoadContainerId
		LEFT JOIN tblEMEntity EY ON EY.intEntityId = CTHeader.intEntityId 
		LEFT JOIN tblEMEntityType ET ON ET.intEntityId = EY.intEntityId AND ET.strType = (CASE WHEN CTHeader.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)  
		LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
		LEFT JOIN tblICCommodity COM ON COM.intCommodityId = Item.intCommodityId
		LEFT JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = Lot.intLocationId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = Lot.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = Lot.intSubLocationId
		LEFT JOIN tblICStorageLocation StorageLocation ON StorageLocation.intStorageLocationId = Lot.intStorageLocationId
		LEFT JOIN tblICLotStatus LotStatus ON LotStatus.intLotStatusId = Lot.intLotStatusId
		LEFT JOIN tblICItemUOM ItemWeightUOM ON ItemWeightUOM.intItemUOMId = Lot.intWeightUOMId
		LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = ItemWeightUOM.intUnitMeasureId
		LEFT JOIN tblICCommodityAttribute CA ON	CA.intCommodityAttributeId = Item.intOriginId AND CA.strType = 'Origin'
		LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
		LEFT JOIN tblICCommodityAttribute CG ON	CG.intCommodityAttributeId = Item.intGradeId AND CG.strType = 'Grade'
		LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CTHeader.intContractBasisId
		LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CTHeader.intPricingTypeId
		LEFT JOIN tblCTPosition PO ON PO.intPositionId = L.intPositionId
		LEFT JOIN tblCTBook BO ON BO.intBookId = CTDetail.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CTDetail.intSubBookId
		LEFT JOIN tblICItemUOM CTDetailUOM ON CTDetailUOM.intItemUOMId = CTDetail.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM2 ON UOM2.intUnitMeasureId = CTDetailUOM.intUnitMeasureId
		LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = COM.intFutureMarketId
		LEFT JOIN tblSMCurrency C ON C.intCurrencyID = FM.intCurrencyId
		LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = FM.intUnitMeasureId
		LEFT JOIN tblICItemUOM IU ON IU.intUnitMeasureId = UM.intUnitMeasureId AND IU.intItemId = Item.intItemId
		LEFT JOIN tblSMCurrency BC ON BC.intCurrencyID = CTDetail.intBasisCurrencyId
		LEFT JOIN tblICItemUOM BIU ON BIU.intItemUOMId = CTDetail.intBasisUOMId
		LEFT JOIN tblICUnitMeasure BUM ON BUM.intUnitMeasureId = BIU.intUnitMeasureId
		LEFT JOIN tblCTContractDetail SCTDetail ON SCTDetail.intContractDetailId = LD.intSContractDetailId
		LEFT JOIN tblCTContractHeader SCTHeader ON SCTHeader.intContractHeaderId = SCTDetail.intContractHeaderId
		LEFT JOIN tblEMEntity Customer ON Customer.intEntityId = LD.intCustomerEntityId
	WHERE Lot.dblQty > 0 
	) InvLots
GO