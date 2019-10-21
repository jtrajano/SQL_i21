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
	Load.strLoadNumber,
	Load.dtmScheduledDate,
	Load.strBLNumber,
	Load.dtmBLDate,
	Load.intWeightUnitMeasureId,
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
	BILL.strBillId,
	BILL.intBillId,
	WC.intBookId, 
	BO.strBook,
	WC.intSubBookId, 
	SB.strSubBook,
	CH.intContractTypeId,
	intContractBasisId = CH.intFreightTermId,
	CB.strContractBasis,
	CD.strERPPONumber,
	CD.strERPItemNumber,
	(SELECT TOP 1 CLSL.strSubLocationName
			FROM tblLGLoadWarehouse LW
			JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
			WHERE LW.intLoadId = Load.intLoadId) strSublocation,
	CD.intPurchasingGroupId,
	PG.strName AS strPurchasingGroupName,
	PG.strDescription AS strPurchasingGroupDesc

FROM tblLGWeightClaim WC
JOIN tblLGWeightClaimDetail WD ON WD.intWeightClaimId = WC.intWeightClaimId
JOIN tblLGLoad Load ON Load.intLoadId = WC.intLoadId
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Load.intWeightUnitMeasureId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = WD.intContractDetailId
JOIN (SELECT
			intContractDetailId = CD.intContractDetailId
			,intSeqPriceUOMId = ISNULL(CD.intAdjItemUOMId,CD.intPriceItemUOMId)
			,strSeqPriceUOM = ISNULL(FM.strUnitMeasure, UM.strUnitMeasure)
			,intSeqCurrencyId = COALESCE(CYXT.intToCurrencyId, CYXF.intFromCurrencyId, CY.intCurrencyID)
			,strSeqCurrency = COALESCE(CYT.strCurrency, CYF.strCurrency, CY.strCurrency)
			,ysnSeqSubCurrency = COALESCE(CYT.ysnSubCurrency, CYF.ysnSubCurrency, CY.ysnSubCurrency)
			,dblSeqPrice = CD.dblCashPrice / ISNULL(CY.intCent, 1) * (CASE WHEN (CYXT.intToCurrencyId IS NOT NULL) THEN 1 / ISNULL(CD.dblRate, 1) ELSE ISNULL(CD.dblRate, 1) END)
		FROM tblCTContractDetail CD
			LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intPriceItemUOMId
			LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
			LEFT JOIN tblICItemUOM FU ON ISNULL(CD.ysnUseFXPrice,0) = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL AND FU.intItemUOMId = CD.intFXPriceUOMId
			LEFT JOIN tblICUnitMeasure FM ON FM.intUnitMeasureId = FU.intUnitMeasureId
			LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CD.intCurrencyId
			LEFT JOIN tblSMCurrency MCY ON MCY.intCurrencyID = CY.intMainCurrencyId
			LEFT JOIN tblSMCurrencyExchangeRate CYXF 
				ON ISNULL(CD.ysnUseFXPrice,0) = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL
				AND CYXF.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId 
				AND CYXF.intFromCurrencyId = ISNULL(CY.intMainCurrencyId, CY.intCurrencyID)
			LEFT JOIN tblSMCurrency CYF ON CYF.intCurrencyID = CYXF.intFromCurrencyId
			LEFT JOIN tblSMCurrencyExchangeRate CYXT 
				ON ISNULL(CD.ysnUseFXPrice,0) = 1 AND CD.intCurrencyExchangeRateId IS NOT NULL AND CD.dblRate IS NOT NULL AND CD.intFXPriceUOMId IS NOT NULL
				AND CYXT.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId 
				AND CYXT.intToCurrencyId = ISNULL(CY.intMainCurrencyId, CY.intCurrencyID)
			LEFT JOIN tblSMCurrency CYT ON CYT.intCurrencyID = CYXT.intFromCurrencyId) AD ON AD.intContractDetailId = CD.intContractDetailId
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
LEFT JOIN tblCTBook BO ON BO.intBookId = WC.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = WC.intSubBookId
LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
