CREATE VIEW vyuLGDropShipmentDetailsView
AS
SELECT
	L.strLoadNumber
	,LD.intLoadId
	,LD.intLoadDetailId
	,Alloc.intCompanyLocationId
	,Alloc.intCommodityId
	,strCommodity = Comm.strDescription
	,CompLoc.strLocationName
	,LD.intAllocationDetailId
	,strSeller = Seller.strName
	,strPurchaseContractNumber = PCH.strContractNumber
	,strPContractNumber = Cast(PCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(PCD.intContractSeq AS VARCHAR(100))
	,intPContractSeq = PCD.intContractSeq
	,strPERPPONumber = PCD.strERPPONumber
	,dblPAllocatedQty = ISNULL(dbo.fnCalculateQtyBetweenUOM(PCD.intItemUOMId, PToUOM.intItemUOMId, ALD.dblPAllocatedQty), ALD.dblPAllocatedQty)
	,dblGrossWt = (LD.dblGross / LD.dblQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(PCD.intItemUOMId, PToUOM.intItemUOMId, ALD.dblPAllocatedQty), ALD.dblPAllocatedQty)
	,dblTareWt = (LD.dblTare / LD.dblQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(PCD.intItemUOMId, PToUOM.intItemUOMId, ALD.dblPAllocatedQty), ALD.dblPAllocatedQty)
	,dblNetWt = (LD.dblNet / LD.dblQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(PCD.intItemUOMId, PToUOM.intItemUOMId, ALD.dblPAllocatedQty), ALD.dblPAllocatedQty)
	,L.intWeightUnitMeasureId
	,strWeightUOM = UOM.strUnitMeasure
	,intPItemId = PCD.intItemId
	,strPItemUOM = PU.strUnitMeasure
	,strPItemNo = PIM.strItemNo
	,strPItemDescription = PIM.strDescription
	,LD.intPContractDetailId
	,ALD.intPUnitMeasureId

	,dblSAllocatedQty = ISNULL(dbo.fnCalculateQtyBetweenUOM(SCD.intItemUOMId, SToUOM.intItemUOMId, ALD.dblSAllocatedQty), ALD.dblSAllocatedQty)
	,intSItemId = SCD.intItemId
	,strSItemUOM = SU.strUnitMeasure
	,strSContractNumber = SCH.strContractNumber
	,strSalesContractNumber = Cast(SCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(SCD.intContractSeq AS VARCHAR(100))
	,strSCustomerRefNo = SCH.strCustomerContract
	,intSContractSeq = SCD.intContractSeq
	,strSERPPONumber = SCD.strERPPONumber
	,strBuyer = Buyer.strName
	,strSItemNo = SIM.strItemNo
	,strSItemDescription = SIM.strDescription
	,strSItemDescriptionSpecification = SIM.strDescription + ' - ' + ISNULL(SCD.strItemSpecification,'')
	,ALD.intSContractDetailId
	,ALD.intSUnitMeasureId
	,dblSCashPrice = SCD.dblCashPrice
	,LD.intCustomerEntityId
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = L.intUnitMeasureId
LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = LD.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader Alloc ON Alloc.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = Alloc.intCommodityId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = Alloc.intCompanyLocationId
LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = LD.intPContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
LEFT JOIN tblEMEntity Seller ON Seller.intEntityId = LD.intVendorEntityId
LEFT JOIN tblICItem PIM ON PIM.intItemId = PCD.intItemId
LEFT JOIN tblICItemUOM PIU ON PIU.intItemUOMId = PCD.intItemUOMId
LEFT JOIN tblICUnitMeasure PU ON PU.intUnitMeasureId = PIU.intUnitMeasureId
LEFT JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = LD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCD.intContractHeaderId
LEFT JOIN tblEMEntity Buyer ON Buyer.intEntityId = SCH.intEntityId
LEFT JOIN tblICItem SIM ON SIM.intItemId = SCD.intItemId
LEFT JOIN tblICItemUOM SIU ON SIU.intItemUOMId = SCD.intItemUOMId
LEFT JOIN tblICUnitMeasure SU ON SU.intUnitMeasureId = SIU.intUnitMeasureId
OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = PCD.intItemId AND intUnitMeasureId = Alloc.intWeightUnitMeasureId) PToUOM
OUTER APPLY (SELECT intItemUOMId FROM tblICItemUOM WHERE intItemId = SCD.intItemId AND intUnitMeasureId = Alloc.intWeightUnitMeasureId) SToUOM
