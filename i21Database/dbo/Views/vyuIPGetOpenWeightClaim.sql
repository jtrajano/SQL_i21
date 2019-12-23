Create VIEW vyuIPGetOpenWeightClaim
AS
SELECT intPurchaseSale = 1
	,intLoadId = L.intLoadId
	,dtmClaimValidTill = NULL
	,intWeightUnitMeasureId = L.intWeightUnitMeasureId
	,dblShippedNetWt = (
		CASE 
			WHEN (CLCT.intCount) > 0
				THEN (CLNW.dblLinkNetWt)
			ELSE LD.dblNet
			END - ISNULL(IRN.dblIRNet, 0)
		)
	,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
	,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
									THEN EMPD.intEntityId
								WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
									THEN EMPH.intEntityId
								ELSE EM.intEntityId END
	,dblFranchiseWt = CASE 
		WHEN (
				CASE 
					WHEN (CLCT.intCount > 0)
						THEN (CLNW.dblLinkNetWt)
					ELSE LD.dblNet
					END * WG.dblFranchise / 100
				) <> 0.0
			THEN (
					(
						CASE 
							WHEN (CLCT.intCount > 0)
								THEN (CLNW.dblLinkNetWt)
							ELSE LD.dblNet
							END - ISNULL(IRN.dblIRNet, 0)
						) * WG.dblFranchise / 100
					)
		ELSE 0.0
		END
	,dblWeightLoss = CASE 
		WHEN (
				RI.dblNet - CASE 
					WHEN (CLCT.intCount > 0)
						THEN (CLNW.dblLinkNetWt)
					ELSE LD.dblNet
					END
				) < 0.0
			THEN (
					RI.dblNet - CASE 
						WHEN (CLCT.intCount) > 0
							THEN (CLNW.dblLinkNetWt)
						ELSE LD.dblNet
						END
					)
		ELSE (
				RI.dblNet - CASE 
					WHEN (CLCT.intCount) > 0
						THEN (CLNW.dblLinkNetWt)
					ELSE LD.dblNet
					END
				)
		END
	,dblClaimableWt = CASE 
		WHEN (
				(
					RI.dblNet - CASE 
						WHEN (CLCT.intCount) > 0
							THEN (CLNW.dblLinkNetWt)
						ELSE LD.dblNet
						END
					) + (LD.dblNet * WG.dblFranchise / 100)
				) < 0.0
			THEN (
					(
						RI.dblNet - CASE 
							WHEN (CLCT.intCount) > 0
								THEN (CLNW.dblLinkNetWt)
							ELSE LD.dblNet
							END
						) + (LD.dblNet * WG.dblFranchise / 100)
					)
		ELSE (
				RI.dblNet - CASE 
					WHEN (CLCT.intCount) > 0
						THEN (CLNW.dblLinkNetWt)
					ELSE LD.dblNet
					END
				)
		END
	,intWeightClaimId = WC.intWeightClaimId
	,dblSeqPrice = AD.dblSeqPrice
	,strSeqPriceUOM = AD.strSeqPriceUOM
	,intSeqCurrencyId = AD.intSeqCurrencyId
	,intSeqPriceUOMId = ISNULL(CD.intPriceItemUOMId, CD.intAdjItemUOMId)
	,ysnSeqSubCurrency = AD.ysnSeqBasisSubCurrency
	,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, ISNULL(CD.intPriceItemUOMId, CD.intAdjItemUOMId), AD.dblSeqPrice)
	,intItemId = CD.intItemId
	,intContractDetailId = CD.intContractDetailId
	,intBookId = CD.intBookId
	,intSubBookId = CD.intSubBookId
	,strReferenceNumber = WC.strReferenceNumber
	,dtmTransDate = WC.dtmTransDate
	,dtmActualWeighingDate = WC.dtmActualWeighingDate
	,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM(WUI.intWeightUOMId, ISNULL(CD.intPriceItemUOMId, CD.intAdjItemUOMId), 1)
	,CLCT.intCount AS intContainerCount
	,IRC.intIRCount AS intIRCount
	,L.intCompanyId
	,dtmETAPOD = L.dtmETAPOD
	,dtmLastWeighingDate = L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dblFranchise = WG.dblFranchise / 100
FROM tblLGLoad L
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId

JOIN (
	SELECT intContractDetailId = CD.intContractDetailId
		,intSeqPriceUOMId = ISNULL(CD.intAdjItemUOMId, CD.intPriceItemUOMId)
		,strSeqPriceUOM = ISNULL(FM.strUnitMeasure, UM.strUnitMeasure)
		,intSeqCurrencyId = COALESCE(CYT.intCurrencyID, CYF.intCurrencyID, MCY.intCurrencyID, CY.intCurrencyID)
		,strSeqCurrency = COALESCE(CYT.strCurrency, CYF.strCurrency, MCY.strCurrency, CY.strCurrency)
		,intSeqBasisCurrencyId = COALESCE(CYT.intCurrencyID, CYF.intCurrencyID, CY.intCurrencyID)
		,strSeqBasisCurrency = COALESCE(CYT.strCurrency, CYF.strCurrency, CY.strCurrency)
		,ysnSeqBasisSubCurrency = COALESCE(CYT.ysnSubCurrency, CYF.ysnSubCurrency, CY.ysnSubCurrency)
		,dblSeqPrice = CD.dblCashPrice * (
			CASE 
				WHEN (CYXT.intToCurrencyId IS NOT NULL)
					THEN 1 / ISNULL(CD.dblRate, 1) / CASE 
							WHEN CY.ysnSubCurrency = 1
								THEN 100
							ELSE 1
							END
				ELSE ISNULL(CD.dblRate, 1)
				END
			)
		
	FROM tblCTContractDetail CD
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItemUOM FU ON ISNULL(CD.ysnUseFXPrice, 0) = 1
		AND CD.intCurrencyExchangeRateId IS NOT NULL
		AND CD.dblRate IS NOT NULL
		AND CD.intFXPriceUOMId IS NOT NULL
		AND FU.intItemUOMId = CD.intFXPriceUOMId
	LEFT JOIN tblICUnitMeasure FM ON FM.intUnitMeasureId = FU.intUnitMeasureId
	LEFT JOIN tblSMCurrency CY ON CY.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblSMCurrency MCY ON MCY.intCurrencyID = CY.intMainCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRate CYXF ON ISNULL(CD.ysnUseFXPrice, 0) = 1
		AND CD.intCurrencyExchangeRateId IS NOT NULL
		AND CD.dblRate IS NOT NULL
		AND CD.intFXPriceUOMId IS NOT NULL
		AND CYXF.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
		AND CYXF.intFromCurrencyId = ISNULL(CY.intMainCurrencyId, CY.intCurrencyID)
	LEFT JOIN tblSMCurrency CYF ON CYF.intCurrencyID = CYXF.intToCurrencyId
	LEFT JOIN tblSMCurrencyExchangeRate CYXT ON ISNULL(CD.ysnUseFXPrice, 0) = 1
		AND CD.intCurrencyExchangeRateId IS NOT NULL
		AND CD.dblRate IS NOT NULL
		AND CD.intFXPriceUOMId IS NOT NULL
		AND CYXT.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
		AND CYXT.intToCurrencyId = ISNULL(CY.intMainCurrencyId, CY.intCurrencyID)
	LEFT JOIN tblSMCurrency CYT ON CYT.intCurrencyID = CYXT.intFromCurrencyId
	) AD ON AD.intContractDetailId = CD.intContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
--JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
	AND CA.strType = 'Origin'
LEFT JOIN tblICItemContract CONI ON CONI.intItemId = I.intItemId
	AND CD.intItemContractId = CONI.intItemContractId
LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId

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
	AND L.intPurchaseSale IN (
		1
		,3
		)
LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = L.intLoadId
	AND WC.intPurchaseSale = 1
OUTER APPLY (
	SELECT TOP 1 intWeightUOMId = IU.intItemUOMId
	FROM tblICItemUOM IU
	WHERE IU.intItemId = CD.intItemId
		AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
	) WUI
CROSS APPLY (
	SELECT intCount = COUNT(*)
	FROM tblLGLoadDetailContainerLink
	WHERE intLoadDetailId = LD.intLoadDetailId
	) CLCT
CROSS APPLY (
	SELECT dblLinkNetWt = SUM(dblLinkNetWt)
	FROM tblLGLoadDetailContainerLink
	WHERE intLoadDetailId = LD.intLoadDetailId
	) CLNW
CROSS APPLY (
	SELECT dblIRNet = SUM(IRI.dblNet)
	FROM tblICInventoryReceipt IR
	JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
	WHERE IRI.intSourceId = LD.intLoadDetailId
		AND IRI.intLineNo = CD.intContractDetailId
		AND IRI.intOrderId = CH.intContractHeaderId
		AND IR.strReceiptType = 'Inventory Return'
	) IRN
CROSS APPLY (
	SELECT intIRCount = Count(*)
	FROM tblICInventoryReceiptItem ReceiptItem
	JOIN tblICInventoryReceipt RI ON RI.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
	WHERE RI.strReceiptType <> 'Inventory Return'
		AND ReceiptItem.intSourceId = LD.intLoadDetailId
		AND ReceiptItem.intLineNo = CD.intContractDetailId
		AND ReceiptItem.intOrderId = CH.intContractHeaderId
	) IRC
WHERE L.intPurchaseSale IN (
		1
		,3
		)
	AND (
		(
			L.intPurchaseSale = 1
			AND L.intShipmentStatus = 4
			)
		OR (
			L.intPurchaseSale <> 1
			AND L.intShipmentStatus IN (
				6
				,11
				)
			)
		)
	AND ISNULL(LD.ysnNoClaim, 0) = 0

