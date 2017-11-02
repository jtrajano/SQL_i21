CREATE VIEW vyuRKPurchaseIntransitView
AS
SELECT 
           PCT.intCompanyLocationId intCompanyLocationId,
              CL.strLocationName,
              C.strCommodityCode as strCommodity,
              PCT.intItemId,
              IM.strItemNo,
              sum(LD.dblQuantity) as dblPurchaseContractShippedQty,
              sum(LD.dblGross) as dblPurchaseContractShippedGrossWt,
              sum(LD.dblTare) as dblPurchaseContractShippedTareWt,
              sum(LD.dblNet) as dblPurchaseContractShippedNetWt,
              sum(ISNULL(LD.dblDeliveredQuantity, 0)) as dblPurchaseContractReceivedQty,
              CH.intCommodityId,CH.intEntityId,e.strName,
              PCT.intContractDetailId,
              CH.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,
                       intCommodityUnitMeasureId as intUnitMeasureId 
              ,L.intPurchaseSale
              ,L1.strLoadNumber
              ,LD.intPContractDetailId intPPContractDetailId
              ,LD1.intPContractDetailId
FROM tblLGLoad L 
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus in(6,3) -- 1.purchase 2.outbound
JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = CASE L.intPurchaseSale WHEN 1 THEN LD.intPContractDetailId WHEN 2 THEN LD.intSContractDetailId END
JOIN   tblCTContractHeader               CH     ON     CH.intContractHeaderId            =       PCT.intContractHeaderId    and intContractStatusId not in(2,3,6)
JOIN   tblICCommodityUnitMeasure                CM     ON     CM.intCommodityUnitMeasureId             =             CH.intCommodityUOMId 
JOIN   tblSMCompanyLocation              CL     ON     CL.intCompanyLocationId           =       PCT.intCompanyLocationId
JOIN   tblICItem                                       IM     ON     IM.intItemId                      =      PCT.intItemId 
JOIN tblICCommodity C on C.intCommodityId=CH.intCommodityId
LEFT JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LDL.intLotId
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
LEFT JOIN tblLGLoadDetail LD1 ON LD1.intLoadDetailId = IRI.intSourceId
LEFT JOIN tblLGLoad L1 ON L1.intLoadId = LD1.intLoadId
LEFT JOIN tblEMEntity e on e.intEntityId=CH.intEntityId
GROUP BY   PCT.intCompanyLocationId ,
              CL.strLocationName,
              C.strCommodityCode,
              PCT.intItemId,
              IM.strItemNo,CH.intCommodityId,CH.intEntityId,e.strName,
              PCT.intContractDetailId,
              CH.strContractNumber,intContractSeq,intCommodityUnitMeasureId,L.intPurchaseSale,L1.strLoadNumber, LD1.intPContractDetailId, LD.intPContractDetailId