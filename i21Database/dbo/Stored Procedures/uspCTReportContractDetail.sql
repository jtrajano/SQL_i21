CREATE PROCEDURE [dbo].[uspCTReportContractDetail]
	
	@intContractHeaderId INT
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)

	SELECT	CD.intContractHeaderId,
			CONVERT(NVARCHAR(50),dtmStartDate,106) + ' - ' + CONVERT(NVARCHAR(50),dtmEndDate,106) strPeriod,
			LTRIM(dblQuantity) + ' ' + UM.strUnitMeasure strQunatity,
			CASE	WHEN	CD.intPricingTypeId = 1 THEN LTRIM(CD.dblCashPrice) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' net' 
					WHEN 	CD.intPricingTypeId = 2	THEN LTRIM(CD.dblCashPrice) + ' ' + CY.strCurrency + ' per ' + PU.strUnitMeasure + ' ' + MO.strFutureMonth +' ('+ LTRIM(CD.dblNoOfLots) +')'  	
			END	AS	strPrice,
			IM.strDescription
	FROM	tblCTContractDetail CD															LEFT
	JOIN	tblICItemUOM		QM	ON	QM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	UM	ON	UM.intUnitMeasureId		=	QM.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM		PM	ON	PM.intItemUOMId			=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure	PU	ON	PU.intUnitMeasureId		=	PM.intUnitMeasureId		LEFT
	JOIN	tblSMCurrency		CY	ON	CY.intCurrencyID		=	CD.intCurrencyId		LEFT
	JOIN	tblRKFuturesMonth	MO	ON	MO.intFutureMonthId		=	CD.intFutureMonthId		LEFT
	JOIN	tblICItem			IM	ON	IM.intItemId			=	CD.intItemId			
	WHERE intContractHeaderId = @intContractHeaderId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO