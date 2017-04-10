CREATE VIEW vyuLGLateShipmentView
AS
SELECT L.strLoadNumber
	,CH.strContractNumber
	,CD.intContractSeq
	,CD.strERPPONumber
	,strVendor = Vendor.strName
	,strProducer = Producer.strName
	,CD.dblNetWeight
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,City.strCity AS strDestinationPort
	,L.strBLNumber
	,CD.dtmStartDate
	,CD.dtmEndDate
	,L.dtmETAPOD
	,L.dtmETAPOL
	,L.dtmETSPOL
	,L.dtmDeadlineCargo
	,ETAPODRC.strReasonCodeDescription AS strETAPODReasonCode
	,ETSPOLRC.strReasonCodeDescription AS strETAPOLReasonCode
	,ETAPOLRC.strReasonCodeDescription AS strETSPOLReasonCode
	,intLateShipmentDays = CONVERT(INT, ISNULL((L.dtmETAPOD - CD.dtmEndDate), 0))
	,L.strExternalLoadNumber AS strSupplierReferenceNo
	,CD.strReference AS strContractDetailReference
	,ShippingLine.strName AS strShippingLine
	,L.dtmScheduledDate
	,C.strCommodityCode
	,L.dtmBLDate
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
JOIN tblEMEntity Vendor ON Vendor.intEntityId = CH.intEntityId
LEFT JOIN tblEMEntity Producer ON Producer.intEntityId = CH.intProducerId
LEFT JOIN tblSMCity City ON City.intCityId = CD.intDestinationPortId
LEFT JOIN tblLGReasonCode ETAPODRC ON ETAPODRC.intReasonCodeId = L.intETAPODReasonCodeId
LEFT JOIN tblLGReasonCode ETAPOLRC ON ETAPOLRC.intReasonCodeId = L.intETAPOLReasonCodeId
LEFT JOIN tblLGReasonCode ETSPOLRC ON ETSPOLRC.intReasonCodeId = L.intETSPOLReasonCodeId
LEFT JOIN tblEMEntity ShippingLine ON ShippingLine.intEntityId = L.intShippingLineEntityId
WHERE L.dtmScheduledDate > CD.dtmEndDate
	AND L.intShipmentType = 1