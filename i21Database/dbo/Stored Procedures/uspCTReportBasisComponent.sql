CREATE PROCEDURE [dbo].[uspCTReportBasisComponent]
				@xmlParam NVARCHAR(MAX) = NULL  
AS
	DECLARE @intContractDetailId	NVARCHAR(MAX),
			@xmlDocumentId			INT,
			@ContractFromDate		DATETIME,
			@ContractToDate			DATETIME,
			@StartFromDate			DATETIME,
			@StartToDate			DATETIME,
			@Condition				NVARCHAR(MAX) = '',
			@SQL					NVARCHAR(MAX),
			@EndFromDate			DATETIME,
			@EndToDate				DATETIME,
			@Position				NVARCHAR(100),
			@Vendor					NVARCHAR(900),
			@strMappingXML			NVARCHAR(MAX),
			@dtmFromContractDate	DATETIME,
			@dtmToContractDate		DATETIME,
			@strProductType			NVARCHAR(100),
			@strReportLogId			NVARCHAR(50),
			@strPosition			NVARCHAR(200),
			@EqualStartDate			DATETIME,
			@EqualEndDate			DATETIME

	IF	LTRIM(RTRIM(@xmlParam)) = ''   
		SET @xmlParam = NULL   
      
	DECLARE @temp_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(MAX),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)

	DECLARE @dummy_xml_table TABLE 
	(  
			[fieldname]		NVARCHAR(50),  
			condition		NVARCHAR(20),        
			[from]			NVARCHAR(MAX), 
			[to]			NVARCHAR(MAX),  
			[join]			NVARCHAR(10),  
			[begingroup]	NVARCHAR(50),  
			[endgroup]		NVARCHAR(50),  
			[datatype]		NVARCHAR(50) 
	)  
  
	IF ISNULL(@xmlParam,'') = '' OR @xmlParam = '<?xml version="1.0" encoding="utf-16"?><xmlparam>''''</xmlparam>'
	BEGIN
		SELECT  CD.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
				CD.strERPPONumber,
				CD.dtmStartDate,
				CD.dtmEndDate,
				CD.strCustomerVendor,
				CD.strItemNo,
				CD.dblDetailQuantity,
				CD.strItemUOM,
				CD.dblNetWeight,
				CD.strWeightUOM,
				CD.dtmContractDate,
				CD.strContractItemName, 
				CD.strContractItemNo,
				CD.strFutMarketName, 
				CD.strFutureMonth,
				CD.dblFutures,
				CD.strCurrency,
				BI.strItemNo	AS strComponentItem,
				CC.dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				1 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition AS Position,
				CD.dtmPlannedAvailabilityDate

		FROM	vyuCTSearchContractDetail	CD
		JOIN	tblCTContractCost			CC	ON	CC.intContractDetailId	=	CD.intContractDetailId
		JOIN	tblICItem					BI	ON	BI.intItemId			=	CC.intItemId
		WHERE	1 = 2 

		RETURN
	END

	EXEC sp_xml_preparedocument @xmlDocumentId output, @xmlParam  
  
	INSERT INTO @temp_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/filters/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(MAX),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)

	INSERT INTO @dummy_xml_table  
	SELECT	*  
	FROM	OPENXML(@xmlDocumentId, 'xmlparam/dummies/filter', 2)  
	WITH (  
				[fieldname]		NVARCHAR(50),  
				condition		NVARCHAR(20),        
				[from]			NVARCHAR(MAX), 
				[to]			NVARCHAR(MAX),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
    
	SELECT	@intContractDetailId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'

	SELECT	@dtmFromContractDate = [from],
			@dtmToContractDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'ContractDate'
			AND	condition = 'Between'

	SELECT	@strProductType = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'ProductType'
			AND	condition = 'Equal To'

	SELECT	@strPosition = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'Position'
	AND		condition = 'Equal To'

	SELECT	@strReportLogId = [from]
	FROM	@dummy_xml_table   
	WHERE	[fieldname] = 'strReportLogId'

	SELECT	@StartFromDate = [from],
			@StartToDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'StartDate'
			AND	condition = 'Between'

	SELECT	@EndFromDate = [from],
			@EndToDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'EndDate'
			AND	condition = 'Between'

	SELECT	@EqualStartDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'StartDate'
			AND	condition = 'Equal To'

	SELECT	@EqualEndDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'EndDate'
			AND	condition = 'Equal To'

	IF EXISTS(SELECT TOP 1 1 FROM tblSRReportLog WHERE strReportLogId = @strReportLogId)
	BEGIN	
		RETURN
	END

	IF OBJECT_ID('tempdb..#BasisComponent') IS NOT NULL  				
		DROP TABLE #BasisComponent				
	
	;WITH CTEDetail AS
	(
			SELECT	CH.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
					CD.strERPPONumber,
					CD.dtmStartDate,
					CD.dtmEndDate,				
					CD.dblQuantity AS dblDetailQuantity,					
					CD.dblNetWeight,
					CD.dblFutures,
					CD.dblBasis,
					CD.dblCashPrice,
					CD.intContractDetailId,
					CD.dtmPlannedAvailabilityDate,
					
					CH.strInternalComment,
					EY.strName AS strCustomerVendor,
					IM.strItemNo,
					UM.strUnitMeasure AS strItemUOM,
					U4.strUnitMeasure AS strWeightUOM,
					CH.dtmContractDate,
					IC.strContractItemName, 
					IC.strContractItemNo,
					FM.strFutMarketName, 
					MO.strFutureMonth,
					CU.strCurrency,
					U2.strUnitMeasure AS strPriceUOM,
					PO.strPosition,
					CA.strDescription  AS strProductType,
					--CB.strContractBasis,
					strContractBasis = CB.strFreightTerm,
					CS.strContractStatus

			FROM	tblCTContractDetail		CD
			JOIN	tblCTContractHeader		CH	ON	CH.intContractHeaderId		=	CD.intContractHeaderId
											AND	CD.intContractStatusId			<>	3
											AND CH.dtmContractDate	BETWEEN ISNULL(@dtmFromContractDate,dtmContractDate)
																	AND		ISNULL(@dtmToContractDate,dtmContractDate)
			JOIN	tblEMEntity				EY	ON	EY.intEntityId				=	CH.intEntityId
			JOIN	tblCTContractStatus		CS	ON	CS.intContractStatusId		=	CD.intContractStatusId
			JOIN	tblICItem				IM	ON	IM.intItemId				=	CD.intItemId
			JOIN	tblICUnitMeasure		UM	ON	UM.intUnitMeasureId			=	CD.intUnitMeasureId

	--LEFT	JOIN	tblCTContractBasis		CB	ON	CB.intContractBasisId		=	CH.intContractBasisId
	LEFT	JOIN	tblSMFreightTerms		CB	ON	CB.intFreightTermId		=	isnull(CH.intFreightTermId,CD.intFreightTermId)
	LEFT	JOIN	tblCTPosition			PO	ON	PO.intPositionId			=	CH.intPositionId
	LEFT	JOIN	tblICItemUOM			WU	ON	WU.intItemUOMId				=	CD.intNetWeightUOMId		
	LEFT	JOIN	tblICUnitMeasure		U4	ON	U4.intUnitMeasureId			=	WU.intUnitMeasureId	
	LEFT	JOIN	tblICItemContract		IC	ON	IC.intItemContractId		=	CD.intItemContractId
	LEFT	JOIN	tblRKFutureMarket		FM	ON	FM.intFutureMarketId		=	CD.intFutureMarketId
	LEFT	JOIN	tblRKFuturesMonth		MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId			
	LEFT	JOIN	tblSMCurrency			CU	ON	CU.intCurrencyID			=	CD.intCurrencyId
	LEFT	JOIN	tblICItemUOM			PU	ON	PU.intItemUOMId				=	CD.intPriceItemUOMId		
	LEFT	JOIN	tblICUnitMeasure		U2	ON	U2.intUnitMeasureId			=	PU.intUnitMeasureId	
	LEFT	JOIN	tblICCommodityAttribute	CA	ON	CA.intCommodityAttributeId	=	IM.intProductTypeId
												AND	CA.strType					=	'ProductType'
	WHERE CD.dtmStartDate between ISNULL(@StartFromDate,CD.dtmStartDate) and ISNULL(@StartToDate,CD.dtmStartDate)
	AND convert(date,CD.dtmStartDate) = isnull(@EqualStartDate,convert(date,CD.dtmStartDate))
	AND CD.dtmEndDate between ISNULL(@EndFromDate,CD.dtmEndDate) and ISNULL(@EndToDate,CD.dtmEndDate)
	AND convert(date,CD.dtmEndDate) = ISNULL(@EqualEndDate,convert(date,CD.dtmEndDate))
	AND CA.strDescription = ISNULL(@strProductType,CA.strDescription)
	AND		PO.strPosition = ISNULL(@strPosition,PO.strPosition)
	)

	SELECT	* 
	INTO	#BasisComponent
	FROM
	(
		SELECT  CD.strContractSeq,
				CD.strERPPONumber,
				CD.dtmStartDate,
				CD.dtmEndDate,
				CD.strCustomerVendor,
				CD.strItemNo,
				CD.dblDetailQuantity,
				CD.strItemUOM,
				CD.dblNetWeight,
				CD.strWeightUOM,
				CD.dtmContractDate,
				CD.strContractItemName, 
				CD.strContractItemNo,
				CD.strFutMarketName, 
				CD.strFutureMonth,
				CD.dblFutures,
				CD.strCurrency,
				BI.strItemNo	AS strComponentItem,
				CC.dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				1 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition,
				CD.dtmPlannedAvailabilityDate,
				CD.strProductType,
				CD.strContractBasis,
				CD.strContractStatus

		FROM	CTEDetail	CD
		JOIN	tblCTContractCost			CC	ON	CC.intContractDetailId	=	CD.intContractDetailId
		JOIN	tblICItem					BI	ON	BI.intItemId			=	CC.intItemId
		WHERE	CC.ysnBasis	=	1 

		UNION ALL

		SELECT  CD.strContractSeq,
				CD.strERPPONumber,
				CD.dtmStartDate,
				CD.dtmEndDate,
				CD.strCustomerVendor,
				CD.strItemNo,
				CD.dblDetailQuantity,
				CD.strItemUOM,
				CD.dblNetWeight,
				CD.strWeightUOM,
				CD.dtmContractDate,
				CD.strContractItemName, 
				CD.strContractItemNo,
				CD.strFutMarketName, 
				CD.strFutureMonth,
				CD.dblFutures,
				CD.strCurrency,
				'Basis'			AS	strComponentItem,
				CD.dblBasis		AS  dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				2 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition,
				CD.dtmPlannedAvailabilityDate,
				CD.strProductType,
				CD.strContractBasis,
				CD.strContractStatus

		FROM	CTEDetail	CD

		UNION ALL

		SELECT  CD.strContractSeq,
				CD.strERPPONumber,
				CD.dtmStartDate,
				CD.dtmEndDate,
				CD.strCustomerVendor,
				CD.strItemNo,
				CD.dblDetailQuantity,
				CD.strItemUOM,
				CD.dblNetWeight,
				CD.strWeightUOM,
				CD.dtmContractDate,
				CD.strContractItemName, 
				CD.strContractItemNo,
				CD.strFutMarketName, 
				CD.strFutureMonth,
				CD.dblFutures,
				CD.strCurrency,
				'Cash Price'		AS	strComponentItem,
				CD.dblCashPrice		AS  dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				3 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition,
				CD.dtmPlannedAvailabilityDate,
				CD.strProductType,
				CD.strContractBasis,
				CD.strContractStatus

		FROM	CTEDetail	CD
	)t
	
	SELECT @strMappingXML = 
	'<mappings>
		<mapping><fieldname>ContractDate</fieldname><fromField>dtmContractDate</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>StartDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>EndDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>Position</fieldname><fromField>strPosition</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>Vendor</fieldname><fromField>strCustomerVendor</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>ProductType</fieldname><fromField>strProductType</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
	</mappings>'

	IF ISNULL(@intContractDetailId,'') <> ''
	BEGIN
		SET @Condition = ' intContractDetailId IN (' + @intContractDetailId + ') '
	END
	ELSE
	BEGIN
		EXEC	uspCTGenerateWhereClause
				@strDataXML= @xmlParam
			   ,@strMappingXML = @strMappingXML
			   ,@strClause = @Condition OUTPUT
	END
	
	IF LEN(LTRIM(RTRIM(ISNULL(@Condition,'')))) > 0
		SET @SQL = 'SELECT * FROM #BasisComponent WHERE ' + @Condition
	ELSE
		SET @SQL = 'SELECT * FROM #BasisComponent'
	
	INSERT INTO tblSRReportLog(strReportLogId,dtmDate) VALUES(@strReportLogId ,GETDATE())

	--SELECT @SQL
	EXEC sp_executesql @SQL