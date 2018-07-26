CREATE PROCEDURE [dbo].[uspCTReportPriceFixationDetail]		
	@xmlParam NVARCHAR(MAX) = NULL	
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
			@strContractDocuments	NVARCHAR(MAX),
			@intLaguageId			INT = null,
			@strExpressionLabelName	NVARCHAR(50) = 'Expression',
			@strMonthLabelName		NVARCHAR(50) = 'Month',
			@intPriceFixationId		INT;

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(50), 
			[to]			NVARCHAR(50),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
  
	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)   
    
	SELECT	@intPriceFixationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intPriceFixationId'
    
	SELECT	@intLaguageId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intSrLanguageId'

	/*Declared variables for translating expression*/
	declare @per nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'per'),'per');
	declare @at nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'at'),'at');
	declare @Lotsfixed nvarchar(500) = isnull(dbo.fnCTGetTranslatedExpression(@strExpressionLabelName,@intLaguageId,'Lot(s) fixed'),'Lot(s) fixed');
			
	SELECT	DISTINCT 
			PF.intPriceFixationId,
			PD.dtmFixationDate,
			strFixationDate = datename(dd,PD.dtmFixationDate) + ' ' + isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,datename(mm,PD.dtmFixationDate)),datename(mm,PD.dtmFixationDate)) + ' ' + datename(yyyy,PD.dtmFixationDate),
			CONVERT(NVARCHAR(50),PD.dtmFixationDate,106) AS dtmFixationDateDesc,
			isnull(rtrt.strTranslation,MA.strFutMarketName) AS strFutMarketName,
			MO.strFutureMonth,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) AS [dblNoOfLots],
			dbo.fnCTChangeNumericScale(PD.dblFutures,2) + ' ' + CY.strCurrency + ' '+@per+' ' + isnull(rtrt2.strTranslation,CM.strUnitMeasure) strPrice,
			PD.strNotes,
			LTRIM(CAST(ROUND(PD.dblFutures,2) AS NUMERIC(18,2))) + ' ' + CY.strCurrency + ' '+@per+' ' + isnull(rtrt2.strTranslation,CM.strUnitMeasure) strPriceDesc,
			FLOOR(PD.[dblNoOfLots]) AS intNoOfLots,
			dbo.fnRemoveTrailingZeroes(PD.[dblNoOfLots]) + ' '+@Lotsfixed+' ' + 
			isnull(rtrt.strTranslation,MA.strFutMarketName) +  ' '  + case when MO.dtmFutureMonthsDate is null then '' else isnull(dbo.fnCTGetTranslatedExpression(@strMonthLabelName,@intLaguageId,DATENAME(mm,MO.dtmFutureMonthsDate)),DATENAME(mm,MO.dtmFutureMonthsDate)) + ' ' + DATENAME(yyyy,MO.dtmFutureMonthsDate) end + ' '+@at+' ' + 
			dbo.fnRemoveTrailingZeroes(PD.dblFutures) + CY.strCurrency + '-' + isnull(rtrt2.strTranslation,CM.strUnitMeasure)	AS strGABPrice,
			CD.dblRatio,
			dbo.fnRemoveTrailingZeroes(PD.dblQuantity) + ' ' + QM.strUnitMeasure AS strQtyWithUOM

	FROM	tblCTPriceFixation			PF
	JOIN	tblCTPriceFixationDetail	PD	ON	PD.intPriceFixationId			=	PF.intPriceFixationId
	JOIN	tblCTContractDetail			CD	ON	CD.intContractHeaderId			=	PF.intContractHeaderId	
											AND	CD.intContractDetailId			=	CASE	WHEN	PF.intContractDetailId IS NOT NULL 
																							THEN	PF.intContractDetailId 
																							ELSE	CD.intContractDetailId 
																					END						LEFT
	JOIN	tblRKFutureMarket			MA	ON	MA.intFutureMarketId			=	PD.intFutureMarketId	LEFT
	JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMonthId				=	PD.intFutureMonthId		LEFT	
	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	CD.intCurrencyId		LEFT
	JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PD.intPricingUOMId		LEFT	
	JOIN	tblICUnitMeasure			CM	ON	CM.intUnitMeasureId				=	CU.intUnitMeasureId		LEFT
	JOIN	tblICItemUOM				QU	ON	QU.intItemUOMId					=	CD.intItemUOMId			LEFT
	JOIN	tblICUnitMeasure			QM	ON	QM.intUnitMeasureId				=	QU.intUnitMeasureId			

	left join tblSMScreen				rts on rts.strNamespace = 'RiskManagement.view.FuturesMarket'
	left join tblSMTransaction			rtt on rtt.intScreenId = rts.intScreenId and rtt.intRecordId = MA.intFutureMarketId
	left join tblSMReportTranslation	rtrt on rtrt.intLanguageId = @intLaguageId and rtrt.intTransactionId = rtt.intTransactionId and rtrt.strFieldName = 'Market Name'
	
	left join tblSMScreen				rts2 on rts2.strNamespace = 'Inventory.view.ReportTranslation'
	left join tblSMTransaction			rtt2 on rtt2.intScreenId = rts2.intScreenId and rtt2.intRecordId = CM.intUnitMeasureId
	left join tblSMReportTranslation	rtrt2 on rtrt2.intLanguageId = @intLaguageId and rtrt2.intTransactionId = rtt2.intTransactionId and rtrt2.strFieldName = 'Name'
			
	WHERE	PF.intPriceFixationId	=	@intPriceFixationId
	

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO