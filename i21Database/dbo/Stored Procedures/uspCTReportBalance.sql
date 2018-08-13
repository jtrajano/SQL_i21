CREATE PROCEDURE [dbo].[uspCTReportBalance]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg			NVARCHAR(MAX)
	DECLARE @xmlDocumentId	INT

	DECLARE @intContractTypeId		INT
	DECLARE @intEntityId			INT
	DECLARE @IntCommodityId			INT
	DECLARE @intUnitMeasureId		INT
	DECLARE @dtmStartDate			DATE
	DECLARE @dtmEndDate				DATE
	DECLARE @intCompanyLocationId	INT
	DECLARE @IntFutureMarketId		INT
	DECLARE @IntFutureMonthId		INT


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

	SELECT	@dtmStartDate = [from]
	FROM	@temp_xml_table   
	WHERE	[fieldname] = 'dtmStartDate'

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

	
	DECLARE @strCompanyName			NVARCHAR(500)
	
	SELECT	@strCompanyName	=	CASE 
									WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL 
									ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) 
								END
	FROM	tblSMCompanySetup



	SELECT	
	 strCompanyName			= @strCompanyName
	,blbHeaderLogo			= dbo.fnSMGetCompanyLogo('Header')
	,strDate				= LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)
	,strContractType		= TP.strContractType
	,intCommodityId			= CH.intCommodityId
	,strCommodity			= CM.strDescription +' '+UOM.strUnitMeasure
	,intCompanyLocationId	= CD.intCompanyLocationId
	,strLocationName		= L.strLocationName
					   
	,strCustomer			= EY.strEntityName
	,strContract			= CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)
	,strPricingType			= CASE 
								  WHEN CD.intPricingTypeId = 1 THEN 'P' 
								  WHEN CD.intPricingTypeId = 2 THEN 'B' 
								  WHEN CD.intPricingTypeId = 3 THEN 'H'
								  WHEN CD.intPricingTypeId = 6 THEN 'C'
								  WHEN CD.intPricingTypeId = 7 THEN 'I'
							 END
	,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	,strShipMethod			= FT.strFreightTerm
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
	,intFutureMarketId       = CD.intFutureMarketId
	,intFutureMonthId       = CD.intFutureMonthId
	,strFutureMonth			= MO.strFutureMonth
	,dblCashPrice			= CD.dblCashPrice
	,dblQuantity			= CD.dblQuantity
	,dblAvailableQty		= ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)
	,dblAmount				= (ISNULL(CD.dblBalance,0) - ISNULL(CD.dblScheduleQty,0)) * CD.dblCashPrice

	FROM tblCTContractDetail					CD	
	JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
	JOIN	tblICCommodity						CM	ON	CM.intCommodityId				=	CH.intCommodityId
	JOIN	tblICCommodityUnitMeasure			C1	ON	C1.intCommodityId				=	CH.intCommodityId AND C1.intCommodityId = CM.intCommodityId AND C1.ysnStockUnit=1
	JOIN    tblICUnitMeasure					UOM ON  UOM.intUnitMeasureId			=   C1.intUnitMeasureId

	JOIN	tblCTContractType					TP	ON	TP.intContractTypeId			=	CH.intContractTypeId
	JOIN    tblSMCompanyLocation				L	ON	L.intCompanyLocationId          =   CD.intCompanyLocationId
	JOIN	vyuCTEntity							EY	ON	EY.intEntityId					=	CH.intEntityId	AND
														EY.strEntityType				=	(
																							 CASE 
																								 WHEN CH.intContractTypeId = 1 THEN 'Vendor' 
																								 ELSE 'Customer' 
																							  END
																							 )
	JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId
	
	WHERE CH.intContractTypeId	  = CASE WHEN ISNULL(@intContractTypeId ,0) > 0    THEN @intContractTypeId	  ELSE CH.intContractTypeId    END
	AND   CH.intEntityId		  = CASE WHEN ISNULL(@intEntityId ,0) > 0		   THEN @intEntityId		  ELSE CH.intEntityId		   END
	AND   CH.intCommodityId		  = CASE WHEN ISNULL(@IntCommodityId ,0) > 0	   THEN @IntCommodityId		  ELSE CH.intCommodityId	   END
	AND   CD.dtmStartDate        >= CASE WHEN @dtmStartDate IS NOT NULL			   THEN @dtmStartDate		  ELSE CD.dtmStartDate		   END
	AND   CD.dtmEndDate			 <= CASE WHEN @dtmEndDate IS NOT NULL			   THEN @dtmEndDate			  ELSE CD.dtmEndDate		   END
	AND   CD.intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId ,0) > 0 THEN @intCompanyLocationId ELSE CD.intCompanyLocationId END
	AND   CD.intFutureMarketId    = CASE WHEN ISNULL(@IntFutureMarketId ,0) > 0	   THEN @IntFutureMarketId	  ELSE CD.intFutureMarketId	   END
	AND   CD.intFutureMonthId     = CASE WHEN ISNULL(@IntFutureMonthId ,0) > 0     THEN @IntFutureMonthId     ELSE CD.intFutureMonthId     END

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO