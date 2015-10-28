CREATE VIEW vyuLGInventoryView
	AS 
SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY strStatus)) as intKeyColumn,*  FROM (
SELECT
	'Afloat' as strStatus
	,Shipment.strContractNumber
	,Shipment.intContractSeq
	,Shipment.intContractDetailId
	,Shipment.dblContainerContractQty - IsNull (Shipment.dblContainerContractReceivedQty, 0.0) as dblStockQty
	,Shipment.strItemUOM as strStockUOM
	,Shipment.dblContainerContractGrossWt - Shipment.dblContainerContractTareWt as dblNetWeight
	,Shipment.strWeightUOM
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

FROM vyuLGPickOpenInventoryLots Spot
WHERE Spot.dblQty > 0.0
) t1