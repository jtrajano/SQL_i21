CREATE VIEW vyuCTPriceContract

AS

	SELECT	D.intContractDetailId, 
			D.dblQuantity,
			D.intUnitMeasureId,
			D.dtmStartDate,
			D.dtmEndDate,
			D.dblFutures,
			D.dblBasis,
			D.dblCashPrice,
			D.intFutureMarketId,
			D.intFuturesMonthYearId,
			D.intContractOptHeaderId,
			D.intContractSeq,
			D.intConcurrencyId,
			T.Name AS strContractType,
			C.strCommodityCode,
			E.strName strEntityName,
			H.intContractNumber,
			L.strLocationName,
			CASE D.intPricingType 
				WHEN 1 THEN 'Priced'
				WHEN 2 THEN 'Basis'
				WHEN 3 THEN 'HTA'
				WHEN 4 THEN 'TBD'
				ELSE 'CanadianBasis'
			END	AS strPricingType
			
	FROM	tblCTContractDetail		D
	JOIN	tblSMCompanyLocation	L	ON	L.intCompanyLocationId	=	D.intCompanyLocationId
	JOIN	tblCTContractHeader		H	ON	H.intContractHeaderId	=	D.intContractHeaderId
	JOIN	tblEntity				E	ON	E.intEntityId			=	H.intEntityId
	JOIN	tblICCommodity			C	ON	C.intCommodityId		=	H.intCommodityId
	JOIN	tblCTContractType		T	ON	T.Value					=	H.intPurchaseSale
	WHERE	D.intPricingType	<>	1
