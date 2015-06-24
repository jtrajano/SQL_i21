CREATE VIEW vyuLGShipmentContainerReceiptContracts
AS   
SELECT 
	intShipmentContractQtyId
	,intShipmentBLContainerContractId = -1
	,intShipmentId
	,intTrackingNumber
	,ysnDirectShipment
	,intContractDetailId
	,intContractHeaderId
	,intContractSeq
	,intContractNumber
	,intItemId
	,intItemUOMId
	,intSubLocationId
	,intLocationId
	,dblQuantity
	,dblReceivedQty
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
	,intTrackingNumber
	,ysnDirectShipment
	,intContractDetailId
	,intContractHeaderId
	,intContractSeq
	,intContractNumber
	,intItemId
	,intItemUOMId
	,intSubLocationId
	,intLocationId
	,dblQuantity
	,dblReceivedQty
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