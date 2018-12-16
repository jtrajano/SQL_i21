CREATE PROCEDURE [dbo].[uspCTReportBalance]
	@xmlParam NVARCHAR(MAX) = NULL  
AS

BEGIN TRY
	
	DECLARE @ErrMsg					NVARCHAR(MAX)
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
	DECLARE @blbHeaderLogo			VARBINARY(MAX)
	
	DECLARE @intContractDetailId	INT
	DECLARE @intShipmentKey			INT
	DECLARE @intReceiptKey			INT
	DECLARE @intPriceFixationKey	INT
	DECLARE @dblShipQtyToAllocate	NUMERIC(38,20)
	DECLARE @dblAllocatedQty		NUMERIC(38,20)
	DECLARE @dblPriceQtyToAllocate  NUMERIC(38,20)


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
	
	DECLARE @Balance TABLE 
	(  
			intContractTypeId		INT,
			strType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(38,20) 
	)
	
	DECLARE @BalanceTotal TABLE 
	(  
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(38,20) 
	)
	
	DECLARE @tblChange TABLE 
	(  
			intSequenceHistoryId		INT,  
			intContractDetailId			INT
	)
	
	DECLARE @Shipment TABLE 
	(  
			intShipmentKey          INT IDENTITY(1,1),
			intContractTypeId		INT,
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dtmDate					DATETIME, 
			dtmStartDate			DATETIME,
			dtmEndDate				DATETIME,
			dblQuantity				NUMERIC(38,20),
			dblAllocatedQuantity	NUMERIC(38,20)
	)

	DECLARE @PriceFixation TABLE 
	(  	 
			intPriceFixationKey     INT IDENTITY(1,1),
			intContractTypeId		INT,
			intContractHeaderId		INT,
			intContractDetailId		INT,
			dtmFixationDate			DATETIME,        
			dblQuantity				NUMERIC(38,20),
			dblFutures				NUMERIC(38,20),
			dblBasis				NUMERIC(38,20),
			dblCashPrice			NUMERIC(38,20),
			dblShippedQty			NUMERIC(38,20)
	)
	
	DECLARE @FinalResult TABLE 
	( 
	 intContractHeaderId	INT
	,intContractDetailId	INT
	,strCompanyName			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
	,blbHeaderLogo			varbinary(max)		
	,strDate				NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
	,strContractType		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intCommodityId			INT
	,strCommodity			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intCompanyLocationId	INT
	,strLocationName		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strCustomer			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strContract			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strPricingType			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strContractDate		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strShipMethod			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,strShipmentPeriod		NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,intFutureMarketId      INT
	,intFutureMonthId       INT
	,strFutureMonth			NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	,dblFutures				NUMERIC(38,20)
	,dblBasis				NUMERIC(38,20)
	,strBasisUOM			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblQuantity			NUMERIC(38,20)
	,strQuantityUOM			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblCashPrice			NUMERIC(38,20)
	,strPriceUOM			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,strStockUOM			NVARCHAR(200) COLLATE Latin1_General_CI_AS
	,dblAvailableQty		NUMERIC(38,20)
	,dblAmount				NUMERIC(38,20)
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

	IF @dtmStartDate IS NOT NULL
		SET @dtmStartDate = dbo.fnRemoveTimeOnDate(@dtmStartDate)
    
	IF @dtmEndDate IS NOT NULL
		SET @dtmEndDate = dbo.fnRemoveTimeOnDate(@dtmEndDate)

	DECLARE @strCompanyName			NVARCHAR(500)
	
	SELECT	@strCompanyName	=	CASE 
									WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL 
									ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) 
								END
	FROM	tblSMCompanySetup

	SELECT @blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')

	 INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate				
	   ,dtmStartDate		
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity			
	  )
	   SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate
	  ,@dtmStartDate AS dtmStartDate 
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(InvTran.dblQty * - 1) AS dblQuantity
	  ,0
	   FROM tblICInventoryTransaction InvTran
	   JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = InvTran.intTransactionId
	   	AND intOrderType = 1
	   JOIN tblICInventoryShipmentItem ON tblICInventoryShipmentItem.intInventoryShipmentItemId = InvTran.intTransactionDetailId
	   JOIN tblCTContractHeader CH ON CH.intContractHeaderId = intOrderId
	   JOIN tblCTContractDetail CD ON CD.intContractDetailId = intLineNo
	   WHERE strTransactionForm = 'Inventory Shipment'
	   	AND InvTran.ysnIsUnposted = 0
	   	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	   	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	   	AND intContractTypeId = 2
	   	AND intInTransitSourceLocationId IS NULL
	   GROUP BY CH.intContractTypeId,CH.intContractHeaderId
	   	,CD.intContractDetailId
		,InvTran.dtmDate
	  
	   INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate				
	   ,dtmStartDate		
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity			
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	   ,InvTran.dtmDate
	  ,@dtmStartDate AS dtmStartDate 
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(InvTran.dblQty)*-1 dblQuantity
	  ,0
	  FROM tblICInventoryTransaction InvTran
	  JOIN tblLGLoadDetail LD ON LD.intLoadId = InvTran.intTransactionId
	  JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	  JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	  WHERE
	  	ysnIsUnposted = 0
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END	
	  	AND InvTran.intTransactionTypeId = 46
	  	AND InvTran.intInTransitSourceLocationId IS NULL
	  GROUP BY CH.intContractTypeId,CH.intContractHeaderId
	  	,CD.intContractDetailId,InvTran.dtmDate

	  INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate				
	   ,dtmStartDate		
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity			
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate
	  ,@dtmStartDate AS dtmStartDate 
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(ReceiptItem.dblOpenReceive) dblQuantity
	  ,0
	  FROM tblICInventoryTransaction InvTran
	  JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = InvTran.intTransactionId
	  	AND strReceiptType = 'Purchase Contract'
	  JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
	  JOIN tblCTContractHeader CH ON CH.intContractHeaderId = intOrderId
	  JOIN tblCTContractDetail CD ON CD.intContractDetailId = intLineNo
	  WHERE strTransactionForm = 'Inventory Receipt'
	  	AND ysnIsUnposted = 0
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	  	AND intContractTypeId = 1
	  	AND InvTran.intTransactionTypeId = 4
	  GROUP BY CH.intContractTypeId,CH.intContractHeaderId
	  	,CD.intContractDetailId,InvTran.dtmDate

	  INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate				
	   ,dtmStartDate		
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity			
	  )
	SELECT 
		 CH.intContractTypeId		
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,dbo.fnRemoveTimeOnDate(SS.dtmCreated)
		,@dtmStartDate AS dtmStartDate 
	    ,@dtmEndDate  AS dtmEndDate
		,SUM(SC.dblUnits) AS dblQuantity
		,0
		FROM tblGRSettleContract SC
		JOIN tblGRSettleStorage  SS ON SS.intSettleStorageId = SC.intSettleStorageId
		JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
		JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		WHERE SS.ysnPosted = 1
			AND SS.intParentSettleStorageId IS NOT NULL
			AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
			AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
		GROUP BY CH.intContractTypeId,CH.intContractHeaderId
			,CD.intContractDetailId,SS.dtmCreated
	
	 
	 
	 INSERT INTO @Balance(intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
	 SELECT
	  CH.intContractTypeId 
	 ,'Audit'
	 ,Audi.intContractHeaderId
	 ,Audi.intContractDetailId
	 ,SUM(Audi.dblTransactionQuantity) AS dblQuantity
	 FROM vyuCTSequenceAudit Audi
	 JOIN tblCTContractHeader CH ON CH.intContractHeaderId = Audi.intContractHeaderId
	 WHERE Audi.strFieldName = 'Quantity'	
	 AND dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) >= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) END
	 GROUP BY CH.intContractTypeId,Audi.intContractHeaderId
	 	,Audi.intContractDetailId    
	
	
	
	INSERT INTO @PriceFixation(intContractTypeId,intContractHeaderId,intContractDetailId,dtmFixationDate,dblQuantity,dblFutures,dblBasis,dblCashPrice,dblShippedQty)
	SELECT	CH.intContractTypeId,
			PF.intContractHeaderId,
			PF.intContractDetailId,											   	
			FD.dtmFixationDate,												   
			SUM(FD.dblQuantity),
			FD.dblFutures,
			FD.dblBasis,
			FD.dblCashPrice,
			0
	FROM	tblCTPriceFixationDetail FD
	JOIN	tblCTPriceFixation		 PF	ON	PF.intPriceFixationId =	FD.intPriceFixationId
	JOIN tblCTContractHeader		 CH ON CH.intContractHeaderId = PF.intContractHeaderId
	WHERE   dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate ELSE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) END
	AND     dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) END
	GROUP BY CH.intContractTypeId,PF.intContractHeaderId,PF.intContractDetailId,FD.dtmFixationDate,FD.dblFutures,FD.dblBasis,FD.dblCashPrice
	
	
	
	SELECT @intShipmentKey = MIN(intShipmentKey) FROM @Shipment WHERE dblQuantity > ISNULL(dblAllocatedQuantity,0) 
	AND intContractHeaderId IN (SELECT intContractHeaderId FROM @PriceFixation WHERE dblQuantity > dblShippedQty)
	
	WHILE @intShipmentKey > 0 
	BEGIN
		
		SET    @dblShipQtyToAllocate = NULL
		SET    @intContractDetailId  = NULL
		
		SELECT @dblShipQtyToAllocate = dblQuantity - ISNULL(dblAllocatedQuantity,0), @intContractDetailId = intContractDetailId  
		FROM @Shipment WHERE intShipmentKey = @intShipmentKey

		SELECT @intPriceFixationKey = MIN(intPriceFixationKey) FROM @PriceFixation WHERE (dblQuantity - dblShippedQty) > 0 AND intContractDetailId = @intContractDetailId

		SELECT @dblPriceQtyToAllocate = dblQuantity - dblShippedQty  FROM @PriceFixation WHERE intPriceFixationKey = @intPriceFixationKey

		SELECT @dblAllocatedQty = CASE WHEN @dblPriceQtyToAllocate > @dblShipQtyToAllocate THEN @dblShipQtyToAllocate ELSE @dblPriceQtyToAllocate END

		UPDATE @PriceFixation SET dblShippedQty = ISNULL(dblShippedQty,0) + @dblAllocatedQty WHERE intPriceFixationKey = @intPriceFixationKey
		UPDATE @Shipment      SET dblAllocatedQuantity = ISNULL(dblAllocatedQuantity,0)+ @dblAllocatedQty  WHERE intShipmentKey = @intShipmentKey	

		SELECT @intShipmentKey = MIN(intShipmentKey) FROM @Shipment WHERE ISNULL(dblQuantity,0) >  ISNULL(dblAllocatedQuantity,0) 
		AND intContractHeaderId IN (SELECT intContractHeaderId FROM @PriceFixation WHERE dblQuantity > dblShippedQty)

	END

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT intContractTypeId,'PriceFixation',intContractHeaderId,intContractDetailId,dblQuantity * -1 FROM @PriceFixation 

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT intContractTypeId,'Shipment',intContractHeaderId,intContractDetailId,(dblQuantity - dblAllocatedQuantity) * -1 FROM @Shipment

	INSERT INTO @BalanceTotal(intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT intContractHeaderId,intContractDetailId,SUM(dblQuantity) FROM @Balance 
	GROUP BY intContractHeaderId,intContractDetailId


	INSERT INTO @FinalResult
	( 
	   intContractHeaderId
	  ,intContractDetailId
	  ,strCompanyName			
	  ,blbHeaderLogo			
	  ,strDate				
	  ,strContractType		
	  ,intCommodityId			
	  ,strCommodity			
	  ,intCompanyLocationId	
	  ,strLocationName		
	  ,strCustomer			
	  ,strContract			
	  ,strPricingType			
	  ,strContractDate		
	  ,strShipMethod			
	  ,strShipmentPeriod		
	  ,intFutureMarketId      
	  ,intFutureMonthId       
	  ,strFutureMonth			
	  ,dblFutures				
	  ,dblBasis
	  ,strBasisUOM				
	  ,dblQuantity
	  ,strQuantityUOM			
	  ,dblCashPrice
	  ,strPriceUOM
	  ,strStockUOM			
	  ,dblAvailableQty		
	  ,dblAmount				
	)				
	SELECT				 			
	 intContractHeaderId    = CH.intContractHeaderId
	,intContractDetailId    = CD.intContractDetailId
	,strCompanyName			= @strCompanyName
	,blbHeaderLogo			= @blbHeaderLogo
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
	,strShipMethod			= StockUM.strUnitMeasure
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
	,intFutureMarketId      = CD.intFutureMarketId
	,intFutureMonthId       = CD.intFutureMonthId
	,strFutureMonth			= MO.strFutureMonth
	,dblFutures				= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0)),0)
	,dblBasis				= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(CD.dblBasis,0)),0)
	,strBasisUOM			= BUOM.strUnitMeasure
	,dblQuantity			= ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
	,strQuantityUOM			= IUM.strUnitMeasure
	,dblCashPrice			= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)	
	,strPriceUOM			= PUOM.strUnitMeasure
	,strStockUOM			= StockUM.strUnitMeasure
	,dblAvailableQty		= ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
	,dblAmount				= (
								ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
							  ) 
							  * ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)

	FROM tblCTContractDetail					CD	
	JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
	LEFT JOIN @BalanceTotal                     BL  ON CH.intContractHeaderId           =   BL.intContractHeaderId
	AND												   CD.intContractDetailId          =    BL.intContractDetailId
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
	JOIN tblICItemUOM						StockUOM   ON StockUOM.intItemId			= CD.intItemId AND StockUOM.ysnStockUnit = 1 
	JOIN tblICUnitMeasure					StockUM	   ON StockUM.intUnitMeasureId		= StockUOM.intUnitMeasureId

	JOIN tblICItemUOM						ItemUOM   ON ItemUOM.intItemUOMId			= CD.intItemUOMId
	JOIN tblICUnitMeasure					IUM		  ON IUM.intUnitMeasureId			= ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM					BASISUOM  ON BASISUOM.intItemUOMId			= CD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure				BUOM	  ON BUOM.intUnitMeasureId			= BASISUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM					PriceUOM  ON PriceUOM.intItemUOMId		    = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure				PUOM	  ON PUOM.intUnitMeasureId			= PriceUOM.intUnitMeasureId

	LEFT JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId
	
	WHERE CH.intContractTypeId	  = CASE WHEN ISNULL(@intContractTypeId ,0) > 0    THEN @intContractTypeId	  ELSE CH.intContractTypeId                  END
	AND   CH.intEntityId		  = CASE WHEN ISNULL(@intEntityId ,0) > 0		   THEN @intEntityId		  ELSE CH.intEntityId		                 END
	AND   CH.intCommodityId		  = CASE WHEN ISNULL(@IntCommodityId ,0) > 0	   THEN @IntCommodityId		  ELSE CH.intCommodityId	                 END
	AND   dbo.fnRemoveTimeOnDate(CD.dtmCreated)	>= CASE WHEN @dtmStartDate IS NOT NULL	THEN @dtmStartDate	  ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
	AND   dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE WHEN @dtmEndDate IS NOT NULL	THEN @dtmEndDate	  ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
	AND   CD.intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId ,0) > 0 THEN @intCompanyLocationId ELSE CD.intCompanyLocationId               END
	AND   CD.intFutureMarketId    = CASE WHEN ISNULL(@IntFutureMarketId ,0) > 0	   THEN @IntFutureMarketId	  ELSE CD.intFutureMarketId	                 END
	AND   CD.intFutureMonthId     = CASE WHEN ISNULL(@IntFutureMonthId ,0) > 0     THEN @IntFutureMonthId     ELSE CD.intFutureMonthId                   END
	
	INSERT INTO @tblChange(intSequenceHistoryId,intContractDetailId)
	SELECT MAX(intSequenceHistoryId),intContractDetailId FROM tblCTSequenceHistory 
	WHERE  dbo.fnRemoveTimeOnDate(dtmHistoryCreated)	<= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END
	GROUP BY intContractDetailId

	UPDATE @FinalResult 
	SET strPricingType = CASE 
								  WHEN SH.intPricingTypeId = 1 THEN 'P' 
								  WHEN SH.intPricingTypeId = 2 THEN 'B' 
								  WHEN SH.intPricingTypeId = 3 THEN 'H'
								  WHEN SH.intPricingTypeId = 6 THEN 'C'
								  WHEN SH.intPricingTypeId = 7 THEN 'I'
						 END
       ,dblFutures        = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
	   ,dblBasis          = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
	   ,dblCashPrice      = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
							+ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
	   ,intFutureMarketId = SH.intFutureMarketId
	   ,intFutureMonthId  = SH.intFutureMonthId
	   ,strFutureMonth    = MO.strFutureMonth
	FROM @FinalResult FR 
	JOIN @tblChange tblChange ON tblChange.intContractDetailId = FR.intContractDetailId
	JOIN tblCTSequenceHistory SH ON SH.intSequenceHistoryId = tblChange.intSequenceHistoryId
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	SH.intFutureMonthId

	INSERT INTO @FinalResult
	( 
	 intContractHeaderId
	,intContractDetailId
	,strCompanyName		
	,blbHeaderLogo			
	,strDate				
	,strContractType		
	,intCommodityId			
	,strCommodity			
	,intCompanyLocationId	
	,strLocationName		
	,strCustomer			
	,strContract			
	,strPricingType			
	,strContractDate		
	,strShipMethod			
	,strShipmentPeriod		
	,intFutureMarketId      
	,intFutureMonthId       
	,strFutureMonth			
	,dblFutures				
	,dblBasis
	,strBasisUOM				
	,dblQuantity
	,strQuantityUOM			
	,dblCashPrice
	,strPriceUOM
	,strStockUOM					
	,dblAvailableQty		
	,dblAmount				
	)			
	SELECT DISTINCT 				 			
	 intContractHeaderId    = CH.intContractHeaderId
	,intContractDetailId    = CD.intContractDetailId
	,strCompanyName			= @strCompanyName
	,blbHeaderLogo			= @blbHeaderLogo
	,strDate				= LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)
	,strContractType		= TP.strContractType
	,intCommodityId			= CH.intCommodityId
	,strCommodity			= CM.strDescription +' '+UOM.strUnitMeasure
	,intCompanyLocationId	= CD.intCompanyLocationId
	,strLocationName		= L.strLocationName					   
	,strCustomer			= EY.strEntityName
	,strContract			= CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)
	,strPricingType			= 'P'
	,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	,strShipMethod			= StockUM.strUnitMeasure
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
	,intFutureMarketId      = CD.intFutureMarketId
	,intFutureMonthId       = CD.intFutureMonthId
	,strFutureMonth			= MO.strFutureMonth
	,dblFutures				= ISNULL(PF.dblFutures,0)
	,dblBasis				= ISNULL(PF.dblBasis,0)
	,strBasisUOM			= BUOM.strUnitMeasure
	,dblQuantity			= ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)
	,strQuantityUOM			= IUM.strUnitMeasure
	,dblCashPrice			= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)
	,strPriceUOM			=  PUOM.strUnitMeasure
	,strStockUOM			= StockUM.strUnitMeasure	
	,dblAvailableQty		= ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)
	,dblAmount				= (ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)) * ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)

	FROM tblCTContractDetail					CD	
	JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
	LEFT JOIN @BalanceTotal                     BL  ON CH.intContractHeaderId           =   BL.intContractHeaderId
	AND												   CD.intContractDetailId           =   BL.intContractDetailId
	JOIN @PriceFixation							PF  ON  PF.intContractDetailId          =   CD.intContractDetailId
												AND     PF.intContractDetailId          =   BL.intContractDetailId
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
	JOIN tblICItemUOM						StockUOM   ON StockUOM.intItemId			= CD.intItemId AND StockUOM.ysnStockUnit = 1 
	JOIN tblICUnitMeasure					StockUM	   ON StockUM.intUnitMeasureId		= StockUOM.intUnitMeasureId

	JOIN tblICItemUOM						ItemUOM   ON ItemUOM.intItemUOMId			= CD.intItemUOMId
	JOIN tblICUnitMeasure					IUM		  ON IUM.intUnitMeasureId			= ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM					BASISUOM  ON BASISUOM.intItemUOMId			= CD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure				BUOM	  ON BUOM.intUnitMeasureId			= BASISUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM					PriceUOM  ON PriceUOM.intItemUOMId		    = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure				PUOM	  ON PUOM.intUnitMeasureId			= PriceUOM.intUnitMeasureId
	
	LEFT JOIN	tblSMFreightTerms				FT	ON	FT.intFreightTermId			=	CD.intFreightTermId
	JOIN	tblRKFuturesMonth				MO	ON	MO.intFutureMonthId			=	CD.intFutureMonthId
	
	WHERE CH.intContractTypeId	  = CASE WHEN ISNULL(@intContractTypeId ,0) > 0    THEN @intContractTypeId	  ELSE CH.intContractTypeId					 END
	AND   CH.intEntityId		  = CASE WHEN ISNULL(@intEntityId ,0) > 0		   THEN @intEntityId		  ELSE CH.intEntityId						 END
	AND   CH.intCommodityId		  = CASE WHEN ISNULL(@IntCommodityId ,0) > 0	   THEN @IntCommodityId		  ELSE CH.intCommodityId					 END
	AND   dbo.fnRemoveTimeOnDate(CD.dtmCreated) >= CASE WHEN @dtmStartDate IS NOT NULL THEN @dtmStartDate	  ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
	AND   dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate		  ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
	AND   CD.intCompanyLocationId = CASE WHEN ISNULL(@intCompanyLocationId ,0) > 0 THEN @intCompanyLocationId ELSE CD.intCompanyLocationId				 END
	AND   CD.intFutureMarketId    = CASE WHEN ISNULL(@IntFutureMarketId ,0) > 0	   THEN @IntFutureMarketId	  ELSE CD.intFutureMarketId					 END
	AND   CD.intFutureMonthId     = CASE WHEN ISNULL(@IntFutureMonthId ,0) > 0     THEN @IntFutureMonthId     ELSE CD.intFutureMonthId					 END
	AND   ISNULL(BL.dblQuantity,0) <= 0
	
	UPDATE @FinalResult 
	SET dblAmount = ISNULL(dblAvailableQty,0) * (ISNULL(dblFutures,0)+ISNULL(dblBasis,0))

	DELETE FROM @FinalResult 
							WHERE intContractDetailId IN (SELECT intContractDetailId FROM tblCTSequenceHistory WHERE intContractStatusId = 6 
							AND dbo.fnRemoveTimeOnDate(dtmHistoryCreated) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate	 ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END) 

	SELECT * FROM @FinalResult WHERE  dblAvailableQty > 0 

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH
GO