CREATE VIEW vyuRKPurchaseIntransitView

AS

SELECT PCT.intCompanyLocationId intCompanyLocationId
	, CL.strLocationName
	, strCommodity = C.strCommodityCode
	, PCT.intItemId
	, IM.strItemNo
	, IM.intCategoryId
	, strCategory = Category.strCategoryCode
	, dblPurchaseContractShippedQty = SUM(LD.dblQuantity)
	, dblPurchaseContractShippedGrossWt = SUM(LD.dblGross)
	, dblPurchaseContractShippedTareWt = SUM(LD.dblTare)
	, dblPurchaseContractShippedNetWt = SUM(LD.dblNet)
	, dblPurchaseContractReceivedQty = SUM(ISNULL(LD.dblDeliveredQuantity, 0))
	, CH.intCommodityId
	, CH.intEntityId
	, e.strName
	, CH.intContractHeaderId
	, PCT.intContractDetailId
	, strContractNumber = (CH.strContractNumber + '-' + CONVERT(NVARCHAR, PCT.intContractSeq)) COLLATE Latin1_General_CI_AS
	, PCT.dtmStartDate
	, PCT.dtmEndDate
	, intUnitMeasureId = intCommodityUnitMeasureId
	, L.intPurchaseSale
	, L1.strLoadNumber
	, intPPContractDetailId = LD.intPContractDetailId
	, LD1.intPContractDetailId
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND ysnPosted = 1 AND L.intShipmentStatus IN (6,3) -- 1.purchase 2.outbound
JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = CASE L.intPurchaseSale WHEN 1 THEN LD.intPContractDetailId WHEN 2 THEN LD.intSContractDetailId END
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PCT.intContractHeaderId AND intContractStatusId NOT IN (2,3,6)
JOIN tblICCommodityUnitMeasure CM ON CM.intCommodityUnitMeasureId = CH.intCommodityUOMId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = PCT.intCompanyLocationId
JOIN tblICItem IM ON IM.intItemId = PCT.intItemId
JOIN tblICCategory Category ON Category.intCategoryId = IM.intCategoryId
JOIN tblICCommodity C ON C.intCommodityId = CH.intCommodityId
LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LDL.intLotId
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
LEFT JOIN tblLGLoadDetail LD1 ON LD1.intLoadDetailId = IRI.intSourceId
LEFT JOIN tblLGLoad L1 ON L1.intLoadId = LD1.intLoadId
LEFT JOIN tblEMEntity e ON e.intEntityId=CH.intEntityId
GROUP BY PCT.intCompanyLocationId
	, CL.strLocationName
	, C.strCommodityCode
	, PCT.intItemId
	, IM.strItemNo
	, IM.intCategoryId
	, Category.strCategoryCode
	, CH.intCommodityId
	, CH.intEntityId
	, e.strName
	, CH.intContractHeaderId
	, PCT.intContractDetailId
	, CH.strContractNumber
	, intContractSeq
	, intCommodityUnitMeasureId
	, L.intPurchaseSale
	, L1.strLoadNumber
	, LD1.intPContractDetailId
	, LD.intPContractDetailId
	, PCT.dtmStartDate
	, PCT.dtmEndDate