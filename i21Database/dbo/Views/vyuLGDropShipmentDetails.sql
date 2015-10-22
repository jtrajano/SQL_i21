CREATE VIEW vyuLGDropShipmentDetails
AS
SELECT
	PS.intShipmentPurchaseSalesContractId
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
	,Alloc.strPItemUOM
	,Alloc.strPItemNo
	,Alloc.strPItemDescription
	,Alloc.intPContractDetailId
	,Alloc.intPUnitMeasureId

	,PS.dblSAllocatedQty
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
LEFT JOIN vyuLGAllocatedContracts Alloc ON Alloc.intAllocationDetailId = PS.intAllocationDetailId
