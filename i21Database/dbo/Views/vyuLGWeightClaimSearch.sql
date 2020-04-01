CREATE VIEW vyuLGWeightClaimSearch
AS
SELECT
	WC.intWeightClaimId,
	WC.intPurchaseSale,
	strType = CASE WHEN WC.intPurchaseSale = 1 THEN 'Inbound' ELSE CASE WHEN WC.intPurchaseSale = 2 THEN 'Outbound'  ELSE 'Drop Ship' END END COLLATE Latin1_General_CI_AS,
	WC.strReferenceNumber,
	WC.dtmTransDate,
	WC.intLoadId,
	WC.dtmETAPOD,
	WC.dtmLastWeighingDate,
	WC.dtmActualWeighingDate,
	WD.intWeightClaimDetailId,
	WD.intItemId,
	WD.dblFromNet,
	WD.dblToNet,
	WD.dblFranchise,
	WD.dblFranchiseWt,
	WD.dblWeightLoss,
	WD.dblClaimableWt,
	WD.intPartyEntityId,
	WD.dblUnitPrice,
	WD.intCurrencyId,
	WD.dblClaimAmount,
	WD.intPriceItemUOMId,
	WD.ysnNoClaim,
	WD.intContractDetailId,
	WC.dtmClaimValidTill,
	L.strLoadNumber,
	L.dtmScheduledDate,
	L.strBLNumber,
	L.dtmBLDate,
	L.intWeightUnitMeasureId,
	strWeightUOM = WUOM.strUnitMeasure,
	CH.strContractNumber,
	CD.intContractSeq,
	strEntityName = EM.strName,
	EM.intEntityId,
	strPaidTo = PTEM.strName,
	strCurrency = SM.strCurrency,
	strPriceUOM = ItemUOM.strUnitMeasure,
	ysnSeqSubCurrency = SM.ysnSubCurrency,
	dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((SELECT Top(1) IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId=CD.intItemId AND IU.intUnitMeasureId=WUOM.intUnitMeasureId),AD.intSeqPriceUOMId,AD.dblSeqPrice),
	AD.dblSeqPrice,
	WC.ysnPosted,
	WC.dtmPosted,
	I.strItemNo,
	C.strCommodityCode,
	CONI.strContractItemNo,
	CONI.strContractItemName,
	OG.strCountry AS strOrigin,
	strBillId = CASE WHEN (WC.intPurchaseSale = 2) THEN INVC.strInvoiceNumber ELSE BILL.strBillId END,
	intBillId = CASE WHEN (WC.intPurchaseSale = 2) THEN INVC.intInvoiceId ELSE BILL.intBillId END,
	WC.intBookId, 
	BO.strBook,
	WC.intSubBookId, 
	SB.strSubBook,
	CH.intContractTypeId,
	intContractBasisId = CH.intFreightTermId,
	CB.strContractBasis,
	CD.strERPPONumber,
	CD.strERPItemNumber,
	strSublocation = (SELECT TOP 1 CLSL.strSubLocationName
			FROM tblLGLoadWarehouse LW
			JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
			WHERE LW.intLoadId = L.intLoadId),
	CD.intPurchasingGroupId,
	strPurchasingGroupName = PG.strName,
	strPurchasingGroupDesc = PG.strDescription,
	WC.intPaymentMethodId,
	PM.strPaymentMethod
FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimDetail WD ON WD.intWeightClaimId = WC.intWeightClaimId
JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = WD.intContractDetailId
JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId 
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId
	AND CONI.intItemId = I.intItemId
LEFT JOIN tblSMCountry OG ON OG.intCountryID  = (
	CASE 
		WHEN ISNULL(CONI.intCountryId, 0) = 0
			THEN ISNULL(CA.intCountryID, 0)
		ELSE CONI.intCountryId
		END
	)
LEFT JOIN tblSMCurrency SM ON SM.intCurrencyID = WD.intCurrencyId
LEFT JOIN vyuICGetItemUOM ItemUOM ON ItemUOM.intItemUOMId = WD.intPriceItemUOMId
LEFT JOIN tblEMEntity PTEM ON PTEM.intEntityId = WD.intPartyEntityId
LEFT JOIN tblAPBill BILL ON BILL.intBillId = WD.intBillId
LEFT JOIN tblARInvoice INVC ON INVC.intInvoiceId = WD.intInvoiceId
LEFT JOIN tblCTBook BO ON BO.intBookId = WC.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = WC.intSubBookId
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
LEFT JOIN tblSMPaymentMethod PM ON PM.intPaymentMethodID = WC.intPaymentMethodId
