CREATE VIEW vyuLGDropShipmentDetails
AS
SELECT
	Shipment.intTrackingNumber
	,PS.intShipmentPurchaseSalesContractId
	,PS.intShipmentContractQtyId 
	,PS.intShipmentId
	,Alloc.intCompanyLocationId
	,Alloc.intCommodityId
	,Alloc.strCommodity
	,Alloc.strLocationName
	,PS.intAllocationDetailId
	,Alloc.strSeller
	,Alloc.strPurchaseContractNumber
	,Alloc.strPContractNumber
	,Alloc.intPContractSeq
	,PS.dblPAllocatedQty
	,dblGrossWt = (ShipContract.dblGrossWt / ShipContract.dblQuantity) * PS.dblPAllocatedQty
	,dblTareWt = (ShipContract.dblTareWt / ShipContract.dblQuantity) * PS.dblPAllocatedQty
	,dblNetWt = (ShipContract.dblNetWt / ShipContract.dblQuantity) * PS.dblPAllocatedQty
	,Shipment.intWeightUnitMeasureId
	,UOM.strUnitMeasure as strWeightUOM
	,ShipContract.intItemId as intPItemId
	,Alloc.strPItemUOM
	,Alloc.strPItemNo
	,Alloc.strPItemDescription
	,Alloc.intPContractDetailId
	,Alloc.intPUnitMeasureId

	,PS.dblSAllocatedQty
	,Alloc.intSItemId
	,Alloc.strSItemUOM
	,Alloc.strSContractNumber
	,Alloc.strSalesContractNumber
	,Alloc.intSContractSeq
	,Alloc.strBuyer
	,Alloc.strSItemNo
	,Alloc.strSItemDescription
	,Alloc.intSContractDetailId
	,Alloc.intSUnitMeasureId
	,Alloc.dblSCashPrice

FROM tblLGShipmentPurchaseSalesContract PS
LEFT JOIN tblLGShipmentContractQty ShipContract On ShipContract.intShipmentContractQtyId = PS.intShipmentContractQtyId
LEFT JOIN tblLGShipment Shipment ON Shipment.intShipmentId = PS.intShipmentId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = Shipment.intWeightUnitMeasureId
LEFT JOIN vyuLGAllocatedContracts Alloc ON Alloc.intAllocationDetailId = PS.intAllocationDetailId