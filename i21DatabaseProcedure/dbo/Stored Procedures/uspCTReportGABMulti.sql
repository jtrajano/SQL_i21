CREATE PROCEDURE [dbo].[uspCTReportGABMulti]
	@strIds			NVARCHAR(MAX),
	@strType		NVARCHAR(50),
	@intLaguageId	INT
AS 
BEGIN
	DECLARE @strExpressionLabelName		NVARCHAR(50) = 'Expression',
			@strMonthLabelName			NVARCHAR(50) = 'Month'

	SELECT	CASE	WHEN	@strType = 'MULTIPLE' 
					THEN	CH.strContractNumber 
					ELSE	CASE	WHEN	strPosition = 'Spot' 
									THEN	CD.strRemark
									ELSE	LEFT(DATENAME(DAY,CD.dtmStartDate),2) + ' ' + 
											ISNULL(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmStartDate),3)), LEFT(DATENAME(MONTH,CD.dtmStartDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmStartDate),4) + ' - ' + LEFT(DATENAME(DAy,CD.dtmEndDate),2) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,LEFT(DATENAME(MONTH,CD.dtmEndDate),3)), LEFT(DATENAME(MONTH,CD.dtmEndDate),3)) + ' ' + LEFT(DATENAME(YEAR,CD.dtmEndDate),4) 
							END 
			END strPart1, 
			CASE	WHEN	@strType = 'MULTIPLE'  
					THEN	' - ' + dbo.fnRemoveTrailingZeroes(CD.dblQuantity) + 
							dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',UM.intUnitMeasureId,@intLaguageId,'Name',UM.strUnitMeasure) 	    + 
							ISNULL(' '+dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'in')+' ' + CD.strPackingDescription,'') + 
							ISNULL('(' + LTRIM(CD.intNumberOfContainers) + ' '+dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Containers')+')','') 
					ELSE	NULL 
			END AS strPart2 ,
			CASE	WHEN	@strType = 'MULTIPLE'  
					THEN	dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,CASE WHEN PO.strPosition = 'Spot' THEN 'Delivery' ELSE 'Shipment' END) + ' ' +
							dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(MONTH,CD.dtmEndDate)) + ' ' +  DATENAME(yyyy,CD.dtmEndDate) 
					ELSE	NULL 
			END AS strPart3,
			CASE	WHEN	@strType = 'MULTIPLE' 
					THEN	dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'at') + ' ' + 
							dbo.fnCTGetTranslation('RiskManagement.view.FuturesMarket',MA.intFutureMarketId,@intLaguageId,'Market Name',MA.strFutMarketName) + ' ' + 
							dbo.fnCTGetTranslation('RiskManagement.view.FuturesTradingMonths',MO.intFutureMonthId,@intLaguageId,'Future Trading Month',MO.strFutureMonth)  + ' ' +  
							CASE	WHEN	CD.intPricingTypeId = 2 
									THEN '('+ CASE WHEN CD.dblBasis < 0 THEN '-' ELSE '+' END + ') ' 
									ELSE    ' ' 
							END +
							CASE    WHEN	CD.intPricingTypeId = 2 
									THEN	dbo.fnRemoveTrailingZeroes(CD.dblBasis) + ' ' + BC.strCurrency + '/' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',BM.intUnitMeasureId,@intLaguageId,'Name',BM.strUnitMeasure)
									ELSE    dbo.fnRemoveTrailingZeroes(CD.dblCashPrice) + ' ' + CY.strCurrency + '/' + dbo.fnCTGetTranslation('Inventory.view.ReportTranslation',PM.intUnitMeasureId,@intLaguageId,'Name',PM.strUnitMeasure)
							END 
					ELSE NULL 
			END strPart4
				
	FROM	tblCTContractDetail		CD
	JOIN	tblCTContractHeader		CH	ON CD.intContractHeaderId		=	CH.intContractHeaderId
	JOIN	tblICItemUOM			IU	ON	IU.intItemUOMId				=	CD.intItemUOMId		
	JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	IU.intUnitMeasureId
	JOIN	tblCTPosition			PO	ON	PO.intPositionId			=	CH.intPositionId
	JOIN	tblRKFutureMarket		MA	ON	MA.intFutureMarketId		=	CD.intFutureMarketId		
	JOIN	tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId	
	JOIN	tblSMCurrency			CY	ON	CY.intCurrencyID			=	CD.intCurrencyId
	JOIN	tblSMCurrency			BC	ON	BC.intCurrencyID			=	CD.intBasisCurrencyId	
	JOIN	tblICItemUOM			BU	ON	BU.intItemUOMId				=	CD.intBasisUOMId		
	JOIN	tblICUnitMeasure		BM	ON	BM.intUnitMeasureId			=	BU.intUnitMeasureId
	JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		
	JOIN	tblICUnitMeasure		PM	ON	PM.intUnitMeasureId			=	PU.intUnitMeasureId
	WHERE	CD.intContractHeaderId	IN	(SELECT Item FROM dbo.fnSplitString(@strIds,','))
		
END
