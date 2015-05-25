CREATE PROCEDURE uspCTReportContractDetailGrain

	@xmlParam NVARCHAR(MAX) = NULL  
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	 

	DECLARE @intContractHeaderId	INT,
			@xmlDocumentId			INT 
			
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
    
	SELECT	@intContractHeaderId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractHeaderId' 

	SELECT	strItemNo,dblDetailQuantity,
			CASE	WHEN intPricingTypeId = 1 THEN dblCashPrice
					WHEN intPricingTypeId = 2 THEN dblBasis
					WHEN intPricingTypeId = 3 THEN dblFutures
			ELSE
					0
			END		AS	dblPrice,
			dtmStartDate,
			dtmEndDate,
			strPricingType,
			strShipVia,
			strLocationName,
			intContractHeaderId,
			strRemark,
			strDetailUnitMeasure
	FROM	vyuCTContractDetailView DV
	WHERE	intContractHeaderId	=	@intContractHeaderId
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspCTReportContractDetailGrain - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO
