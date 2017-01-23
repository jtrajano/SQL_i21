CREATE VIEW vyuLGContractWithoutShippingInstruction
AS
SELECT CH.strContractNumber
	,CD.intContractSeq
	,CT.strContractType
	,CD.dtmStartDate
	,CD.dtmEndDate
	,Vendor.strName AS strVendor
	,Producer.strName AS strProducer
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblCTContractType CT ON CT.intContractTypeId = CH.intContractTypeId
JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
JOIN tblEMEntity Vendor ON Vendor.intEntityId = CH.intEntityId
WHERE CH.intContractTypeId = 1
	AND CD.intContractDetailId NOT IN (
		SELECT CASE 
				WHEN L.intPurchaseSale = 1
					THEN LD.intPContractDetailId
				ELSE intSContractDetailId
				END
		FROM tblLGLoadDetail LD
		JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE L.intShipmentType = 2
		)