﻿CREATE VIEW [dbo].[vyuCTSearchPriceContract]

AS 
	with weightedPrice as (
		select
			pf.intContractHeaderId
			,intContractDetailId = isnull(pf.intContractDetailId,0)
			,dblweightedAvg = sum((fd.dblNoOfLots * fd.dblFinalPrice)) / sum(fd.dblNoOfLots)
		from
			tblCTPriceFixation pf
			join tblCTPriceFixationDetail fd on fd.intPriceFixationId = pf.intPriceFixationId
		group by pf.intContractHeaderId,pf.intContractDetailId
	),
	cpHTA as (
		select top 1 intPricingTypeId = (case when isnull(ysnEnableHTAMultiplePricing,0) = 1 then 3 else 0 end) from tblCTCompanyPreference
	),
	CTEGridContractDetail AS
	(
		SELECT	CD.intContractDetailId,
				CD.intContractHeaderId,
				CH.ysnLoad						AS	ysnLoad,
				dblQuantityPriceFixed = (case when CH.ysnLoad = 1 then (PD.dblQuantityPriceFixed / CD.dblQuantityPerLoad) else PD.dblQuantityPriceFixed end),
				dblQuantity = (case when CH.ysnLoad = 1 then (CD.dblQuantity / CD.dblQuantityPerLoad) else CD.dblQuantity end),
				CASE	WHEN	CH.ysnLoad = 1
									THEN	ISNULL(CD.intNoOfLoad,0)	-	ISNULL(CD.dblBalanceLoad,0)
									ELSE	ISNULL(CD.dblQuantity,0)	-	ISNULL(CD.dblBalance,0)												
						END		AS	dblAppliedQty

		FROM			tblCTContractDetail				CD WITH (NOLOCK)
				JOIN	tblCTContractHeader				CH WITH (NOLOCK) ON	CH.intContractHeaderId				=		CD.intContractHeaderId	
	
		LEFT    JOIN	tblCTPriceFixation				PF WITH (NOLOCK) ON	CD.intContractDetailId				=		PF.intContractDetailId		
		LEFT    JOIN	(
							--SELECT	 intPriceFixationId,
							--		 COUNT(intPriceFixationDetailId) intPFDCount,
							--		 SUM(dblQuantity) dblQuantityPriceFixed,
							--		 MAX(intQtyItemUOMId) dblPFQuantityUOMId  
							--FROM	 tblCTPriceFixationDetail WITH (NOLOCK)
							--GROUP BY intPriceFixationId
							SELECT	 PF.intPriceFixationId,
									 COUNT(PF.intPriceFixationDetailId) intPFDCount,
									 SUM(dblQuantity) dblQuantityPriceFixed,
									 MAX(intQtyItemUOMId) dblPFQuantityUOMId,
									 SUM(PF.dblNoOfLots) dblNoOfLots
							FROM	 tblCTPriceFixationDetail PF WITH (NOLOCK)
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
							) T ON T.intPriceFixationId = PF.intPriceFixationId and T.intPriceFixationDetailId = PF.intPriceFixationDetailId
							WHERE T.intPriceFixationId IS NULL
							GROUP BY PF.intPriceFixationId
						)								PD	ON	PD.intPriceFixationId				=		PF.intPriceFixationId
		cross apply (select intPricingTypeId from cpHTA) hta
		where CH.intPricingTypeId <> case when hta.intPricingTypeId = 3 then 0 else 3 end
	),
	x as 
	(
		select
			intContractHeaderId
			,ysnLoad = isnull(ysnLoad,convert(bit,0))
			,intContractDetailId
			,dblQuantityPriced = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,1) then 0.00 else isnull(dblQuantityPriceFixed,0.00) end
			,dblQuantityUnpriced = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,1) then 0.00 else isnull(dblQuantity,0.00) - isnull(dblQuantityPriceFixed,0.00) end
			,dblAppliedQty = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,1) then 0.00 else isnull(dblAppliedQty,0.00) end
			,dblQuantityAppliedUnpriced =
				case
					when isnull(ysnLoad, convert(bit,0)) = convert(bit,1)
					then 0.00
					else 
						case
							when (isnull(dblAppliedQty,0.00) - isnull(dblQuantityPriceFixed,0.00)) > 0
							then (isnull(dblAppliedQty,0.00) - isnull(dblQuantityPriceFixed,0.00))
							else 0.00
						end
				end
			,dblLoadPriced = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,0) then 0.00 else isnull(dblQuantityPriceFixed,0.00) end
			,dblLoadUnpriced = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,0) then 0.00 else isnull(dblQuantity,0.00) - isnull(dblQuantityPriceFixed,0.00) end
			,dblAppliedLoad = case when isnull(ysnLoad, convert(bit,0)) = convert(bit,0) then 0.00 else isnull(dblAppliedQty,0.00) end
			,dblLoadAppliedUnpriced =
				case
					when isnull(ysnLoad, convert(bit,0)) = convert(bit,0)
					then 0.00
					else 
						case
							when (isnull(dblAppliedQty,0.00) - isnull(dblQuantityPriceFixed,0.00)) > 0
							then (isnull(dblAppliedQty,0.00) - isnull(dblQuantityPriceFixed,0.00))
							else 0.00
						end
				end
		from
			CTEGridContractDetail
	)

	SELECT	CAST(ROW_NUMBER() OVER (ORDER BY t.intContractHeaderId) AS INT) AS intUniqueId
			--,t.*
			,t.intPriceContractId
			,t.intPriceFixationId
			,t.intContractDetailId
			,t.intContractHeaderId
			,t.strContractNumber
			,t.intContractSeq
			,t.intContractTypeId
			,t.strContractType
			,t.intEntityId
			,t.strEntityName
			,t.intCommodityId
			,t.strCommodityDescription
			,t.ysnMultiplePriceFixation
			,t.dblQuantity
			,t.strUOM
			,t.dblNoOfLots
			,t.strLocationName
			,t.intItemId
			,t.intItemUOMId
			,t.intFutureMarketId
			,t.strFutMarketName
			,t.intFutureMonthId
			,t.strFutureMonth
			,t.dblBasis
			,t.dblFutures
			,t.dblCashPrice
			,t.intPriceItemUOMId
			,t.intBookId
			,t.intSubBookId
			,t.intSalespersonId
			,t.intCurrencyId
			,t.intCompanyLocationId
			,t.strStatus
			,t.dblLotsFixed
			,t.dblBalanceNoOfLots
			,t.intLotsHedged
			,dblFinalPrice = case when t.strStatus = 'Fully Priced' then t.dblFinalPrice else null end
			,t.intDefaultCommodityUOMId
			,t.intDiscountScheduleCodeId
			,t.intBasisCommodityUOMId
			,t.strEntityContract
			,t.dtmStartDate
			,t.dtmEndDate
			,t.strBook
			,t.strSubBook
			,t.strPriceUOM
			,t.strPriceContractNo
			,t.strCurrency
			,t.ysnSubCurrency
			,t.strMainCurrency
			,t.strPricingType
			,t.strItemNo
			,t.strItemDescription
			,t.strItemShortName
			,t.intHeaderBookId
			,t.intHeaderSubBookId
			,t.intDetailBookId
			,t.intDetailSubBookId
			,t.intInvoiceCurrencyId
			,t.strInvoiceCurrency
			,t.intMainCurrencyId
			,x.dblQuantityPriced
			,x.dblQuantityUnpriced
			,x.dblAppliedQty
			,x.dblQuantityAppliedUnpriced
			,x.dblLoadPriced
			,x.dblLoadUnpriced
			,x.dblAppliedLoad
			,x.dblLoadAppliedUnpriced 
			,x.ysnLoad
			,ysnApproved = CAST(isnull(PF.ysnApproved,0) as BIT)
			,strApprovalStatus = isnull(PF.strApprovalStatus, '')
	FROM
	(
		SELECT 		CAST (NULL AS INT) AS intPriceContractId,
					CAST (NULL AS INT) AS intPriceFixationId,
					intContractDetailId, 
					intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					(SELECT SUM(dblQuantity) FROM vyuCTContractDetailQuantityTotal WHERE intContractDetailId = CD.intContractDetailId) AS dblQuantity,--(SELECT SUM(dblQuantity) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId) AS dblQuantity,
					strItemUOM AS strUOM,
					(SELECT SUM(dblNoOfLots) FROM vyuCTContractDetailNoOfLotsTotal WHERE intContractDetailId = CD.intContractDetailId)  AS dblNoOfLots,--(SELECT SUM(dblNoOfLots) FROM tblCTContractDetail WHERE intContractDetailId = CD.intContractDetailId OR ISNULL(intSplitFromId,0) = CD.intContractDetailId) dblNoOfLots,
					strLocationName,
					CD.intItemId,
					CD.intItemUOMId,
					intFutureMarketId,
					strFutMarketName,
					intFutureMonthId,
					strFutureMonthYear AS strFutureMonth,
					dblBasis,
					dblFutures,
					dblCashPrice,
					intPriceItemUOMId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					CD.intCurrencyId,
					intCompanyLocationId,
					'Unpriced' COLLATE Latin1_General_CI_AS AS strStatus,
					CAST(0 AS INT) AS dblLotsFixed,
					dblNoOfLots AS dblBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId AS intBasisCommodityUOMId,
					CD.strEntityContract,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.strBook,
					CD.strSubBook,
					CD.strPriceUOM,
					NULL						AS strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType,
					CD.strItemNo,
					CD.strItemDescription,
					CD.strShortName strItemShortName,
					intHeaderBookId,
					intHeaderSubBookId,
					intDetailBookId,
					intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
		FROM		vyuCTContractSequence		CD 	WITH (NOLOCK)
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CD.intCommodityId AND CU.ysnDefault = 1
		JOIN		tblICItemUOM				IM	ON	IM.intItemUOMId		=	CD.intPriceItemUOMId
		JOIN		tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId	=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		cross apply (select * from cpHTA) hta
		WHERE		CD.intPricingTypeId IN (2, 8, hta.intPricingTypeId)
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0
		AND			intContractDetailId NOT IN (SELECT ISNULL(intContractDetailId,0) FROM tblCTPriceFixation)
		AND			CD.intContractStatusId <> 3
		--AND			CD.intSplitFromId	IS NULL
		AND			CD.intContractStatusId NOT IN (2,3)

		UNION ALL
		
		SELECT 		CAST (NULL AS INT)			AS	intPriceContractId,
					CAST (NULL AS INT)			AS	intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					CD.intContractHeaderId,
					CD.strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CAST(NULL AS NUMERIC(18, 6)) AS	dblHeaderQuantity,
					QM.strUnitMeasure			AS	strHeaderUnitMeasure,
					ISNULL(CH.dblNoOfLots,SUM(CD.dblNoOfLots))			AS	dblNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(CD.intFutureMarketId)		AS	intFutureMarketId,
					MAX(CD.strFutMarketName)		AS	strFutMarketName,
					MAX(CD.intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonthYear)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblBasis,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblFutures,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CH.intBookId,
					CH.intSubBookId,
					CD.intSalespersonId,
					MAX(CD.intCurrencyId)			AS	intCurrencyId,
					MAX(CD.intCompanyLocationId)	AS	intCompanyLocationId,
					'Unpriced' COLLATE Latin1_General_CI_AS AS strStatus,
					CAST(0 AS INT) AS intLotsFixed,
					CH.dblNoOfLots AS dblBalanceNoOfLots,
					CAST(0 AS INT) AS intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CAST (NULL AS INT)			AS	intDiscountScheduleCodeId,
					CU.intCommodityUnitMeasureId			AS	intBasisCommodityUOMId,
					CD.strEntityContract,
					MAX(CD.dtmStartDate)		AS	dtmStartDate,
					MAX(CD.dtmEndDate)			AS	dtmEndDate,
					BK.strBook,
					SB.strSubBook,
					CD.strPriceUOM,
					NULL						AS	strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType
					,strItemNo = NULL --CD.strItemNo
					,strItemDescription =  NULL --CD.strItemDescription,
					,strItemShortName = NULL --CD.strShortName 
					,intHeaderBookId
					,intHeaderSubBookId
					,intDetailBookId
					,intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
		FROM		vyuCTContractSequence		CD  WITH (NOLOCK)
		JOIN		tblCTContractHeader			CH	WITH (NOLOCK) ON	CH.intContractHeaderId			=	CD.intContractHeaderId
		JOIN		tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN		tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=	QU.intUnitMeasureId	
		JOIN		tblICItemUOM				PU	ON	PU.intItemUOMId					=	CD.intPriceItemUOMId		
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId				=	CD.intCommodityId 
													AND CU.intUnitMeasureId				=	PU.intUnitMeasureId 
LEFT	JOIN		tblCTBook					BK	ON	BK.intBookId					=	CH.intBookId						
LEFT	JOIN		tblCTSubBook				SB	ON	SB.intSubBookId					=	CH.intSubBookId	
cross apply (select * from cpHTA) hta
		WHERE		ISNULL(CD.ysnMultiplePriceFixation,0) = 1
		AND			CD.intContractHeaderId NOT IN (SELECT ISNULL(intContractHeaderId,0) FROM tblCTPriceFixation)
		AND			CD.intContractStatusId NOT IN (2,3)
		AND			CH.intPricingTypeId  in (2,hta.intPricingTypeId)
		GROUP BY	CD.intContractHeaderId,
					CD.strContractNumber,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CH.dblQuantity,
					QM.strUnitMeasure,
					CD.intSalespersonId,
					CU.intCommodityUnitMeasureId,
					CH.dblNoOfLots,
					CD.strEntityContract,
					BK.strBook,
					SB.strSubBook,
					CH.intBookId,
					CH.intSubBookId,
					CD.strPriceUOM,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType,
					intHeaderBookId,
					intHeaderSubBookId,
					intDetailBookId,
					intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
					--,CD.strItemNo,
					--CD.strItemDescription,
					--CD.strShortName

		UNION ALL

		SELECT 		PF.intPriceContractId,
					PF.intPriceFixationId,
					PF.intContractDetailId, 
					PF.intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					CD.dblQuantity,
					strItemUOM AS strUOM,
					PF.[dblTotalLots] AS dblNoOfLots,
					strLocationName,
					CD.intItemId,
					CD.intItemUOMId,
					CD.intFutureMarketId,
					strFutMarketName,
					CD.intFutureMonthId,
					strFutureMonthYear AS strFutureMonth,
					CD.dblBasis,
					CD.dblFutures,
					CD.dblCashPrice,
					intPriceItemUOMId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					CD.intCurrencyId,
					intCompanyLocationId,
					CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END),0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END),0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		COLLATE Latin1_General_CI_AS AS strStatus,
					SUM(CASE WHEN (T.intPriceFixationId) IS NOT NULL THEN 0 ELSE PFD.dblNoOfLots END) [dblLotsFixed],
					PF.[dblTotalLots]-SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END) AS dblBalanceNoOfLots,
					CASE WHEN ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END),0) = 0 THEN 0 ELSE PF.intLotsHedged END intLotsHedged,
					dblFinalPrice = max(CASE WHEN (T.intPriceFixationId) IS NOT NULL THEN null ELSE wap.dblweightedAvg END),
				
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId AS intBasisCommodityUOMId,
					CD.strEntityContract,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.strBook,
					CD.strSubBook,
					CD.strPriceUOM,
					PC.strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType,
					CD.strItemNo,
					CD.strItemDescription,
					CD.strShortName strItemShortName,
					intHeaderBookId,
					intHeaderSubBookId,
					intDetailBookId,
					intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
		FROM		tblCTPriceFixation			PF 	WITH (NOLOCK)
		JOIN		tblCTPriceContract			PC	WITH (NOLOCK) ON PC.intPriceContractId	=	PF.intPriceContractId
		JOIN		vyuCTContractSequence		CD	ON	CD.intContractDetailId	=	PF.intContractDetailId
		JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId		=	CD.intCommodityId AND CU.ysnDefault = 1 
		JOIN		tblICItemUOM				IM	ON	IM.intItemUOMId			=	CD.intPriceItemUOMId
		JOIN		tblICCommodityUnitMeasure	PU	ON	PU.intCommodityId		=	CD.intCommodityId AND PU.intUnitMeasureId = IM.intUnitMeasureId
		--WHERE		intPricingTypeId = 2 
		AND			ISNULL(ysnMultiplePriceFixation,0) = 0
		AND			CD.intContractStatusId <> 3 
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
		left join weightedPrice wap on wap.intContractHeaderId = PF.intContractHeaderId and wap.intContractDetailId = isnull(PF.intContractDetailId,0)
		
		GROUP BY
		PF.intPriceContractId,
					PF.intPriceFixationId,
					PF.intContractDetailId, 
					PF.intContractHeaderId,
					strContractNumber,
					intContractSeq,
					intContractTypeId,
					strContractType,
					intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					ysnMultiplePriceFixation,
					CD.dblQuantity,
					strItemUOM ,
					PF.[dblTotalLots] ,
					strLocationName,
					CD.intItemId,
					CD.intItemUOMId,
					CD.intFutureMarketId,
					strFutMarketName,
					CD.intFutureMonthId,
					strFutureMonthYear,
					CD.dblBasis,
					CD.dblFutures,
					CD.dblCashPrice,
					intPriceItemUOMId,
					intBookId,
					intSubBookId,
					intSalespersonId,
					CD.intCurrencyId,
					intCompanyLocationId,
					PF.[dblTotalLots]-[dblLotsFixed] ,
					PF.intLotsHedged,
					PF.dblFinalPrice,
					CU.intCommodityUnitMeasureId ,
					CD.intDiscountScheduleCodeId,
					PU.intCommodityUnitMeasureId ,
					CD.strEntityContract,
					CD.dtmStartDate,
					CD.dtmEndDate,
					CD.strBook,
					CD.strSubBook,
					CD.strPriceUOM,
					PC.strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType,
					CD.strItemNo,
					CD.strItemDescription,
					CD.strShortName,
					intHeaderBookId,
					intHeaderSubBookId,
					intDetailBookId,
					intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId

		UNION ALL
		
		SELECT 		PF.intPriceContractId,
					PF.intPriceFixationId,
					CAST (NULL AS INT)			AS	intContractDetailId, 
					CD.intContractHeaderId,
					CD.strContractNumber,
					CAST (NULL AS INT)			AS	intContractSeq,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CAST(NULL AS NUMERIC(18, 6)) AS  dblHeaderQuantity,
					QM.strUnitMeasure			AS	strHeaderUnitMeasure,
					PF.[dblTotalLots]			AS	dblNoOfLots,
					LTRIM(NULL)					AS	strLocationName,
					CAST (NULL AS INT)			AS	intItemId,
					CAST (NULL AS INT)			AS	intItemUOMId,
					MAX(CD.intFutureMarketId)		AS	intFutureMarketId,
					MAX(CD.strFutMarketName)		AS	strFutMarketName,
					MAX(CD.intFutureMonthId)		AS	intFutureMonthId,
					MAX(strFutureMonthYear)			AS	strFutureMonth,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblBasis,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblFutures,
					CAST (NULL AS NUMERIC(18, 6)) AS	dblCashPrice,
					CAST (NULL AS INT)			AS	intPriceItemUOMId,
					CH.intBookId,
					CH.intSubBookId,
					CD.intSalespersonId,
					MAX(CD.intCurrencyId)			AS	intCurrencyId,
					MAX(CD.intCompanyLocationId)	AS	intCompanyLocationId,
					CASE	WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(PF.[dblLotsFixed],0) = 0 
							THEN 'Fully Priced' 
							WHEN ISNULL([dblLotsFixed],0) = 0 THEN 'Unpriced'
							ELSE 'Partially Priced' 
					END		COLLATE Latin1_General_CI_AS AS strStatus,
					PF.[dblLotsFixed],
					PF.[dblTotalLots]-PF.[dblLotsFixed] AS dblBalanceNoOfLots,
					PF.intLotsHedged,
					CAST(NULL AS NUMERIC(18, 6)) AS dblFinalPrice,
					CU.intCommodityUnitMeasureId AS intDefaultCommodityUOMId,
					CAST (NULL AS INT)			AS	intDiscountScheduleCodeId,
					CAST (NULL AS INT)			AS	intBasisCommodityUOMId,
					CD.strEntityContract,
					MAX(CD.dtmStartDate)		AS	dtmStartDate,
					MAX(CD.dtmEndDate)			AS	dtmEndDate,
					BK.strBook,
					SB.strSubBook,
					CD.strPriceUOM,
					PC.strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,					
					 CD.strPricingType
					,strItemNo = NULL --CD.strItemNo
					,strItemDescription =  NULL --CD.strItemDescription,
					,strItemShortName = NULL --CD.strShortName 
					,intHeaderBookId
					,intHeaderSubBookId
					,intDetailBookId
					,intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
		FROM		tblCTPriceFixation			PF	WITH (NOLOCK)
		JOIN		tblCTPriceContract			PC	WITH (NOLOCK) ON	PC.intPriceContractId			=	PF.intPriceContractId
		JOIN		vyuCTContractSequence		CD	WITH (NOLOCK) ON	CD.intContractHeaderId			=	PF.intContractHeaderId
		JOIN		tblCTContractHeader			CH	WITH (NOLOCK) ON	CH.intContractHeaderId			=	CD.intContractHeaderId
		JOIN		tblICCommodityUnitMeasure	QU	ON	QU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		left JOIN		tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId				=	CD.intCommodityId 
													AND CU.ysnDefault					=	1 				
LEFT	JOIN		tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=	QU.intUnitMeasureId		
LEFT	JOIN		tblCTBook					BK	ON	BK.intBookId					=	CH.intBookId						
LEFT	JOIN		tblCTSubBook				SB	ON	SB.intSubBookId					=	CH.intSubBookId	
		WHERE		ISNULL(CD.ysnMultiplePriceFixation,0) = 1
		GROUP BY	CD.intContractHeaderId,
					CD.strContractNumber,
					CD.intContractTypeId,
					strContractType,
					CD.intEntityId,
					strEntityName,
					CD.intCommodityId,
					strCommodityDescription,
					CD.ysnMultiplePriceFixation,
					CH.dblQuantity,
					QM.strUnitMeasure,
					CD.intSalespersonId,
					PF.[dblLotsFixed],
					PF.[dblTotalLots],
					PF.intLotsHedged,
					PF.intPriceFixationId,
					CU.intCommodityUnitMeasureId,
					CD.strEntityContract,
					PF.intPriceContractId,
					BK.strBook,
					SB.strSubBook,
					CH.intBookId,
					CH.intSubBookId,
					CD.strPriceUOM,
					PC.strPriceContractNo,
					strCurrency,
					ysnSubCurrency,
					strMainCurrency,
					CD.strPricingType,
					intHeaderBookId,
					intHeaderSubBookId,
					intDetailBookId,
					intDetailSubBookId
					,CD.intInvoiceCurrencyId
					,CD.strInvoiceCurrency
					,CD.intMainCurrencyId
					--,CD.strItemNo,
					--CD.strItemDescription,
					--CD.strShortName
	)t
	LEFT JOIN x ON x.intContractHeaderId = t.intContractHeaderId AND ISNULL(t.ysnMultiplePriceFixation,0) = 0
	OUTER APPLY (
	
		select	intPriceFixationId	=		PF.intPriceFixationId
			   , ysnApproved		=		CASE WHEN strApprovalStatus in ('Approved', 'Approved with Modifications') THEN 1 ELSE 0 END
			   , strApprovalStatus	=		CASE WHEN strApprovalStatus in ('Approved', 'Approved with Modifications') THEN 'Approved' 
													 WHEN strApprovalStatus in ('Waiting for Submit', 'Waiting for Approval') THEN strApprovalStatus
											ELSE '' END
		from tblCTPriceFixation PF 
		LEFT JOIN (
			select intRecordId, strApprovalStatus
				from
					tblSMScreen sc
					join tblSMTransaction tr on tr.intScreenId = sc.intScreenId
				where
			sc.strModule = 'Contract Management'
			and sc.strNamespace in ('ContractManagement.view.PriceContracts','ContractManagement.view.PriceContractsNew')
		) app on app.intRecordId = PF.intPriceContractId
		where PF.intPriceFixationId = t.intPriceFixationId

	) PF

	where 
	 ISNULL(t.intContractDetailId,0) = CASE WHEN t.ysnMultiplePriceFixation = 1 THEN ISNULL(t.intContractDetailId,0) ELSE x.intContractDetailId END
