CREATE VIEW [dbo].[vyuCTMultiCurrencyRevalue]

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
			,dblQuantity			=	CD.dblQuantity
			,dblUnitPrice			=	CD.dblCashPrice
			,dblAmount				=	CD.dblTotalCost
			,intCurrencyId			=	CD.intCurrencyId
			,intForexRateType		=	CD.intRateTypeId
			,strForexRateType		=	RT.strCurrencyExchangeRateType
			,dblForexRate			=	CD.dblRate
			,dblHistoricAmount		=	CD.dblTotalCost * CD.dblRate
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
