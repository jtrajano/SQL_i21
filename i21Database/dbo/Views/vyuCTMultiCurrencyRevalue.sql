
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
			,dblQuantity			=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblQuantity ELSE CD.dblQuantity END
			,dblUnitPrice			=	CD.dblCashPrice
			,dblAmount				=	CD.dblTotalCost
			,intCurrencyId			=	CD.intCurrencyId
			,intForexRateType		=	CD.intRateTypeId
			,strForexRateType		=	RT.strCurrencyExchangeRateType
			,dblForexRate			=	CD.dblRate
			,dblHistoricAmount		=	CASE WHEN t.strStatus = 'Partially Priced' THEN t.dblFinalPrice ELSE CD.dblTotalCost END * CD.dblRate
			,dblNewForexRate		=	0
			,dblNewAmount			=	0
			,dblUnrealizedDebitGain =	0
			,dblUnrealizedCreditGain=	0
			,dblDebit				=	0
			,dblCredit				=	0
			,intCompanyLocationId	=	CL.intCompanyLocationId	
			,intLOBSegmentCodeId	=	LB.intSegmentCodeId
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
	OUTER APPLY  (
		SELECT 		intContractDetailId		=	PF.intContractDetailId
			,strStatus				=	CASE WHEN ISNULL(PF.[dblTotalLots],0)-ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END),0) = 0 
												THEN 'Fully Priced' 
												WHEN ISNULL(SUM(CASE WHEN (T.intPriceFixationId) IS NOT  NULL THEN 0 ELSE PFD.dblNoOfLots END),0) = 0 THEN 'Unpriced'
												ELSE 'Partially Priced' 
										END		COLLATE Latin1_General_CI_AS
			,dblFinalPrice			=	PF.dblFinalPrice
			,dblQuantity			=	SUM(ISNULL(PFD.dblQuantity,0))
				
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


