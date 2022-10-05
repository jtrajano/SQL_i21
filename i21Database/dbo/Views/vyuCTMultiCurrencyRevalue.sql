﻿CREATE VIEW [dbo].[vyuCTMultiCurrencyRevalue]

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
			,intForexRateType		=	CD.intHistoricalRateTypeId
			,strForexRateType		=	RT.strCurrencyExchangeRateType
			,dblForexRate			=	CD.dblHistoricalRate
			,dblHistoricAmount		=	CD.dblTotalCost * CD.dblHistoricalRate
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
