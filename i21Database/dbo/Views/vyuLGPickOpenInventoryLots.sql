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
	   ,strBundleItemNo = ISNULL(ConBundle.strItemNo, Bundle.strBundleItemNo)
       ,strLotNumber = Lot.strLotNumber
       ,intSubLocationId = Lot.intSubLocationId
       ,strSubLocationName = SubLocation.strSubLocationName
       ,intStorageLocationId = Lot.intStorageLocationId
       ,strStorageLocation = StorageLocation.strName
       ,dblQty = Lot.dblQty
       ,dblUnPickedQty = CASE WHEN Lot.dblQty > 0.0 THEN 
							  Lot.dblQty - IsNull(SR.dblReservedQty, 0) 
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
	   ,dtmETSPOL = L.dtmETSPOL
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
	   ,strTerm = Term.strTerm
	   ,strPricingType = PT.strPricingType
       ,intContractDetailId = CTDetail.intContractDetailId
       ,intContractSeq = CTDetail.intContractSeq
	   ,dtmStartDate = CTDetail.dtmStartDate
	   ,dtmEndDate = CTDetail.dtmEndDate
       ,dblOriginalQty = CTDetail.dblQuantity
	   ,strOriginalQtyUOM = UOM2.strUnitMeasure
       ,dblAllocatedQty = ISNULL(AL.dblAllocatedQty, 0)
       ,dblReservedQty = ISNULL(SR.dblReservedQty, 0) 
	   ,strContainerNumber = LC.strContainerNumber
       ,strBLNumber = L.strBLNumber
	   ,dtmBLDate = L.dtmBLDate
       ,strVendor = EY.strName 
	   ,intLoadId = L.intLoadId
       ,strLoadNumber = L.strLoadNumber
	   ,strExternalShipmentNumber = L.strExternalShipmentNumber
       ,dtmPostedDate = L.dtmPostedDate
       ,strWarehouseRefNo = ISNULL(Receipt.strWarehouseRefNo,Lot.strWarehouseRefNo)
	   ,dblFutures = CTDetail.dblFutures
	   ,dblBasis = CTDetail.dblBasis
	   ,dblCashPrice = ISNULL(AD.dblSeqPrice, AD.dblSeqPartialPrice)
	   ,intPriceItemUOMId = CTDetail.intPriceItemUOMId
	   ,strPriceBasis = CAST(BC.strCurrency as VARCHAR(100)) + '/' + CAST(BUM.strUnitMeasure as VARCHAR(100))
	   ,dblTotalCost = CTDetail.dblTotalCost
	   ,intWeightItemUOMId = LD.intWeightItemUOMId
	   ,strPosition = PO.strPosition
	   ,intBookId = ISNULL(Lot.intBookId, CTDetail.intBookId)
	   ,strBook = ISNULL(LBO.strBook, BO.strBook)
	   ,intSubBookId = ISNULL(Lot.intSubBookId, CTDetail.intSubBookId)
	   ,strSubBook = ISNULL(LSB.strSubBook, SB.strSubBook)
	   ,intCropYear = CAST (0 AS int)
	   ,intFutureMarketId = FM.intFutureMarketId
	   ,intDefaultCurrencyId = C.intCurrencyID
	   ,strDefaultCurrency = C.strCurrency
	   ,ysnSubCurrency = C.ysnSubCurrency
	   ,intSubCurrencyCents = C.intCent
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
		LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intLotId = ISNULL(Lot.intSplitFromLotId, Lot.intLotId)
		LEFT JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
		LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		LEFT JOIN tblCTContractDetail CTDetail ON CTDetail.intContractDetailId = ReceiptItem.intLineNo 
		LEFT JOIN tblCTContractHeader CTHeader ON CTHeader.intContractHeaderId = ReceiptItem.intOrderId
		LEFT JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CTDetail.intContractDetailId
		LEFT JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = ReceiptItem.intSourceId
		LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = ReceiptItem.intContainerId AND ISNULL(LC.ysnRejected, 0) <> 1
		LEFT JOIN tblEMEntity EY ON EY.intEntityId = CTHeader.intEntityId   
		LEFT JOIN tblICItem Item ON Item.intItemId = Lot.intItemId
		LEFT JOIN tblICCommodity COM ON COM.intCommodityId = Item.intCommodityId
		LEFT JOIN tblICItem ConBundle ON ConBundle.intItemId = CTDetail.intItemBundleId
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
		LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CTHeader.intFreightTermId
		LEFT JOIN tblSMTerm Term ON Term.intTermID = CTHeader.intTermId
		LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CTHeader.intPricingTypeId
		LEFT JOIN tblCTPosition PO ON PO.intPositionId = L.intPositionId
		LEFT JOIN tblCTBook BO ON BO.intBookId = CTDetail.intBookId
		LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CTDetail.intSubBookId
		LEFT JOIN tblCTBook LBO ON LBO.intBookId = Lot.intBookId
		LEFT JOIN tblCTSubBook LSB ON LSB.intSubBookId = Lot.intSubBookId
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
		OUTER APPLY (SELECT TOP 1 strBundleItemNo = BI.strItemNo FROM tblICItem BI 
						INNER JOIN tblICItemBundle IB ON IB.intItemId = BI.intItemId
					 WHERE IB.intBundleItemId = Item.intItemId) Bundle
		OUTER APPLY (SELECT dblReservedQty = SUM(SR.dblQty) from tblICStockReservation SR
					WHERE SR.intLotId = Lot.intLotId AND SR.ysnPosted <> 1) SR
		OUTER APPLY (SELECT dblAllocatedQty = SUM(AL.dblPAllocatedQty) FROM tblLGAllocationDetail AL 
					WHERE AL.intPContractDetailId = CTDetail.intContractDetailId) AL
	WHERE Lot.dblQty > 0 
	) InvLots
GO