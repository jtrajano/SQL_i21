CREATE VIEW vyuLGLateShipmentView
AS
SELECT L.strLoadNumber
	  ,CH.strContractNumber
	  ,CD.intContractSeq
	  ,L.dtmScheduledDate
	  ,CD.dtmStartDate
	  ,CD.dtmEndDate
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
														WHEN L.intPurchaseSale = 1
															THEN LD.intPContractDetailId
														ELSE LD.intSContractDetailId
														END
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
WHERE L.dtmScheduledDate > CD.dtmEndDate AND L.intShipmentType = 1