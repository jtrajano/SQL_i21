CREATE VIEW vyuLGShipmentPurchaseContracts
AS   
SELECT t1.*, 
		dblCashPriceInWeightUOM = IsNull(dbo.fnCTConvertQtyToTargetItemUOM(t1.intWeightItemUOMId, t1.intPriceItemUOMId, t1.dblCashPrice), 0.0)
FROM ( 
SELECT 	
	   SCQ.intShipmentContractQtyId,
       SCQ.intShipmentId,
       S.intTrackingNumber,
	   S.ysnDirectShipment,
       SCQ.intContractDetailId,
       CT.intContractHeaderId,
       CT.intContractSeq,
       CT.strContractNumber,
	   CT.intEntityId as intVendorEntityId,
	   S.dtmInventorizedDate,
	   strBLNumber = (SELECT Top 1 SBL.strBLNumber FROM tblLGShipmentBL SBL WHERE SBL.intShipmentId = S.intShipmentId),
	   Item.intCommodityId,
       SCQ.intItemId,
       CT.intItemUOMId,
       S.intSubLocationId,
       intLocationId = S.intCompanyLocationId,
       SCQ.dblQuantity,
	   IsNull(SCQ.dblReceivedQty, 0) as dblReceivedQty,
       SCQ.dblGrossWt,
       SCQ.dblTareWt,
       SCQ.dblNetWt,
       dblCost = CT.dblCashPrice, 
       intWeightUOMId = S.intWeightUnitMeasureId,
       WTUOM.strUnitMeasure as strWeightUOM,
       intEntityVendorId = S.intVendorEntityId,
       CT.strEntityName as strVendor,
       Item.strItemNo,
       strItemDescription = Item.strDescription,
       Item.strLotTracking,
       Item.strType,
	   Item.intLifeTime,
	   Item.strLifeTimeType,
       UOM.strUnitMeasure
       , dblItemUOMCF = ItemUOM.dblUnitQty
       ,intStockUOM = ISNULL((SELECT TOP 1 intItemUOMId FROM tblICItemUOM ItemUOM WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId),0)
       ,strStockUOM = (SELECT TOP 1 strUnitMeasure FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId)
       ,strStockUOMType = (SELECT TOP 1 strUnitType FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId)
       ,dblStockUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId WHERE ysnStockUnit = 1 AND ItemUOM.intItemUOMId = CT.intItemUOMId),0)
       ,SubLocation.strSubLocationName
	   ,S.intCompanyLocationId
	   ,CT.dblCashPrice
	   ,CT.dblCashPriceInQtyUOM
	   ,intWeightItemUOMId = (SELECT WeightItem.intItemUOMId FROM tblICItemUOM WeightItem WHERE WeightItem.intItemId=SCQ.intItemId AND WeightItem.intUnitMeasureId=S.intWeightUnitMeasureId)
	   ,CT.intPriceItemUOMId
	   ,CT.strPriceUOM
	   ,intCostUOMId = CT.intPriceItemUOMId
	   ,strCostUOM = CT.strPriceUOM
	   ,dblCostUOMCF = ISNULL((SELECT TOP 1 dblUnitQty FROM tblICItemUOM ItemUOM WHERE ItemUOM.intItemUOMId = CT.intPriceItemUOMId),0)
	   ,CT.strCurrency
	   ,CT.strMainCurrency
	   ,CT.ysnSubCurrency
	   ,CT.dblMainCashPrice
	   ,dblFranchise = CASE WHEN WG.dblFranchise > 0 THEN WG.dblFranchise / 100 ELSE 0 END

FROM tblLGShipmentContractQty SCQ
JOIN tblLGShipment S ON S.intShipmentId = SCQ.intShipmentId
JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = SCQ.intContractDetailId
JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CT.intItemUOMId
JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = SCQ.intUnitMeasureId
JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = S.intWeightUnitMeasureId
LEFT JOIN tblICItem Item ON Item.intItemId = SCQ.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = S.intSubLocationId
LEFT JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CT.intWeightId
) t1
