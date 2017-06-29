CREATE VIEW vyuLGInventoryView
	AS 
SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY strStatus)) as intKeyColumn,*  FROM (
SELECT
	'In-transit' as strStatus
	,Shipment.strContractNumber
	,Shipment.intContractSeq
	,Shipment.intContractDetailId
	,Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0) as dblStockQty
	,Shipment.strItemUOM as strStockUOM
	,CASE WHEN IsNull (Shipment.dblContainerContractReceivedQty, 0) > 0 THEN
							((Shipment.dblContainerContractGrossWt - Shipment.dblContainerContractTareWt) / Shipment.dblContainerContractQty) * (Shipment.dblContainerContractQty - Shipment.dblContainerContractReceivedQty)
						ELSE
							Shipment.dblContainerContractGrossWt - Shipment.dblContainerContractTareWt
						END as dblNetWeight
	,Shipment.strWeightUOM
	,Shipment.intVendorEntityId
	,Shipment.strVendor
	,Shipment.strCommodity
	,Shipment.strItemNo
	,Shipment.strItemDescription
	,'' strTrackingNumber
	,Shipment.strBLNumber
	,Shipment.strContainerNumber
	,Shipment.strMarks
	,'' as strLotNumber
	,Shipment.strSubLocationName as strWarehouse
	,'' as strCondition
	,Shipment.dtmPostedDate
	,dblQtyInStockUOM = (Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)) * dbo.fnICConvertUOMtoStockUnit (Shipment.intItemId, Shipment.intItemUOMId, 1)
	,Shipment.intItemId
	,intWeightItemUOMId = (SELECT U.intItemUOMId FROM tblICItemUOM U WHERE U.intItemId = Shipment.intItemId AND U.intUnitMeasureId=Shipment.intWeightUOMId)
	,strWarehouseRefNo = ''
	,Shipment.dblFutures
	,Shipment.dblCashPrice
	,Shipment.dblBasis
	,Shipment.dblTotalCost

FROM vyuLGInboundShipmentView Shipment
WHERE (Shipment.dblContainerContractQty - IsNull(Shipment.dblContainerContractReceivedQty, 0.0)) > 0.0 AND Shipment.ysnInventorized = 1

UNION ALL

SELECT 
	'Spot'
	,Spot.strContractNumber
	,Spot.intContractSeq
	,Spot.intContractDetailId
	,Spot.dblQty as dblStockQty
	,Spot.strItemUOM as strStockUOM
	,Spot.dblNetWeight
	,Spot.strWeightUOM
	,Spot.intEntityVendorId
	,Spot.strVendor
	,Spot.strCommodity
	,Spot.strItemNo
	,Spot.strItemDescription
	,Spot.strLoadNumber AS strTrackingNumber
	,Spot.strBLNumber
	,Spot.strContainerNumber
	,Spot.strMarkings as strMarks
	,Spot.strLotNumber
	,Spot.strSubLocationName as strWarehouse
	,Spot.strCondition
	,Spot.dtmPostedDate
	,dblQtyInStockUOM = Spot.dblQty * dbo.fnICConvertUOMtoStockUnit (Spot.intItemId, Spot.intItemUOMId, 1)
	,Spot.intItemId
	,intWeightItemUOMId = Spot.intItemWeightUOMId
	,Spot.strWarehouseRefNo
	,Spot.dblFutures
	,Spot.dblCashPrice
	,Spot.dblBasis
	,Spot.dblTotalCost

FROM vyuLGPickOpenInventoryLots Spot
WHERE Spot.dblQty > 0.0
) t1