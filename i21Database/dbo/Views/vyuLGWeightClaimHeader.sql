CREATE VIEW vyuLGWeightClaimHeader
AS
SELECT
	WC.intWeightClaimId,
	WC.intPurchaseSale,
	strType = CASE WHEN L.intPurchaseSale = 1 THEN 'Inbound' ELSE 'Outbound' END COLLATE Latin1_General_CI_AS,
	WC.strReferenceNumber,
	WC.dtmTransDate,
	WC.intLoadId,
	WC.dtmETAPOD,
	WC.dtmLastWeighingDate,
	WC.dtmActualWeighingDate,
	WC.dtmClaimValidTill,
	WC.dtmPosted,
	WC.ysnPosted,
	L.strLoadNumber,
	L.dtmScheduledDate,
	L.strBLNumber,
	L.dtmBLDate,
	L.intWeightUnitMeasureId,
	strWeightUOM = WUOM.strUnitMeasure,
	intClaimValidTill = WCD.intClaimValidTill,
	intBillOrInvoiceId = WCD.intBillOrInvoiceId,
	WC.intBookId, 
	BO.strBook,
	WC.intSubBookId, 
	SB.strSubBook,
	WC.intPaymentMethodId,
	PM.strPaymentMethod,
	WC.intConcurrencyId
FROM tblLGWeightClaim WC
JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
OUTER APPLY (SELECT TOP 1 
					intBillOrInvoiceId = ISNULL(WCD.intBillId, WCD.intInvoiceId)
					,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
				FROM tblLGWeightClaimDetail WCD
					LEFT JOIN tblCTContractDetail CD ON WCD.intContractDetailId = WCD.intContractDetailId
					LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
			  WHERE WCD.intWeightClaimId = WC.intWeightClaimId) WCD
LEFT JOIN tblCTBook BO ON BO.intBookId = WC.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = WC.intSubBookId
LEFT JOIN tblSMPaymentMethod PM ON PM.intPaymentMethodID = WC.intPaymentMethodId