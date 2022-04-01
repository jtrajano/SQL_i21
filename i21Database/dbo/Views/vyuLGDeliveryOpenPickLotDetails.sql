CREATE VIEW vyuLGDeliveryOpenPickLotDetails
AS
SELECT DISTINCT PL.intPickLotDetailId,
  PL.intPickLotHeaderId,
  PLH.strCustomer,
  PLH.intCustomerEntityId,
  PLH.[strPickLotNumber],
  PLH.strType,
  PLH.dtmPickDate,
  PLH.strCommodity,
  PLH.strLocationName,
  PLH.intCompanyLocationId,
  PLH.strWeightUnitMeasure,
  PLH.intBookId,
  PLH.strBook,
  PLH.intSubBookId,
  PLH.strSubBook,
  PL.intAllocationDetailId,
  PL.intLotId,
  PL.intContainerId,
  PL.dblSalePickedQty,
  PL.dblLotPickedQty,
  dblLotPickedQtyFromParent = PL.dblLotPickedQty - ISNULL(PCPL.dblLotPickedQtyFromParent, 0),
  PL.intSaleUnitMeasureId,
  PL.intLotUnitMeasureId,
  PL.dblGrossWt,
  PL.dblTareWt,
  PL.dblNetWt,
  PL.intWeightUnitMeasureId,
  intWeightItemUOMId = (SELECT IU.intItemUOMId from tblICItemUOM IU WHERE IU.intItemId = IM.intItemId AND IU.intUnitMeasureId=PL.intWeightUnitMeasureId),
  PL.dtmPickedDate,
  Lot.strLotNumber,
  Lot.strReceiptNumber,
  Lot.strMarkings,
  Con.strContainerNumber,
  strContainerID = Con.strContainerNumber, --TO BE REPLACED BY CONTAINER Unique ID
  IM.intItemId,
  Lot.intItemUOMId,
  IM.strItemNo,
  IM.strDescription as strItemDescription,
  IM.strLotTracking as strLotTracking,
  IM.intCommodityId as intCommodityId,
  intSubLocationId = ISNULL(PLH.intSubLocationId, Lot.intSubLocationId),
  strSubLocationName = ISNULL(SubLocation.strSubLocationName, Lot.strSubLocationName),
  Lot.intStorageLocationId,
  Lot.strStorageLocation,
  PCD.intContractHeaderId as intPContractHeaderId,
  PCD.intContractDetailId as intPContractDetailId,
  PCH.strContractNumber as strPContractNumber,
  PCD.intContractSeq as intPContractSeq,
  SCD.dblCashPrice,
  SCD.dblQuantity as dblDetailQuantity,
  SCD.intContractHeaderId as intSContractHeaderId,
  SCD.intContractDetailId as intSContractDetailId,
  SCH.strContractNumber as strSContractNumber,
  SCD.intContractSeq as intSContractSeq,
  UM.strUnitMeasure as strLotUnitMeasure,
  UM.strUnitType as strLotUnitType,
  SaleUOM.strUnitMeasure as strSaleUnitMeasure,
  SaleUOM.strUnitType as strSaleUnitType,
  Lot.intOwnershipType,
  Lot.strOwnershipType,
  Lot.dblAvailableQty,
  Lot.dblWeightPerQty AS dblWeightPerUnit,
  dblItemUOMConv = (SELECT IU.dblUnitQty from tblICItemUOM IU WHERE IU.intItemUOMId = Lot.intItemUOMId),
  dblWeightItemUOMConv = (SELECT IU.dblUnitQty from tblICItemUOM IU WHERE IU.intItemId = IM.intItemId AND IU.intUnitMeasureId=PL.intWeightUnitMeasureId),
  PLH.strCustomerNo, 
  Receipt.strWarehouseRefNo,
  L.strLoadNumber,
  ysnDelivered = CONVERT(BIT,(CASE WHEN ISNULL(L.strLoadNumber,'') = '' THEN 0 ELSE 1 END)),
  strPriceCurrency = SCurrency.strCurrency,
  dblSalesPrice = SCD.dblCashPrice,
  strPriceUOM = SUOM.strUnitMeasure,
  dblSalesAmount = CASE WHEN SCurrency.ysnSubCurrency <> 1 THEN
						PL.dblNetWt * SCD.dblCashPrice * dbo.fnLGGetItemUnitConversion(SCD.intItemId, (SELECT Top(1) IU.intItemUOMId from tblICItemUOM IU WHERE IU.intItemId = SCD.intItemId AND IU.intUnitMeasureId=PL.intWeightUnitMeasureId), SUOM.intUnitMeasureId)
					ELSE
						PL.dblNetWt * SCD.dblCashPrice * dbo.fnLGGetItemUnitConversion(SCD.intItemId, (SELECT Top(1) IU.intItemUOMId from tblICItemUOM IU WHERE IU.intItemId = SCD.intItemId AND IU.intUnitMeasureId=PL.intWeightUnitMeasureId), SUOM.intUnitMeasureId) / 100
					END,
  strSplitFrom = PPL.strPickLotNumber,
  strAllocationNumber = AH.strAllocationNumber,
  strAllocationDetailRefNo = AD.strAllocationDetailRefNo,
  PLH.dblGAShrinkFactor,
  PLH.strOrigin,
  PLH.strProductType,
  PLH.strGrade,
  PLH.strRegion,
  PLH.strSeason,
  PLH.strClass,
  PLH.strProductLine,
  PLH.strMarketValuation
FROM tblLGPickLotDetail  PL
JOIN vyuLGDeliveryOpenPickLotHeader PLH ON PLH.intPickLotHeaderId  = PL.intPickLotHeaderId
JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = PL.intAllocationDetailId
JOIN tblLGAllocationHeader AH ON AH.intAllocationHeaderId = AD.intAllocationHeaderId
JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = AD.intPContractDetailId
JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = AD.intSContractDetailId
JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
JOIN tblICUnitMeasure  UM ON UM.intUnitMeasureId   = PL.intLotUnitMeasureId
JOIN tblICUnitMeasure SaleUOM ON SaleUOM.intUnitMeasureId = PL.intSaleUnitMeasureId
JOIN tblSMCurrency SCurrency ON SCurrency.intCurrencyID = SCD.intCurrencyId
JOIN tblICItemUOM SItemUOM ON SItemUOM.intItemUOMId = SCD.intPriceItemUOMId
JOIN tblICUnitMeasure SUOM ON SUOM.intUnitMeasureId = SItemUOM.intUnitMeasureId
JOIN tblICItem IM ON IM.intItemId = SCD.intItemId 
LEFT JOIN tblLGLoadContainer Con ON Con.intLoadContainerId = PL.intContainerId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PLH.intSubLocationId
LEFT JOIN vyuICGetLot Lot ON Lot.intLotId = PL.intLotId
LEFT JOIN tblICInventoryReceiptItemLot ReceiptLot ON ReceiptLot.intParentLotId = Lot.intParentLotId
LEFT JOIN tblICInventoryReceiptItem	ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = ReceiptLot.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
LEFT JOIN tblLGLoadDetail LD ON LD.intPickLotDetailId = PL.intPickLotDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGPickLotHeader PPL ON PPL.intPickLotHeaderId = PLH.intParentPickLotHeaderId
OUTER APPLY 
	(SELECT dblLotPickedQtyFromParent = SUM(PL1.dblLotPickedQty) 
	 FROM tblLGPickLotDetail PL1
	 LEFT JOIN tblLGPickLotHeader PH1 ON PH1.intPickLotHeaderId = PL1.intPickLotHeaderId
	 WHERE PH1.intParentPickLotHeaderId = PLH.intPickLotHeaderId
		AND PH1.intType = 1
		AND PL1.intLotId = PL.intLotId 
	) PCPL