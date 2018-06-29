CREATE VIEW vyuLGContractWithoutShippingInstruction
AS
SELECT CH.strContractNumber
	,CD.intContractSeq
	,CT.strContractType
	,CD.dtmStartDate
	,CD.dtmEndDate
	,Vendor.strName AS strVendor
	,Producer.strName AS strProducer
	,I.strItemNo
	,C.strCommodityCode
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
LEFT JOIN tblEMEntity Vendor ON Vendor.intEntityId = CH.intEntityId
WHERE CH.intContractTypeId = 1
	AND CD.intContractDetailId NOT IN (
		SELECT ISNULL(CASE 
					  WHEN L.intPurchaseSale = 1
						 THEN LD.intPContractDetailId
					  ELSE intSContractDetailId
					  END,0)
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE L.intShipmentType = 2
		)