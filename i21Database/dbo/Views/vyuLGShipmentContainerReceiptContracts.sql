CREATE VIEW vyuLGShipmentContainerReceiptContracts
AS   
SELECT 
	intShipmentContractQtyId
	,intShipmentBLContainerContractId = -1
	,intShipmentId
	,intShipmentBLId = -1
	,intShipmentBLContainerId = -1
	,intTrackingNumber
	,ysnDirectShipment
	,intContractDetailId
	,intContractHeaderId
	,intContractSeq
	,intContractNumber
	,intCommodityId
	,intItemId
	,intItemUOMId
	,intSubLocationId
	,intLocationId
	,dblQuantity
	,dblReceivedQty
	,dblBalanceToReceive = dblQuantity - dblReceivedQty
	,dblGrossWt
	,dblTareWt
	,dblNetWt
	,dblCost
	,intWeightUOMId
	,strWeightUOM
	,intEntityVendorId
	,strVendor
	,strItemNo
	,strItemDescription
	,strLotTracking
	,strType
	,strUnitMeasure
	,dblItemUOMCF
	,intStockUOM
	,strStockUOM
	,strStockUOMType
	,dblStockUOMCF
	,strSubLocationName
	,strBLNumber = NULL
	,strContainerNumber = NULL
	,strLotNumber = NULL
	,strMarks = NULL
	,strOtherMarks = NULL
	,strSealNumber = NULL
	,strContainerType = NULL

FROM vyuLGShipmentPurchaseContracts WHERE intShipmentContractQtyId NOT IN (Select intShipmentContractQtyId FROM vyuLGShipmentContainerPurchaseContracts)

UNION ALL

SELECT 

	intShipmentContractQtyId
	,intShipmentBLContainerContractId
	,intShipmentId
	,intShipmentBLId
	,intShipmentBLContainerId
	,intTrackingNumber
	,ysnDirectShipment
	,intContractDetailId
	,intContractHeaderId
	,intContractSeq
	,intContractNumber
	,intCommodityId
	,intItemId
	,intItemUOMId
	,intSubLocationId
	,intLocationId
	,dblQuantity
	,dblReceivedQty
	,dblBalanceToReceive = dblQuantity - dblReceivedQty
	,dblGrossWt
	,dblTareWt
	,dblNetWt
	,dblCost
	,intWeightUOMId
	,strWeightUOM
	,intEntityVendorId
	,strVendor
	,strItemNo
	,strItemDescription
	,strLotTracking
	,strType
	,strUnitMeasure
	,dblItemUOMCF
	,intStockUOM
	,strStockUOM
	,strStockUOMType
	,dblStockUOMCF
	,strSubLocationName
	,strBLNumber
	,strContainerNumber
	,strLotNumber
	,strMarks
	,strOtherMarks
	,strSealNumber
	,strContainerType

FROM vyuLGShipmentContainerPurchaseContracts