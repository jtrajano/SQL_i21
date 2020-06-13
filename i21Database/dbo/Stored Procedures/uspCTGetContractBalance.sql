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

	BEGIN TRAN

	IF EXISTS(SELECT TOP 1 1 FROM tblCTMiscellaneous WITH (NOLOCK) WHERE ysnContractBalanceInProgress = 1)
	BEGIN
		RAISERROR ('Contract Balance generation is ongoing for other users. Please try again after a few minutes.',18,1,'WITH NOWAIT')
	END

	-- SET "CONTRACT BALANCE" STATUS IN-PROGRESS TO AVOID SIMULTANEOUS REPORT BUILDING 
	UPDATE tblCTMiscellaneous SET ysnContractBalanceInProgress = 1

	DECLARE @ErrMsg							NVARCHAR(MAX)
	DECLARE @blbHeaderLogo					VARBINARY(MAX)
	DECLARE @intContractDetailId			INT
	DECLARE @intShipmentKey					INT
	DECLARE @intReceiptKey					INT
	DECLARE @intPriceFixationKey			INT
	DECLARE @dblShipQtyToAllocate			NUMERIC(38,20)
	DECLARE @dblAllocatedQty				NUMERIC(38,20)
	DECLARE @dblPriceQtyToAllocate			NUMERIC(38,20)
	DECLARE @intShipmentNoOfLoad			INT
	DECLARE @intPriceNoOfLoad				INT

	DECLARE @SequenceHistory TABLE
	(
		intContractDetailId INT,
		intContractStatusId INT,
		intPricingTypeId	INT,
		dtmHistoryCreated   DATETIME
	)

	DECLARE @Audit TABLE 
	(  
			intContractTypeId		INT,
			strType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			intContractHeaderId		INT,  
			intContractDetailId		INT,        
			dblQuantity				NUMERIC(38,20),
			intNoOfLoad				INT 
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
			intSourceId				INT,
			strType					NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL
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

	DECLARE @PriceFixationTotal TABLE
	(
			intContractHeaderId		INT,
			intContractDetailId		INT,
			dblQuantity				NUMERIC(38,20), 
			intNoOfLoad				INT 
	) 

	DECLARE @TempContractBalance TABLE(
		 intContractBalanceId				INT
		,intContractTypeId					INT	
		,intEntityId						INT
		,intCommodityId						INT
		,dtmEndDate							DATETIME
		,intCompanyLocationId				INT
		,intFutureMarketId					INT
		,intFutureMonthId					INT
		,intContractHeaderId				INT
		,strType							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractDetailId				INT	
		,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strContractType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intItemId							INT
		,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomer						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContract						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipMethod						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipmentPeriod					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strDeliveryMonth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblFutures							NUMERIC(38,20)
		,dblBasis							NUMERIC(38,20)
		,strBasisUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblQuantity						NUMERIC(38,20)
		,strQuantityUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice						NUMERIC(38,20)
		,strPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strStockUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblAvailableQty					NUMERIC(38,20)
		,dblAmount							NUMERIC(38,20)
		,dblQtyinCommodityStockUOM			NUMERIC(38,20)
		,dblFuturesinCommodityStockUOM		NUMERIC(38,20)
		,dblBasisinCommodityStockUOM		NUMERIC(38,20)
		,dblCashPriceinCommodityStockUOM	NUMERIC(38,20)
		,dblAmountinCommodityStockUOM		NUMERIC(38,20)
		,intPricingTypeId					INT
		,strPricingTypeDesc					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intUnitMeasureId					INT
		,intContractStatusId				INT
		,intCurrencyId						INT
		,strCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmContractDate					DATETIME
		,dtmSeqEndDate						DATETIME	
		,strFutMarketName					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCategory 						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)

	DECLARE @FinalContractBalance TABLE(
		 intContractBalanceId				INT
		,intContractTypeId					INT	
		,intEntityId						INT
		,intCommodityId						INT
		,dtmEndDate							DATETIME
		,intCompanyLocationId				INT
		,intFutureMarketId					INT
		,intFutureMonthId					INT
		,intContractHeaderId				INT
		,strType							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractDetailId				INT	
		,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strContractType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intItemId							INT
		,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomer						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContract						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipMethod						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipmentPeriod					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strDeliveryMonth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblFutures							NUMERIC(38,20)
		,dblBasis							NUMERIC(38,20)
		,strBasisUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblQuantity						NUMERIC(38,20)
		,strQuantityUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice						NUMERIC(38,20)
		,strPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strStockUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblAvailableQty					NUMERIC(38,20)
		,dblAmount							NUMERIC(38,20)
		,dblQtyinCommodityStockUOM			NUMERIC(38,20)
		,dblFuturesinCommodityStockUOM		NUMERIC(38,20)
		,dblBasisinCommodityStockUOM		NUMERIC(38,20)
		,dblCashPriceinCommodityStockUOM	NUMERIC(38,20)
		,dblAmountinCommodityStockUOM		NUMERIC(38,20)
		,intPricingTypeId					INT
		,strPricingTypeDesc					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intUnitMeasureId					INT
		,intContractStatusId				INT
		,intCurrencyId						INT
		,strCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dtmContractDate					DATETIME
		,dtmSeqEndDate						DATETIME	
		,strFutMarketName					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCategory 						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)	

	DECLARE @TempPriceFixation TABLE(
		 intContractBalanceId				INT
		,intContractTypeId					INT	
		,intEntityId						INT
		,intCommodityId						INT
		,dtmEndDate							DATETIME
		,intCompanyLocationId				INT
		,intFutureMarketId					INT
		,intFutureMonthId					INT
		,intContractHeaderId				INT
		,strType							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractDetailId				INT	
		,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strContractType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intItemId							INT
		,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomer						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContract						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipMethod						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipmentPeriod					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strDeliveryMonth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblFutures							NUMERIC(38,20)
		,dblBasis							NUMERIC(38,20)
		,strBasisUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblQuantity						NUMERIC(38,20)
		,strQuantityUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice						NUMERIC(38,20)
		,strPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strStockUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblAvailableQty					NUMERIC(38,20)
		,intItemUOMId						INT
		,intPriceItemUOMId					INT
		,dblAmount							NUMERIC(38,20)
		,dblQtyinCommodityStockUOM			NUMERIC(38,20)
		,dblFuturesinCommodityStockUOM		NUMERIC(38,20)
		,dblBasisinCommodityStockUOM		NUMERIC(38,20)
		,dblCashPriceinCommodityStockUOM	NUMERIC(38,20)
		,dblAmountinCommodityStockUOM		NUMERIC(38,20)
		,intPricingTypeId					INT
		,strPricingTypeDesc					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intUnitMeasureId					INT
		,intContractStatusId				INT
		,intCurrencyId						INT
		,strCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intCent							INT
		,dtmContractDate					DATETIME
		,dtmSeqEndDate						DATETIME	
		,strFutMarketName					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCategory 						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intPriceFixationKey				INT
	)    

	DECLARE @FinalPriceFixation TABLE(
		 intContractBalanceId				INT
		,intContractTypeId					INT	
		,intEntityId						INT
		,intCommodityId						INT
		,dtmEndDate							DATETIME
		,intCompanyLocationId				INT
		,intFutureMarketId					INT
		,intFutureMonthId					INT
		,intContractHeaderId				INT
		,strType							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intContractDetailId				INT	
		,strDate							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
		,strContractType					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strCommodityCode					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCommodity						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intItemId							INT
		,strItemNo							NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strLocationName					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strCustomer						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContract						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strPricingType						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strContractDate					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipMethod						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strShipmentPeriod					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL	
		,strDeliveryMonth					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,strFutureMonth						NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,dblFutures							NUMERIC(38,20)
		,dblBasis							NUMERIC(38,20)
		,strBasisUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblQuantity						NUMERIC(38,20)
		,strQuantityUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblCashPrice						NUMERIC(38,20)
		,strPriceUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strStockUOM						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,dblAvailableQty					NUMERIC(38,20)
		,intItemUOMId						INT
		,intPriceItemUOMId					INT
		,dblAmount							NUMERIC(38,20)
		,dblQtyinCommodityStockUOM			NUMERIC(38,20)
		,dblFuturesinCommodityStockUOM		NUMERIC(38,20)
		,dblBasisinCommodityStockUOM		NUMERIC(38,20)
		,dblCashPriceinCommodityStockUOM	NUMERIC(38,20)
		,dblAmountinCommodityStockUOM		NUMERIC(38,20)
		,intPricingTypeId					INT
		,strPricingTypeDesc					NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		,intUnitMeasureId					INT
		,intContractStatusId				INT
		,intCurrencyId						INT
		,strCurrency						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,intCent							INT
		,dtmContractDate					DATETIME
		,dtmSeqEndDate						DATETIME	
		,strFutMarketName					NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strCategory 						NVARCHAR(200) COLLATE Latin1_General_CI_AS
		,strPricingStatus					NVARCHAR(200) COLLATE Latin1_General_CI_AS
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
		,strType
	  )
	  SELECT
	   CH.intContractTypeId
	   ,CH.intContractHeaderId
	   ,CD.intContractDetailId
	   ,Shipment.dtmShipDate
	   ,@dtmEndDate AS dtmEndDate
	   ,dblQuantity = CASE 
	   					WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE
							ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intItemUOMId,ShipmentItem.intPriceUOMId,
							CASE
								WHEN ISNULL(INV.ysnPosted, 0) = 1 AND ShipmentItem.dblDestinationNet IS NOT NULL
								THEN MAX(CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN (ShipmentItem.dblDestinationNet * 1) - ISNULL(OVR.dblOverage,0)  ELSE 0 END)
								ELSE SUM(CASE WHEN CM.intInventoryShipmentItemId IS NULL THEN ShipmentItem.dblQuantity ELSE 0 END)
							END)
							,0)
						END
		,0
		,COUNT(DISTINCT Shipment.intInventoryShipmentId)
		,Shipment.intInventoryShipmentId
		,'Inventory Shipment'
		FROM
		--tblICInventoryTransaction InvTran
		tblICInventoryShipment Shipment
		JOIN tblICInventoryShipmentItem ShipmentItem 
			ON Shipment.intInventoryShipmentId = ShipmentItem.intInventoryShipmentId
		JOIN tblCTContractHeader CH ON CH.intContractHeaderId = ShipmentItem.intOrderId
		JOIN tblCTContractDetail CD ON CD.intContractDetailId = ShipmentItem.intLineNo
		AND CD.intContractHeaderId = CH.intContractHeaderId
		LEFT JOIN 
		(
			SELECT DISTINCT ID.intInventoryShipmentItemId, IV.ysnPosted
			FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
			AND  IV.ysnPosted = 1
			AND dbo.fnRemoveTimeOnDate(IV.dtmPostDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(IV.dtmPostDate) END
		) INV ON INV.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId      
		LEFT JOIN 
		(
			SELECT DISTINCT ID.intInventoryShipmentItemId
			FROM tblARInvoice IV INNER JOIN tblARInvoiceDetail ID ON IV.intInvoiceId = ID.intInvoiceId
			WHERE IV.strTransactionType = 'Credit Memo'
			AND  IV.ysnPosted = 1
			AND dbo.fnRemoveTimeOnDate(IV.dtmPostDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(IV.dtmPostDate) END
		) CM ON CM.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId 
		OUTER APPLY
		(
			SELECT dblOverage = SUM(b.dblQtyShipped)
			FROM tblARInvoice a
			INNER JOIN tblARInvoiceDetail b on a.intInvoiceId = b.intInvoiceId
			WHERE b.strPricing = 'Subsystem - Direct'
			AND a.ysnPosted = 1
			AND dbo.fnRemoveTimeOnDate(a.dtmPostDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(a.dtmPostDate) END
			AND b.intInventoryShipmentItemId = ShipmentItem.intInventoryShipmentItemId 
		) OVR 
		WHERE Shipment.intOrderType = 1
		AND Shipment.ysnPosted = 1
		AND dbo.fnRemoveTimeOnDate(Shipment.dtmShipDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate  ELSE dbo.fnRemoveTimeOnDate(Shipment.dtmShipDate) END
		AND intContractTypeId = 2
		GROUP BY 
		  CH.intContractTypeId
		  ,CH.intContractHeaderId
		  ,CD.intContractDetailId
		  ,Shipment.dtmShipDate
		  ,Shipment.intInventoryShipmentId
		  ,INV.ysnPosted
		  ,ShipmentItem.dblDestinationNet
		  ,CD.intItemUOMId
		  ,ShipmentItem.intPriceUOMId
		  ,CH.ysnLoad
		
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
	   ,strType
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate	  
	  ,@dtmEndDate AS dtmEndDate
	  ,dblQuantity = CASE 
	  					WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE SUM(InvTran.dblQty * - 1)
					 END
	  ,0
	  ,COUNT(DISTINCT Invoice.intInvoiceId)
	  ,Invoice.intInvoiceId
	  ,'Invoice'
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
		,CH.ysnLoad

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
	   ,strType
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	   ,InvTran.dtmDate
	  ,@dtmEndDate  AS dtmEndDate
	  ,dblQuantity = CASE
	  					WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE MAX(LD.dblNet)--,SUM(InvTran.dblQty)*-1 dblQuantity
					 END
	  ,0
	  ,COUNT(DISTINCT LD.intLoadId)
	  ,LD.intLoadId
	  ,'Outbound Shipment'
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
	  GROUP BY CH.intContractTypeId,CH.intContractHeaderId,CD.intContractDetailId,InvTran.dtmDate,LD.intLoadId,CH.ysnLoad

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
	   ,strType
	  )
	  SELECT 
	   CH.intContractTypeId 
	  ,CH.intContractHeaderId
	  ,CD.intContractDetailId
	  ,InvTran.dtmDate
	  ,@dtmEndDate  AS dtmEndDate
	  ,dblQuantity = CASE
	  					WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intItemUOMId,ReceiptItem.intCostUOMId,MAX(ReceiptItem.dblOpenReceive)),0)
					 END
	  ,0
	  ,COUNT(DISTINCT Receipt.intInventoryReceiptId)
	  ,Receipt.intInventoryReceiptId
	  ,'Inventory Receipt'
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
	  	,CD.intContractDetailId,InvTran.dtmDate,Receipt.intInventoryReceiptId,CD.intItemUOMId,ReceiptItem.intCostUOMId,CH.ysnLoad

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
	   ,strType
	  )
	SELECT 
		 CH.intContractTypeId		
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,dbo.fnRemoveTimeOnDate(SS.dtmCreated)
	    ,@dtmEndDate  AS dtmEndDate
		,dblQuantity = CASE
						WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE SUM(SC.dblUnits)
					   END
		,0
		,COUNT(DISTINCT SS.intSettleStorageId)
		,SS.intSettleStorageId
		,'Storage'
		FROM tblGRSettleContract SC
		JOIN tblGRSettleStorage  SS ON SS.intSettleStorageId = SC.intSettleStorageId
		JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
		JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
		AND CD.intContractHeaderId = CH.intContractHeaderId
		WHERE SS.ysnPosted = 1
			AND SS.intParentSettleStorageId IS NULL
			AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) <= CASE WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate   ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
		GROUP BY CH.intContractTypeId,CH.intContractHeaderId,CD.intContractDetailId,SS.dtmCreated,SS.intSettleStorageId,CH.ysnLoad

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
	   ,strType
	  )
	SELECT
		CH.intContractTypeId 
		,CH.intContractHeaderId
		,CD.intContractDetailId
		,IB.dtmImported
		,@dtmEndDate  AS dtmEndDate
		,dblQuantity = CASE
						WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
						ELSE SUM(IB.dblReceivedQty)
					   END
		,0
		,COUNT(DISTINCT IB.intImportBalanceId)
		,IB.intImportBalanceId
		,'Import Balance'
	FROM tblCTImportBalance IB
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = IB.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = IB.intContractDetailId
	WHERE dbo.fnRemoveTimeOnDate(IB.dtmImported) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(IB.dtmImported) END
	GROUP BY CH.intContractTypeId,CH.intContractHeaderId,CD.intContractDetailId,IB.dtmImported,IB.intImportBalanceId,CH.ysnLoad

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
	  ,strType
	)
	SELECT 
	CH.intContractTypeId 
	,CH.intContractHeaderId
	,CD.intContractDetailId
	,Invoice.dtmPostDate
	,@dtmEndDate AS dtmEndDate
	,dblQuantity = CASE 
					WHEN ISNULL(CH.ysnLoad,0) = 1 THEN MAX(CH.dblQuantityPerLoad)
					ELSE SUM(InvoiceDetail.dblQtyShipped)
				   END
	,0
	,COUNT(DISTINCT Invoice.intInvoiceId)
	,Invoice.intInvoiceId
	,'Invoice'
	FROM tblARInvoiceDetail InvoiceDetail
	JOIN tblARInvoice Invoice ON Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
	AND Invoice.intInvoiceId = InvoiceDetail.intInvoiceId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = InvoiceDetail.intContractHeaderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = InvoiceDetail.intContractDetailId
	LEFT JOIN tblSOSalesOrderDetail SOD ON SOD.intSalesOrderDetailId = InvoiceDetail.intSalesOrderDetailId
	AND CD.intContractHeaderId = CH.intContractHeaderId
	WHERE dbo.fnRemoveTimeOnDate(Invoice.dtmPostDate) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(Invoice.dtmPostDate) END
	AND InvoiceDetail.strPricing = 'Subsystem - Direct'
	AND Invoice.ysnPosted = 1
	GROUP BY 
	CH.intContractTypeId
	,CH.intContractHeaderId
	,CD.intContractDetailId
	,Invoice.dtmPostDate
	,Invoice.intInvoiceId
	,CH.ysnLoad

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

		SELECT @dblShipQtyToAllocate = dblQuantity - ISNULL(dblAllocatedQuantity,0), @intContractDetailId = intContractDetailId  
		FROM @Shipment WHERE intShipmentKey = @intShipmentKey

		SELECT @intPriceFixationKey = MIN(intPriceFixationKey) FROM @PriceFixation WHERE (dblQuantity - dblShippedQty) > 0 AND intContractDetailId = @intContractDetailId
		
		IF EXISTS(SELECT 1 FROM @PriceFixation WHERE intNoOfLoad > intShippedNoOfLoad AND intPriceFixationKey = @intPriceFixationKey)--IF EXISTS(SELECT 1 FROM @Shipment WHERE dblAllocatedQuantity = 0 AND intShipmentKey = @intShipmentKey)
		BEGIN
				SELECT @intShipmentNoOfLoad = SUM(intNoOfLoad) FROM @Shipment WHERE intContractDetailId = @intContractDetailId
				SELECT @intPriceNoOfLoad = SUM(intShippedNoOfLoad) FROM @PriceFixation WHERE intContractDetailId = @intContractDetailId

				IF @intShipmentNoOfLoad > @intPriceNoOfLoad
				BEGIN
					UPDATE @PriceFixation SET intShippedNoOfLoad = ISNULL(intShippedNoOfLoad,0) + 1
					WHERE intPriceFixationKey = @intPriceFixationKey 
				END		
		END

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

	INSERT INTO @Audit(intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
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

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractTypeId,'PriceFixation',intContractHeaderId,intContractDetailId,dblQuantity * -1,intNoOfLoad = 0 FROM @PriceFixation 

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractTypeId,'Shipment',intContractHeaderId,intContractDetailId,(dblQuantity - dblAllocatedQuantity) * -1,ISNULL(intNoOfLoad,0)intNoOfLoad 
	FROM @Shipment

	INSERT INTO @PriceFixationTotal(intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad) 
	SELECT intContractHeaderId,intContractDetailId,SUM(dblQuantity) *-1,SUM(intNoOfLoad) FROM @PriceFixation
	GROUP BY intContractHeaderId,intContractDetailId 

	INSERT INTO @BalanceTotal(intContractHeaderId,intContractDetailId,dblQuantity,intNoOfLoad)
	SELECT intContractHeaderId,intContractDetailId,SUM(dblQuantity),SUM(intNoOfLoad) FROM @Balance 
	GROUP BY intContractHeaderId,intContractDetailId
	
	INSERT INTO @tblChange(intSequenceHistoryId,intContractDetailId)
	SELECT MAX(intSequenceHistoryId),intContractDetailId FROM tblCTSequenceHistory 
	WHERE  dbo.fnRemoveTimeOnDate(dtmHistoryCreated)	<= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END
	GROUP BY intContractDetailId
				
	INSERT INTO @TempContractBalance
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 								
	)				
	SELECT *
	FROM (
		SELECT					 			
		 intContractTypeId		= CH.intContractTypeId
		,intEntityId			= CH.intEntityId
		,intCommodityId			= CH.intCommodityId
		,dtmEndDate			    = @dtmEndDate
		,intCompanyLocationId	= CD.intCompanyLocationId
		,intFutureMarketId      = ISNULL(HT.intFutureMarketId, CD.intFutureMarketId)
		,intFutureMonthId       = ISNULL(HT.intFutureMonthId, CD.intFutureMonthId)
		,intContractHeaderId    = CH.intContractHeaderId
		,strType				= HT.strPricingTypeDesc
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
		,intPricingTypeId		= ISNULL(HT.intPricingTypeId, CD.intPricingTypeId)
		,strPricingType			= ISNULL(HT.strPricingType, LEFT(PT.strPricingType,1))
		,strPricingTypeDesc	    = ISNULL(HT.strPricingTypeDesc, PT.strPricingType)
		,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
		,strShipMethod			= FT.strFreightTerm
		,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
									  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))
		,strDeliveryMonth		= LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
		,strFutureMonth			= FH.strFutureMonth
		,dblFutures				= ISNULL(HT.dblFutures, CASE WHEN HT.intPricingTypeId IN (1,3) THEN ISNULL(CD.dblFutures,0) ELSE NULL END)
		,dblFuturesinCommodityStockUOM	= CASE WHEN CD.intPricingTypeId IN (1,3) THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0)),0) ELSE NULL END
		,dblBasis				= ISNULL(HT.dblBasis, CASE WHEN CD.intPricingTypeId <> 3 THEN ISNULL(CD.dblBasis,0) ELSE NULL END)
		,dblBasisinCommodityStockUOM = CASE WHEN CD.intPricingTypeId <> 3 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(HT.dblBasis,CD.dblBasis)),0) ELSE NULL END
		,strBasisUOM			= BUOM.strUnitMeasure
		,dblQuantity            =    CASE 
										WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) + ISNULL(BL.dblQuantity, 0)
										ELSE (CD.intNoOfLoad - CASE WHEN ISNULL(PFT.intNoOfLoad,0) > ISNULL(BL.intNoOfLoad,0) THEN ISNULL(PFT.intNoOfLoad,0) ELSE ISNULL(BL.intNoOfLoad,0) END) * CD.dblQuantityPerLoad
									END + ISNULL(ADT.dblQuantity, 0)
		,strQuantityUOM			= IUM.strUnitMeasure
		,dblCashPrice			= ISNULL(HT.dblCashPrice, CASE WHEN HT.intPricingTypeId = 1 THEN ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0) ELSE NULL END)
		,dblCashPriceinCommodityStockUOM = ISNULL(HT.dblCashPriceinCommodityStockUOM, CASE 
											WHEN HT.intPricingTypeId = 1 THEN ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)
											ELSE NULL
										   END)
		,strPriceUOM			= PUOM.strUnitMeasure
		,dblQtyinCommodityStockUOM = dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId,
										CASE 
											WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) + ISNULL(BL.dblQuantity, 0)
											ELSE (CD.intNoOfLoad - CASE WHEN ISNULL(PFT.intNoOfLoad,0) > ISNULL(BL.intNoOfLoad,0) THEN ISNULL(PFT.intNoOfLoad,0) ELSE ISNULL(BL.intNoOfLoad,0) END) * CD.dblQuantityPerLoad
										END + ISNULL(ADT.dblQuantity, 0)
									)
		,strStockUOM			= dbo.fnCTGetCommodityUOM(C1.intUnitMeasureId)
		,dblAvailableQty        =  CASE 
										WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) + ISNULL(BL.dblQuantity, 0)
										ELSE (CD.intNoOfLoad - CASE WHEN ISNULL(PFT.intNoOfLoad,0) > ISNULL(BL.intNoOfLoad,0) THEN ISNULL(PFT.intNoOfLoad,0) ELSE ISNULL(BL.intNoOfLoad,0) END) * CD.dblQuantityPerLoad
									END + ISNULL(ADT.dblQuantity, 0)
		,dblAmount				= CASE WHEN HT.intPricingTypeId = 1 THEN
								  [dbo].[fnCTConvertQtyToStockItemUOM]
								  (
									CD.intItemUOMId, 
									(
										CASE 
											WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) + ISNULL(BL.dblQuantity, 0)
											ELSE (CD.intNoOfLoad - CASE WHEN PFT.intNoOfLoad > BL.intNoOfLoad THEN PFT.intNoOfLoad ELSE BL.intNoOfLoad END) * CD.dblQuantityPerLoad
										END + ISNULL(ADT.dblQuantity, 0)
									)
								  )
								  * 
								  [dbo].[fnCTConvertPriceToStockItemUOM](CD.intPriceItemUOMId,ISNULL(HT.dblFutures,CD.dblFutures) + ISNULL(HT.dblBasis,CD.dblBasis))
								  ELSE NULL END
		,dblAmountinCommodityStockUOM =  -- This is dblQtyinCommodityStockUOM converted back to item stock UOM
										CASE WHEN HT.intPricingTypeId = 1 THEN
											(dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId,
												CASE 
													WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(CD.dblQuantity, 0) + ISNULL(BL.dblQuantity, 0)
													ELSE (CD.intNoOfLoad - CASE WHEN ISNULL(PFT.intNoOfLoad,0) > ISNULL(BL.intNoOfLoad,0) THEN ISNULL(PFT.intNoOfLoad,0) ELSE ISNULL(BL.intNoOfLoad,0) END) * CD.dblQuantityPerLoad
												END + ISNULL(ADT.dblQuantity, 0)
												)
											)
											*-- This is dblCashPriceinCommodityStockUOM
											(ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId), ISNULL(HT.dblFutures,CD.dblFutures) + ISNULL(HT.dblBasis,CD.dblBasis)),0))
										ELSE NULL END
		,intUnitMeasureId		= CD.intItemUOMId
		,intContractStatusId	= ISNULL(HT.intContractStatusId, CD.intContractStatusId)
		,intCurrencyId			= CD.intCurrencyId
		,strCurrency			= Cur.strCurrency
		,dtmContractDate		= CH.dtmContractDate
		,dtmSeqEndDate			= CD.dtmEndDate
		,strFutMarketName		= FM.strFutMarketName
		,strCategory			= Category.strCategoryCode
		,strPricingStatus		= ISNULL(HT.strPricingStatus, CASE WHEN ISNULL(PF.dblQuantity, 0) = 0 THEN 'Unpriced' ELSE 'Partially Priced' END)
	
		FROM tblCTContractDetail					CD
		JOIN tblCTContractStatus					CS	ON CS.intContractStatusId			=	CD.intContractStatusId
		JOIN tblCTContractHeader					CH  ON CH.intContractHeaderId		    =   CD.intContractHeaderId
		LEFT JOIN @BalanceTotal                     BL  ON CH.intContractHeaderId           =   BL.intContractHeaderId
		AND												   CD.intContractDetailId          =    BL.intContractDetailId
		LEFT JOIN @PriceFixationTotal				PFT ON CH.intContractHeaderId           =   PFT.intContractHeaderId 
		AND												   CD.intContractDetailId          =    PFT.intContractDetailId 
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
		LEFT JOIN   tblSMCurrency				Cur		  ON Cur.intCurrencyID				=	CD.intCurrencyId
		LEFT JOIN	tblRKFutureMarket			FM		  ON FM.intFutureMarketId			=	CD.intFutureMarketId
		LEFT JOIN	tblRKFuturesMonth			FH		  ON FH.intFutureMonthId			=	CD.intFutureMonthId	
		LEFT JOIN	@Audit						ADT		  ON CH.intContractHeaderId         =   ADT.intContractHeaderId
															AND CD.intContractDetailId      =   ADT.intContractDetailId
		LEFT JOIN
		(
			SELECT C.intContractDetailId
			   ,SH.intContractStatusId
			   ,SH.intPricingTypeId AS intPricingTypeId
			   ,LEFT(PT.strPricingType,1) AS strPricingType
			   ,PT.strPricingType AS strPricingTypeDesc
			   ,CASE WHEN SH.intPricingTypeId IN (1,3) THEN ISNULL(SH.dblFutures,0) ELSE NULL END AS dblFutures
			   ,CASE WHEN SH.intPricingTypeId IN (1,3) THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0) ELSE NULL END AS dblFuturesinCommodityStockUOM 
			   ,CASE WHEN SH.intPricingTypeId <> 3 THEN ISNULL(SH.dblBasis,0) ELSE NULL END AS dblBasis
			   ,CASE WHEN SH.intPricingTypeId <> 3 THEN ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0) ELSE NULL END AS dblBasisinCommodityStockUOM
			   ,CASE WHEN SH.intPricingTypeId = 1 THEN  ISNULL(SH.dblFutures,0) + ISNULL(SH.dblBasis,0) ELSE NULL END AS dblCashPrice
			   ,CASE 
					WHEN SH.intPricingTypeId = 1 THEN  ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(SH.intCommodityId,SH.intPriceItemUOMId,dbo.fnCTGetCommodityStockUOM(SH.intCommodityId), ISNULL(SH.dblFutures,0)),0)
														+ ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(SH.intCommodityId,SH.intPriceItemUOMId,dbo.fnCTGetCommodityStockUOM(SH.intCommodityId), ISNULL(SH.dblBasis,0)),0)
					ELSE NULL
				END AS dblCashPriceinCommodityStockUOM
			   ,SH.intFutureMarketId AS intFutureMarketId
			   ,SH.intFutureMonthId AS intFutureMonthId
			   ,SH.strPricingStatus AS strPricingStatus
			FROM @tblChange C 
			JOIN tblCTSequenceHistory SH ON SH.intSequenceHistoryId = C.intSequenceHistoryId
			JOIN tblCTPricingType	  PT ON PT.intPricingTypeId		= SH.intPricingTypeId
			LEFT JOIN tblICItemUOM	PriceUOM  ON PriceUOM.intItemUOMId = SH.intPriceItemUOMId			
		) HT ON HT.intContractDetailId = CD.intContractDetailId

		WHERE dbo.[fnCTConvertDateTime](CD.dtmCreated,'ToServerDate',1) <= CASE WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate ELSE dbo.[fnCTConvertDateTime](CD.dtmCreated,'ToServerDate',1) END AND CS.strContractStatus <> 'Unconfirmed'
	) t
	WHERE dblQuantity > 0

	-- INSERT BASIS QUANTITIES
	INSERT INTO @FinalContractBalance
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 								
	)	
	SELECT  intContractTypeId		
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 
	FROM @TempContractBalance
	WHERE intPricingTypeId <> 1

	INSERT INTO @TempPriceFixation
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures			
	,dblFuturesinCommodityStockUOM
	,dblBasis
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty
	,intItemUOMId
	,intPriceItemUOMId		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency
	,intCent		
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus
	,intPriceFixationKey		
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
	,intPricingTypeId		= HT.intPricingTypeId
	,strPricingType			= 'P'
	,strPricingTypeDesc		= 'Priced'
	,strContractDate		= LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)
	,strShipMethod			= FT.strFreightTerm
	,strShipmentPeriod		=    LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - '
								  + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))	
	,strDeliveryMonth		= LEFT(DATENAME(MONTH, CD.dtmEndDate), 3) + ' ' + RIGHT(DATENAME(YEAR, CD.dtmEndDate),2)
	,strFutureMonth			= FH.strFutureMonth
	,dblFutures				= ISNULL(PF.dblFutures,0)
	,dblFuturesinCommodityStockUOM	= ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(PF.dblFutures,0)),0)
	,dblBasis				= ISNULL(HT.dblBasis, PF.dblBasis)
	,dblBasisinCommodityStockUOM = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(HT.dblBasis,PF.dblBasis)),0)
	,strBasisUOM			= BUOM.strUnitMeasure
	,dblQuantity			= CASE
							WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(PF.dblQuantity,0) - ISNULL(PF.dblShippedQty,0) 
							ELSE (ISNULL(PF.intNoOfLoad,0) - ISNULL(PF.intShippedNoOfLoad,0)) * CD.dblQuantityPerLoad
							END
	,strQuantityUOM			= IUM.strUnitMeasure
	,dblCashPrice			= ISNULL(HT.dblCashPrice,PF.dblCashPrice)
	,dblCashPriceinCommodityStockUOM = ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,CH.intCommodityUOMId, ISNULL(HT.dblCashPrice,PF.dblCashPrice)),0)
	,strPriceUOM			=  PUOM.strUnitMeasure
	,dblQtyinCommodityStockUOM = ISNULL(dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId, 
									(CASE
									WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(PF.dblQuantity,0) - ISNULL(PF.dblShippedQty,0) 
									ELSE (ISNULL(PF.intNoOfLoad,0) - ISNULL(PF.intShippedNoOfLoad,0)) * CD.dblQuantityPerLoad
									END)), 0)
	,strStockUOM			= dbo.fnCTGetCommodityUOM(C1.intUnitMeasureId)
	,dblAvailableQty		= CASE
								WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(PF.dblQuantity,0) - ISNULL(PF.dblShippedQty,0) 
								ELSE (ISNULL(PF.intNoOfLoad,0) - ISNULL(PF.intShippedNoOfLoad,0)) * CD.dblQuantityPerLoad
								END
	,intItemUOMId			= CD.intItemUOMId
	,intPriceItemUOMId		= CD.intPriceItemUOMId
	,dblAmount				= ([dbo].[fnCTConvertQtyToStockItemUOM](CD.intItemUOMId, 
								(CASE
								WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(PF.dblQuantity,0) - ISNULL(PF.dblShippedQty,0) 
								ELSE (ISNULL(PF.intNoOfLoad,0) - ISNULL(PF.intShippedNoOfLoad,0)) * CD.dblQuantityPerLoad
								END)) * [dbo].[fnCTConvertPriceToStockItemUOM](CD.intPriceItemUOMId,(ISNULL(HT.dblCashPrice,PF.dblCashPrice))))
	,dblAmountinCommodityStockUOM = -- This is dblQtyinCommodityStockUOM converted back to item stock UOM
									ISNULL(dbo.fnCTConvertQtyToTargetCommodityUOM(CH.intCommodityId,dbo.fnCTGetCommodityUnitMeasure(CH.intCommodityUOMId),C1.intUnitMeasureId,
									(CASE
										WHEN ISNULL(CD.intNoOfLoad, 0) = 0 THEN ISNULL(PF.dblQuantity,0) - ISNULL(PF.dblShippedQty,0) 
										ELSE (ISNULL(PF.intNoOfLoad,0) - ISNULL(PF.intShippedNoOfLoad,0)) * CD.dblQuantityPerLoad
									END)), 0)
									* --dblCashPriceinCommodityStockUOM
									ISNULL(dbo.fnCTConvertCostToTargetCommodityUOM(CH.intCommodityId,CD.intBasisUOMId,CH.intCommodityUOMId, ISNULL(HT.dblCashPrice,PF.dblCashPrice)),0)
	,intUnitMeasureId			= CD.intItemUOMId
	,intContractStatusId		= ISNULL(HT.intContractStatusId, CD.intContractStatusId)
	,intCurrencyId				= CD.intCurrencyId
	,strCurrency				= Cur.strCurrency
	,intCent					= Cur.intCent
	,dtmContractDate			= CH.dtmContractDate
	,dtmSeqEndDate				= CD.dtmEndDate
	,strFutMarketName			= FM.strFutMarketName
	,strCategory 				= Category.strCategoryCode
	,strPricingStatus			= 'Priced'
	,intPriceFixationKey		= PF.intPriceFixationKey
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
	LEFT JOIN	tblRKFuturesMonth			FH		  ON	FH.intFutureMonthId			=	CD.intFutureMonthId
	LEFT JOIN
	(
		SELECT SH.intContractDetailId
			,SH.intContractStatusId
			,SH.intPricingTypeId
			,SH.dblBasis
			,SH.dblCashPrice
		FROM @tblChange C 
		JOIN tblCTSequenceHistory SH ON SH.intSequenceHistoryId = C.intSequenceHistoryId		
	) HT ON HT.intContractDetailId = CD.intContractDetailId
	
	WHERE dbo.[fnCTConvertDateTime](CD.dtmCreated,'ToServerDate',1)	<= CASE 
														WHEN @dtmEndDate IS NOT NULL   THEN @dtmEndDate		  
														ELSE dbo.[fnCTConvertDateTime](CD.dtmCreated,'ToServerDate',1) 
												   END

	-- AVERAGE AND REMOVE USED PRICE FIXATION
	INSERT INTO @FinalPriceFixation
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
		,strDeliveryMonth
		,strFutureMonth
		,dblFutures			
		,dblFuturesinCommodityStockUOM
		,dblBasis
		,dblBasisinCommodityStockUOM
		,strBasisUOM			
		,dblQuantity			
		,strQuantityUOM			
		,dblCashPrice		
		,dblCashPriceinCommodityStockUOM
		,strPriceUOM	
		,dblQtyinCommodityStockUOM		
		,strStockUOM			
		,dblAvailableQty		
		,dblAmount
		,dblAmountinCommodityStockUOM
		,intUnitMeasureId			
		,intContractStatusId
		,intCurrencyId		
		,strCurrency				
		,dtmContractDate
		,dtmSeqEndDate			
		,strFutMarketName			
		,strCategory
		,strPricingStatus 				
	)
	SELECT intContractTypeId
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
		,strDeliveryMonth
		,strFutureMonth
		,dblFutures = AVG(dblFutures)
		,dblFuturesinCommodityStockUOM = AVG(dblFuturesinCommodityStockUOM)
		,dblBasis
		,dblBasisinCommodityStockUOM
		,strBasisUOM
		,dblQuantity = SUM(dblQuantity)
		,strQuantityUOM
		,dblCashPrice = AVG(dblCashPrice)
		,dblCashPriceinCommodityStockUOM = AVG(dblCashPriceinCommodityStockUOM)
		,strPriceUOM
		,dblQtyinCommodityStockUOM = SUM(dblQtyinCommodityStockUOM)
		,strStockUOM
		,dblAvailableQty = SUM(dblAvailableQty)
		,dblAmount = [dbo].[fnCTConvertQtyToTargetItemUOM](intItemUOMId, intPriceItemUOMId, SUM(dblQuantity)) * AVG(dblCashPrice) / ISNULL(intCent, 1)
		,dblAmountinCommodityStockUOM = SUM(dblQtyinCommodityStockUOM) * AVG(dblCashPriceinCommodityStockUOM) / ISNULL(intCent, 1)
		,intUnitMeasureId
		,intContractStatusId
		,intCurrencyId
		,strCurrency
		,dtmContractDate
		,dtmSeqEndDate
		,strFutMarketName
		,strCategory
		,strPricingStatus
	FROM @TempPriceFixation
	WHERE dblQuantity > 0
	GROUP BY intContractTypeId
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
		,strDeliveryMonth
		,strFutureMonth
		,dblBasis
		,dblBasisinCommodityStockUOM
		,strBasisUOM
		,strQuantityUOM
		,strPriceUOM		
		,strStockUOM
		,intItemUOMId
		,intPriceItemUOMId
		,intUnitMeasureId
		,intContractStatusId
		,intCurrencyId
		,strCurrency
		,intCent
		,dtmContractDate
		,dtmSeqEndDate
		,strFutMarketName
		,strCategory
		,strPricingStatus

	-- INSERT PRICED QUANTITIES
	INSERT INTO @FinalPriceFixation
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
		,strDeliveryMonth
		,strFutureMonth
		,dblFutures			
		,dblFuturesinCommodityStockUOM
		,dblBasis
		,dblBasisinCommodityStockUOM
		,strBasisUOM			
		,dblQuantity			
		,strQuantityUOM			
		,dblCashPrice		
		,dblCashPriceinCommodityStockUOM
		,strPriceUOM	
		,dblQtyinCommodityStockUOM		
		,strStockUOM			
		,dblAvailableQty		
		,dblAmount
		,dblAmountinCommodityStockUOM
		,intUnitMeasureId			
		,intContractStatusId
		,intCurrencyId		
		,strCurrency				
		,dtmContractDate
		,dtmSeqEndDate			
		,strFutMarketName			
		,strCategory
		,strPricingStatus 				
	)
	SELECT intContractTypeId		
		,intEntityId			
		,intCommodityId
		,dtmEndDate				
		,intCompanyLocationId	
		,intFutureMarketId      
		,intFutureMonthId
		,intContractHeaderId	
		,strType = 'PriceFixation'
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
		,strDeliveryMonth
		,strFutureMonth
		,dblFutures			
		,dblFuturesinCommodityStockUOM
		,dblBasis
		,dblBasisinCommodityStockUOM
		,strBasisUOM			
		,dblQuantity			
		,strQuantityUOM			
		,dblCashPrice		
		,dblCashPriceinCommodityStockUOM
		,strPriceUOM	
		,dblQtyinCommodityStockUOM		
		,strStockUOM			
		,dblAvailableQty		
		,dblAmount
		,dblAmountinCommodityStockUOM
		,intUnitMeasureId			
		,intContractStatusId
		,intCurrencyId		
		,strCurrency				
		,dtmContractDate
		,dtmSeqEndDate			
		,strFutMarketName			
		,strCategory
		,strPricingStatus = 'Priced'
	FROM @TempContractBalance
	WHERE intPricingTypeId = 1	

	INSERT INTO @FinalContractBalance
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 								
	)
	SELECT
	FPF.intContractTypeId		
	,FPF.intEntityId			
	,FPF.intCommodityId
	,FPF.dtmEndDate				
	,FPF.intCompanyLocationId	
	,FPF.intFutureMarketId      
	,FPF.intFutureMonthId
	,FPF.intContractHeaderId	
	,FPF.strType
	,FPF.intContractDetailId	
	,FPF.strDate				
	,FPF.strContractType	
	,FPF.strCommodityCode		
	,FPF.strCommodity			
	,FPF.intItemId				
	,FPF.strItemNo		
	,FPF.strLocationName		
	,FPF.strCustomer			
	,FPF.strContract
	,FPF.intPricingTypeId
	,FPF.strPricingType
	,FPF.strPricingTypeDesc			
	,FPF.strContractDate		
	,FPF.strShipMethod			
	,FPF.strShipmentPeriod		
	,FPF.strDeliveryMonth
	,FPF.strFutureMonth
	,dblFutures = MAX(FPF.dblFutures)	
	,dblFuturesinCommodityStockUOM = MAX(FPF.dblFuturesinCommodityStockUOM)
	,dblBasis = MAX(FPF.dblBasis)
	,dblBasisinCommodityStockUOM = MAX(FPF.dblBasisinCommodityStockUOM)
	,FPF.strBasisUOM			
	,dblQuantity = SUM(FPF.dblQuantity)			
	,FPF.strQuantityUOM			
	,dblCashPrice = MAX(FPF.dblCashPrice)		
	,dblCashPriceinCommodityStockUOM = MAX(FPF.dblCashPriceinCommodityStockUOM)
	,FPF.strPriceUOM	
	,dblQtyinCommodityStockUOM = SUM(FPF.dblQtyinCommodityStockUOM)
	,FPF.strStockUOM			
	,dblAvailableQty = SUM(FPF.dblAvailableQty)		
	,dblAmount = SUM(FPF.dblAmount)
	,dblAmountinCommodityStockUOM = SUM(FPF.dblAmountinCommodityStockUOM)
	,FPF.intUnitMeasureId
	,FPF.intContractStatusId
	,FPF.intCurrencyId		
	,FPF.strCurrency				
	,FPF.dtmContractDate
	,FPF.dtmSeqEndDate			
	,FPF.strFutMarketName			
	,FPF.strCategory
	,FPF.strPricingStatus
	FROM @FinalPriceFixation FPF	
	GROUP BY 
	FPF.intContractTypeId		
	,FPF.intEntityId			
	,FPF.intCommodityId
	,FPF.dtmEndDate				
	,FPF.intCompanyLocationId	
	,FPF.intFutureMarketId      
	,FPF.intFutureMonthId
	,FPF.intContractHeaderId	
	,FPF.strType
	,FPF.intContractDetailId	
	,FPF.strDate				
	,FPF.strContractType	
	,FPF.strCommodityCode		
	,FPF.strCommodity			
	,FPF.intItemId				
	,FPF.strItemNo		
	,FPF.strLocationName		
	,FPF.strCustomer			
	,FPF.strContract
	,FPF.intPricingTypeId
	,FPF.strPricingType
	,FPF.strPricingTypeDesc			
	,FPF.strContractDate		
	,FPF.strShipMethod			
	,FPF.strShipmentPeriod		
	,FPF.strDeliveryMonth
	,FPF.strFutureMonth
	,FPF.strBasisUOM			
	,FPF.strQuantityUOM			
	,FPF.strPriceUOM	
	,FPF.strStockUOM			
	,FPF.intUnitMeasureId
	,FPF.intContractStatusId
	,FPF.intCurrencyId		
	,FPF.strCurrency				
	,FPF.dtmContractDate
	,FPF.dtmSeqEndDate			
	,FPF.strFutMarketName			
	,FPF.strCategory
	,FPF.strPricingStatus

	;WITH CTE
	AS 
	(
		SELECT Row_Number() OVER (PARTITION BY SH.intContractDetailId ORDER BY SH.dtmHistoryCreated DESC) AS Row_Num
		,SH.intContractDetailId
		FROM tblCTSequenceHistory SH
		JOIN  @FinalContractBalance FR ON SH.intContractDetailId = FR.intContractDetailId
		WHERE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) <= CASE 
																WHEN @dtmEndDate IS NOT NULL THEN @dtmEndDate	 
																ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) 
															END		
		AND	FR.dtmEndDate =		 @dtmEndDate
		AND FR.intContractStatusId IN (3,5,6)

	)
	INSERT INTO @SequenceHistory
	(
		intContractDetailId
	)
	SELECT DISTINCT
	intContractDetailId
	FROM CTE WHERE Row_Num = 1	
		
	INSERT INTO tblCTContractBalance --WITH (TABLOCK)
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 								
	)
	SELECT
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
	,strDeliveryMonth
	,strFutureMonth
	,dblFutures	
	,dblFuturesinCommodityStockUOM
	,dblBasis	
	,dblBasisinCommodityStockUOM
	,strBasisUOM			
	,dblQuantity			
	,strQuantityUOM			
	,dblCashPrice		
	,dblCashPriceinCommodityStockUOM
	,strPriceUOM	
	,dblQtyinCommodityStockUOM		
	,strStockUOM			
	,dblAvailableQty		
	,dblAmount
	,dblAmountinCommodityStockUOM
	,intUnitMeasureId			
	,intContractStatusId
	,intCurrencyId		
	,strCurrency				
	,dtmContractDate
	,dtmSeqEndDate			
	,strFutMarketName			
	,strCategory
	,strPricingStatus 
	FROM @FinalContractBalance

	DELETE FROM tblCTContractBalance
	WHERE intContractDetailId IN (SELECT intContractDetailId FROM @SequenceHistory)

	UPDATE tblCTMiscellaneous SET ysnContractBalanceInProgress = 0

	COMMIT TRAN

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
	,strDeliveryMonth
	,strFutureMonth			
	,dblFutures						  = CAST (dblFutures AS NUMERIC(20,6))
	,dblBasis						  = CAST (dblBasis AS NUMERIC(20,6))	
	,strBasisUOM			
	,dblQuantity					  = CAST (dblQuantity AS NUMERIC(20,6))
	,strQuantityUOM
	,dblCashPrice					  = CAST (dblCashPrice AS NUMERIC(20,6))
	,strPriceUOM			
	,strStockUOM			
	,dblAvailableQty				  = CAST (dblAvailableQty AS NUMERIC(20,6))
	,dblAmount						  = CAST (dblAmount AS NUMERIC(20,6))
	,dblQtyinCommodityStockUOM		  = CAST (dblQtyinCommodityStockUOM AS NUMERIC(20,6))
	,dblFuturesinCommodityStockUOM	  = CAST (dblFuturesinCommodityStockUOM AS NUMERIC(20,6))
	,dblBasisinCommodityStockUOM	  = CAST (dblBasisinCommodityStockUOM AS NUMERIC(20,6))
	,dblCashPriceinCommodityStockUOM  = CAST (dblCashPriceinCommodityStockUOM AS NUMERIC(20,6))
	,dblAmountinCommodityStockUOM	  = CAST (dblAmountinCommodityStockUOM AS NUMERIC(20,6))
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
	
	ROLLBACK TRAN
	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	
END CATCH