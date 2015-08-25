CREATE VIEW vyuLGShipmentContainerPurchaseContracts
AS   
SELECT 
	   SC.intShipmentBLContainerContractId,
	   SC.intShipmentContractQtyId,
       SC.intShipmentId,
	   SC.intShipmentBLId,
	   SC.intShipmentBLContainerId,
       S.intTrackingNumber,
	   S.ysnDirectShipment,
       SCQ.intContractDetailId,
       CH.intContractHeaderId,
       CT.intContractSeq,
       CH.strContractNumber,
	   Item.intCommodityId,
       SCQ.intItemId,
       CT.intItemUOMId,
       S.intSubLocationId,
       intLocationId = S.intCompanyLocationId,
       SC.dblQuantity,
	   IsNull(SC.dblReceivedQty, 0) as dblReceivedQty,
       dblGrossWt = (Container.dblGrossWt / Container.dblQuantity) * SC.dblQuantity,
       dblTareWt = (Container.dblTareWt / Container.dblQuantity) * SC.dblQuantity,
       dblNetWt = (Container.dblNetWt / Container.dblQuantity) * SC.dblQuantity,
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
	   , BL.strBLNumber
	   , Container.strContainerNumber
	   , Container.strLotNumber
	   , Container.strMarks
	   , Container.strOtherMarks
	   , Container.strSealNumber
	   , ContType.strContainerType

FROM tblLGShipmentBLContainerContract SC
LEFT JOIN tblLGShipmentContractQty SCQ ON SCQ.intShipmentContractQtyId = SC.intShipmentContractQtyId
JOIN tblLGShipment S ON S.intShipmentId = SC.intShipmentId
JOIN tblLGShipmentBL BL ON BL.intShipmentBLId = SC.intShipmentBLId
LEFT JOIN tblLGShipmentBLContainer Container ON Container.intShipmentBLContainerId = SC.intShipmentBLContainerId
LEFT JOIN tblLGContainerType ContType ON ContType.intContainerTypeId = Container.intContainerTypeId
JOIN tblCTContractDetail CT ON CT.intContractDetailId = SCQ.intContractDetailId
JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CT.intContractHeaderId
JOIN tblEntity EN ON EN.intEntityId = S.intVendorEntityId
JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SC.intUnitMeasureId
JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = S.intWeightUnitMeasureId
LEFT JOIN tblICItem Item ON Item.intItemId = SCQ.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = S.intSubLocationId
