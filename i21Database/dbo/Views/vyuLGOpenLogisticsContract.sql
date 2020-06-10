CREATE VIEW vyuLGOpenLogisticsContract  
AS 
SELECT 
	[TERM] = CASE WHEN CAST(DATEDIFF(DAY,GETDATE(),CD.dtmEndDate) AS FLOAT)/365> 1 THEN 'LongTerm' ELSE 'ShortTerm' END COLLATE Latin1_General_CI_AS
	,[ALLOC_STATUS] = CASE WHEN ISNULL (PAlloc.QTY_ALLOC, 0)=  0 THEN 'UNSOLD' ELSE 'SOLD' END COLLATE Latin1_General_CI_AS
	,[PO_NUMBER] = CH.strContractNumber + '-' + CAST(CD.intContractSeq AS NVARCHAR(10))
	,[PODATE] = CONVERT(VARCHAR(10),CH.dtmContractDate,105) COLLATE Latin1_General_CI_AS
	,[SELLER_NAME] = EV.strName 
	,[ITEM_SHORTNAME] = Item.strItemNo 
	,[DESCRIPTION] = Item.strDescription 
	,[ORIGIN] = ItemOrigin.strDescription 
	,[CONTRACT_TERM] = CB.strContractBasis 
	,[START_DATE] = CD.dtmStartDate 
	,[END_DATE] = CD.dtmEndDate 
	,[QTY] = CD.dblQuantity
	,[PO_UNIT] = UnitMeasure.strUnitMeasure
	,[PO_QTY_IN_MT] = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,MTUOM.intItemUOMId,CD.dblQuantity) 
	,[CONTRACT_TYPE] = CASE WHEN CT.strPricingType ='Priced' THEN 'OT' WHEN CT.strPricingType ='Basis' THEN 'FX' ELSE 'UF' END COLLATE Latin1_General_CI_AS
	,[CURRENCY] = CASE WHEN CT.strPricingType ='Basis' THEN CRB.strCurrency ELSE CR.strCurrency END 
	,[PRICE] = dbo.fnCTGetSequencePrice(CD.intContractDetailId,null) 
	,[UNIT] = CASE WHEN CT.strPricingType ='Basis' THEN ISNULL(UnitMeasureBasis.strUnitMeasure,UnitMeasurePrice.strUnitMeasure) ELSE UnitMeasurePrice.strUnitMeasure END 
	,[PRICE_IN_KG] = CASE WHEN CT.strPricingType ='Basis' 
		THEN (dbo.fnCTGetSequencePrice(CD.intContractDetailId,NULL)) 
			* dbo.fnCTCalculateAmountBetweenCurrency(ISNULL(CD.intBasisCurrencyId,CD.intCurrencyId),CRUSD.intCurrencyID,1,0) 
				/ (ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,ISNULL(BasisItemUOM.intUnitMeasureId,PriceItemUOM.intUnitMeasureId),MTUnit.intUnitMeasureId,1)*1000,1))
		ELSE CD.dblCashPrice*dbo.fnCTCalculateAmountBetweenCurrency(CD.intCurrencyId,CRUSD.intCurrencyID,1,0) 
			/ (ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,PriceItemUOM.intUnitMeasureId,MTUnit.intUnitMeasureId,1)*1000,1))
		END 
	,[PO_VALUE] = CAST(CASE WHEN CT.strPricingType ='Basis'
		THEN CD.dblQuantity * dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,ISNULL(CD.intBasisUOMId,CD.intPriceItemUOMId),1)
			* dbo.fnCTGetSequencePrice(CD.intContractDetailId,null) * dbo.fnCTCalculateAmountBetweenCurrency(ISNULL(CD.intBasisCurrencyId,CD.intCurrencyId),CompanyDfltCR.intDefaultCurrencyId,1,0)
		ELSE ((CD.dblQuantity*CD.dblCashPrice) * dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intPriceItemUOMId,1)) 
			* dbo.fnCTCalculateAmountBetweenCurrency(CD.intCurrencyId,CompanyDfltCR.intDefaultCurrencyId,1,0)
		END AS NVARCHAR) + '*' + (SELECT strCurrency FROM tblSMCurrency WHERE intCurrencyID=CompanyDfltCR.intDefaultCurrencyId) 
	,[INT_TRACK_NO] = LGLoad.strLoadNumber 
	,[SHIP_QTY_MT] = LGLoad.LDQty 
	,[ALLOC_QTY_MT] = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,MTUOM.intItemUOMId,PAlloc.QTY_ALLOC) 
	,[INV_QTY] = ARInv.INV_QTY
	,[INVOICE_STATUS] = CASE WHEN ISNULL(ARInv.INV_QTY,0) = 0 THEN 'NOT INVOICED' 
		  WHEN dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,MTUOM.intItemUOMId,CD.dblQuantity) - ISNULL(ARInv.INV_QTY,0)<=0 THEN 'FULLY INVOICED'
		  ELSE 'PARTIALLY INVOICED' END COLLATE Latin1_General_CI_AS
FROM tblCTContractDetail CD JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId AND CH.intContractTypeId=1
JOIN tblEMEntity EV ON CH.intEntityId = EV.intEntityId
JOIN tblICItem Item ON CD.intItemId = Item.intItemId
JOIN tblICCommodityAttribute ItemType ON Item.intProductTypeId = ItemType.intCommodityAttributeId
JOIN tblICCommodityAttribute ItemOrigin ON Item.intOriginId = ItemOrigin.intCommodityAttributeId
JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
JOIN tblICItemUOM ItemUOM ON CD.intItemUOMId = ItemUOM.intItemUOMId
JOIN tblICUnitMeasure UnitMeasure ON ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
JOIN  tblCTPosition PS ON CH.intPositionId = PS.intPositionId
JOIN (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol LIKe '%MT%') MTUnit ON 1=1
JOIN tblICItemUOM MTUOM ON CD.intItemId = MTUOM.intItemId AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
JOIN tblCTPricingType CT ON CH.intPricingTypeId=CT.intPricingTypeId
LEFT JOIN (SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency='USD')CRUSD ON 1=1
LEFT JOIN tblICItemUOM BasisItemUOM ON CD.intBasisUOMId = BasisItemUOM.intItemUOMId
LEFT JOIN tblICItemUOM PriceItemUOM ON CD.intPriceItemUOMId = PriceItemUOM.intItemUOMId
LEFT JOIN (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference) CompanyDfltCR ON 1=1
LEFT JOIN (SELECT LD.intPContractDetailId,L.strLoadNumber,SUM (ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(LD.intItemUOMId,MTUOM.intItemUOMId,LD.dblQuantity),0)) LDQty
    FROM tblLGLoadDetail LD JOIN tblLGLoad L ON LD.intLoadId = L.intLoadId AND L.intPurchaseSale IN (1,3) AND L.intShipmentType=1
	JOIN (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol LIKe '%MT%') MTUnit ON 1=1
    JOIN tblICItemUOM MTUOM ON LD.intItemId = MTUOM.intItemId AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
	GROUP BY LD.intPContractDetailId,L.strLoadNumber)LGLoad ON CD.intContractDetailId = LGLoad.intPContractDetailId
LEFT JOIN tblSMCurrency CR ON CD.intCurrencyId = CR.intCurrencyID
LEFT JOIN tblSMCurrency CRB ON CD.intCurrencyId = CRB.intCurrencyID
LEFT JOIN tblICItemUOM ItemUOMPrice ON CD.intPriceItemUOMId = ItemUOMPrice.intItemUOMId
LEFT JOIN tblICItemUOM ItemUOMBasis ON CD.intBasisUOMId = ItemUOMBasis.intItemUOMId
LEFT JOIN tblICUnitMeasure UnitMeasurePrice ON ItemUOMPrice.intUnitMeasureId = UnitMeasurePrice.intUnitMeasureId
LEFT JOIN tblICUnitMeasure UnitMeasureBasis ON ItemUOMBasis.intUnitMeasureId = UnitMeasureBasis.intUnitMeasureId
LEFT JOIN (SELECT intPContractDetailId,SUM (dblPAllocatedQty) QTY_ALLOC FROM tblLGAllocationDetail GROUP BY intPContractDetailId) PAlloc ON CD.intContractDetailId = PAlloc.intPContractDetailId
LEFT JOIN (SELECT RP.intFutureMarketId,RPM.intFutureMonthId,RPM.dblLastSettle
           FROM tblRKFutSettlementPriceMarketMap RPM JOIN tblRKFuturesSettlementPrice RP ON RPM.intFutureSettlementPriceId = RP.intFutureSettlementPriceId
		   JOIN (SELECT RP.intFutureMarketId,RPM.intFutureMonthId,MAX (RP.dtmPriceDate) dtmPriceDate
		  FROM tblRKFutSettlementPriceMarketMap RPM JOIN tblRKFuturesSettlementPrice RP ON RPM.intFutureSettlementPriceId = RP.intFutureSettlementPriceId
		  WHERE ISNULL (dblLastSettle, 0) <> 0
		  GROUP BY RP.intFutureMarketId,RPM.intFutureMonthId)RK ON RP.intFutureMarketId=RK.intFutureMarketId 
		  AND RPM.intFutureMonthId=RK.intFutureMonthId AND RP.dtmPriceDate=RK.dtmPriceDate) RKFutPrice ON CD.intFutureMarketId = RKFutPrice.intFutureMarketId AND CD.intFutureMonthId = RKFutPrice.intFutureMonthId
LEFT JOIN (SELECT intPContractDetailId,MAX (INV_QTY) INV_QTY
    FROM
		(SELECT AD.intPContractDetailId,SUM(dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemUOMId,MTUOM.intItemUOMId,ARD.dblQtyOrdered))INV_QTY
		FROM tblARInvoiceDetail ARD
		INNER JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		INNER JOIN tblLGLoadDetail LD ON ARD.intLoadDetailId = LD.intLoadDetailId AND ARD.intContractDetailId IS NOT NULL
		INNER JOIN tblLGAllocationDetail AD ON LD.intAllocationDetailId = AD.intAllocationDetailId AND ARD.intContractDetailId = AD.intSContractDetailId
		INNER JOIN (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol LIKe '%MT%')MTUnit ON 1=1
		INNER JOIN tblICItemUOM MTUOM ON ARD.intItemId = MTUOM.intItemId AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
		WHERE ISNULL(AR.ysnCancelled, 0) = 0 AND AR.strType = 'Standard'
		GROUP BY AD.intPContractDetailId
		UNION ALL
		SELECT AD.intPContractDetailId,SUM(dbo.fnCTConvertQtyToTargetItemUOM(ARD.intItemUOMId,MTUOM.intItemUOMId,ARD.dblQtyOrdered))INV_QTY
		FROM tblARInvoiceDetail ARD
		INNER JOIN tblARInvoice AR ON ARD.intInvoiceId = AR.intInvoiceId
		INNER JOIN tblLGLoadDetail LD ON ARD.intLoadDetailId = LD.intLoadDetailId AND ARD.intContractDetailId IS NOT NULL
		INNER JOIN tblLGAllocationDetail AD ON LD.intAllocationDetailId = AD.intAllocationDetailId AND ARD.intContractDetailId = AD.intSContractDetailId
		INNER JOIN (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol LIKe '%MT%')MTUnit ON 1=1
		INNER JOIN tblICItemUOM MTUOM ON ARD.intItemId = MTUOM.intItemId AND MTUnit.intUnitMeasureId = MTUOM.intUnitMeasureId
		WHERE ISNULL(AR.ysnCancelled, 0) = 0 AND AR.strType = 'Provisional'
		GROUP BY AD.intPContractDetailId)AR
	GROUP BY intPContractDetailId) ARInv ON CD.intContractDetailId = ARInv.intPContractDetailId
LEFT JOIN (SELECT CD.intContractDetailId
                 ,(PFD.dblFixationPrice*dbo.fnCTCalculateAmountBetweenCurrency(CD.intBasisCurrencyId,PC.intFinalCurrencyId,1,0))/ISNULL(dbo.fnCTConvertQuantityToTargetItemUOM(CD.intItemId,ItemUOM.intUnitMeasureId,CMUnitMeasure.intUnitMeasureId,1),1)dblFixationPrice
				 ,PFD.dblNoOfLots,ISNULL(CD.dblBasis,0)dblBasis
		   FROM tblCTPriceFixation PF JOIN tblCTPriceFixationDetail PFD ON PF.intPriceFixationId=PFD.intPriceFixationId 
		   JOIN tblCTPriceContract PC ON PF.intPriceContractId = PC.intPriceContractId
		   JOIN tblICCommodityUnitMeasure CMUnitMeasure ON PC.intFinalPriceUOMId = CMUnitMeasure.intCommodityUnitMeasureId
		   JOIN tblCTContractDetail CD ON PF.intContractDetailId = CD.intContractDetailId
		   JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId AND CH.intContractTypeId=1
		   JOIN tblICItemUOM ItemUOM ON CD.intBasisUOMId = ItemUOM.intItemUOMId)PF ON CD.intContractDetailId = PF.intContractDetailId
WHERE dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,MTUOM.intItemUOMId,CD.dblQuantity) - ISNULL(ARInv.INV_QTY,0) >0
	AND dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,MTUOM.intItemUOMId,CD.dblQuantity) - ISNULL(LGLoad.LDQty,0) >0