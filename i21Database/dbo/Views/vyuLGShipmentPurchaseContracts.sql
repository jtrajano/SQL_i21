CREATE VIEW vyuLGShipmentPurchaseContracts
AS   
SELECT 
	   SCQ.intShipmentContractQtyId,
       SCQ.intShipmentId,
       S.intTrackingNumber,
	   S.ysnDirectShipment,
       SCQ.intContractDetailId,
       CH.intContractHeaderId,
       CT.intContractSeq,
       CH.intContractNumber,
       SCQ.intItemId,
       CT.intItemUOMId,
       S.intSubLocationId,
       intLocationId = S.intCompanyLocationId,
       SCQ.dblQuantity,
	   SCQ.dblReceivedQty,
       SCQ.dblGrossWt,
       SCQ.dblTareWt,
       SCQ.dblNetWt,
       dblCost = CT.dblCashPrice, 
       intWeightUOMId = S.intWeightUnitMeasureId,
       WTUOM.strUnitMeasure as strWeightUOM,
       intEntityVendorId = S.intVendorEntityId,
       EN.strName as strVendor,
       Item.strItemNo,
       strItemDescription = Item.strDescription,
       Item.strLotTracking,
       Item.strType,
       UOM.strUnitMeasure
       , dblItemUOMCF = ItemUOM.dblUnitQty
       ,intStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId),0)
       ,strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId)
       ,strStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId)
       ,dblStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId),0)
       ,SubLocation.strSubLocationName

FROM tblLGShipmentContractQty SCQ
JOIN tblLGShipment S ON S.intShipmentId = SCQ.intShipmentId
JOIN tblCTContractDetail CT ON CT.intContractDetailId = SCQ.intContractDetailId
JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
JOIN tblEntity EN ON EN.intEntityId = S.intVendorEntityId
JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SCQ.intUnitMeasureId
JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = S.intWeightUnitMeasureId
LEFT JOIN tblICItem Item ON Item.intItemId = SCQ.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = S.intSubLocationId

