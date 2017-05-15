CREATE VIEW vyuLGDropShipmentDetailsView
AS
SELECT
	L.strLoadNumber
	,LD.intLoadId
	,LD.intLoadDetailId
	,Alloc.intCompanyLocationId
	,Alloc.intCommodityId
	,Alloc.strCommodity
	,Alloc.strLocationName
	,LD.intAllocationDetailId
	,Alloc.strSeller
	,Alloc.strPurchaseContractNumber
	,Alloc.strPContractNumber
	,Alloc.intPContractSeq
	,Alloc.dblPAllocatedQty
	,dblGrossWt = (LD.dblGross / CASE WHEN ISNULL(LD.dblQuantity,0) = 0 THEN 1 ELSE LD.dblQuantity END) * Alloc.dblPAllocatedQty
	,dblTareWt = (LD.dblTare / CASE WHEN ISNULL(LD.dblQuantity,0) = 0 THEN 1 ELSE LD.dblQuantity END) * Alloc.dblPAllocatedQty
	,dblNetWt = (LD.dblNet / CASE WHEN ISNULL(LD.dblQuantity,0) = 0 THEN 1 ELSE LD.dblQuantity END) * Alloc.dblPAllocatedQty
	,L.intWeightUnitMeasureId
	,UOM.strUnitMeasure as strWeightUOM
	,LD.intItemId as intPItemId
	,Alloc.strPItemUOM
	,Alloc.strPItemNo
	,Alloc.strPItemDescription
	,Alloc.intPContractDetailId
	,Alloc.intPUnitMeasureId

	,Alloc.dblSAllocatedQty
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
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = L.intUnitMeasureId
LEFT JOIN vyuLGAllocatedContracts Alloc ON Alloc.intAllocationDetailId = LD.intAllocationDetailId