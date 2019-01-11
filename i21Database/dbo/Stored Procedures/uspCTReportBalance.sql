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
	DECLARE @dtmStartDate			DATE
	DECLARE @dtmEndDate				DATE
	DECLARE @intCompanyLocationId	INT
	DECLARE @IntFutureMarketId		INT
	DECLARE @IntFutureMonthId		INT
	DECLARE @strCompanyName			NVARCHAR(500)

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

  /*
	SELECT  
	 CB.intContractHeaderId
	,CB.strType
	,CB.intContractDetailId
	,strCompanyName = @strCompanyName		
	,blbHeaderLogo	= @blbHeaderLogo		
	,CB.strDate				
	,CB.strContractType		
	,CB.intCommodityId			
	,strCommodity = CB.strCommodity  +' '+UOM.strUnitMeasure
	,CB.intItemId		
	,CB.strItemNo					
	,CB.intCompanyLocationId	
	,CB.strLocationName		
	,CB.strCustomer			
	,CB.strContract			
	,strPricingType = LEFT(CB.strPricingType,1)
	,CB.strContractDate		
	,CB.strShipMethod			
	,CB.strShipmentPeriod		
	,CB.intFutureMarketId      
	,CB.intFutureMonthId       
	,CB.strFutureMonth			
	,CB.dblFutures				
	,CB.dblBasis
	,CB.strBasisUOM				
	,CB.dblQuantity
	,CB.strQuantityUOM			
	,CB.dblCashPrice
	,CB.strPriceUOM
	,CB.strStockUOM					
	,CB.dblAvailableQty		
	,CB.dblAmount		
	FROM 
	[dbo].[fnCTGetContractBalance]
	(
		 @intContractTypeId		
		,@intEntityId			
		,@IntCommodityId		
		,@dtmStartDate			
		,@dtmEndDate			
		,@intCompanyLocationId
		,@IntFutureMarketId   
		,@IntFutureMonthId    
		,NULL 
	) CB
	JOIN	tblICCommodityUnitMeasure			C1	ON	C1.intCommodityId				=	CB.intCommodityId AND C1.ysnStockUnit=1
	JOIN    tblICUnitMeasure					UOM ON  UOM.intUnitMeasureId			=   C1.intUnitMeasureId
 */

	EXEC uspCTGetContractBalance
		 @intContractTypeId	   = 	@intContractTypeId
		,@intEntityId		   =	@intEntityId
		,@IntCommodityId	   =    @IntCommodityId		
		,@dtmStartDate		   =    @dtmStartDate	
		,@dtmEndDate		   =    @dtmEndDate		
		,@intCompanyLocationId =	@intCompanyLocationId
		,@IntFutureMarketId    =    @IntFutureMarketId
		,@IntFutureMonthId     =    @IntFutureMonthId

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO