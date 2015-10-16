CREATE VIEW vyuLGDeliveryOpenPickLotDetails
AS
SELECT PL.intPickLotDetailId,
  PL.intPickLotHeaderId,
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
  PL.dtmPickedDate,
  Lot.strLotNumber,
  Lot.strReceiptNumber,
  Lot.strMarkings,
  IM.strItemNo as strItemNo,
  IM.strDescription as strItemDescription,
  IM.strLotTracking as strLotTracking,
  IM.intCommodityId as intCommodityId,
  PLH.intSubLocationId,
  SubLocation.strSubLocationName,
  Lot.intStorageLocationId,
  Lot.strStorageLocation,
  CD.dblCashPrice,
  CD.strContractNumber as strSContractNumber,
  CD.intContractSeq as intSContractSeq,
  UM.strUnitMeasure as strLotUnitMeasure,
  UM.strUnitType as strLotUnitType,
  SaleUOM.strUnitMeasure as strSaleUnitMeasure,
  SaleUOM.strUnitType as strSaleUnitType
FROM tblLGPickLotDetail  PL
JOIN tblLGPickLotHeader  PLH ON PLH.intPickLotHeaderId  = PL.intPickLotHeaderId
LEFT JOIN vyuICGetLot    Lot ON Lot.intLotId    = PL.intLotId
LEFT JOIN tblICItem    IM ON IM.intItemId    = Lot.intItemId
JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = PL.intAllocationDetailId
LEFT JOIN vyuCTContractDetailView CD ON CD.intContractDetailId  = AD.intSContractDetailId
JOIN tblICUnitMeasure  UM ON UM.intUnitMeasureId   = PL.intLotUnitMeasureId
JOIN tblICUnitMeasure SaleUOM ON SaleUOM.intUnitMeasureId = PL.intSaleUnitMeasureId
JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PLH.intSubLocationId