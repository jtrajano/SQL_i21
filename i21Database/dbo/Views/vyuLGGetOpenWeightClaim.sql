CREATE VIEW vyuLGGetOpenWeightClaim
AS
SELECT TOP 100 PERCENT Convert(INT, ROW_NUMBER() OVER (
			ORDER BY intLoadId
			)) AS intKeyColumn
	,dblClaimableAmount = CASE WHEN ((CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END) < 0)
								THEN (CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END) * - 1
								ELSE (CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END)
								END
	,*
FROM 
	--Inbound/Drop Ship side
	(SELECT intPurchaseSale = 1 
		,strType = 'Inbound' COLLATE Latin1_General_CI_AS
		,strContractNumber = CH.strContractNumber
		,intContractTypeId = CH.intContractTypeId
		,intContractSeq = CD.intContractSeq
		,strEntityName = EM.strName
		,intEntityId = EM.intEntityId
		,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
									THEN EMPD.intEntityId
								WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
									THEN EMPH.intEntityId
								ELSE EM.intEntityId END
		,strPaidTo = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
							THEN EMPD.strName
						WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
							THEN EMPH.strName
						ELSE EM.strName END
		,intLoadId = L.intLoadId
		,strLoadNumber = L.strLoadNumber
		,dtmScheduledDate = L.dtmScheduledDate
		,strTransportationMode = CASE L.intTransportationMode 
									WHEN 1 THEN 'Truck' 
									WHEN 2 THEN 'Ocean Vessel' 
									WHEN 3 THEN 'Rail' END COLLATE Latin1_General_CI_AS
		,dtmETAPOD = L.dtmETAPOD
		,dtmLastWeighingDate = L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,strBLNumber = L.strBLNumber
		,dtmBLDate = L.dtmBLDate
		,intWeightUnitMeasureId = L.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,intWeightId = CH.intWeightId
		,strWeightGradeDesc = WG.strWeightGradeDesc
		,dblShippedNetWt = (CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0))
		,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt = CASE WHEN (CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) > 0.0
							THEN ((CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
						ELSE 0.0 END
		,dblWeightLoss = CASE WHEN (RI.dblNet - CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) < 0.0
							THEN (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) END
		,dblClaimableWt = CASE WHEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
							THEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100))
							ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						END
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CAST(CASE WHEN IsNull(WC.intWeightClaimId, 0) <> 0 THEN 1 ELSE 0 END AS BIT)
		,dblSeqPrice = AD.dblSeqPrice
		,strSeqCurrency = AD.strSeqCurrency
		,strSeqPriceUOM = AD.strSeqPriceUOM
		,intSeqCurrencyId = AD.intSeqCurrencyId
		,intSeqPriceUOMId = ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)
		,ysnSeqSubCurrency = AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId), AD.dblSeqPrice)
		,intItemId = CD.intItemId
		,intContractDetailId = CD.intContractDetailId
		,intBookId = CD.intBookId
		,strBook = BO.strBook
		,intSubBookId = CD.intSubBookId
		,strSubBook = SB.strSubBook
		,strReferenceNumber = WC.strReferenceNumber
		,dtmTransDate = WC.dtmTransDate
		,dtmActualWeighingDate = WC.dtmActualWeighingDate
		,strItemNo = I.strItemNo
		,strCommodityCode = C.strCommodityCode
		,strContractItemNo = CONI.strContractItemNo
		,strContractItemName = CONI.strContractItemName
		,strOrigin = ISNULL(OG.strCountry, OG2.strCountry)
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId), 1)
		,intContractBasisId = CH.intFreightTermId
		,strContractBasis = CB.strContractBasis
		,strERPPONumber = CD.strERPPONumber
		,strERPItemNumber = CD.strERPItemNumber
		,strSublocation = SL.strSubLocation
		,CD.intPurchasingGroupId
		,PG.strName AS strPurchasingGroupName
		,PG.strDescription AS strPurchasingGroupDesc
	FROM tblLGLoad L
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
	JOIN (SELECT
			intContractDetailId = CD.intContractDetailId
			,intSeqPriceUOMId = ISNULL(CD.intAdjItemUOMId,CD.intPriceItemUOMId)
			,strSeqPriceUOM = ISNULL(FM.strUnitMeasure, UM.strUnitMeasure)
			,intSeqCurrencyId = COALESCE(CYXT.intToCurrencyId, CYXF.intFromCurrencyId, MCY.intMainCurrencyId, CY.intCurrencyID)
			,strSeqCurrency = COALESCE(CYT.strCurrency, CYF.strCurrency, MCY.strCurrency, CY.strCurrency)
			,ysnSeqSubCurrency = CY.ysnSubCurrency
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
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId AND CA.strType = 'Origin'
	LEFT JOIN tblICItemContract CONI ON CONI.intItemId = I.intItemId AND CD.intItemContractId = CONI.intItemContractId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CONI.intCountryId
	LEFT JOIN tblSMCountry OG2 ON OG2.intCountryID = CA.intCountryID
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	LEFT JOIN (
		SELECT SUM(ReceiptItem.dblNet) dblNet
			,ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		FROM tblICInventoryReceiptItem ReceiptItem
		JOIN tblICInventoryReceipt RI ON RI.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE RI.strReceiptType <> 'Inventory Return'
		GROUP BY ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		) RI ON RI.intSourceId = LD.intLoadDetailId
		AND RI.intLineNo = LD.intPContractDetailId
		AND RI.intOrderId = CH.intContractHeaderId
		AND L.intPurchaseSale IN (1, 3)
	LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 1
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) WUI
	OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
	CROSS APPLY (SELECT intCount = COUNT(*) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
	CROSS APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
	CROSS APPLY (SELECT dblIRNet = SUM(IRI.dblNet) FROM tblICInventoryReceipt IR 
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
	WHERE L.intPurchaseSale IN (1, 3)
		AND ((L.intPurchaseSale = 1 AND L.intShipmentStatus = 4) OR (L.intPurchaseSale <> 1 AND L.intShipmentStatus IN (6,11)))
		AND WC.intWeightClaimId IS NULL
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	
	UNION ALL

	--Outbound/Dropship Side
	SELECT intPurchaseSale = 2 
		,strType = 'Outbound' COLLATE Latin1_General_CI_AS
		,strContractNumber = CH.strContractNumber
		,intContractTypeId = CH.intContractTypeId
		,intContractSeq = CD.intContractSeq
		,strEntityName = EM.strName
		,intEntityId = EM.intEntityId
		,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
									THEN EMPD.intEntityId
								WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
									THEN EMPH.intEntityId
								ELSE EM.intEntityId END
		,strPaidTo = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
							THEN EMPD.strName
						WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
							THEN EMPH.strName
						ELSE EM.strName END
		,intLoadId = L.intLoadId
		,strLoadNumber = L.strLoadNumber
		,dtmScheduledDate = L.dtmScheduledDate
		,strTransportationMode = CASE L.intTransportationMode 
									WHEN 1 THEN 'Truck' 
									WHEN 2 THEN 'Ocean Vessel' 
									WHEN 3 THEN 'Rail' END COLLATE Latin1_General_CI_AS
		,dtmETAPOD = L.dtmETAPOD
		,dtmLastWeighingDate = L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,strBLNumber = L.strBLNumber
		,dtmBLDate = L.dtmBLDate
		,intWeightUnitMeasureId = L.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,intWeightId = CH.intWeightId
		,strWeightGradeDesc = WG.strWeightGradeDesc
		,dblShippedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
		,dblReceivedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt = 0.0
		,dblWeightLoss = 0.0
		,dblClaimableWt = 0.0
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CAST(CASE WHEN (WC.intWeightClaimId IS NULL) THEN 1 ELSE 0 END AS BIT)
		,dblSeqPrice = AD.dblSeqPrice
		,strSeqCurrency = AD.strSeqCurrency
		,strSeqPriceUOM = AD.strSeqPriceUOM
		,intSeqCurrencyId = AD.intSeqCurrencyId
		,intSeqPriceUOMId = AD.intSeqPriceUOMId
		,ysnSeqSubCurrency = AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId), AD.dblSeqPrice)
		,intItemId = CD.intItemId
		,intContractDetailId = CD.intContractDetailId
		,intBookId = CD.intBookId
		,strBook = BO.strBook
		,intSubBookId = CD.intSubBookId
		,strSubBook = SB.strSubBook
		,strReferenceNumber = WC.strReferenceNumber
		,dtmTransDate = WC.dtmTransDate
		,dtmActualWeighingDate = WC.dtmActualWeighingDate
		,strItemNo = I.strItemNo
		,strCommodityCode = C.strCommodityCode
		,strContractItemNo = CONI.strContractItemNo
		,strContractItemName = CONI.strContractItemName
		,strOrigin = ISNULL(OG.strCountry, OG2.strCountry)
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, AD.intSeqPriceUOMId, 1)
		,intContractBasisId = CH.intFreightTermId
		,strContractBasis = CB.strContractBasis
		,strERPPONumber = CD.strERPPONumber
		,strERPItemNumber = CD.strERPItemNumber
		,strSublocation = SL.strSubLocation
		,CD.intPurchasingGroupId
		,strPurchasingGroupName = PG.strName
		,strPurchasingGroupDesc = PG.strDescription
	FROM tblLGLoad L
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intSContractDetailId
	JOIN (SELECT
			intContractDetailId = CD.intContractDetailId
			,intSeqPriceUOMId = ISNULL(CD.intAdjItemUOMId,CD.intPriceItemUOMId)
			,strSeqPriceUOM = ISNULL(FM.strUnitMeasure, UM.strUnitMeasure)
			,intSeqCurrencyId = COALESCE(CYXT.intToCurrencyId, CYXF.intFromCurrencyId, MCY.intMainCurrencyId, CY.intCurrencyID)
			,strSeqCurrency = COALESCE(CYT.strCurrency, CYF.strCurrency, MCY.strCurrency, CY.strCurrency)
			,ysnSeqSubCurrency = CY.ysnSubCurrency
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
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblICItemContract CONI ON CONI.intItemId = I.intItemId AND CD.intItemContractId = CONI.intItemContractId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CONI.intCountryId
	LEFT JOIN tblSMCountry OG2 ON OG2.intCountryID = CA.intCountryID
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 2
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) WUI
	OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
	CROSS APPLY (SELECT intCount = COUNT(*) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
	CROSS APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
	WHERE L.intPurchaseSale IN (2, 3)
		AND (L.intShipmentStatus = 6 OR (L.intPurchaseSale = 3 AND L.intShipmentStatus = 11))
		AND WC.intWeightClaimId IS NULL
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	) t1