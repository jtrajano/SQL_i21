CREATE FUNCTION [dbo].[fnRKGetContractDetail] (
	@dtmToDate  date)

RETURNS @FinalResult TABLE (intContractHeaderId	INT
	, intContractDetailId INT	
	, strDate NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL		
	, strContractType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intCommodityId INT
	, strCommodityCode NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intCompanyLocationId INT
	, strLocationName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strEntityName NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strContractNumber NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strPricingType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strContractDate NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strShipMethod NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strShipmentPeriod NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intFutureMarketId INT
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, dblFutures NUMERIC(38,20)
	, dblBasis NUMERIC(38,20)
	, strBasisUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblQuantity NUMERIC(38,20)
	, dblBalance NUMERIC(38,20)
	, strQuantityUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblCashPrice NUMERIC(38,20)
	, strPriceUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strStockUOM NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, dblAvailableQty NUMERIC(38,20)
	, dblAmount NUMERIC(38,20)
	, dtmEndDate DATETIME
	, intUnitMeasureId INT
	, intPricingTypeId INT
	, intContractTypeId INT
	, intCommodityUnitMeasureId INT
	, intContractStatusId INT
	, intEntityId INT
	, intCurrencyId INT
	, strCurrency NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, dtmContractDate DATETIME
	, strFutMarketName NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(250) COLLATE Latin1_General_CI_AS
	, strCustomerContract NVARCHAR(250) COLLATE Latin1_General_CI_AS)	 

AS 

BEGIN
	DECLARE @intContractDetailId	INT
	DECLARE @intShipmentKey			INT
	DECLARE @intReceiptKey			INT
	DECLARE @intPriceFixationKey	INT
	DECLARE @dblShipQtyToAllocate	NUMERIC(38,20)
	DECLARE @dblAllocatedQty		NUMERIC(38,20)
	DECLARE @dblPriceQtyToAllocate  NUMERIC(38,20)
	
	DECLARE @Balance TABLE (intContractTypeId INT
		, strType NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		, intContractHeaderId INT
		, intContractDetailId INT
		, dblQuantity NUMERIC(38,20))
	
	DECLARE @BalanceTotal TABLE (intContractHeaderId INT
		, intContractDetailId INT
		, dblQuantity NUMERIC(38,20))
	
	DECLARE @tblChange TABLE (intSequenceHistoryId INT
		, intContractDetailId INT)
	
	DECLARE @Shipment TABLE (intShipmentKey INT IDENTITY(1,1)
		, intContractTypeId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, dtmDate DATETIME
		, dtmEndDate DATETIME
		, dblQuantity NUMERIC(38,20)
		, dblAllocatedQuantity NUMERIC(38,20))

	DECLARE @PriceFixation TABLE (intPriceFixationKey INT IDENTITY(1,1)
		, intContractTypeId INT
		, intContractHeaderId INT
		, intContractDetailId INT
		, dtmFixationDate DATETIME
		, dblQuantity NUMERIC(38,20)
		, dblFutures NUMERIC(38,20)
		, dblBasis NUMERIC(38,20)
		, dblCashPrice NUMERIC(38,20)
		, dblShippedQty NUMERIC(38,20))
	
	IF @dtmToDate IS NOT NULL
		SET @dtmToDate = dbo.fnRemoveTimeOnDate(@dtmToDate)
	
	INSERT INTO @Shipment (intContractTypeId
		, intContractHeaderId
		, intContractDetailId
		, dtmDate
		, dtmEndDate
		, dblQuantity
		, dblAllocatedQuantity)
	SELECT CH.intContractTypeId 
		, CH.intContractHeaderId
		, CD.intContractDetailId
		, InvTran.dtmDate
		, @dtmToDate AS dtmEndDate
		, SUM(InvTran.dblQty * - 1) AS dblQuantity
		, 0
	FROM tblICInventoryTransaction InvTran
	JOIN tblICInventoryShipment Shipment ON Shipment.intInventoryShipmentId = InvTran.intTransactionId AND intOrderType = 1
	JOIN tblICInventoryShipmentItem ON tblICInventoryShipmentItem.intInventoryShipmentItemId = InvTran.intTransactionDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = intOrderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intLineNo
	WHERE strTransactionForm = 'Inventory Shipment'
		AND InvTran.ysnIsUnposted = 0
		AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmToDate IS NOT NULL   THEN @dtmToDate   ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
		AND intContractTypeId = 2
		AND intInTransitSourceLocationId IS NULL
	GROUP BY CH.intContractTypeId, CH.intContractHeaderId, CD.intContractDetailId, InvTran.dtmDate
	
	INSERT INTO @Shipment (intContractTypeId
		, intContractHeaderId
		, intContractDetailId
		, dtmDate
		, dtmEndDate
		, dblQuantity
		, dblAllocatedQuantity)
	SELECT CH.intContractTypeId
		, CH.intContractHeaderId
		, CD.intContractDetailId
		, InvTran.dtmDate
		, @dtmToDate AS dtmEndDate
		, SUM(InvTran.dblQty)*-1 dblQuantity
		, 0
	FROM tblICInventoryTransaction InvTran
	JOIN tblLGLoadDetail LD ON LD.intLoadId = InvTran.intTransactionId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE ysnIsUnposted = 0
		AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
		AND InvTran.intTransactionTypeId = 46
		AND InvTran.intInTransitSourceLocationId IS NULL
	GROUP BY CH.intContractTypeId, CH.intContractHeaderId, CD.intContractDetailId, InvTran.dtmDate
	
	INSERT INTO @Shipment (intContractTypeId
		, intContractHeaderId
		, intContractDetailId
		, dtmDate
		, dtmEndDate
		, dblQuantity
		, dblAllocatedQuantity)
	SELECT CH.intContractTypeId
		, CH.intContractHeaderId
		, CD.intContractDetailId
		, InvTran.dtmDate
		, @dtmToDate AS dtmEndDate
		, SUM(ReceiptItem.dblNet) dblQuantity
		, 0
	FROM tblICInventoryTransaction InvTran
	JOIN tblICInventoryReceipt Receipt ON Receipt.intInventoryReceiptId = InvTran.intTransactionId AND strReceiptType = 'Purchase Contract'
	JOIN tblICInventoryReceiptItem ReceiptItem ON ReceiptItem.intInventoryReceiptItemId = InvTran.intTransactionDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = intOrderId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intLineNo
	WHERE strTransactionForm = 'Inventory Receipt'
		AND ysnIsUnposted = 0
		AND dbo.fnRemoveTimeOnDate(InvTran.dtmDate) <= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate ELSE dbo.fnRemoveTimeOnDate(InvTran.dtmDate) END
		AND intContractTypeId = 1
		AND InvTran.intTransactionTypeId = 4
	GROUP BY CH.intContractTypeId, CH.intContractHeaderId, CD.intContractDetailId, InvTran.dtmDate
	
	INSERT INTO @Shipment (intContractTypeId
		, intContractHeaderId
		, intContractDetailId
		, dtmDate
		, dtmEndDate
		, dblQuantity
		, dblAllocatedQuantity)
	SELECT CH.intContractTypeId
		, CH.intContractHeaderId
		, CD.intContractDetailId
		, dbo.fnRemoveTimeOnDate(SS.dtmCreated)
		, @dtmToDate AS dtmEndDate
		, SUM(SC.dblUnits) AS dblQuantity
		, 0
	FROM tblGRSettleContract SC
	JOIN tblGRSettleStorage  SS ON SS.intSettleStorageId = SC.intSettleStorageId
	JOIN tblCTContractDetail CD ON SC.intContractDetailId = CD.intContractDetailId
	JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE SS.ysnPosted = 1
		AND SS.intParentSettleStorageId IS NOT NULL
		AND dbo.fnRemoveTimeOnDate(SS.dtmCreated) <= CASE WHEN @dtmToDate IS NOT NULL   THEN @dtmToDate   ELSE dbo.fnRemoveTimeOnDate(SS.dtmCreated) END
	GROUP BY CH.intContractTypeId, CH.intContractHeaderId, CD.intContractDetailId, SS.dtmCreated
	
	INSERT INTO @Balance(intContractTypeId
		, strType
		, intContractHeaderId
		, intContractDetailId
		, dblQuantity)
	SELECT CH.intContractTypeId
		, 'Audit' COLLATE Latin1_General_CI_AS
		, Audi.intContractHeaderId
		, Audi.intContractDetailId
		, SUM(Audi.dblTransactionQuantity*-1) AS dblQuantity
	FROM vyuCTSequenceAudit Audi
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = Audi.intContractHeaderId
	WHERE Audi.strFieldName = 'Quantity'
		AND dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) >= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate ELSE dbo.fnRemoveTimeOnDate(Audi.dtmTransactionDate) END
	GROUP BY CH.intContractTypeId, Audi.intContractHeaderId,Audi.intContractDetailId
	
	INSERT INTO @PriceFixation(intContractTypeId
		, intContractHeaderId
		, intContractDetailId
		, dtmFixationDate
		, dblQuantity
		, dblFutures
		, dblBasis
		, dblCashPrice
		, dblShippedQty)
	SELECT CH.intContractTypeId
		, PF.intContractHeaderId
		, PF.intContractDetailId
		, FD.dtmFixationDate
		, SUM(FD.dblQuantity)
		, FD.dblFutures
		, FD.dblBasis
		, FD.dblCashPrice
		, 0
	FROM tblCTPriceFixationDetail FD
	JOIN tblCTPriceFixation PF ON PF.intPriceFixationId = FD.intPriceFixationId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = PF.intContractHeaderId
	WHERE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) <= CASE WHEN @dtmToDate IS NOT NULL   THEN @dtmToDate   ELSE dbo.fnRemoveTimeOnDate(FD.dtmFixationDate) END
	GROUP BY CH.intContractTypeId, PF.intContractHeaderId, PF.intContractDetailId, FD.dtmFixationDate, FD.dblFutures, FD.dblBasis, FD.dblCashPrice
	
	SELECT @intShipmentKey = MIN(intShipmentKey) FROM @Shipment
	WHERE dblQuantity > ISNULL(dblAllocatedQuantity,0) AND intContractHeaderId IN (SELECT intContractHeaderId FROM @PriceFixation WHERE dblQuantity > dblShippedQty)
	
	WHILE @intShipmentKey > 0 
	BEGIN
		SET @dblShipQtyToAllocate = NULL
		SET @intContractDetailId  = NULL
		
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
	SELECT intContractTypeId,'PriceFixation' COLLATE Latin1_General_CI_AS,intContractHeaderId,intContractDetailId,dblQuantity * -1 FROM @PriceFixation 

	INSERT INTO @Balance (intContractTypeId,strType,intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT intContractTypeId,'Shipment' COLLATE Latin1_General_CI_AS,intContractHeaderId,intContractDetailId,(dblQuantity - dblAllocatedQuantity) * -1 FROM @Shipment

	INSERT INTO @BalanceTotal(intContractHeaderId,intContractDetailId,dblQuantity)
	SELECT intContractHeaderId,intContractDetailId,SUM(dblQuantity) FROM @Balance 
	GROUP BY intContractHeaderId,intContractDetailId

	INSERT INTO @FinalResult (intContractHeaderId
		, intContractDetailId
		, strDate
		, dtmEndDate
		, strContractType
		, intCommodityId
		, strCommodityCode
		, intCompanyLocationId
		, strLocationName
		, strEntityName
		, strContractNumber
		, strPricingType
		, strContractDate
		, strShipMethod
		, strShipmentPeriod
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMonth
		, dblFutures
		, dblBasis
		, strBasisUOM
		, dblQuantity
		, dblBalance
		, strQuantityUOM
		, dblCashPrice
		, strPriceUOM
		, strStockUOM
		, dblAvailableQty
		, dblAmount
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCommodityUnitMeasureId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strCurrency
		, intItemId
		, strItemNo
		, dtmContractDate
		, strFutMarketName
		, intCategoryId
		, strCategory)
	SELECT intContractHeaderId = CH.intContractHeaderId
		, intContractDetailId = CD.intContractDetailId
		, strDate = (LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)) COLLATE Latin1_General_CI_AS
		, dtmEndDate
		, strContractType = TP.strContractType
		, intCommodityId = CH.intCommodityId
		, strCommodityCode = CM.strDescription 
		, intCompanyLocationId = CD.intCompanyLocationId
		, strLocationName = L.strLocationName					   
		, EY.strEntityName
		, strContractNumber = (CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
		, strPricingType = CASE WHEN CD.intPricingTypeId = 1 THEN 'Priced'
								WHEN CD.intPricingTypeId = 2 THEN 'Basis'
								WHEN CD.intPricingTypeId = 3 THEN 'HTA'
								WHEN CD.intPricingTypeId = 4 THEN 'Unit'
								WHEN CD.intPricingTypeId = 6 THEN 'Cash'
								WHEN CD.intPricingTypeId = 7 THEN 'Index' END COLLATE Latin1_General_CI_AS
		, strContractDate = (LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5)) COLLATE Latin1_General_CI_AS
		, strShipMethod = FT.strFreightTerm
		, strShipmentPeriod = (LTRIM(DATEPART(mm, CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd, CD.dtmStartDate)) + ' - ' + LTRIM(DATEPART(mm, CD.dtmEndDate)) + '/' + LTRIM(DATEPART(dd, CD.dtmEndDate))) COLLATE Latin1_General_CI_AS
		, intFutureMarketId = CD.intFutureMarketId
		, intFutureMonthId = CD.intFutureMonthId
		, strFutureMonth = MO.strFutureMonth
		, dblFutures = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0)),0)
		, dblBasis = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId),ISNULL(CD.dblBasis,0)),0)
		, strBasisUOM = BUOM.strUnitMeasure
		, dblQuantity = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
		, dblBalance = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
		, strQuantityUOM = IUM.strUnitMeasure
		, dblCashPrice = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)	
		, strPriceUOM = PUOM.strUnitMeasure
		, strStockUOM = StockUM.strUnitMeasure
		, dblAvailableQty = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)	
		, dblAmount = (ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,CD.dblQuantity) ,0) + ISNULL(BL.dblQuantity,0)) 
						* ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(CD.dblFutures,0) + ISNULL(CD.dblBasis,0)),0)
		, CD.intUnitMeasureId
		, CD.intPricingTypeId
		, CH.intContractTypeId
		, C1.intCommodityUnitMeasureId
		, CD.intContractStatusId
		, EY.intEntityId
		, CD.intCurrencyId
		, Cur.strCurrency
		, CD.intItemId		
		, Itm.strItemNo		
		, CH.dtmContractDate
		, FM.strFutMarketName
		, Category.intCategoryId
		, Category.strCategoryCode
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN @BalanceTotal  BL ON CH.intContractHeaderI = BL.intContractHeaderId AND CD.intContractDetailId = BL.intContractDetailId
	JOIN tblICCommodity CM ON CM.intCommodityId = CH.intCommodityId
	JOIN tblICCommodityUnitMeasure C1 ON C1.intCommodityId = CH.intCommodityId AND C1.intCommodityId = CM.intCommodityId AND C1.ysnStockUnit=1
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = C1.intUnitMeasureId
	JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
	JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = CD.intCompanyLocationId
	JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = CD.intItemId AND StockUOM.ysnStockUnit = 1 
	JOIN tblICUnitMeasure StockUM ON StockUM.intUnitMeasureId = StockUOM.intUnitMeasureId
	JOIN tblICItem Itm	ON Itm.intItemId = CD.intItemId
	JOIN tblICCategory Category ON Category.intCategoryId = Itm.intCategoryId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM BASISUOM ON BASISUOM.intItemUOMId = CD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure BUOM ON BUOM.intUnitMeasureId = BASISUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
	LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblSMCurrency Cur ON Cur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
	WHERE dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE WHEN @dtmToDate IS NOT NULL	THEN @dtmToDate	  ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
	
	INSERT INTO @tblChange(intSequenceHistoryId,intContractDetailId)
	SELECT MAX(intSequenceHistoryId),intContractDetailId FROM tblCTSequenceHistory 
	WHERE  dbo.fnRemoveTimeOnDate(dtmHistoryCreated)	<= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END
	GROUP BY intContractDetailId

	UPDATE @FinalResult 
	SET strPricingType = CASE WHEN SH.intPricingTypeId = 1 THEN 'Priced'
							WHEN SH.intPricingTypeId = 2 THEN 'Basis'
							WHEN SH.intPricingTypeId = 3 THEN 'HTA'
							WHEN SH.intPricingTypeId = 4 THEN 'Unit'
							WHEN SH.intPricingTypeId = 6 THEN 'Cash'
							WHEN SH.intPricingTypeId = 7 THEN 'Index' END COLLATE Latin1_General_CI_AS
		, dblFutures = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
		, dblBasis = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
		, dblCashPrice = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblFutures,0)),0)
						+ ISNULL(dbo.fnMFConvertCostToTargetItemUOM(SH.intPriceItemUOMId,dbo.fnGetItemStockUOM(SH.intItemId), ISNULL(SH.dblBasis,0)),0)
	   , intFutureMarketId = SH.intFutureMarketId
	   , intFutureMonthId = SH.intFutureMonthId
	   , strFutureMonth = MO.strFutureMonth
	FROM @FinalResult FR 
	JOIN @tblChange tblChange ON tblChange.intContractDetailId = FR.intContractDetailId
	JOIN tblCTSequenceHistory SH ON SH.intSequenceHistoryId = tblChange.intSequenceHistoryId
	JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = SH.intFutureMonthId
	
	INSERT INTO @FinalResult (intContractHeaderId
		, intContractDetailId
		, strDate
		, dtmEndDate
		, strContractType
		, intCommodityId
		, strCommodityCode
		, intCompanyLocationId
		, strLocationName
		, strEntityName
		, strContractNumber
		, strPricingType
		, strContractDate
		, strShipMethod
		, strShipmentPeriod
		, intFutureMarketId
		, intFutureMonthId
		, strFutureMonth
		, dblFutures
		, dblBasis
		, strBasisUOM
		, dblQuantity
		, dblBalance
		, strQuantityUOM
		, dblCashPrice
		, strPriceUOM
		, strStockUOM
		, dblAvailableQty
		, dblAmount
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCommodityUnitMeasureId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strCurrency
		, intItemId
		, strItemNo
		, dtmContractDate
		, strFutMarketName
		, intCategoryId
		, strCategory)
	SELECT DISTINCT intContractHeaderId = CH.intContractHeaderId
		, intContractDetailId = CD.intContractDetailId
		, strDate = (LTRIM(DATEPART(mm,GETDATE())) + '-' + LTRIM(DATEPART(dd,GETDATE())) + '-' + RIGHT(LTRIM(DATEPART(yyyy,GETDATE())),2)) COLLATE Latin1_General_CI_AS
		, dtmEndDate
		, strContractType = TP.strContractType
		, intCommodityId = CH.intCommodityId
		, strCommodityCode = CM.strDescription
		, intCompanyLocationId = CD.intCompanyLocationId
		, strLocationName = L.strLocationName
		, EY.strEntityName
		, strContractNumber = (CH.strContractNumber+'-' +LTRIM(CD.intContractSeq)) COLLATE Latin1_General_CI_AS
		, strPricingType = 'Priced' COLLATE Latin1_General_CI_AS
		, strContractDate = LEFT(CONVERT(NVARCHAR,CH.dtmContractDate,101),5) COLLATE Latin1_General_CI_AS
		, strShipMethod = FT.strFreightTerm
		, strShipmentPeriod = (LTRIM(DATEPART(mm,CD.dtmStartDate)) + '/' + LTRIM(DATEPART(dd,CD.dtmStartDate))+' - ' + LTRIM(DATEPART(mm,CD.dtmEndDate))   + '/' + LTRIM(DATEPART(dd,CD.dtmEndDate))) COLLATE Latin1_General_CI_AS
		, intFutureMarketId = CD.intFutureMarketId
		, intFutureMonthId = CD.intFutureMonthId
		, strFutureMonth = MO.strFutureMonth
		, dblFutures = ISNULL(PF.dblFutures,0)
		, dblBasis = ISNULL(PF.dblBasis,0)
		, strBasisUOM = BUOM.strUnitMeasure
		, dblQuantity = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)
		, dblBalance = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)
		, strQuantityUOM = IUM.strUnitMeasure
		, dblCashPrice = ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)
		, strPriceUOM = PUOM.strUnitMeasure
		, strStockUOM = StockUM.strUnitMeasure
		, dblAvailableQty = ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)
		, dblAmount = (ISNULL(dbo.fnICConvertUOMtoStockUnit(CD.intItemId,CD.intItemUOMId,ISNULL(PF.dblQuantity,0)) ,0) - ISNULL(PF.dblShippedQty,0)) * ISNULL(dbo.fnMFConvertCostToTargetItemUOM(CD.intPriceItemUOMId,dbo.fnGetItemStockUOM(CD.intItemId), ISNULL(PF.dblCashPrice,0)),0)
		, CD.intUnitMeasureId
		, CD.intPricingTypeId
		, CH.intContractTypeId
		, C1.intCommodityUnitMeasureId
		, CD.intContractStatusId
		, EY.intEntityId
		, CD.intCurrencyId
		, Cur.strCurrency
		, CD.intItemId
		, Itm.strItemNo
		, CH.dtmContractDate
		, FM.strFutMarketName
		, Category.intCategoryId
		, Category.strCategoryCode
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN @BalanceTotal BL ON CH.intContractHeaderId = BL.intContractHeaderId AND CD.intContractDetailId = BL.intContractDetailId
	JOIN @PriceFixation PF ON PF.intContractDetailId = CD.intContractDetailId AND PF.intContractDetailId = BL.intContractDetailId
	JOIN tblICCommodity CM ON CM.intCommodityId = CH.intCommodityId
	JOIN tblICCommodityUnitMeasure C1 ON C1.intCommodityId = CH.intCommodityId AND C1.intCommodityId = CM.intCommodityId AND C1.ysnStockUnit=1
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = C1.intUnitMeasureId
	JOIN tblCTContractType TP ON TP.intContractTypeId = CH.intContractTypeId
	JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = CD.intCompanyLocationId
	JOIN vyuCTEntity EY ON EY.intEntityId = CH.intEntityId	AND EY.strEntityType =(CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
	JOIN tblICItemUOM StockUOM ON StockUOM.intItemId = CD.intItemId AND StockUOM.ysnStockUnit = 1 
	JOIN tblICUnitMeasure StockUM ON StockUM.intUnitMeasureId = StockUOM.intUnitMeasureId
	JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure IUM ON IUM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblICItem Itm ON Itm.intItemId = CD.intItemId
	JOIN tblICCategory Category ON Category.intCategoryId = Itm.intCategoryId
	LEFT JOIN tblICItemUOM BASISUOM ON BASISUOM.intItemUOMId = CD.intBasisUOMId
	LEFT JOIN tblICUnitMeasure BUOM ON BUOM.intUnitMeasureId = BASISUOM.intUnitMeasureId
	LEFT JOIN tblICItemUOM PriceUOM ON PriceUOM.intItemUOMId = CD.intPriceItemUOMId
	LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PriceUOM.intUnitMeasureId
	LEFT JOIN tblSMFreightTerms FT ON FT.intFreightTermId = CD.intFreightTermId
	LEFT JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = CD.intFutureMonthId
	LEFT JOIN tblSMCurrency Cur ON Cur.intCurrencyID = CD.intCurrencyId
	LEFT JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
	WHERE dbo.fnRemoveTimeOnDate(CD.dtmCreated)	<= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate ELSE dbo.fnRemoveTimeOnDate(CD.dtmCreated) END
		AND ISNULL(BL.dblQuantity,0) <= 0
	
	UPDATE @FinalResult
	SET dblAmount = ISNULL(dblAvailableQty,0) * (ISNULL(dblFutures,0)+ISNULL(dblBasis,0))
		, strType = (strContractType + ' ' + strPricingType) COLLATE Latin1_General_CI_AS

	DELETE FROM @FinalResult 
	WHERE intContractDetailId IN (SELECT intContractDetailId FROM tblCTSequenceHistory WHERE intContractStatusId IN (3,5,6)
	AND dbo.fnRemoveTimeOnDate(dtmHistoryCreated) <= CASE WHEN @dtmToDate IS NOT NULL THEN @dtmToDate	 ELSE dbo.fnRemoveTimeOnDate(dtmHistoryCreated) END) 

	DELETE FROM @FinalResult
	WHERE dblAvailableQty <= 0

	RETURN
END