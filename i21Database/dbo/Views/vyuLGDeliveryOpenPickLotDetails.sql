CREATE VIEW vyuLGDeliveryOpenPickLotDetails
AS
SELECT PL.intPickLotDetailId,
  PL.intPickLotHeaderId,
  PLH.strCustomer,
  PLH.intCustomerEntityId,
  PLH.intReferenceNumber,
  PLH.dtmPickDate,
  PLH.strCommodity,
  PLH.strLocationName,
  PLH.intCompanyLocationId,
  PLH.strWeightUnitMeasure,
  PL.intAllocationDetailId,
  PL.intLotId,
  PL.dblSalePickedQty,
  PL.dblLotPickedQty,
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
  IM.intItemId,
  Lot.intItemUOMId,
  IM.strItemNo,
  IM.strDescription as strItemDescription,
  IM.strLotTracking as strLotTracking,
  IM.intCommodityId as intCommodityId,
  PLH.intSubLocationId,
  SubLocation.strSubLocationName,
  Lot.intStorageLocationId,
  Lot.strStorageLocation,
  PCD.intContractHeaderId as intPContractHeaderId,
  PCD.intContractDetailId as intPContractDetailId,
  PCD.strContractNumber as strPContractNumber,
  PCD.intContractSeq as intPContractSeq,
  SCD.dblCashPrice,
  SCD.dblDetailQuantity,
  SCD.intContractHeaderId as intSContractHeaderId,
  SCD.intContractDetailId as intSContractDetailId,
  SCD.strContractNumber as strSContractNumber,
  SCD.intContractSeq as intSContractSeq,
  UM.strUnitMeasure as strLotUnitMeasure,
  UM.strUnitType as strLotUnitType,
  SaleUOM.strUnitMeasure as strSaleUnitMeasure,
  SaleUOM.strUnitType as strSaleUnitType,
  Lot.intOwnershipType,
  Lot.strOwnershipType,
  Lot.dblAvailableQty,
  dblItemUOMConv = (SELECT IU.dblUnitQty from tblICItemUOM IU WHERE IU.intItemUOMId = Lot.intItemUOMId),
  dblWeightItemUOMConv = (SELECT IU.dblUnitQty from tblICItemUOM IU WHERE IU.intItemId = IM.intItemId AND IU.intUnitMeasureId=PL.intWeightUnitMeasureId),
  PLH.strCustomerNo

FROM tblLGPickLotDetail  PL
JOIN vyuLGDeliveryOpenPickLots PLH ON PLH.intPickLotHeaderId  = PL.intPickLotHeaderId
JOIN vyuICGetLot    Lot ON Lot.intLotId    = PL.intLotId
JOIN tblICItem    IM ON IM.intItemId    = Lot.intItemId
JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = PL.intAllocationDetailId
JOIN vyuCTContractDetailView PCD ON PCD.intContractDetailId  = AD.intPContractDetailId
JOIN vyuCTContractDetailView SCD ON SCD.intContractDetailId  = AD.intSContractDetailId
JOIN tblICUnitMeasure  UM ON UM.intUnitMeasureId   = PL.intLotUnitMeasureId
JOIN tblICUnitMeasure SaleUOM ON SaleUOM.intUnitMeasureId = PL.intSaleUnitMeasureId
JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PLH.intSubLocationId
WHERE PL.intPickLotDetailId NOT IN (SELECT IsNull(LD.intPickLotDetailId, 0) FROM tblLGLoadDetail LD)