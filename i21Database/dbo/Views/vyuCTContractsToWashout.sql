CREATE VIEW [dbo].[vyuCTContractsToWashout]
AS

	SELECT	CD.intContractDetailId,	
			CD.intContractSeq,				
			CD.dtmStartDate,				
			CD.dtmEndDate,														
			CD.dblQuantity,				
			CD.dblFutures,			
			CD.dblBasis,									
			CD.dblCashPrice,			
			CD.dblScheduleQty,

			--Detail Join
			IM.strItemNo,			
			PT.strPricingType,		
			CS.strContractStatus,
			FM.strFutMarketName,							
			QM.strUnitMeasure			AS	strItemUOM,
			CL.strLocationName,		
			PM.strUnitMeasure			AS	strPriceUOM,			
			CU.strCurrency,		
			CY.strCurrency				AS	strMainCurrency,
			REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ')	AS	strFutureMonth,
			
			--Header
			CH.intContractHeaderId,								
			CH.strContractNumber,					
			
			--Header Join
			TP.strContractType,			
			EY.strName					AS	strEntityName,
			
			LG.ysnLoadExist,
			PD.ysnMultiplePricing
			
			
	FROM			tblCTContractDetail			CD	
			JOIN	tblSMCompanyLocation		CL	ON	CL.intCompanyLocationId		=	CD.intCompanyLocationId
			JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
			JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CH.intEntityId			
			JOIN	tblCTContractType			TP	ON	TP.intContractTypeId		=	CH.intContractTypeId		
			
	LEFT	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CD.intContractStatusId			
	LEFT	JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId			=	CD.intPricingTypeId			
	LEFT	JOIN	tblICItem					IM	ON	IM.intItemId				=	CD.intItemId				
	LEFT	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId				=	CD.intItemUOMId				
	LEFT	JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId			=	QU.intUnitMeasureId			
	LEFT	JOIN	tblICItemUOM				PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		
	LEFT	JOIN	tblICUnitMeasure			PM	ON	PM.intUnitMeasureId			=	PU.intUnitMeasureId				

	LEFT	JOIN	tblRKFutureMarket			FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId		
	LEFT	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			
	LEFT	JOIN	tblSMCurrency				CU	ON	CU.intCurrencyID			=	CD.intCurrencyId			
	LEFT	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID			=	CU.intMainCurrencyId	
	LEFT	JOIN
	(
			SELECT  CAST(COUNT(1) AS BIT) ysnLoadExist,
					ISNULL(LD.intPContractDetailId,LD.intSContractDetailId) AS intContractDetailId
			FROM	tblLGLoadDetail			LD
			JOIN	tblLGLoad				LO	 ON	LO.intLoadId = LD.intLoadId
			WHERE	LO.intShipmentStatus <> 10
			GROUP BY LD.intPContractDetailId,LD.intSContractDetailId
	)		LG	ON	LG.intContractDetailId  =   CD.intContractDetailId
	LEFT    JOIN	
	(
			SELECT	intContractDetailId,
					CAST(CASE WHEN COUNT(intPriceFixationDetailId) > 1 THEN 1 ELSE 0 END AS BIT) ysnMultiplePricing
			FROM	tblCTPriceFixationDetail	FD
			JOIN	tblCTPriceFixation			PF	ON	FD.intPriceFixationId	=	PF.intPriceFixationId		
			GROUP BY intContractDetailId
	)		PD	ON	PD.intContractDetailId	=	CD.intContractDetailId
	WHERE	CD.intContractDetailId NOT IN (SELECT intSourceDetailId FROM tblCTWashout)
	AND		CD.intContractDetailId NOT IN (SELECT intWashoutDetailId FROM tblCTWashout)
	AND		ISNULL(CD.dblBalance,0) = ISNULL(CD.dblQuantity,0)