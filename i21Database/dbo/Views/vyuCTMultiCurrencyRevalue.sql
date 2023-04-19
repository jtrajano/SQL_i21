
Create VIEW [dbo].[vyuCTMultiCurrencyRevalue]

AS 

	SELECT   strTransactionType		=	CT.strContractType
			,strTransactionId		=	CH.strContractNumber
			,strTransactionDate		=	CD.dtmStartDate
			,strTransactionDueDate	=	CD.dtmEndDate
			,strVendorName			=	EY.strName
			,strCommodity			=	CY.strDescription
			,strLineOfBusiness		=	CG.strDescription
			,strLocation			=	CL.strLocationName
			,strTicket				=	'' COLLATE Latin1_General_CI_AS 
			,strContractNumber		=	CH.strContractNumber
			,strItemId				=	IM.strItemNo
			,dblQuantity			=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblQuantity ELSE CD.dblBalance END
			,dblUnitPrice			=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblCashPrice ELSE CD.dblCashPrice END
			,dblAmount				=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblFinalPrice ELSE CD.dblTotalCost END
			,intCurrencyId			=	CD.intInvoiceCurrencyId
			,intForexRateType		=	CD.intHistoricalRateTypeId
			,strForexRateType		=	RT.strCurrencyExchangeRateType
			,dblForexRate			=	CASE WHEN CD.intPricingTypeId = 2 and t.strStatus is null THEN 1 ELSE CD.dblHistoricalRate END
			,dblHistoricAmount		=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblFinalPrice ELSE CD.dblTotalCost END * CD.dblHistoricalRate
			,dblNewForexRate		=	0
			,dblNewAmount			=	0
			,dblUnrealizedDebitGain =	0
			,dblUnrealizedCreditGain=	0
			,dblDebit				=	0
			,dblCredit				=	0
			,intCompanyLocationId	=	CL.intCompanyLocationId	
			,intLOBSegmentCodeId	=	LB.intSegmentCodeId
			,CASE WHEN CH.ysnLoad = 1 THEN ISNULL(CD.intNoOfLoad, 0) - ISNULL(CD.dblBalanceLoad, 0) ELSE ISNULL(CD.dblQuantity, 0) - ISNULL(CD.dblBalance, 0) END dblAppliedQty
			,CASE WHEN CD.intPricingTypeId = 1 THEN 0.00 ELSE ISNULL(CD.dblBalance, 0) *  ISNULL(LS.dblLastSettle, 0 ) END dblSettlementAmount
		
			
	FROM	tblCTContractDetail				CD
	JOIN	tblCTContractHeader				CH	ON	CD.intContractHeaderId				=	CH.intContractHeaderId
	JOIN	tblCTContractType				CT	ON	CT.intContractTypeId				=	CH.intContractTypeId
	JOIN	tblEMEntity						EY	ON	EY.intEntityId						=	CH.intEntityId
	JOIN	tblICCommodity					CY	ON	CY.intCommodityId					=	CH.intCommodityId
	JOIN	tblSMCompanyLocation			CL	ON	CL.intCompanyLocationId				=	CD.intCompanyLocationId			LEFT
	JOIN	tblICItem						IM	ON	IM.intItemId						=	CD.intItemId					LEFT
	JOIN	tblICCategory					CG	ON	CG.intCategoryId					=	IM.intCategoryId				LEFT 
	JOIN	tblSMCurrencyExchangeRateType	RT	ON	RT.intCurrencyExchangeRateTypeId	=	CD.intRateTypeId				LEFT
	JOIN	tblSMLineOfBusiness				LB	ON 	LB.intLineOfBusinessId				=	CG.intLineOfBusinessId
	LEFT JOIN (
		select 
		fspm.dblLastSettle, cmm.intCommodityId, sp.intFutureMarketId , fspm.intFutureMonthId, sp.dtmPriceDate 
		from
		tblRKFuturesSettlementPrice sp
		join tblRKCommodityMarketMapping cmm on cmm.intFutureMarketId = sp.intFutureMarketId
		join tblRKFutSettlementPriceMarketMap fspm on fspm.intFutureSettlementPriceId = sp.intFutureSettlementPriceId
		join (
			select max(dtmPriceDate) dtmPriceDate, intFutureMarketId
			from tblRKFuturesSettlementPrice
			GROUP BY intFutureMarketId
		) mx on mx.intFutureMarketId = sp.intFutureMarketId and mx.dtmPriceDate = sp.dtmPriceDate
		where
		sp.strPricingType = 'Mark to Market' COLLATE Latin1_General_CS_AS
		and sp.intCommodityMarketId = cmm.intCommodityMarketId
	) LS on LS.intCommodityId = CH.intCommodityId and LS.intFutureMarketId = CD.intFutureMarketId and LS.intFutureMonthId = CD.intFutureMonthId

	OUTER APPLY  (
		SELECT 		intContractDetailId		=	PF.intContractDetailId
			,strStatus				=	CASE WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE ISNULL(PFD.dblNoOfLots,0) END),0) = 0 
												THEN 'Fully Priced' 
												WHEN ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE ISNULL(PFD.dblNoOfLots,0) END),0) = 0 THEN 'Unpriced'
												ELSE 'Partially Priced' 
										END		COLLATE Latin1_General_CI_AS
			,dblFinalPrice			=	PF.dblFinalPrice
			,dblQuantity			=	SUM(ISNULL(PFD.dblQuantity,0))
			,dblCashPrice =   SUM(PFD.dblCashPrice)
		FROM		tblCTPriceFixation			PF 	WITH (NOLOCK)
		LEFT JOIN tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = PF.intPriceFixationId
		LEFT JOIN (
			
									SELECT PFD.intPriceFixationId, MAX(PFD.intPriceFixationDetailId) intPriceFixationDetailId
												FROM
									tblCTContractDetail cd
									join tblCTContractHeader ch
										on ch.intContractHeaderId = cd.intContractHeaderId
									join tblCTPriceFixation pf
										on pf.intContractHeaderId = ch.intContractHeaderId
										and isnull(pf.intContractDetailId,0) = (case when ch.ysnMultiplePriceFixation = 1 then isnull(pf.intContractDetailId,0) else cd.intContractDetailId end)
									left join tblCTPriceFixationDetail PFD on PFD.intPriceFixationId = pf.intPriceFixationId
									join  tblSMTransaction t on t.intRecordId = pf.intPriceContractId and t.intScreenId = 119 and t.strApprovalStatus in 	('Waiting for Approval', 'Waiting for Submit')
									group By PFD.intPriceFixationId
		) T on T.intPriceFixationId = PF.intPriceFixationId  and T.intPriceFixationDetailId = PFD.intPriceFixationDetailId
		where PF.intContractDetailId = CD.intContractDetailId
		GROUP BY
					PF.intContractDetailId, 
					PF.[dblTotalLots] ,
					PF.dblFinalPrice

	) t
GO





