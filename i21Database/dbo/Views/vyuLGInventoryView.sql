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
	,Shipment.dblContainerContractGrossWt - Shipment.dblContainerContractTareWt as dblNetWeight
	,Shipment.strWeightUOM
	,Shipment.intVendorEntityId
	,Shipment.strVendor
	,Shipment.strItemNo
	,Shipment.strItemDescription
	,Shipment.intTrackingNumber
	,Shipment.strBLNumber
	,Shipment.strContainerNumber
	,Shipment.strMarks
	,'' as strLotNumber
	,Shipment.strSubLocationName as strWarehouse
	,'' as strCondition
	,Shipment.dtmInventorizedDate
	,dblQtyInStockUOM = (Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0)) * dbo.fnICConvertUOMtoStockUnit (Shipment.intItemId, Shipment.intItemUOMId, 1)

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
	,Spot.strItemNo
	,Spot.strItemDescription
	,Spot.intTrackingNumber
	,Spot.strBLNumber
	,Spot.strContainerNumber
	,Spot.strMarkings as strMarks
	,Spot.strLotNumber
	,Spot.strSubLocationName as strWarehouse
	,Spot.strCondition
	,Spot.dtmInventorizedDate
	,dblQtyInStockUOM = Spot.dblQty * dbo.fnICConvertUOMtoStockUnit (Spot.intItemId, Spot.intItemUOMId, 1)

FROM vyuLGPickOpenInventoryLots Spot
WHERE Spot.dblQty > 0.0
) t1