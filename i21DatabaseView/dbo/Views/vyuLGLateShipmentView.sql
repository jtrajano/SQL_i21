CREATE VIEW vyuLGLateShipmentView
AS
SELECT L.strLoadNumber
	  ,CH.strContractNumber
	  ,CD.intContractSeq
	  ,L.dtmScheduledDate
	  ,CD.dtmStartDate
	  ,CD.dtmEndDate
	  ,I.strItemNo
	  ,C.strCommodityCode
	  ,L.dtmBLDate
	  ,intLateShipmentDays = CONVERT(INT,ISNULL((L.dtmScheduledDate - CD.dtmEndDate),0))
	  ,strVendor = Vendor.strName 
	  ,strProducer = Producer.strName
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE 
														WHEN L.intPurchaseSale = 1
															THEN LD.intPContractDetailId
														ELSE LD.intSContractDetailId
														END
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId 
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
JOIN tblEMEntity Vendor ON Vendor.intEntityId = CH.intEntityId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
WHERE L.dtmScheduledDate > CD.dtmEndDate AND L.intShipmentType = 1