CREATE VIEW vyuLGOpenLogisticsContract (
	"TERM"
	,"ALLOC_STATUS"
	,"PO_NUMBER"
	,"PODATE"
	,"SELLER_NAME"
	,"ITEM_SHORTNAME"
	,"DESCRIPTION"
	,"ORIGIN"
	,"CONTRACT_TERM"
	,"START_DATE"
	,"END_DATE"
	,"QTY"
	,"PO_UNIT"
	,"PO_QTY_IN_MT"
	,"CONTRACT_TYPE"
	,"CURRENCY"
	,"PRICE"
	,"UNIT"
	,"PRICE_IN_KG"
	,"PO_VALUE"
	,"INT_TRACK_NO"
	,"SHIP_QTY_MT"
	,"ALLOC_QTY_MT"
	,"INV_QTY"
	,"INVOICE_STATUS"
	)
AS
SELECT CASE 
		WHEN CAST(DATEDIFF(day, GETDATE(), CD.dtmEndDate) AS FLOAT) / 365 > 1
			THEN 'LongTerm'
		ELSE 'ShortTerm'
		END TERM
	,CASE 
		WHEN ISNULL(PAlloc.QTY_ALLOC, 0) = 0
			THEN 'UNSOLD'
		ELSE 'SOLD'
		END ALLOC_STATUS
	,SUBSTRING(CH.strContractNumber, PATINDEX('%[0-9]%', CH.strContractNumber), PATINDEX('%[0-9][^0-9]%', CH.strContractNumber + 't') - PATINDEX('%[0-9]%', CH.strContractNumber) + 1) PO_NUMBER
	,CONVERT(VARCHAR(10), CH.dtmContractDate, 105) PODATE
	,EV.strName SELLER_NAME
	,Item.strItemNo ITEM_SHORTNAME
	,Item.strDescription DESCRIPTION
	,ItemOrigin.strDescription ORIGIN
	,CB.strContractBasis CONTRACT_TERM
	,CD.dtmStartDate START_DATE
	,CD.dtmEndDate END_DATE
	,CD.dblQuantity QTY
	,UnitMeasure.strUnitMeasure PO_UNIT
	,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, MTUOM.intItemUOMId, CD.dblQuantity) PO_QTY_IN_MT
	,CASE 
		WHEN CT.strPricingType = 'Priced'
			THEN 'OT'
		WHEN CT.strPricingType = 'Basis'
			THEN 'FX'
		ELSE 'UF'
		END CONTRACT_TYPE
	,CASE 
		WHEN CT.strPricingType = 'Basis'
			THEN CRB.strCurrency
		ELSE CR.strCurrency
		END CURRENCY
	,CASE 
		WHEN CT.strPricingType = 'Basis'
			THEN ISNULL(PF.dblNoOfLots * (PF.dblFixationPrice + PF.dblBasis), 0) + ISNULL((CD.dblNoOfLots - PF.dblNoOfLots) * RKFutPrice.dblLastSettle, 0)
		ELSE CD.dblCashPrice
		END PRICE
	,CASE 
		WHEN CT.strPricingType = 'Basis'
			THEN UnitMeasureBasis.strUnitMeasure
		ELSE UnitMeasurePrice.strUnitMeasure
		END UNIT
	,CASE 
		WHEN CT.strPricingType = 'Basis'
			THEN (ISNULL(PF.dblNoOfLots * (PF.dblFixationPrice + PF.dblBasis), 0) + ISNULL((CD.dblNoOfLots - PF.dblNoOfLots) * RKFutPrice.dblLastSettle, 0)) * dbo.fnCTCalculateAmountBetweenCurrency(CD.intBasisCurrencyId, CRUSD.intCurrencyID, 1, 0) / (ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, BasisItemUOM.intUnitMeasureId, MTUnit.intUnitMeasureId, 1) * 1000, 1))
		ELSE CD.dblCashPrice * dbo.fnCTCalculateAmountBetweenCurrency(CD.intCurrencyId, CRUSD.intCurrencyID, 1, 0) / (ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, PriceItemUOM.intUnitMeasureId, MTUnit.intUnitMeasureId, 1) * 1000, 1))
		END PRICE_IN_KG
	,CASE 
		WHEN CT.strPricingType = 'Basis'
			THEN CD.dblQuantity * dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CD.intBasisUOMId, 1) * ISNULL(PF.dblNoOfLots * (PF.dblFixationPrice + PF.dblBasis), 0) + ISNULL((CD.dblNoOfLots - PF.dblNoOfLots) * RKFutPrice.dblLastSettle, 0) * dbo.fnCTCalculateAmountBetweenCurrency(CD.intBasisCurrencyId, CompanyDfltCR.intDefaultCurrencyId, 1, 0)
		ELSE ((CD.dblQuantity * CD.dblCashPrice) * dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, CD.intPriceItemUOMId, 1)) * dbo.fnCTCalculateAmountBetweenCurrency(CD.intCurrencyId, CompanyDfltCR.intDefaultCurrencyId, 1, 0)
		END PO_VALUE
	,LGLoad.strLoadNumber INT_TRACK_NO
	,LGLoad.LDQty SHIP_QTY_MT
	,dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, MTUOM.intItemUOMId, PAlloc.QTY_ALLOC) ALLOC_QTY_MT
	,ARInv.INV_QTY
	,CASE 
		WHEN ISNULL(ARInv.INV_QTY, 0) = 0
			THEN 'NOT INVOICED'
		WHEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, MTUOM.intItemUOMId, CD.dblQuantity) - ISNULL(ARInv.INV_QTY, 0) <= 0
			THEN 'FULLY INVOICED'
		ELSE 'PARTIALLY INVOICED'
		END INVOICE_STATUS
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	AND CH.intContractTypeId = 1
JOIN tblEMEntity EV ON CH.intEntityId = EV.intEntityId
JOIN tblICItem Item ON CD.intItemId = Item.intItemId
JOIN tblICCommodityAttribute ItemType ON Item.intProductTypeId = ItemType.intCommodityAttributeId
JOIN tblICCommodityAttribute ItemOrigin ON Item.intOriginId = ItemOrigin.intCommodityAttributeId
JOIN tblCTContractBasis CB ON CH.intContractBasisId = CB.intContractBasisId
JOIN tblICItemUOM ItemUOM ON CD.intItemUOMId = ItemUOM.intItemUOMId
JOIN tblICUnitMeasure UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
JOIN tblCTPosition PS ON CH.intPositionId = PS.intPositionId
JOIN (
	SELECT TOP 1 intUnitMeasureId
	FROM tblICUnitMeasure
	WHERE strSymbol LIKE '%MT%'
	) MTUnit ON 1 = 1
JOIN tblICItemUOM MTUOM ON CD.intItemId = MTUOM.intItemId
	AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
JOIN tblCTPricingType CT ON CH.intPricingTypeId = CT.intPricingTypeId
LEFT JOIN (
	SELECT TOP 1 intCurrencyID
	FROM tblSMCurrency
	WHERE strCurrency = 'USD'
	) CRUSD ON 1 = 1
LEFT JOIN tblICItemUOM BasisItemUOM ON CD.intBasisUOMId = BasisItemUOM.intItemUOMId
LEFT JOIN tblICItemUOM PriceItemUOM ON CD.intPriceItemUOMId = PriceItemUOM.intItemUOMId
LEFT JOIN (
	SELECT TOP 1 intDefaultCurrencyId
	FROM tblSMCompanyPreference
	) CompanyDfltCR ON 1 = 1
LEFT JOIN (
	SELECT LD.intPContractDetailId
		,L.strLoadNumber
		,SUM(ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId, MTUOM.intItemUOMId, LD.dblQuantity), 0)) LDQty
	FROM tblLGLoadDetail LD
	JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId
		AND L.intPurchaseSale IN (
			1
			,3
			)
		AND L.intShipmentType = 1
	JOIN (
		SELECT TOP 1 intUnitMeasureId
		FROM tblICUnitMeasure
		WHERE strSymbol LIKE '%MT%'
		) MTUnit ON 1 = 1
	JOIN tblICItemUOM MTUOM ON LD.intItemId = MTUOM.intItemId
		AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
	GROUP BY LD.intPContractDetailId
		,L.strLoadNumber
	) LGLoad ON CD.intContractDetailId = LGLoad.intPContractDetailId
LEFT JOIN tblSMCurrency CR ON CD.intCurrencyId = CR.intCurrencyID
LEFT JOIN tblSMCurrency CRB ON CD.intCurrencyId = CRB.intCurrencyID
LEFT JOIN tblICItemUOM ItemUOMPrice ON CD.intPriceItemUOMId = ItemUOMPrice.intItemUOMId
LEFT JOIN tblICItemUOM ItemUOMBasis ON CD.intBasisUOMId = ItemUOMBasis.intItemUOMId
LEFT JOIN tblICUnitMeasure UnitMeasurePrice ON ItemUOMPrice.intUnitMeasureId = UnitMeasurePrice.intUnitMeasureId
LEFT JOIN tblICUnitMeasure UnitMeasureBasis ON ItemUOMBasis.intUnitMeasureId = UnitMeasureBasis.intUnitMeasureId
LEFT JOIN (
	SELECT intPContractDetailId
		,SUM(dblPAllocatedQty) QTY_ALLOC
	FROM tblLGAllocationDetail
	GROUP BY intPContractDetailId
	) PAlloc ON CD.intContractDetailId = PAlloc.intPContractDetailId
LEFT JOIN (
	SELECT RP.intFutureMarketId
		,RPM.intFutureMonthId
		,RPM.dblLastSettle
	FROM tblRKFutSettlementPriceMarketMap RPM
	JOIN tblRKFuturesSettlementPrice RP ON RPM.intFutureSettlementPriceId = RP.intFutureSettlementPriceId
	JOIN (
		SELECT RP.intFutureMarketId
			,RPM.intFutureMonthId
			,MAX(RP.dtmPriceDate) dtmPriceDate
		FROM tblRKFutSettlementPriceMarketMap RPM
		JOIN tblRKFuturesSettlementPrice RP ON RPM.intFutureSettlementPriceId = RP.intFutureSettlementPriceId
		WHERE ISNULL(dblLastSettle, 0) <> 0
		GROUP BY RP.intFutureMarketId
			,RPM.intFutureMonthId
		) RK ON RP.intFutureMarketId = RK.intFutureMarketId
		AND RPM.intFutureMonthId = RK.intFutureMonthId
		AND RP.dtmPriceDate = RK.dtmPriceDate
	) RKFutPrice ON CD.intFutureMarketId = RKFutPrice.intFutureMarketId
	AND CD.intFutureMonthId = RKFutPrice.intFutureMonthId
LEFT JOIN (
	SELECT intPContractDetailId
		,MAX(INV_QTY) INV_QTY
	FROM (
		SELECT AD.intPContractDetailId
			,SUM(dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemUOMId, MTUOM.intItemUOMId, ARD.dblQtyOrdered)) INV_QTY
		FROM tblARInvoiceDetail ARD
		INNER JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		INNER JOIN tblLGLoadDetail LD ON ARD.intLoadDetailId = LD.intLoadDetailId
			AND ARD.intContractDetailId IS NOT NULL
		INNER JOIN tblLGAllocationDetail AD ON LD.intAllocationDetailId = AD.intAllocationDetailId
			AND ARD.intContractDetailId = AD.intSContractDetailId
		INNER JOIN (
			SELECT TOP 1 intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strSymbol LIKE '%MT%'
			) MTUnit ON 1 = 1
		INNER JOIN tblICItemUOM MTUOM ON ARD.intItemId = MTUOM.intItemId
			AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
		WHERE ISNULL(AR.ysnCancelled, 0) = 0
			AND AR.strType = 'Standard'
		GROUP BY AD.intPContractDetailId
		
		UNION ALL
		
		SELECT AD.intPContractDetailId
			,SUM(dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemUOMId, MTUOM.intItemUOMId, ARD.dblQtyOrdered)) INV_QTY
		FROM tblARInvoiceDetail ARD
		INNER JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		INNER JOIN tblLGLoadDetail LD ON ARD.intLoadDetailId = LD.intLoadDetailId
			AND ARD.intContractDetailId IS NOT NULL
		INNER JOIN tblLGAllocationDetail AD ON LD.intAllocationDetailId = AD.intAllocationDetailId
			AND ARD.intContractDetailId = AD.intSContractDetailId
		INNER JOIN (
			SELECT TOP 1 intUnitMeasureId
			FROM tblICUnitMeasure
			WHERE strSymbol LIKE '%MT%'
			) MTUnit ON 1 = 1
		INNER JOIN tblICItemUOM MTUOM ON ARD.intItemId = MTUOM.intItemId
			AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
		WHERE ISNULL(AR.ysnCancelled, 0) = 0
			AND AR.strType = 'Provisional'
		GROUP BY AD.intPContractDetailId
		) AR
	GROUP BY intPContractDetailId
	) ARInv ON CD.intContractDetailId = ARInv.intPContractDetailId
LEFT JOIN (
	SELECT CD.intContractDetailId
		,(PFD.dblFixationPrice * dbo.fnCTCalculateAmountBetweenCurrency(CD.intBasisCurrencyId, PC.intFinalCurrencyId, 1, 0)) / ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId, ItemUOM.intUnitMeasureId, CMUnitMeasure.intUnitMeasureId, 1), 1) dblFixationPrice
		,PFD.dblNoOfLots
		,ISNULL(CD.dblBasis, 0) dblBasis
	FROM tblCTPriceFixation PF
	JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId = PFD.intPriceFixationId
	JOIN tblCTPriceContract PC ON PF.intPriceContractId = PC.intPriceContractId
	JOIN tblICCommodityUnitMeasure CMUnitMeasure ON PC.intFinalPriceUOMId = CMUnitMeasure.intCommodityUnitMeasureId
	JOIN tblCTContractDetail CD ON PF.intContractDetailId = CD.intContractDetailId
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		AND CH.intContractTypeId = 1
	JOIN tblICItemUOM ItemUOM ON CD.intBasisUOMId = ItemUOM.intItemUOMId
	) PF ON CD.intContractDetailId = PF.intContractDetailId
WHERE dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, MTUOM.intItemUOMId, CD.dblQuantity) - ISNULL(ARInv.INV_QTY, 0) > 0
	AND dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, MTUOM.intItemUOMId, CD.dblQuantity) - ISNULL(LGLoad.LDQty, 0) > 0