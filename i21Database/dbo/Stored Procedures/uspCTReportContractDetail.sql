CREATE PROCEDURE [dbo].[uspCTReportContractDetail]
	
	@intContractHeaderId INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT	CD.intContractHeaderId,
			CD.intContractSeq,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			LTRIM(CD.dblQuantity) + ' ' + UM.strUnitMeasure strQunatity,
			CD.dblQuantity,
			CASE	WHEN	CD.intPricingTypeId IN (1,6) THEN LTRIM(CAST(CD.dblCashPrice AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
					WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CAST(CD.dblBasis AS NUMERIC(18, 6))) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' ' + MO.strFutureMonth +' ('+ LTRIM(CAST(CD.dblNoOfLots AS INT)) +' Lots)'  	
			END	AS	strPrice,
			IM.strDescription,
			BM.strBagMark,
			CD.strReference,
			GETDATE() AS dtmETD,
			CH.dtmContractDate,
			EF.strFieldNumber strGarden,
			CD.strGrade,
			CD.dblNetWeight,
			NU.strUnitMeasure strWeightUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,1) dblUnitQty,
			CD.dblCashPrice,
			CY.strCurrency,
			CD.dblTotalCost,
			PU.strUnitMeasure strPriceUOM,
			CASE 
				WHEN UM.strUnitType='Weight' THEN LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblQuantity)) + ' ' + UM.strUnitMeasure+CASE WHEN CD.dblNetWeight IS NOT NULL THEN  ' (' ELSE '' END + ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') +CASE WHEN U7.strUnitMeasure IS NOT NULL THEN   ')' ELSE '' END  
				ELSE ISNULL(LTRIM(dbo.fnRemoveTrailingZeroes(CD.dblNetWeight)),'')+ ' '+ ISNULL(U7.strUnitMeasure,'') 
			END
			AS  strQuantityDesc			
	FROM	tblCTContractDetail CD	
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItemUOM		QM	ON	QM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	QM.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM		PM	ON	PM.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PU	ON	PU.intUnitMeasureId		=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	[tblEMEntityFarm]	EF	ON	EF.intFarmFieldId		=	CD.intFarmFieldId		LEFT
	JOIN	tblCTBagMark		BM	ON	BM.intContractDetailId	=	CD.intContractDetailId	
									AND	BM.ysnDefault			=	1						LEFT
	JOIN	tblICItemUOM		NM	ON	NM.intWeightUOMId		=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICItemUOM		WU	ON	WU.intItemUOMId			=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure	U7	ON	U7.intUnitMeasureId		=	WU.intUnitMeasureId		LEFT
	JOIN	tblICUnitMeasure	NU	ON	NU.intUnitMeasureId		=	NM.intUnitMeasureId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO