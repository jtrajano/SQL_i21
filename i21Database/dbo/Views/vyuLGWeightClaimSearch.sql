CREATE VIEW vyuLGWeightClaimSearch
AS
SELECT
	WC.intWeightClaimId
	,WC.intPurchaseSale
	,strType = CASE WHEN (WC.intPurchaseSale = 2) THEN 'Outbound' ELSE 'Inbound' END COLLATE Latin1_General_CI_AS
	,WC.strReferenceNumber
	,WC.dtmTransDate
	,WC.intLoadId
	,WC.dtmETAPOD
	,WC.dtmLastWeighingDate
	,WC.dtmActualWeighingDate
	,WD.intWeightClaimDetailId
	,WD.intItemId
	,WD.dblFromNet
	,WD.dblToNet
	,WD.dblFranchise
	,WD.dblFranchiseWt
	,WD.dblWeightLoss
	,WD.dblClaimableWt
	,WD.intPartyEntityId
	,WD.dblUnitPrice
	,WD.intCurrencyId
	,WD.dblClaimAmount
	,WD.intPriceItemUOMId
	,WD.ysnNoClaim
	,WD.intContractDetailId
	,WD.intLoadContainerId
	,strContainerNumber = LC.strContainerNumber
	,strMarks = LC.strMarks
	,WC.dtmClaimValidTill
	,L.strLoadNumber
	,L.dtmScheduledDate
	,L.strBLNumber
	,L.dtmBLDate
	,L.intWeightUnitMeasureId
	,strWeightUOM = WUOM.strUnitMeasure
	,CH.strContractNumber
	,CD.intContractSeq
	,strEntityName = EM.strName
	,EM.intEntityId
	,strPaidTo = PTEM.strName
	,strCurrency = SM.strCurrency
	,strPriceUOM = PUM.strUnitMeasure
	,ysnSeqSubCurrency = SM.ysnSubCurrency
	,dblSeqPriceInWeightUOM = WD.dblUnitPrice * WD.dblSeqPriceConversionFactoryWeightUOM
	,dblSeqPrice = WD.dblUnitPrice
	,WC.ysnPosted
	,WC.dtmPosted
	,I.strItemNo
	,I.strDescription
	,C.strCommodityCode
	,CONI.strContractItemNo
	,CONI.strContractItemName
	,strOrigin = ISNULL(OG.strCountry, CAC.strCountry)
	,strBillId = CASE WHEN (WC.intPurchaseSale = 2) THEN INVC.strInvoiceNumber ELSE BILL.strBillId END
	,intBillId = CASE WHEN (WC.intPurchaseSale = 2) THEN INVC.intInvoiceId ELSE BILL.intBillId END
	,WC.intBookId
	,BO.strBook
	,WC.intSubBookId
	,SB.strSubBook
	,CH.intContractTypeId
	,intContractBasisId = CH.intFreightTermId
	,CB.strContractBasis
	,CD.strERPPONumber
	,CD.strERPItemNumber
	,strSublocation = WH.strSubLocationName
	,CD.intPurchasingGroupId
	,strPurchasingGroupName = PG.strName
	,strPurchasingGroupDesc = PG.strDescription
	,WC.intPaymentMethodId
	,PM.strPaymentMethod
FROM tblLGWeightClaim WC
	JOIN tblLGWeightClaimDetail WD ON WD.intWeightClaimId = WC.intWeightClaimId
	JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = WD.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId 
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WD.intLoadContainerId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId AND CONI.intItemId = I.intItemId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CONI.intCountryId
	LEFT JOIN tblSMCountry CAC ON CAC.intCountryID = CA.intCountryID
	LEFT JOIN tblSMCurrency SM ON SM.intCurrencyID = WD.intCurrencyId
	LEFT JOIN tblICItemUOM PUOM ON PUOM.intItemUOMId = WD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PUM ON PUM.intUnitMeasureId = PUOM.intUnitMeasureId
	LEFT JOIN tblEMEntity PTEM ON PTEM.intEntityId = WD.intPartyEntityId
	LEFT JOIN tblAPBill BILL ON BILL.intBillId = WD.intBillId
	LEFT JOIN tblARInvoice INVC ON INVC.intInvoiceId = WD.intInvoiceId
	LEFT JOIN tblCTBook BO ON BO.intBookId = WC.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = WC.intSubBookId
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	LEFT JOIN tblSMPaymentMethod PM ON PM.intPaymentMethodID = WC.intPaymentMethodId
	OUTER APPLY (SELECT TOP 1 CLSL.strSubLocationName
				FROM tblLGLoadWarehouse LW
				JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
				WHERE LW.intLoadId = L.intLoadId) WH
