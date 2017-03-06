CREATE VIEW vyuLGWeightClaimHeader
AS
SELECT
	WC.intWeightClaimId,
	WC.intPurchaseSale,
	strType = CASE WHEN Load.intPurchaseSale = 1 THEN 'Inbound' ELSE CASE WHEN Load.intPurchaseSale = 2 THEN 'Outbound'  ELSE 'Drop Ship' END END,
	WC.strReferenceNumber,
	WC.dtmTransDate,
	WC.intLoadId,
	WC.dtmETAPOD,
	WC.dtmLastWeighingDate,
	WC.dtmActualWeighingDate,
	WC.dtmClaimValidTill,
	Load.strLoadNumber,
	Load.dtmScheduledDate,
	Load.strBLNumber,
	Load.dtmBLDate,
	Load.intWeightUnitMeasureId,
	strWeightUOM = WUOM.strUnitMeasure,
	intClaimValidTill = (SELECT TOP 1 ISNULL(ASN.intClaimValidTill, 0)
						 FROM tblCTContractDetail CD
						 LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
						 LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
						 LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
						 WHERE WCD.intWeightClaimId = WC.intWeightClaimId)
FROM tblLGWeightClaim WC
JOIN tblLGLoad Load ON Load.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Load.intWeightUnitMeasureId


