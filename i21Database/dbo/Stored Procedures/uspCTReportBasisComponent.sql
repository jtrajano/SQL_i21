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
			@Position				NVARCHAR(100)

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
				CD.strPosition AS Position

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
				[from]			NVARCHAR(50), 
				[to]			NVARCHAR(50),  
				[join]			NVARCHAR(10),  
				[begingroup]	NVARCHAR(50),  
				[endgroup]		NVARCHAR(50),  
				[datatype]		NVARCHAR(50)  
	)  
    
	SELECT	@intContractDetailId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractDetailId'

	SELECT	@ContractFromDate = [from],@ContractToDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'ContractDate'

	SELECT	@StartFromDate = [from],@StartToDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'StartDate'

	SELECT	@EndFromDate = [from],@EndToDate = [to]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'EndDate'

	SELECT	@Position = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'Position'

	IF OBJECT_ID('tempdb..##BasisComponent') IS NOT NULL  				
		DROP TABLE ##BasisComponent				

	SELECT	* 
	INTO	##BasisComponent
	FROM
	(
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
				CD.strPosition AS Position

		FROM	vyuCTSearchContractDetail	CD
		JOIN	tblCTContractCost			CC	ON	CC.intContractDetailId	=	CD.intContractDetailId
		JOIN	tblICItem					BI	ON	BI.intItemId			=	CC.intItemId
		WHERE	CC.ysnBasis	=	1 

		UNION ALL

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
				'Basis'			AS	strComponentItem,
				CD.dblBasis		AS  dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				2 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition

		FROM	vyuCTSearchContractDetail	CD

		UNION ALL

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
				'Cash Price'		AS	strComponentItem,
				CD.dblCashPrice		AS  dblRate,
				CD.strPriceUOM,
				CD.dblBasis,
				CD.dblCashPrice,
				3 AS intDisplayOrder,
				CD.strInternalComment,
				CD.intContractDetailId,
				CD.strPosition

		FROM	vyuCTSearchContractDetail	CD
	)t
	
	
	IF ISNULL(@intContractDetailId,'') <> ''
	BEGIN
		SET @Condition = ' intContractDetailId IN (' + @intContractDetailId + ') '
	END
	
	IF RTRIM(LTRIM(ISNULL(@Position,''))) <> ''
	BEGIN
		SET @Condition = ' Position IN (''' + @Position + ''') '
	END

	IF LEN(@Condition) > 0 AND ISNULL(@intContractDetailId,'') = ''
	BEGIN
		SET @Condition = @Condition + ' AND '
	END

	IF @ContractFromDate IS NOT NULL AND @ContractToDate IS NOT NULL
	BEGIN
		SET @Condition = @Condition +  ' dtmContractDate BETWEEN ''' + CONVERT(NVARCHAR(20), @ContractFromDate,101)  + ''' AND ''' + CONVERT(NVARCHAR(20), @ContractToDate,101) +''' '
	END
	ELSE IF @ContractFromDate IS NOT NULL AND @ContractToDate IS NULL
	BEGIN
		SET @Condition = @Condition +  ' dtmContractDate = ''' + @ContractFromDate + ''' '
	END
	ELSE
	BEGIN
		SET @Condition = SUBSTRING(@Condition,0,LEN(@Condition) -3)
	END

	IF LEN(@Condition) > 0 AND ISNULL(@intContractDetailId,'') = ''
	BEGIN
		SET @Condition = @Condition + ' AND '
	END

	IF @StartFromDate IS NOT NULL AND @StartToDate IS NOT NULL
	BEGIN
		SET @Condition = @Condition +  ' dtmStartDate >= ''' + CONVERT(NVARCHAR(20), @StartFromDate,101) + ''' AND  DATEADD(d, 0, DATEDIFF(d, 0, dtmStartDate)) <=''' + CONVERT(NVARCHAR(20), @StartToDate,101) +''''
	END
	ELSE IF @StartFromDate IS NOT NULL AND @StartToDate IS NULL
	BEGIN
		SET @Condition = @Condition +  ' ''' + CONVERT(NVARCHAR(20), @StartFromDate,101) + ''' BETWEEN dtmStartDate AND dtmEndDate'
	END
	ELSE IF @StartFromDate IS  NULL AND @StartToDate IS NOT NULL
	BEGIN
		SET @Condition = @Condition +  ' ''' + CONVERT(NVARCHAR(20), @StartToDate,101) + ''' BETWEEN dtmStartDate AND dtmEndDate'
	END
	ELSE
	BEGIN
		SET @Condition = SUBSTRING(@Condition,0,LEN(@Condition) -3)
	END

	IF LEN(@Condition) > 0 AND ISNULL(@intContractDetailId,'') = ''
	BEGIN
		SET @Condition = @Condition + ' AND '
	END

	IF @EndFromDate IS NOT NULL AND @EndToDate IS NOT NULL
	BEGIN
		SET @Condition = @Condition +  ' dtmStartDate >= ''' + CONVERT(NVARCHAR(20), @EndFromDate,101) + ''' AND  DATEADD(d, 0, DATEDIFF(d, 0, dtmEndDate)) <=''' + CONVERT(NVARCHAR(20), @EndToDate,101) +''''
	END
	ELSE IF @EndFromDate IS NOT NULL AND @EndToDate IS NULL
	BEGIN
		SET @Condition = @Condition +  ' ''' + CONVERT(NVARCHAR(20), @EndFromDate,101) + ''' BETWEEN dtmStartDate AND dtmEndDate'
	END
	ELSE IF @EndFromDate IS  NULL AND @EndToDate IS NOT NULL
	BEGIN
		SET @Condition = @Condition +  ' ''' + CONVERT(NVARCHAR(20), @EndToDate,101) + ''' BETWEEN dtmStartDate AND dtmEndDate'
	END
	ELSE
	BEGIN
		SET @Condition = SUBSTRING(@Condition,0,LEN(@Condition) -3)
	END

	SET @SQL = 'SELECT * FROM ##BasisComponent WHERE ' + @Condition

	EXEC sp_executesql @SQL