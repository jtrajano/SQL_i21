CREATE PROCEDURE [dbo].[uspCTGetContractBalance]
   	@intContractTypeId		INT  = NULL
   ,@intEntityId			INT  = NULL
   ,@IntCommodityId			INT  = NULL  
   ,@dtmEndDate				DATE = NULL
   ,@intCompanyLocationId   INT  = NULL
   ,@IntFutureMarketId      INT  = NULL
   ,@IntFutureMonthId       INT  = NULL
   ,@strPositionIncludes    NVARCHAR(MAX) = NULL
   ,@strCallingApp			NVARCHAR(MAX) = NULL
   ,@strPrintOption			NVARCHAR(MAX) = NULL

AS

BEGIN TRY

	DECLARE @ErrMsg					NVARCHAR(MAX)
	DECLARE @blbHeaderLogo			VARBINARY(MAX)	
	DECLARE @intContractDetailId	INT
	DECLARE @intShipmentKey			INT
	DECLARE @intReceiptKey			INT
	DECLARE @intPriceFixationKey	INT
	DECLARE @dblShipQtyToAllocate	NUMERIC(38,20)
	DECLARE @dblAllocatedQty		NUMERIC(38,20)
	DECLARE @dblPriceQtyToAllocate  NUMERIC(38,20)

	DECLARE @SequenceHistory TABLE
	(
		intContractDetailId INT,
		intContractStatusId INT,
		intPricingTypeId	INT,
		dtmHistoryCreated   DATETIME
	)

	DECLARE @Balance TABLE 
	(  
			intContractTypeId		INT,
			strType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(38,20),
			intNoOfLoad				INT 
	)
	
	DECLARE @BalanceTotal TABLE 
	(  
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(38,20),
			intNoOfLoad				INT 
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
			dtmEndDate				DATETIME,
			dblQuantity				NUMERIC(38,20),
			dblAllocatedQuantity	NUMERIC(38,20),
			intNoOfLoad				INT,
			intSourceId				INT
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
			dblShippedQty			NUMERIC(38,20),
			intNoOfLoad				INT,
			intShippedNoOfLoad		INT
	)
    
	IF @dtmEndDate IS NOT NULL
		SET @dtmEndDate = dbo.fnRemoveTimeOnDate(@dtmEndDate)

	DECLARE @strCompanyName			NVARCHAR(500)
	
	SELECT	@strCompanyName	=	CASE 
									WHEN LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) = '' THEN NULL 
									ELSE LTRIM(RTRIM(tblSMCompanySetup.strCompanyName)) 
								END
	FROM	tblSMCompanySetup

	SELECT @blbHeaderLogo = dbo.fnSMGetCompanyLogo('Header')
	
	--Delete the data from tblCTContractBalance table with the passed param dtmEndDate
	--This is to make sure we are regenerating the data real time
	DELETE FROM tblCTContractBalance WHERE dtmEndDate = @dtmEndDate


	INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate	
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity
	   ,intNoOfLoad
	   ,intSourceId	  
	  )
	   SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate	  
	  ,@dtmEndDate AS dtmEndDate
	  ,dblQuantity = CASE
					 	WHEN SUM(ISNULL(ShipmentItem.dblDestinationNet, 0)) = 0 OR SUM(ShipmentItem.dblDestinationNet * 1) > SUM(CD.dblQuantity)
					 		THEN SUM(InvTran.dblQty * - 1) 
					 	ELSE SUM(ShipmentItem.dblDestinationNet * 1)
					 END
	  ,0
	  ,COUNT(DISTINCT Shipment.intInventoryShipmentId)
	  ,Shipment.intInventoryShipmentId	  
	   FROM tblICInventoryTransaction InvTran
	   JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = InvTran.intTransactionId AND Shipment.intOrderType = 1
	   JOIN tblICInventoryShipmentItem ShipmentItem ON ShipmentItem.intInventoryShipmentId = InvTran.intTransactionId
	   AND Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
	   AND ShipmentItem.intInventoryShipmentItemId = InvTran.intTransactionDetailId
	   JOIN tblCTContractHeader CH ON CH.intContractHeaderId = ShipmentItem.intOrderId
	   JOIN tblCTContractDetail CD ON CD.intContractDetailId = ShipmentItem.intLineNo 
	   AND CD.intContractHeaderId = CH.intContractHeaderId
	   WHERE InvTran.strTransactionForm = 'Inventory Shipment'
	   	AND InvTran.ysnIsUnposted = 0
	   	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	   	AND intContractTypeId = 2
	   	AND InvTran.intInTransitSourceLocationId IS NULL
	   GROUP BY 
	     CH.intContractTypeId
		,CH.intContractHeaderId
	   	,CD.intContractDetailId
		,InvTran.dtmDate
		,Shipment.intInventoryShipmentId
		
	INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate	
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity
	   ,intNoOfLoad
	   ,intSourceId	  
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate	  
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(InvTran.dblQty * - 1) AS dblQuantity
	  ,0
	  ,COUNT(DISTINCT Invoice.intInvoiceId)
	  ,Invoice.intInvoiceId	  
	   FROM tblICInventoryTransaction InvTran
	   JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvTran.intTransactionId 
	   JOIN tblARInvoiceDetail InvoiceDetail ON InvoiceDetail.intInvoiceId = InvTran.intTransactionId
	   AND Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
	   AND InvoiceDetail.intInvoiceDetailId = InvTran.intTransactionDetailId
	   JOIN tblCTContractHeader CH ON CH.intContractHeaderId = InvoiceDetail.intContractHeaderId
	   JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvoiceDetail.intContractDetailId
	   LEFT JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = InvoiceDetail.intSalesOrderDetailId
	   AND CD.intContractHeaderId = CH.intContractHeaderId
	   WHERE InvTran.strTransactionForm = 'Invoice'
	   	AND InvTran.ysnIsUnposted = 0
	   	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	   	AND intContractTypeId = 2
	   	AND InvTran.intInTransitSourceLocationId IS NULL
	   GROUP BY 
	     CH.intContractTypeId
		,CH.intContractHeaderId
	   	,CD.intContractDetailId
		,InvTran.dtmDate
		,Invoice.intInvoiceId

	INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity
	   ,intNoOfLoad
	   ,intSourceId			
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	   ,InvTran.dtmDate
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(InvTran.dblQty)*-1 dblQuantity
	  ,0
	  ,COUNT(DISTINCT LD.intLoadId)
	  , LD.intLoadId
	  FROM tblICInventoryTransaction InvTran
	  JOIN tblLGLoadDetail LD ON LD.intLoadId = InvTran.intTransactionId
	  JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	  JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	  AND CD.intContractHeaderId = CH.intContractHeaderId
	  WHERE
	  	ysnIsUnposted = 0
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END	
	  	AND InvTran.intTransactionTypeId = 46
	  	AND InvTran.intInTransitSourceLocationId IS NULL
	  GROUP BY CH.intContractTypeId,CH.intContractHeaderId
	  	,CD.intContractDetailId,InvTran.dtmDate, LD.intLoadId

	INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity
	   ,intNoOfLoad
	   ,intSourceId			
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate
	  ,@dtmEndDate  AS dtmEndDate
	  ,SUM(ReceiptItem.dblOpenReceive) dblQuantity
	  ,0
	  ,COUNT(DISTINCT Receipt.intInventoryReceiptId)
	  ,Receipt.intInventoryReceiptId
	  FROM tblICInventoryTransaction InvTran
	  JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = InvTran.intTransactionId
	  	AND strReceiptType = 'Purchase Contract'
	  JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptId = InvTran.intTransactionId
	  AND ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
	  AND ReceiptItem.intInventoryReceiptId = Receipt.intInventoryReceiptId
	  JOIN tblCTContractHeader CH ON CH.intContractHeaderId = ReceiptItem.intOrderId
	  JOIN tblCTContractDetail CD ON CD.intContractDetailId = ReceiptItem.intLineNo
	  AND CD.intContractHeaderId = CH.intContractHeaderId
	  WHERE strTransactionForm = 'Inventory Receipt'
	  	AND ysnIsUnposted = 0
	  	AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
	  	AND intContractTypeId = 1
	  	AND InvTran.intTransactionTypeId = 4
	  GROUP BY CH.intContractTypeId,CH.intContractHeaderId
	  	,CD.intContractDetailId,InvTran.dtmDate,Receipt.intInventoryReceiptId

	INSERT INTO @Shipment
	  (
	    intContractTypeId
	   ,intContractHeaderId	
	   ,intContractDetailId	
	   ,dtmDate
	   ,dtmEndDate			
	   ,dblQuantity
	   ,dblAllocatedQuantity
	   ,intNoOfLoad
	   ,intSourceId			
	  )
	SELECT 
		 CH.intContractTypeId		
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,dbo.fnRemoveTimeOnDate(SS.dtmCreated)
	    ,@dtmEndDate  AS dtmEndDate
		,SUM(SC.dblUnits) AS dblQuantity
		,0
		,COUNT(DISTINCT SS.intSettleStorageId)
		,SS.intSettleStorageId
		FROM tblGRSettleContract SC
		JOIN tblGRSettleStorage  SS ON SS.intSettleStorageId = SC.intSettleStorageId
		JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
		JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		AND CD.intContractHeaderId = CH.intContractHeaderId
		WHERE SS.ysnPosted = 1
			AND SS.intParentSettleStorageId IS NOT NULL
			AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
		GROUP BY CH.intContractTypeId,CH.intContractHeaderId
			,CD.intContractDetailId,SS.dtmCreated,SS.intSettleStorageId
		  
	INSERT INTO @Balance(intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
	 SELECT
	  CH.intContractTypeId 
	 ,'Audit'
	 ,Audi.intContractHeaderId
	 ,Audi.intContractDetailId
	 ,SUM(Audi.dblTransactionQuantity*-1) AS dblQuantity
	 FROM vyuCTSequenceAudit Audi
	 JOIN tblCTContractHeader CH ON CH.intContractHeaderId = Audi.intContractHeaderId
	 WHERE Audi.strFieldName = 'Quantity'
	 AND Audi.intSequenceUsageHistoryId <> -3	
	 AND dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) > CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) END
	 GROUP BY CH.intContractTypeId,Audi.intContractHeaderId
	 	,Audi.intContractDetailId    	
	
	INSERT INTO @PriceFixation
	(
		intContractTypeId
	   ,intContractHeaderId
	   ,intContractDetailId
	   ,dtmFixationDate
	   ,dblQuantity
	   ,dblFutures
	   ,dblBasis
	   ,dblCashPrice
	   ,dblShippedQty
	   ,intNoOfLoad
	   ,intShippedNoOfLoad
	 )
	SELECT	
		CH.intContractTypeId,																																	
		PF.intContractHeaderId,
		PF.intContractDetailId,											   	
		FD.dtmFixationDate,												   
		SUM(FD.dblQuantity),
		FD.dblFutures,
		FD.dblBasis,
		FD.dblCashPrice,
		0,
		intNoOfLoad		   = SUM(FD.dblQuantity)/CD.dblQuantityPerLoad
	   ,intShippedNoOfLoad = 0
	FROM	tblCTPriceFixationDetail FD
	JOIN	tblCTPriceFixation		 PF	ON	PF.intPriceFixationId =	FD.intPriceFixationId
	JOIN tblCTContractHeader		 CH ON CH.intContractHeaderId = PF.intContractHeaderId
	JOIN tblCTContractDetail		 CD ON CD.intContractDetailId = PF.intContractDetailId
	AND     dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) END
	GROUP BY CH.intContractTypeId,PF.intContractHeaderId,PF.intContractDetailId,FD.dtmFixationDate,FD.dblFutures,FD.dblBasis,FD.dblCashPrice,CD.dblQuantityPerLoad
	
	SELECT @intShipmentKey = MIN(Ship.intShipmentKey) 
	FROM @Shipment Ship
	JOIN @PriceFixation PF ON PF.intContractHeaderId = Ship.intContractHeaderId AND Ship.intContractDetailId = PF.intContractDetailId
	WHERE Ship.dblQuantity > ISNULL(Ship.dblAllocatedQuantity,0) 
	AND PF.dblQuantity > PF.dblShippedQty
	
	WHILE @intShipmentKey > 0 
	BEGIN
		
		SET    @dblShipQtyToAllocate = NULL
		SET    @intContractDetailId  = NULL
		
		IF EXISTS(SELECT 1 FROM @Shipment WHERE dblAllocatedQuantity = 0 AND intShipmentKey = @intShipmentKey)
		BEGIN
				UPDATE @PriceFixation SET intShippedNoOfLoad = ISNULL(intShippedNoOfLoad,0) + 1
				WHERE intPriceFixationKey = @intPriceFixationKey 
		END

		SELECT @dblShipQtyToAllocate = dblQuantity - ISNULL(dblAllocatedQuantity,0), @intContractDetailId = intContractDetailId  
		FROM @Shipment WHERE intShipmentKey = @intShipmentKey

		SELECT @intPriceFixationKey = MIN(intPriceFixationKey) FROM @PriceFixation WHERE (dblQuantity - dblShippedQty) > 0 AND intContractDetailId = @intContractDetailId

		SELECT @dblPriceQtyToAllocate = dblQuantity - dblShippedQty  FROM @PriceFixation WHERE intPriceFixationKey = @intPriceFixationKey

		SELECT @dblAllocatedQty = CASE WHEN @dblPriceQtyToAllocate > @dblShipQtyToAllocate THEN @dblShipQtyToAllocate ELSE @dblPriceQtyToAllocate END

		UPDATE @PriceFixation SET dblShippedQty = ISNULL(dblShippedQty,0) + @dblAllocatedQty WHERE intPriceFixationKey = @intPriceFixationKey
		UPDATE @Shipment      SET dblAllocatedQuantity = ISNULL(dblAllocatedQuantity,0)+ @dblAllocatedQty  WHERE intShipmentKey = @intShipmentKey	

		SELECT @intShipmentKey = MIN(Ship.intShipmentKey) 
		FROM @Shipment Ship
		JOIN @PriceFixation PF ON PF.intContractHeaderId = Ship.intContractHeaderId AND Ship.intContractDetailId = PF.intContractDetailId
		WHERE ISNULL(Ship.dblQuantity,0) > ISNULL(Ship.dblAllocatedQuantity,0) 
		AND PF.dblQuantity > PF.dblShippedQty
		

	END

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractTypeId,'PriceFixation',intContractHeaderId,intContractDetailId,dblQuantity * -1,intNoOfLoad = 0 FROM @PriceFixation 

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractTypeId,'Shipment',intContractHeaderId,intContractDetailId,(dblQuantity - dblAllocatedQuantity) * -1,ISNULL(intNoOfLoad,0)intNoOfLoad 
	FROM @Shipment

	INSERT INTO @BalanceTotal(intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractHeaderId,intContractDetailId,SUM(dblQuantity),SUM(intNoOfLoad) FROM @Balance 
	GROUP BY intContractHeaderId,intContractDetailId

	INSERT INTO tblCTContractBalance
	( 
     intContractTypeId		
	,intEntityId			
	,intCommodityId
	,dtmEndDate				
	,intCompanyLocationId	
	,intFutureMarketId      
	,intFutureMonthId
	,intContractHeaderId	
	,strType				
	,intContractDetailId	
	,strDate				
	,strContractType	
	,strCommodityCode		
	,strCommodity			
	,intItemId				
	,strItemNo		
	,strLocationName		
	,strCustomer			
	,strContract
	,intPricingTypeId			
	,strPricingType
	,strPricingTypeDesc			
	,strContractDate		
	,strShipMethod			
	,strShipmentPeriod		
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
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory 								
	)				
	
	SELECT				 			
	 intContractTypeId		= CH.intContractTypeId
	,intEntityId		   = CH.intEntityId
	,intCommodityId			= CH.intCommodityId
	,dtmEndDate			    = @dtmEndDate
	,intCompanyLocationId	= CD.intCompanyLocationId
	,intFutureMarketId      = CD.intFutureMarketId
	,intFutureMonthId       = CD.intFutureMonthId
	,intContractHeaderId    = CH.intContractHeaderId
	,strType				= 'Basis'
	,intContractDetailId    = CD.intContractDetailId	
	,strDate				= LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)
	,strContractType		= TP.strContractType	
	,strCommodityCode		= CM.strCommodityCode
	,strCommodity			= CM.strDescription +' '+UOM.strUnitMeasure
	,intItemId				= CD.intItemId
	,strItemNo				= IM.strItemNo	
	,strLocationName		= L.strLocationName					   
	,strCustomer			= EY.strEntityName
	,strContract			= CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)
	,intPricingTypeId		= CD.intPricingTypeId	
	,strPricingType			= LEFT(PT.strPricingType,1)
	,strPricingTypeDesc	    = PT.strPricingType
	,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	,strShipMethod			= FT.strFreightTerm
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
	
	,strFutureMonth			= LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
	,dblFutures				= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0)),0)
	,dblBasis				= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(CD.dblBasis,0)),0)
	,strBasisUOM			= BUOM.strUnitMeasure
	,dblQuantity			= CASE 
									WHEN ISNULL(CD.intNoOfLoad,0) = 0 THEN 
										ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)
									ELSE
										ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,(CD.intNoOfLoad -ISNULL(BL.intNoOfLoad,0)) * CD.dblQuantityPerLoad),0) 
							  END
	,strQuantityUOM			= IUM.strUnitMeasure
	,dblCashPrice			= CASE 
										WHEN CD.intPricingTypeId IN(1,2) THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)
										ELSE ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblCashPrice,0)),0)
							  END											
	,strPriceUOM			= PUOM.strUnitMeasure
	,strStockUOM			= StockUM.strUnitMeasure
	,dblAvailableQty		=  CASE 
							  		WHEN ISNULL(CD.intNoOfLoad,0) = 0 THEN 
							  			ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)
							  		ELSE
							  			ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,(CD.intNoOfLoad -ISNULL(BL.intNoOfLoad,0)) * CD.dblQuantityPerLoad),0) 
							    END

	,dblAmount				= (
								CASE 
									WHEN ISNULL(CD.intNoOfLoad,0) = 0 THEN 
										ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)
									ELSE
										ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,(CD.intNoOfLoad -ISNULL(BL.intNoOfLoad,0)) * CD.dblQuantityPerLoad),0) 
							    END
							  ) 
							  * ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)
    ,intUnitMeasureId			= CD.intUnitMeasureId
	,intContractStatusId		= CD.intContractStatusId
	,intCurrencyId				= CD.intCurrencyId
	,strCurrency				= Cur.strCurrency
	,dtmContractDate			= CH.dtmContractDate
	,dtmSeqEndDate				= CD.dtmEndDate
	,strFutMarketName			= FM.strFutMarketName
	,strCategory 				= Category.strCategoryCode

	FROM tblCTContractDetail					CD	
	JOIN tblCTContractStatus					CS	ON CS.intContractStatusId			=	CD.intContractStatusId
	JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
	LEFT JOIN @BalanceTotal                     BL  ON CH.intContractHeaderId           =   BL.intContractHeaderId
	AND												   CD.intContractDetailId          =    BL.intContractDetailId
	LEFT JOIN(
			SELECT intContractDetailId,SUM(dblQuantity) dblQuantity FROM @PriceFixation
			GROUP BY intContractDetailId
		) 												PF  ON  PF.intContractDetailId  =   CD.intContractDetailId
												AND     PF.intContractDetailId          =   BL.intContractDetailId
	JOIN	tblICCommodity						CM	ON	CM.intCommodityId				=	CH.intCommodityId
	JOIN	tblICItem                           IM  ON  IM.intItemId					=   CD.intItemId
	JOIN	tblICCategory						Category  ON Category.intCategoryId			= IM.intCategoryId
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
	JOIN tblCTPricingType					PT		  ON PT.intPricingTypeId			= CD.intPricingTypeId
	LEFT JOIN tblICItemUOM					BASISUOM  ON BASISUOM.intItemUOMId			= CD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure				BUOM	  ON BUOM.intUnitMeasureId			= BASISUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM					PriceUOM  ON PriceUOM.intItemUOMId		    = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure				PUOM	  ON PUOM.intUnitMeasureId			= PriceUOM.intUnitMeasureId

	LEFT JOIN	tblSMFreightTerms			FT		  ON FT.intFreightTermId			=	CD.intFreightTermId
	LEFT JOIN   tblSMCurrency						Cur ON Cur.intCurrencyID			=	CD.intCurrencyId
	LEFT JOIN	tblRKFutureMarket				FM	ON FM.intFutureMarketId				=	CD.intFutureMarketId
	
	WHERE dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE 
														WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate	  
														ELSE	 dbo.fnRemoveTimeOnDate(CD.dtmCreated) 
												   END
		AND CS.strContractStatus <> 'Unconfirmed'

	INSERT INTO @tblChange(intSequenceHistoryId,intContractDetailId)
	SELECT MAX(intSequenceHistoryId),intContractDetailId FROM tblCTSequenceHistory 
	WHERE  dbo.fnRemoveTimeOnDate(dtmHistoryCreated)	<= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END
	GROUP BY intContractDetailId

	UPDATE tblCTContractBalance 
	SET intPricingTypeId   = SH.intPricingTypeId
       ,strPricingType	   = LEFT(PT.strPricingType,1)
       ,strPricingTypeDesc = PT.strPricingType
       ,dblFutures         = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
	   ,dblBasis           = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
	   ,dblCashPrice       =  CASE 
										WHEN SH.intPricingTypeId IN(1,2) THEN  ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
																			 + ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
										ELSE ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblCashPrice,0)),0)
							  END	
	   
							
	   ,intFutureMarketId = SH.intFutureMarketId
	   ,intFutureMonthId  = SH.intFutureMonthId
	FROM tblCTContractBalance FR 
	JOIN @tblChange tblChange ON tblChange.intContractDetailId = FR.intContractDetailId
	JOIN tblCTSequenceHistory SH ON SH.intSequenceHistoryId = tblChange.intSequenceHistoryId
	JOIN tblCTPricingType	  PT ON PT.intPricingTypeId		= SH.intPricingTypeId
	WHERE FR.dtmEndDate = @dtmEndDate

	INSERT INTO tblCTContractBalance
	( 
     intContractTypeId		
	,intEntityId			
	,intCommodityId
	,dtmEndDate				
	,intCompanyLocationId	
	,intFutureMarketId      
	,intFutureMonthId
	,intContractHeaderId	
	,strType				
	,intContractDetailId	
	,strDate				
	,strContractType	
	,strCommodityCode		
	,strCommodity			
	,intItemId				
	,strItemNo		
	,strLocationName		
	,strCustomer			
	,strContract			
	,strPricingType
	,strPricingTypeDesc			
	,strContractDate		
	,strShipMethod			
	,strShipmentPeriod		
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
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory 				
	)		
	SELECT DISTINCT
     intContractTypeId		= CH.intContractTypeId
	,intEntityId		   = CH.intEntityId
	,intCommodityId			= CH.intCommodityId	
	,dtmEndDate			    = @dtmEndDate
	,intCompanyLocationId	= CD.intCompanyLocationId
	,intFutureMarketId      = CD.intFutureMarketId
	,intFutureMonthId       = CD.intFutureMonthId				 			
	,intContractHeaderId    = CH.intContractHeaderId
	,strType				= 'PriceFixation'
	,intContractDetailId    = CD.intContractDetailId	
	,strDate				= LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)
	,strContractType		= TP.strContractType	
	,strCommodityCode		= CM.strCommodityCode
	,strCommodity			= CM.strDescription +' '+UOM.strUnitMeasure
	,intItemId				= CD.intItemId
	,strItemNo				= IM.strItemNo	
	,strLocationName		= L.strLocationName					   
	,strCustomer			= EY.strEntityName
	,strContract			= CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)
	,strPricingType			= 'P'
	,strPricingTypeDesc		= 'Priced'
	,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	,strShipMethod			= FT.strFreightTerm
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))	
	,strFutureMonth			= LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
	,dblFutures				= ISNULL(PF.dblFutures,0)
	,dblBasis				= ISNULL(PF.dblBasis,0)
	,strBasisUOM			= BUOM.strUnitMeasure
	,dblQuantity			= ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)- ISNULL(PF.dblShippedQty,0)) ,0) 
	,strQuantityUOM			= IUM.strUnitMeasure
	,dblCashPrice			= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)
	,strPriceUOM			=  PUOM.strUnitMeasure
	,strStockUOM			= StockUM.strUnitMeasure
	,dblAvailableQty		=  ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)- ISNULL(PF.dblShippedQty,0)) ,0) 
	,dblAmount				= (
								ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)- ISNULL(PF.dblShippedQty,0)) ,0)
							   ) 
							   * ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)
    
	,intUnitMeasureId			= CD.intUnitMeasureId
	,intContractStatusId		= CD.intContractStatusId
	,intCurrencyId				= CD.intCurrencyId
	,strCurrency				= Cur.strCurrency
	,dtmContractDate			= CH.dtmContractDate
	,dtmSeqEndDate				= CD.dtmEndDate
	,strFutMarketName			= FM.strFutMarketName
	,strCategory 				= Category.strCategoryCode

	FROM tblCTContractDetail					CD	
	JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
	LEFT JOIN @BalanceTotal                     BL  ON CH.intContractHeaderId           =   BL.intContractHeaderId
	AND												   CD.intContractDetailId           =   BL.intContractDetailId
	JOIN @PriceFixation							PF  ON  PF.intContractDetailId          =   CD.intContractDetailId
												AND     PF.intContractDetailId          =   BL.intContractDetailId
	JOIN	tblICCommodity						CM	ON	CM.intCommodityId				=	CH.intCommodityId
	JOIN	tblICItem                           IM  ON  IM.intItemId					=   CD.intItemId
	JOIN	tblICCategory						Category  ON Category.intCategoryId		= IM.intCategoryId
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
	
	LEFT JOIN	tblSMFreightTerms			FT		  ON	FT.intFreightTermId			=	CD.intFreightTermId
	LEFT JOIN   tblSMCurrency				Cur		  ON	Cur.intCurrencyID			=	CD.intCurrencyId
	LEFT JOIN	tblRKFutureMarket			FM		  ON	FM.intFutureMarketId		=	CD.intFutureMarketId
	
	WHERE dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE 
														WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate		  
														ELSE	   dbo.fnRemoveTimeOnDate(CD.dtmCreated) 
												   END

	UPDATE tblCTContractBalance 
	SET dblAmount = ISNULL(dblAvailableQty,0) * (ISNULL(dblFutures,0)+ISNULL(dblBasis,0))
	WHERE dtmEndDate = @dtmEndDate

	;WITH CTE
	AS 
	(
		SELECT Row_Number() OVER (PARTITION BY SH.intContractDetailId ORDER BY SH.dtmHistoryCreated DESC) AS Row_Num
		,SH.intContractDetailId
		,SH.intContractStatusId
		,SH.intPricingTypeId
		,SH.dtmHistoryCreated
		FROM tblCTSequenceHistory SH
		JOIN  tblCTContractBalance FR ON SH.intContractDetailId = FR.intContractDetailId
		WHERE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) <= CASE 
																WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate	 
																ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) 
															END
		AND	FR.dtmEndDate =		 @dtmEndDate						  													  
	)
	INSERT INTO @SequenceHistory
	(
		intContractDetailId,
		intContractStatusId,
		intPricingTypeId,
		dtmHistoryCreated
	)
	SELECT 
	intContractDetailId,
	intContractStatusId,
	intPricingTypeId,
	dtmHistoryCreated
	FROM CTE WHERE Row_Num = 1

	UPDATE FR
	SET 
		 FR.intContractStatusId = SH.intContractStatusId
		,FR.intPricingTypeId	= SH.intPricingTypeId
	FROM tblCTContractBalance FR
	JOIN @SequenceHistory SH ON SH.intContractDetailId = FR.intContractDetailId
	WHERE FR.dtmEndDate = @dtmEndDate

	UPDATE FR
	SET FR.strPricingType	  = LEFT(PT.strPricingType,1),
		FR.strPricingTypeDesc = PT.strPricingType
	FROM tblCTContractBalance FR
	JOIN tblCTPricingType PT ON PT.intPricingTypeId = FR.intPricingTypeId
	WHERE FR.dtmEndDate = @dtmEndDate AND (FR.strPricingType IS NULL OR FR.strPricingTypeDesc IS NULL)

	DELETE FR
	FROM tblCTContractBalance FR
	JOIN @SequenceHistory SH ON SH.intContractDetailId = FR.intContractDetailId
	WHERE SH.intContractStatusId IN (3,5,6)
		AND FR.dtmEndDate = @dtmEndDate

	UPDATE FR
	 SET
	 FR.dblQtyinCommodityStockUOM		 = dbo.fnGRConvertQuantityToTargetItemUOM(FR.intItemId,ItemStockUOM.intUnitMeasureId,ComStockUOM.intUnitMeasureId,FR.dblQuantity)
	,FR.dblFuturesinCommodityStockUOM    = dbo.fnGRConvertQuantityToTargetItemUOM(FR.intItemId,ItemStockUOM.intUnitMeasureId,ComStockUOM.intUnitMeasureId,FR.dblFutures)
	,FR.dblBasisinCommodityStockUOM      = dbo.fnGRConvertQuantityToTargetItemUOM(FR.intItemId,ItemStockUOM.intUnitMeasureId,ComStockUOM.intUnitMeasureId,FR.dblBasis)
	,FR.dblCashPriceinCommodityStockUOM  = dbo.fnGRConvertQuantityToTargetItemUOM(FR.intItemId,ItemStockUOM.intUnitMeasureId,ComStockUOM.intUnitMeasureId,FR.dblCashPrice)
	,FR.dblAmountinCommodityStockUOM     = dbo.fnGRConvertQuantityToTargetItemUOM(FR.intItemId,ItemStockUOM.intUnitMeasureId,ComStockUOM.intUnitMeasureId,FR.dblAmount)
	FROM tblCTContractBalance FR
	JOIN tblICCommodityUnitMeasure ComStockUOM	ON	ComStockUOM.intCommodityId = FR.intCommodityId 
		AND ComStockUOM.ysnStockUnit = 1
	JOIN tblICItemUOM ItemStockUOM ON ItemStockUOM.intItemId = FR.intItemId 
		AND ItemStockUOM.ysnStockUnit = 1
	WHERE FR.dtmEndDate = @dtmEndDate



    IF ISNULL(@strCallingApp,'') <> 'DPR'
	BEGIN
	 SELECT 
	 intContractBalanceId
	,intContractHeaderId	
	,strType				
	,intContractDetailId	
	,strCompanyName			= @strCompanyName
	,blbHeaderLogo			= @blbHeaderLogo
	,strDate				
	,strContractType		
	,intCommodityId
	,strCommodityCode			
	,strCommodity			
	,intItemId				
	,strItemNo				
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
	,dblFutures						  = CAST (dblFutures AS NUMERIC(18,6))
	,dblBasis						  = CAST (dblBasis AS NUMERIC(18,6))	
	,strBasisUOM			
	,dblQuantity					  = CAST (dblQuantity AS NUMERIC(18,6))
	,strQuantityUOM			
	,dblCashPrice					  = CAST (dblCashPrice AS NUMERIC(18,6))
	,strPriceUOM			
	,strStockUOM			
	,dblAvailableQty				  = CAST (dblAvailableQty AS NUMERIC(18,6))
	,dblAmount						  = CAST (dblAmount AS NUMERIC(18,6))
	,dblQtyinCommodityStockUOM		  = CAST (dblQtyinCommodityStockUOM AS NUMERIC(18,6))
	,dblFuturesinCommodityStockUOM	  = CAST (dblFuturesinCommodityStockUOM AS NUMERIC(18,6))
	,dblBasisinCommodityStockUOM	  = CAST (dblBasisinCommodityStockUOM AS NUMERIC(18,6))
	,dblCashPriceinCommodityStockUOM  = CAST (dblCashPriceinCommodityStockUOM AS NUMERIC(18,6))
	,dblAmountinCommodityStockUOM	  = CAST (dblAmountinCommodityStockUOM AS NUMERIC(18,6))
	,strPrintOption	= @strPrintOption
	FROM tblCTContractBalance 
	WHERE 
	intContractTypeId		  = CASE WHEN ISNULL(@intContractTypeId ,0) > 0		THEN @intContractTypeId	      ELSE intContractTypeId     END
	AND intEntityId			  = CASE WHEN ISNULL(@intEntityId ,0) > 0			THEN @intEntityId		      ELSE intEntityId		     END
	AND intCommodityId		  = CASE WHEN ISNULL(@IntCommodityId ,0) > 0		THEN @IntCommodityId	      ELSE intCommodityId	     END
	AND intCompanyLocationId  = CASE WHEN ISNULL(@intCompanyLocationId ,0) > 0	THEN @intCompanyLocationId	  ELSE intCompanyLocationId	 END
	
	AND ISNULL(intFutureMarketId,0)	= CASE 
											WHEN ISNULL(@IntFutureMarketId ,0) > 0		THEN @IntFutureMarketId		  
											ELSE ISNULL(intFutureMarketId,0)	 
									  END
	AND ISNULL(intFutureMonthId,0)	=  CASE 
											WHEN ISNULL(@IntFutureMonthId ,0) > 0		THEN @IntFutureMonthId		  
											ELSE ISNULL(intFutureMonthId,0)		 
									  END
	AND dtmEndDate			=  @dtmEndDate
 END
 

END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH