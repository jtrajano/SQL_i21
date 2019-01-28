CREATE PROCEDURE [dbo].[uspCTReportBalance]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE @blbHeaderLogo			VARBINARY(MAX)
	DECLARE @xmlDocumentId			INT
	DECLARE @intContractTypeId		INT
	DECLARE @intEntityId			INT
	DECLARE @IntCommodityId			INT
	DECLARE @intUnitMeasureId		INT	
	DECLARE @dtmEndDate				DATE
	DECLARE @intCompanyLocationId	INT
	DECLARE @IntFutureMarketId		INT
	DECLARE @IntFutureMonthId		INT
	DECLARE @strCompanyName			NVARCHAR(500)
	DECLARE @strPrintOption			NVARCHAR(500)	

	SELECT	@strCompanyName	=	CASE 
									WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL 
									ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) 
								END
	FROM	tblSMCompanySetup

	SELECT @blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
	


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

	SELECT	@intContractTypeId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intContractTypeId'
	
	SELECT	@intEntityId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intEntityId'
	
	SELECT	@IntCommodityId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'IntCommodityId'

	SELECT	@intUnitMeasureId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intUnitMeasureId'

	SELECT	@dtmEndDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'dtmEndDate'

	SELECT	@intCompanyLocationId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intCompanyLocationId'

	SELECT	@IntFutureMarketId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intFutureMarketId'

	SELECT	@IntFutureMonthId = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'intFutureMonthId'

	SELECT	@strPrintOption = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'strPrintOption'
	
	EXEC uspCTGetContractBalance
		 @intContractTypeId	   = 	@intContractTypeId
		,@intEntityId		   =	@intEntityId
		,@IntCommodityId	   =    @IntCommodityId	
		,@dtmEndDate		   =    @dtmEndDate		
		,@intCompanyLocationId =	@intCompanyLocationId
		,@IntFutureMarketId    =    @IntFutureMarketId
		,@IntFutureMonthId     =    @IntFutureMonthId
		,@strPrintOption	   =    @strPrintOption

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO