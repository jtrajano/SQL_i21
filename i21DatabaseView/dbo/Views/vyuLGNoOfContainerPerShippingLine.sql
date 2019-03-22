CREATE VIEW vyuLGNoOfContainerPerShippingLine
AS
SELECT CH.strContractNumber + '/' + CONVERT(NVARCHAR, CD.intContractSeq) AS strContractNo
	,CD.dtmStartDate
	,CD.dtmEndDate
	,ShippingLine.strName AS strShippingLine
	,SI.strLoadNumber AS strShippingInstructionNo
	,SI.intNumberOfContainers AS intForcastNoOfContainers
	,SAL.strLoadNumber AS strShippingAdviceNo
	,(
		SELECT COUNT(*)
		FROM tblLGLoadContainer LC
		WHERE LC.intLoadId = SAL.intLoadId
		) AS intActualNofContainers
	,ISNULL(SICType.strContainerType, SACType.strContainerType) AS strContainerType
	,SAL.strMVessel
	,SAL.strMVoyageNumber
	,SAL.strFVessel
	,SAL.strFVoyageNumber
	,I.strItemNo
	,C.strCommodityCode
	,SAL.dtmBLDate
	,intLateShipmentDays = CONVERT(INT,ISNULL((SAL.dtmScheduledDate - CD.dtmEndDate),0))
	,strVendor = Vendor.strName 
	,strProducer = Producer.strName
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
JOIN tblLGLoadDetail SILD ON CD.intContractDetailId = CASE WHEN CH.intContractTypeId = 1 THEN SILD.intPContractDetailId ELSE SILD.intSContractDetailId END
JOIN tblLGLoad SI ON SI.intLoadId = SILD.intLoadId 
								AND SI.intShipmentType = 2
JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = SI.intShippingLineEntityId
JOIN tblEMEntity Vendor ON Vendor.intEntityId = CH.intEntityId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
LEFT JOIN tblLGLoad SAL ON SAL.intLoadShippingInstructionId = SI.intLoadId
LEFT JOIN tblLGLoadDetail SID ON SID.intLoadId = SI.intLoadId
LEFT JOIN tblLGContainerType SICType ON SICType.intContainerTypeId = SI.intContainerTypeId
LEFT JOIN tblLGContainerType SACType ON SACType.intContainerTypeId = SAL.intContainerTypeId