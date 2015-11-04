﻿CREATE PROCEDURE [dbo].[uspCTReportContractDetail]
	
	@intContractHeaderId INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT	CD.intContractHeaderId,
			CD.intContractSeq,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			LTRIM(CD.dblQuantity) + ' ' + UM.strUnitMeasure strQunatity,
			CD.dblQuantity,
			CASE	WHEN	CD.intPricingTypeId = 1 THEN LTRIM(CD.dblCashPrice) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
					WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CD.dblCashPrice) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' ' + MO.strFutureMonth +' ('+ LTRIM(CD.dblNoOfLots) +')'  	
			END	AS	strPrice,
			IM.strDescription,
			BM.strBagMark,
			'' AS strPO,
			GETDATE() AS dtmETD,
			CH.dtmContractDate,
			CD.strGarden,
			CD.strGrade,
			CD.dblNetWeight,
			NU.strUnitMeasure strWeightUOM,
			dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,CD.intNetWeightUOMId,1) dblUnitQty,
			CD.dblCashPrice,
			CY.strCurrency,
			CD.dblTotalCost,
			PU.strUnitMeasure strPriceUOM
	FROM	tblCTContractDetail CD	
	JOIN	tblCTContractHeader	CH	ON	CH.intContractHeaderId	=	CD.intContractHeaderId	LEFT
	JOIN	tblICItemUOM		QM	ON	QM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	QM.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM		PM	ON	PM.intItemUOMId			=	CD.intPriceItemUOMId	LEFT
	JOIN	tblICUnitMeasure	PU	ON	PU.intUnitMeasureId		=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CD.intItemId			LEFT
	JOIN	tblCTBagMark		BM	ON	BM.intContractDetailId	=	CD.intContractDetailId	
									AND	BM.ysnDefault			=	1						LEFT
	JOIN	tblICItemUOM		NM	ON	NM.intWeightUOMId		=	CD.intNetWeightUOMId	LEFT
	JOIN	tblICUnitMeasure	NU	ON	NU.intUnitMeasureId		=	NM.intUnitMeasureId
	WHERE	CD.intContractHeaderId	=	@intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO