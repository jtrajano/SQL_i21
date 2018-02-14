CREATE PROCEDURE [dbo].[uspCTReportSimultaneousDetail]
		
	@intPriceFixationId INT = NULL
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @strCompanyName			NVARCHAR(500),
			@strAddress				NVARCHAR(500),
			@strCounty				NVARCHAR(500),
			@strCity				NVARCHAR(500),
			@strState				NVARCHAR(500),
			@strZip					NVARCHAR(500),
			@strCountry				NVARCHAR(500),
			@xmlDocumentId			INT,
			@strContractDocuments	NVARCHAR(MAX)
			

	
	SELECT	PF.intPriceFixationId,
			CH.strContractNumber + '-' + LTRIM(CD.intContractSeq) strOurRef,
			ISNULL(IM.strDescription,IM.strItemNo)			AS	strItem,
			dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + 
							' ' + UM.strUnitMeasure			AS	strQunatity,
			CAST(SF.dblOriginalBasis AS NUMERIC(18, 6))		AS	dblOriginalBasis,
			CAST(SF.dblFutures AS NUMERIC(18, 6))			AS	dblFutures,
			CAST(SF.dblRollArb AS NUMERIC(18, 6))			AS	dblRollArb,
			CAST(SF.dblAdditionalCost AS NUMERIC(18, 6))	AS	dblAdditionalCost,
			CAST(SF.dblFinalPrice AS NUMERIC(18, 6))		AS	dblFinalPrice,
			CY.strCurrency + ' per ' + CM.strUnitMeasure	AS	strPricePerUOM
	
	FROM	tblCTPriceFixation			PF
	JOIN	vyuCTSimultaneousFixation	SF	ON	SF.intPriceFixationId			=		PF.intPriceFixationId
	JOIN	tblCTContractHeader			CH	ON	CH.intContractHeaderId			=		PF.intContractHeaderId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractDetailId			=		SF.intContractDetailId
	JOIN	tblICItem					IM	ON	IM.intItemId					=		CD.intItemId	
	JOIN	tblICItemUOM				QM	ON	QM.intItemUOMId					=		CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=		QM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=		CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=		SF.intFinalPriceUOMId	LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=		CU.intUnitMeasureId												
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO