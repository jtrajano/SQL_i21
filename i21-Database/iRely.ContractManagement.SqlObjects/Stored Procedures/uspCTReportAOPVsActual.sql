CREATE PROCEDURE [dbo].[uspCTReportAOPVsActual]
	@xmlParam NVARCHAR(MAX) = NULL  
AS
	DECLARE	 @intContractDetailId	NVARCHAR(MAX),
			 @xmlDocumentId			INT,
			 @ContractFromDate		DATETIME,
			 @ContractToDate		DATETIME,
			 @StartFromDate			DATETIME,
			 @StartToDate			DATETIME,
			 @Condition				NVARCHAR(MAX) = '',
			 @SQL					NVARCHAR(MAX),
			 @EndFromDate			DATETIME,
			 @EndToDate				DATETIME,
			 @Position				NVARCHAR(100),
			 @Vendor				NVARCHAR(900),
			 @strMappingXML			NVARCHAR(MAX)

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
				0.0 AS dblActual,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				1 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition AS Position,
				CD.dtmPlannedAvailabilityDate,
				CD.strCommodityCode,
				CD.strBook,
				CD.strSubBook,
				CD.dblRatio,
				0.0 AS dblVolume,
				NULL AS intItemId
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
    
	SELECT	@intContractDetailId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'

	IF OBJECT_ID('tempdb..##BasisComponentTemp') IS NOT NULL  				
		DROP TABLE ##BasisComponentTemp

	SELECT		CD.strContractNumber + ' - ' + LTRIM(CD.intContractSeq) strContractSeq,
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
				AD.dblCost as dblEstimate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				1 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition AS Position,
				CD.dtmPlannedAvailabilityDate,
				CD.strProductType,
				CD.strContractBasis,
				CD.strContractStatus,
				CD.strCommodityCode,
				CD.strBook,
				CD.strSubBook,
				CD.dblRatio,
				AO.strYear,
				AO.dtmFromDate,
				AO.dtmToDate,
				AD.dblVolume,
				DL.intItemId

		INTO	##BasisComponentTemp
		FROM	vyuCTSearchContractDetail	CD
		JOIN	tblCTContractDetail			DL	ON  DL.intContractDetailId	 =	CD.intContractDetailId
		JOIN	tblCTContractCost			CC	ON  CC.intContractDetailId	 =	CD.intContractDetailId
		JOIN	tblICItem					BI	ON  BI.intItemId			 =	CC.intItemId
		JOIN	tblCTAOPDetail				AD	ON  AD.intItemId			 =	DL.intItemId
												AND AD.intBasisItemId		 =	CC.intItemId
		JOIN	 tblCTAOP					AO	ON	AO.intAOPId				 =	AD.intAOPId
		WHERE	CC.ysnBasis	=	1 
		AND		CD.strContractStatus	<>	'Cancelled'
	  --AND		CD.strContractNumber = '2825'

	IF OBJECT_ID('tempdb..##BasisComponent') IS NOT NULL  				
		DROP TABLE ##BasisComponent				

	SELECT	* 
	INTO	##BasisComponent
	FROM
	(
		SELECT	* 
		FROM	##BasisComponentTemp
		UNION ALL
		SELECT	strContractSeq,strERPPONumber,dtmStartDate,dtmEndDate,strCustomerVendor,strItemNo,dblDetailQuantity,strItemUOM,dblNetWeight,strWeightUOM,dtmContractDate,
				strContractItemName,strContractItemNo,strFutMarketName,strFutureMonth,dblFutures,strCurrency,'Basis',dblBasis dblRate,NULL AS dblEstimate,strPriceUOM,dblBasis,
				dblCashPrice,2,strInternalComment,intContractDetailId,Position,dtmPlannedAvailabilityDate,strProductType,strContractBasis,strContractStatus,
				strCommodityCode,strBook,strSubBook,dblRatio,strYear,dtmFromDate,dtmToDate,dblVolume,intItemId
		FROM	##BasisComponentTemp
		UNION ALL
		SELECT	strContractSeq,strERPPONumber,dtmStartDate,dtmEndDate,strCustomerVendor,strItemNo,dblDetailQuantity,strItemUOM,dblNetWeight,strWeightUOM,dtmContractDate,
				strContractItemName,strContractItemNo,strFutMarketName,strFutureMonth,dblFutures,strCurrency,'Cash Price',dblCashPrice dblRate,NULL AS dblEstimate,strPriceUOM,dblBasis,
				dblCashPrice,3,strInternalComment,intContractDetailId,Position,dtmPlannedAvailabilityDate,strProductType,strContractBasis,strContractStatus,
				strCommodityCode,strBook,strSubBook,dblRatio,strYear,dtmFromDate,dtmToDate,dblVolume,intItemId
		FROM	##BasisComponentTemp
	)t
	
	SELECT @strMappingXML = 
	'<mappings>
		<mapping><fieldname>ContractDate</fieldname><fromField>dtmContractDate</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>StartDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>EndDate</fieldname><fromField>dtmStartDate</fromField><toField>dtmEndDate</toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>Position</fieldname><fromField>Position</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>Vendor</fieldname><fromField>strCustomerVendor</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>ProductType</fieldname><fromField>strProductType</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>FiscalYear</fieldname><fromField>strYear</fromField><toField></toField><ignoreTime></ignoreTime></mapping>
		<mapping><fieldname>FromDate</fieldname><fromField>dtmFromDate</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>ToDate</fieldname><fromField>dtmToDate</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping>
		<mapping><fieldname>strItemNo</fieldname><fromField>strItemNo</fromField><toField></toField><ignoreTime>1</ignoreTime></mapping>
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
	--SELECT @Condition
	IF LEN(LTRIM(RTRIM(ISNULL(@Condition,'')))) > 0
	BEGIN
		--SELECT @Condition = REPLACE(@Condition,'dtmToDate)','dtmToDate OR dtmFromDate = ''1900-01-01 00:00:00.000'' OR dtmToDate = ''1900-01-01 00:00:00.000'')')
		SELECT @Condition = REPLACE(@Condition,'(strYear','(strYear = ''0000'' OR strYear')
		SET @SQL = 'SELECT * FROM ##BasisComponent WHERE ' + @Condition
	END
	ELSE
		SET @SQL = 'SELECT * FROM ##BasisComponent'

    EXEC('
    UPDATE A SET A.dblEstimate = B.dblEstimate
    FROM ##BasisComponent A
    JOIN (SELECT strItemNo,SUM(dblEstimate)dblEstimate FROM ##BasisComponent WHERE strComponentItem NOT IN (''Basis'',''Cash Price'') GROUP BY strItemNo) B
    ON B.strItemNo= A.strItemNo
    WHERE A.strComponentItem = ''Basis''')

	EXEC sp_executesql @SQL