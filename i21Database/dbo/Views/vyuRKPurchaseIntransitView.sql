CREATE VIEW vyuRKPurchaseIntransitView
AS
SELECT 
	    LD.intPCompanyLocationId intCompanyLocationId,
		PCT.strLocationName,
		PCT.strCommodityDescription as strCommodity,
		PCT.intItemId,
		PCT.strItemNo,
	    LD.dblQuantity as dblPurchaseContractShippedQty,
		LD.dblGross as dblPurchaseContractShippedGrossWt,
		LD.dblTare as dblPurchaseContractShippedTareWt,
		LD.dblNet as dblPurchaseContractShippedNetWt,
		ISNULL(LD.dblDeliveredQuantity, 0) as dblPurchaseContractReceivedQty,
		PCT.intCommodityId,PCT.intEntityId,e.strName,
		PCT.intContractDetailId,
		PCT.strContractNumber +'-' +Convert(nvarchar,intContractSeq) strContractNumber,intCommodityUnitMeasureId as intUnitMeasureId 
FROM tblLGLoad L 
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId and ysnPosted=1 AND L.intShipmentStatus = 3
JOIN vyuCTContractDetailView PCT ON PCT.intContractDetailId = LD.intPContractDetailId
JOIN tblEMEntity e on e.intEntityId=PCT.intEntityId

GO