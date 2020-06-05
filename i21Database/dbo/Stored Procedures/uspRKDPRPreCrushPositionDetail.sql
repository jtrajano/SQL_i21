CREATE PROCEDURE [dbo].[uspRKDPRPreCrushPositionDetail]
	@intCommodityId NVARCHAR(max)
	, @intLocationId NVARCHAR(max) = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(50) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @intBookId INT = NULL
	, @intSubBookId INT = NULL
	, @strPositionBy NVARCHAR(100) = NULL
	, @intUserId INT  = NULL
	, @ysnRefresh BIT = 0
	, @ysnLogDPR BIT = 0
AS

BEGIN
	SET @dtmToDate = convert(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	IF (@intLocationId = 0) SET @intLocationId = NULL
	IF (@intVendorId = 0) SET @intVendorId = NULL
	IF (@intBookId = 0) SET @intBookId = NULL
	IF (@intSubBookId = 0) SET @intSubBookId = NULL
	
	DECLARE @strPurchaseSaleFilter NVARCHAR(50) = NULL
	IF ISNULL(@strPurchaseSales, '') <> ''
	BEGIN
		IF @strPurchaseSales = 'Purchase'
		BEGIN
			SELECT @strPurchaseSaleFilter = 'Sale'
		END
		ELSE
		BEGIN
			SELECT @strPurchaseSaleFilter = 'Purchase'
		END
	END

	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END
	IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		SET @intVendorId = NULL
	END

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE isnull(ysnLicensed, 0) END

	DECLARE @strCommodityCode NVARCHAR(50)
	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodity INT)
	DECLARE @CrushReport BIT = 1
	--IF (ISNULL(@strPositionBy, '') = 'Delivery Month' OR ISNULL(@strPositionBy, '') = 'Futures Month')
	--BEGIN
	--	SET @CrushReport = 1
	--END

	INSERT INTO @Commodity (intCommodity)
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@intCommodityId, ',')

	DECLARE @List AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intOrderId int
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, strTransactionReferenceId NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTransactionReferenceId INT
		, intTransactionReferenceDetailId INT)
	DECLARE @FinalList AS TABLE (intRowNumber INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24, 10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intOrderId int
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, strTransactionReferenceId NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTransactionReferenceId INT
		, intTransactionReferenceDetailId INT)
	DECLARE @InventoryStock AS TABLE (strCommodityCode NVARCHAR(100)
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal numeric(24,10)
		, strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intFromCommodityUnitMeasureId int
		, strType nvarchar(100) COLLATE Latin1_General_CI_AS
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId int
		, strTransactionReferenceId NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTransactionReferenceId INT
		, intTransactionReferenceDetailId INT)


	DECLARE @mRowNumber INT
	DECLARE @intCommodityId1 INT
	DECLARE @strDescription NVARCHAR(50)
	DECLARE @intOneCommodityId INT
	DECLARE @intCommodityUnitMeasureId INT
		, @intCommodityStockUOMId INT
		, @ysnExchangeTraded BIT

	SELECT @mRowNumber = MIN(intCommodityIdentity)
	FROM @Commodity

	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity
		FROM @Commodity
		WHERE intCommodityIdentity = @mRowNumber

		SELECT TOP 1 @strDescription = strCommodityCode
			, @ysnExchangeTraded = ysnExchangeTraded
			, @strCommodityCode = strCommodityCode
		FROM tblICCommodity
		WHERE intCommodityId = @intCommodityId

		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
				,@intCommodityStockUOMId = intUnitMeasureId
		FROM tblICCommodityUnitMeasure
		WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

		IF @intCommodityId > 0
		BEGIN

			IF OBJECT_ID('tempdb..#tblGetSalesIntransitWOPickLot') IS NOT NULL
				DROP TABLE #tblGetSalesIntransitWOPickLot
			--=============================
			-- Sales In Transit w/o Pick Lot
			--=============================
			SELECT strShipmentNumber
				, intInventoryShipmentId
				, strContractNumber
				, intContractHeaderId
				, intCompanyLocationId
				, strLocationName
				, dblBalanceToInvoice 
				, intEntityId
				, strCustomerReference 
				, dtmTicketDateTime
				, intTicketId
				, strTicketNumber
				, intCommodityId
				, intItemId
				, strItemNo
				, strCategory
				, intCategoryId
				, strContractEndMonth
				, strFutureMonth
				, strDeliveryDate
			INTO #tblGetSalesIntransitWOPickLot
			FROM(
				SELECT 
					 strShipmentNumber = InTran.strTransactionId
					,intInventoryShipmentId = InTran.intTransactionId
					,strContractNumber = SI.strOrderNumber + '-' + CONVERT(NVARCHAR, SI.intContractSeq) COLLATE Latin1_General_CI_AS 
					,intContractHeaderId = SI.intOrderId 
					,strTicketNumber = SI.strSourceNumber
					,intTicketId = SI.intSourceId
					,dtmTicketDateTime = InTran.dtmDate
					,intCompanyLocationId = Inv.intLocationId
					,strLocationName = Inv.strLocationName
					,strUOM = InTran.strUnitMeasure
					,Inv.intEntityId
					,strCustomerReference = SI.strCustomerName
					,Com.intCommodityId
					,Itm.intItemId
					,Itm.strItemNo
					,strCategory = Cat.strCategoryCode
					,Cat.intCategoryId
					,dblBalanceToInvoice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((InTran.dblInTransitQty),0))
					,strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), InTran.dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
					,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblCTContractDetail cd INNER JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId =  fmnt.intFutureMonthId WHERE intContractHeaderId = SI.intLineNo)
					,strDeliveryDate =  (SELECT TOP 1 dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') FROM tblCTContractDetail WHERE intContractHeaderId = SI.intLineNo)
				FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmToDate) InTran
					INNER JOIN vyuICGetInventoryValuation Inv ON InTran.intInventoryTransactionId = Inv.intInventoryTransactionId
					INNER JOIN tblICItem Itm ON InTran.intItemId = Itm.intItemId
					INNER JOIN tblICCommodity Com ON Itm.intCommodityId = Com.intCommodityId
					INNER JOIN tblICCategory Cat ON Itm.intCategoryId = Cat.intCategoryId
					LEFT JOIN vyuICGetInventoryShipmentItem SI ON InTran.intTransactionDetailId = SI.intInventoryShipmentItemId
					INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InTran.intItemUOMId
					INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
					JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = Com.intCommodityId AND cum.intUnitMeasureId = UOM.intUnitMeasureId
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmToDate)
					AND ISNULL(Inv.intEntityId,0) = CASE WHEN ISNULL(@intVendorId,0)=0 THEN ISNULL(Inv.intEntityId,0) ELSE @intVendorId END				
			)t

			DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
				, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intCommodityId INT
				, intContractHeaderId INT
				, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmEndDate DATETIME
				, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblBalance DECIMAL(24, 10)
				, intUnitMeasureId INT
				, intPricingTypeId INT
				, intContractTypeId INT
				, intCompanyLocationId INT
				, strContractType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strPricingType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intContractDetailId INT
				, intContractStatusId INT
				, intEntityId INT
				, intCurrencyId INT
				, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intItemId INT
				, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dtmContractDate DATETIME
				, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intFutureMarketId INT
				, intFutureMonthId INT
				, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS)

			INSERT INTO @tblGetOpenContractDetail (intRowNum
				, strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strLocationName
				, dtmEndDate
				, strFutureMonth
				, dblBalance
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName)
			SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC)
				, strCommodityCode = CD.strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber = CD.strContract
				, strLocationName
				, dtmEndDate = dtmSeqEndDate--= CASE WHEN ISNULL(strFutureMonth,'') <> '' THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) ELSE dtmEndDate END
				, strFutureMonth
				, dblBalance = CD.dblQtyinCommodityStockUOM
				, intUnitMeasureId
				, intPricingTypeId
				, intContractTypeId
				, intCompanyLocationId
				, strContractType
				, strPricingType = CD.strPricingTypeDesc
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) COLLATE Latin1_General_CI_AS
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName = CD.strCustomer
				, intFutureMarketId
				, intFutureMonthId
				, strCategory
				, strFutMarketName
			FROM tblCTContractBalance CD
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
			AND   CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate
						
			DECLARE @tblGetOpenFutureByDate TABLE (intFutOptTransactionId INT
				, dblOpenContract NUMERIC(18,6)
				, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strInternalTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblContractSize NUMERIC(24,10)
				, strFutureMarket NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strOptionMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, dblStrike NUMERIC(24,10)
				, strOptionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strInstrumentType NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strBrokerAccount NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strBroker NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, strNewBuySell NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intFutOptTransactionHeaderId int
				, ysnPreCrush BIT
				, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS
				, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
				, intBrokerageAccountId INT)
	
			INSERT INTO @tblGetOpenFutureByDate (intFutOptTransactionId
				, dblOpenContract
				, strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, dblContractSize
				, strFutureMarket
				, strFutureMonth
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, strNewBuySell
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strNotes
				, strBrokerTradeNo
				, intBrokerageAccountId)
			SELECT intFutOptTransactionId
				, dblOpenContract
				, strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, dblContractSize
				, strFutureMarket
				, strFutureMonth
				, strOptionMonth
				, dblStrike
				, strOptionType
				, strInstrumentType
				, strBrokerAccount
				, strBroker
				, strNewBuySell
				, intFutOptTransactionHeaderId
				, ysnPreCrush
				, strNotes
				, strBrokerTradeNo
				, intBrokerageAccountId
			FROM fnRKGetOpenFutureByDate (@intCommodityId, '1/1/1900', @dtmToDate, @CrushReport)

			INSERT INTO @List (strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate)
			SELECT strCommodityCode
				, intCommodityId
				, intContractHeaderId
				, strContractNumber
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
			FROM (
				SELECT DISTINCT strCommodityCode
					, CD.intCommodityId
					, CD.intContractHeaderId
					, strContractNumber
					, CD.strType
					, strLocationName
					, strContractEndMonth = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
												ELSE (CASE WHEN ISNULL(CD.strFutureMonth, '') = '' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END) END COLLATE Latin1_General_CI_AS
					, strContractEndMonthNearBy = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8)
													ELSE (CASE WHEN ISNULL(CD.strFutureMonth, '') = '' THEN RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(CD.strFutureMonth, ' ', ' 1, ')) , 106), 8) END) END COLLATE Latin1_General_CI_AS
					, dblTotal = CASE WHEN intContractTypeId = 1 THEN  ISNULL(CD.dblBalance, 0) ELSE - ISNULL(CD.dblBalance, 0) END
					, CD.intUnitMeasureId intFromCommodityUnitMeasureId
					, CD.strEntityName
					, CD.intItemId
					, CD.strItemNo
					, CD.strCategory
					, CD.intFutureMarketId
					, CD.strFutMarketName
					, CD.intFutureMonthId
					, CD.strFutureMonth
					, strDeliveryDate = CASE WHEN ISNULL(CD.dtmEndDate, '') = '' THEN '' ELSE RIGHT(CONVERT(VARCHAR(11), CD.dtmEndDate, 106), 8) END COLLATE Latin1_General_CI_AS
					, CD.intContractDetailId
				FROM @tblGetOpenContractDetail CD
				JOIN tblCTContractDetail det ON CD.intContractDetailId = det.intContractDetailId
				WHERE intContractTypeId IN (1, 2) AND CD.intCommodityId = @intCommodityId
					AND CD.intContractStatusId <> 3
					AND CD.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
					AND CD.intEntityId = ISNULL(@intVendorId, CD.intEntityId)
			) t WHERE dblTotal <> 0
			
			INSERT INTO @FinalList (strCommodityCode
				, strContractNumber
				, intContractHeaderId
				, strInternalTradeNo
				, intFutOptTransactionHeaderId
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, strUnitMeasure
				, strAccountNumber
				, strTranType
				, dblNoOfLot
				, dblDelta
				, intBrokerageAccountId
				, strInstrumentType
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush)
			SELECT strCommodityCode
				, strContractNumber
				, intContractHeaderId
				, strInternalTradeNo
				, intFutOptTransactionHeaderId
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, um.strUnitMeasure
				, strAccountNumber
				, strTranType
				, dblNoOfLot
				, dblDelta
				, intBrokerageAccountId
				, strInstrumentType
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM @List t
			JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
			JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
			WHERE t.intCommodityId = @intCommodityId

			--=============================
			-- Storage Detail By Date
			--=============================
			SELECT * INTO #tblGetStorageDetailByDate
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY gh.intStorageHistoryId ORDER BY gh.intStorageHistoryId ASC)
					, a.intCustomerStorageId
					, a.intCompanyLocationId
					, c.strLocationName
					, strContractEndMonth = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
					, strDeliveryDate = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
					, a.intEntityId
					, strCustomerName = E.strName
					, a.strDPARecieptNumber [Receipt]
					, dblDiscDue = a.dblDiscountsDue
					, a.dblStorageDue
					, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
					, a.intStorageTypeId
					, strStorageType = b.strStorageTypeDescription
					, a.intCommodityId
					, CM.strCommodityCode
					, strCommodityDescription = CM.strDescription
					, b.strOwnedPhysicalStock
					, b.ysnReceiptedStorage
					, b.ysnDPOwnedType
					, b.ysnGrainBankType
					, b.ysnActive ysnCustomerStorage
					, a.strCustomerReference
					, a.dtmLastStorageAccrueDate
					, c1.strScheduleId
					, i.intItemId
					, i.strItemNo
					, i.intCategoryId
					, strCategory = Category.strCategoryCode
					, ium.intCommodityUnitMeasureId
					, t.dtmTicketDateTime
					, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
										WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
										WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
										ELSE gh.intCustomerStorageId END)
					, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
										WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
										WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
										ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
					, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
										WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
										WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
										ELSE a.strStorageTicketNumber END)
					, gh.intInventoryReceiptId
					, gh.intInventoryShipmentId
					, strReceiptNumber = ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '')
					, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
					, b.intStorageScheduleTypeId
					, strFutureMonth = '' COLLATE Latin1_General_CI_AS
				FROM tblGRStorageHistory gh
				JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
				JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
				JOIN tblICItem i ON i.intItemId = a.intItemId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
				JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
				JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
				JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
				LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
				WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
					AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
				
				UNION ALL
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY gh.intStorageHistoryId ORDER BY gh.intStorageHistoryId ASC)
					, a.intCustomerStorageId
					, a.intCompanyLocationId
					, c.strLocationName
					, strContractEndMonth = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
					, strDeliveryDate = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
					, a.intEntityId
					, strCustomerName = E.strName
					, [Receipt] = a.strDPARecieptNumber
					, dblDiscDue = a.dblDiscountsDue 
					, a.dblStorageDue
					, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
					, a.intStorageTypeId
					, strStorageType = b.strStorageTypeDescription
					, a.intCommodityId
					, CM.strCommodityCode
					, strCommodityDescription = CM.strDescription
					, b.strOwnedPhysicalStock
					, b.ysnReceiptedStorage
					, b.ysnDPOwnedType
					, b.ysnGrainBankType
					, b.ysnActive ysnCustomerStorage
					, a.strCustomerReference
					, a.dtmLastStorageAccrueDate
					, c1.strScheduleId
					, i.intItemId
					, i.strItemNo
					, i.intCategoryId
					, strCategory = Category.strCategoryCode
					, ium.intCommodityUnitMeasureId
					, dtmTicketDateTime = NULL
					, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
										WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
										WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
										ELSE gh.intCustomerStorageId END)
					, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
										WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
										WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
										ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
					, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN NULL
										WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
										WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
										ELSE a.strStorageTicketNumber END)
					, intInventoryReceiptId = (CASE WHEN gh.strType = 'From Inventory Adjustment' THEN gh.intInventoryAdjustmentId ELSE gh.intInventoryReceiptId END)
					, gh.intInventoryShipmentId
					, strReceiptNumber = (CASE WHEN gh.strType ='From Inventory Adjustment' THEN gh.strTransactionId
											ELSE ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '') END)
					, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
					, b.intStorageScheduleTypeId
					, strFutureMonth = '' COLLATE Latin1_General_CI_AS
				FROM tblGRStorageHistory gh
				JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
				JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
				JOIN tblICItem i ON i.intItemId = a.intItemId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
				LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
				JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
				JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
				JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
				WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
					AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
			)t

			--========================
			-- TRANSFER
			--========================
			DECLARE @transfer TABLE (dblTotal numeric(24,10)
				, Ticket NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, intCommodityId int
				, intFromCommodityUnitMeasureId int
				, intLocationId int
				, strTransactionId  NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strTransactionType NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, intItemId int
				, strDistributionOption NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, strTicketStatus NVARCHAR(200) COLLATE Latin1_General_CI_AS
				, intEntityId INT)

			INSERT INTO @transfer
			SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))
				, t.strTicketNumber Ticket
				, s.strLocationName
				, s.strItemNo
				, i.intCommodityId intCommodityId
				, intCommodityUnitMeasureId intFromCommodityUnitMeasureId
				, s.intLocationId intLocationId
				, strTransactionId
				, strTransactionType
				, i.intItemId
				, t.strDistributionOption
				, strTicketStatus
				, s.intEntityId
			FROM vyuRKGetInventoryValuation s
			JOIN tblICItem i on i.intItemId=s.intItemId
			JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
			JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
			JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
			LEFT JOIN tblSCTicket t on s.intSourceId = t.intTicketId
			LEFT JOIN tblICInventoryReceiptItem IRI ON s.intTransactionId = IRI.intInventoryTransferId --Join here to determine if an IT has a corresponding transfer in
			WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <>0 
				AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) AND ISNULL(strTicketStatus,'') <> 'V'
				AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
				AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToDate)
				AND ysnInTransit = 1
				AND strTransactionForm IN('Inventory Transfer')
				AND IRI.intInventoryReceiptItemId IS NULL
				AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			-- inventory
			INSERT INTO @InventoryStock(strCommodityCode
				, strItemNo
				, strCategory
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, strTransactionReferenceId
				, intTransactionReferenceId
				, intTransactionReferenceDetailId)
			SELECT strCommodityCode
				, strItemNo
				, strCategoryCode
				, dblTotal = dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, strTransactionId
				, intTransactionId
				, intTransactionDetailId
			FROM (
				SELECT strCommodityCode
					, i.strItemNo
					, Category.strCategoryCode
					, dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
					, strLocationName
					, intCommodityId = @intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
					, s.strTransactionId
					, s.intTransactionId
					, s.intTransactionDetailId
				FROM vyuRKGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId = s.intItemId
				JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
				JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
				JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity,0) <> 0 AND ysnInTransit = 0
					AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND strTransactionId NOT IN (SELECT strTransactionId FROM @transfer)
			) t

			--Collateral
			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT strCommodityCode
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
			FROM (
				SELECT strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType = 'Collateral' COLLATE Latin1_General_CI_AS
				FROM (
					SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intCollateralId ORDER BY c.dtmOpenDate DESC)
						, dblTotal = CASE WHEN c.strType = 'Purchase' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(c.dblOriginalQuantity, 0) - ISNULL(ca.dblAdjustmentAmount, 0))
										ELSE - ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(c.dblOriginalQuantity, 0) -  ISNULL(ca.dblAdjustmentAmount, 0))) END
						, intCommodityId = @intCommodityId
						, co.strCommodityCode
						, cl.strLocationName
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
						, ysnIncludeInPriceRiskAndCompanyTitled
					FROM tblRKCollateral c
					LEFT JOIN (
						SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
						WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						GROUP BY intCollateralId

					) ca on c.intCollateralId = ca.intCollateralId
					JOIN tblICCommodity co ON co.intCommodityId = c.intCommodityId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
					JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
					LEFT JOIN @tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
					LEFT JOIn tblCTContractDetail det ON ch.intContractDetailId = det.intContractDetailId
					WHERE c.intCommodityId = @intCommodityId 
						AND c.intLocationId = ISNULL(@intLocationId, c.intLocationId)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				) a WHERE a.intRowNum = 1 AND ysnIncludeInPriceRiskAndCompanyTitled = 1
			) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
	
			
			--=========================================
			-- Includes DP based on Company Preference
			--========================================
			If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
			BEGIN
				INSERT INTO @InventoryStock(strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, strTransactionReferenceId
					, intTransactionReferenceId)
				SELECT strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal = -sum(dblTotal)
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, 'Company Titled' COLLATE Latin1_General_CI_AS
					, strTransactionReferenceId
					, intTransactionReferenceId
				FROM (
					SELECT intTicketId
						, strTicketType
						, strTicketNumber
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
						, ch.intCompanyLocationId
						, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, dtmTicketDateTime
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, strCommodityCode
						, strTransactionReferenceId = CASE WHEN ISNULL(ch.strReceiptNumber,'')  <> '' THEN ch.strReceiptNumber ELSE ch.strShipmentNumber END
						, intTransactionReferenceId = ISNULL(ch.intInventoryReceiptId, ch.intInventoryShipmentId)
					FROM #tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
					)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY strCommodityCode
					, strItemNo
					, strCategory
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strTransactionReferenceId
					, intTransactionReferenceId
			END
			ELSE
			BEGIN
				INSERT INTO @InventoryStock(strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, strTransactionReferenceId
					, intTransactionReferenceId)
				SELECT strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal = -sum(dblTotal)
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, 'Delayed Pricing' COLLATE Latin1_General_CI_AS
					, strTransactionReferenceId
					, intTransactionReferenceId
				FROM (
					SELECT intTicketId
						, strTicketType
						, strTicketNumber
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
						, ch.intCompanyLocationId
						, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, dtmTicketDateTime
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, strCommodityCode
						, strTransactionReferenceId = CASE WHEN ISNULL(ch.strReceiptNumber,'')  <> '' THEN ch.strReceiptNumber ELSE ch.strShipmentNumber END
						, intTransactionReferenceId = ISNULL(ch.intInventoryReceiptId, ch.intInventoryShipmentId)
					FROM #tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
					)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY strCommodityCode
					, strItemNo
					, strCategory
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strTransactionReferenceId
					, intTransactionReferenceId
			END



			INSERT INTO @FinalList(intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
				, strTransactionReferenceId
				, intTransactionReferenceId)
			SELECT intContractHeaderId
				, strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR, BD.intContractSeq) COLLATE Latin1_General_CI_AS 
				, BD.intCommodityId
				, strCommodityCode
				, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
				, strLocationName = BD.strCompanyLocation
				, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
				, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
				, dblTotal = BD.dblQuantity
				, intSeqId = BD.intContractSeq
				, strUnitMeasure = NULL
				, intFromCommodityUnitMeasureId = NULL
				, strEntityName = BD.strCustomerVendor
				, intOrderId = 6
				, BD.intItemId
				, BD.strItemNo
				, cat.strCategoryCode
				, fm.intFutureMarketId
				, fm.strFutMarketName
				, mnt.intFutureMonthId
				, mnt.strFutureMonth
				, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
				, strTransactionId
				, intTransactionId
			FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
				INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
				INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
				INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
				INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
			WHERE BD.intCommodityId = @intCommodityId
				AND strContractType = 'Sale'
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND BD.ysnOpenGetBasisDelivery = 1

			--INSERT INTO @FinalList(intContractHeaderId
			--	, strContractNumber
			--	, intCommodityId
			--	, strCommodityCode
			--	, strType
			--	, strLocationName
			--	, strContractEndMonth
			--	, strContractEndMonthNearBy
			--	, dblTotal
			--	, intSeqNo
			--	, strUnitMeasure
			--	, intFromCommodityUnitMeasureId
			--	, strEntityName
			--	, intOrderId
			--	, intItemId
			--	, strItemNo
			--	, strCategory
			--	, intFutureMarketId
			--	, strFutMarketName
			--	, intFutureMonthId
			--	, strFutureMonth
			--	, strDeliveryDate)
			--SELECT intContractHeaderId
			--	, strContractNumber
			--	, intCommodityId
			--	, strCommodityCode
			--	, strType
			--	, strLocationName
			--	, strContractEndMonth
			--	, strContractEndMonthNearBy
			--	, dblTotal
			--	, intSeqId
			--	, strUnitMeasure
			--	, intFromCommodityUnitMeasureId
			--	, strEntityName
			--	, intOrderId
			--	, intItemId
			--	, strItemNo
			--	, strCategory
			--	, intFutureMarketId
			--	, strFutMarketName
			--	, intFutureMonthId
			--	, strFutureMonth
			--	, strDeliveryDate
			--FROM  (
			--	SELECT DISTINCT cd.intContractHeaderId
			--		, strContractNumber = ch.strContractNumber + '-' +LTRIM(cd.intContractSeq) COLLATE Latin1_General_CI_AS
			--		, ch.intCommodityId
			--		, com.strCommodityCode
			--		, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
			--		, cd.intCompanyLocationId
			--		, v.strLocationName
			--		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
			--		, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
			--		, dblTotal = dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,iuom.intUnitMeasureId,@intCommodityStockUOMId,isnull(ri.dblQuantity, 0))
			--		, intSeqId = 6
			--		, um.strUnitMeasure
			--		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
			--		, strEntityName = v.strEntity
			--		, intOrderId = 6
			--		, cd.intItemId
			--		, i.strItemNo
			--		, strCategory = cat.strCategoryCode
			--		, cd.intFutureMarketId
			--		, fm.strFutMarketName
			--		, cd.intFutureMonthId
			--		, mnt.strFutureMonth
			--		, strDeliveryDate = dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
			--		--, strDeliveryDate = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
			--		--						ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(cd.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
			--		, ri.intSourceId
			--	FROM vyuRKGetInventoryValuation v
			--	JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
			--	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
			--	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
			--	INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId  AND ch.intContractTypeId = 2
			--	INNER JOIN tblICCommodity com on ch.intCommodityId = com.intCommodityId
			--	INNER JOIN tblICItem i on cd.intItemId = i.intItemId
			--	INNER JOIN tblICItemUOM iuom on iuom.intItemId = i.intItemId and iuom.intItemUOMId = ri.intItemUOMId
			--	INNER JOIN tblICCategory cat on i.intCategoryId = cat.intCategoryId
			--	INNER JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
			--	INNER JOIN tblRKFuturesMonth mnt on cd.intFutureMonthId = mnt.intFutureMonthId
			--	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = @intCommodityStockUOMId
			--	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
			--	LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
			--	LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
			--	LEFT JOIN tblCTPriceFixationDetail pfd ON invD.intInvoiceDetailId = pfd.intInvoiceDetailId
			--	WHERE ch.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
			--		AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
			--		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			--		AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(inv.dtmDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
			--		AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(pfd.dtmFixationDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
			--) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
						
			INSERT INTO @FinalList(intContractHeaderId
				, strContractNumber
				, intCommodityId
				, strCommodityCode
				, strType
				, strLocationName
				, strContractEndMonth
				, strContractEndMonthNearBy
				, dblTotal
				, intSeqNo
				, strUnitMeasure
				, intFromCommodityUnitMeasureId
				, strEntityName
				, intOrderId
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strDeliveryDate
				, strTransactionReferenceId
				, intTransactionReferenceId)
			SELECT intContractHeaderId
				, strContractNumber = strContractNumber + '-' + CONVERT(NVARCHAR, BD.intContractSeq) COLLATE Latin1_General_CI_AS 
				, BD.intCommodityId
				, strCommodityCode
				, strType = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
				, strLocationName = BD.strCompanyLocation
				, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
				, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
				, dblTotal =  dblQuantity * -1
				, intSeqNo = BD.intContractSeq
				, strUnitMeasure = ''
				, intFromCommodityUnitMeasureId = ''
				, strEntityName = BD.strCustomerVendor
				, intOrderId = 5
				, BD.intItemId
				, BD.strItemNo
				, cat.intCategoryId
				, cat.strCategoryCode
				, fm.intFutureMarketId
				, fm.strFutMarketName
				, mnt.intFutureMonthId
				, strFutureMonth
				, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
				, strTransactionId
				, intTransactionId
			FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
				INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
				INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
				INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
				INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
			WHERE BD.intCommodityId = @intCommodityId
				AND strContractType = 'Purchase'
				AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND BD.ysnOpenGetBasisDelivery = 1

			IF ((SELECT TOP 1 ysnIncludeInTransitInCompanyTitled FROM tblRKCompanyPreference) = 1)
				BEGIN
			INSERT INTO @InventoryStock(strCommodityCode
										, dblTotal
										, strLocationName
										, intCommodityId
										, intFromCommodityUnitMeasureId
										, strInventoryType)

					SELECT 
						  strCommodityCode
						, dblTotal = SUM(dblTotal)
						, strLocationName
						, @intCommodityId
						, intFromCommodityUnitMeasureId
						, strInventoryType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
					FROM (
						SELECT i.intUnitMeasureId
							, dblTotal = ISNULL(i.dblPurchaseContractShippedQty, 0)
							, i.strLocationName
							, i.intItemId
							, i.strItemNo
							, i.intCompanyLocationId, 
							c.strCommodityCode,
							c.intCommodityId,
							intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId
						FROM vyuRKPurchaseIntransitView i
						join tblICCommodity c on i.intCommodityId=c.intCommodityId
						WHERE i.intCommodityId = @intCommodityId
							AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
							AND i.intPurchaseSale = 1 -- 1.Purchase 2. Sales
							AND i.intEntityId = ISNULL(@intVendorId, i.intEntityId)					
					) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					GROUP BY strCommodityCode
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId

				INSERT INTO @InventoryStock(strCommodityCode
										, dblTotal
										, strLocationName
										, intCommodityId
										, intFromCommodityUnitMeasureId
										, strInventoryType)
					SELECT 
						  strCommodityCode
						, dblTotal = SUM(dblTotal)
						, strLocationName
						, intCommodityId
						, intFromCommodityUnitMeasureId
						, strInventoryType = 'Sales In-Transit' COLLATE Latin1_General_CI_AS
					FROM (
						SELECT intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId
							, dblTotal = dblBalanceToInvoice
							, i.strLocationName
							, i.intCompanyLocationId
							,c.strCommodityCode,
							c.intCommodityId
						FROM #tblGetSalesIntransitWOPickLot i						
						join tblICCommodity c on i.intCommodityId=c.intCommodityId
						WHERE i.intCommodityId = @intCommodityId
					AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)		
					AND i.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					) t GROUP BY strCommodityCode
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId				

				END
		END
		SELECT @mRowNumber = MIN(intCommodityIdentity)
		FROM @Commodity
		WHERE intCommodityIdentity > @mRowNumber
	END
END

UPDATE @FinalList
SET strContractEndMonth = 'Near By'
WHERE strContractEndMonth <> 'Near By'
	AND CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110))

DELETE FROM @List

INSERT INTO @List(intContractHeaderId
	, strContractNumber
	, intCommodityId
	, strCommodityCode
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intSeqNo
	, strUnitMeasure
	, intFromCommodityUnitMeasureId
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate)
SELECT intContractHeaderId
	, strContractNumber
	, intCommodityId
	, strCommodityCode
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intSeqNo
	, strUnitMeasure
	, intFromCommodityUnitMeasureId
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
FROM @FinalList
WHERE strType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')

INSERT INTO @List (strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal = ISNULL(dblTotal, 0)
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId = CASE WHEN strType = 'Purchase Priced' THEN 1
						WHEN strType = 'Sale Priced' THEN 2
						WHEN strType = 'Purchase HTA' THEN 3
						WHEN strType = 'Sale HTA' THEN 4
						WHEN strType = 'Purchase Basis' THEN 19
						WHEN strType = 'Sale Basis' THEN 20
						WHEN strType = 'Purchase DP (Priced Later)' THEN 17
						WHEN strType = 'Sale DP (Priced Later)' THEN 18
						WHEN strType = 'Purchase Unit' THEN 22
						WHEN strType = 'Sale Unit' THEN 21 END
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList
WHERE strContractEndMonth = 'Near By' AND strType IN ('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')

INSERT INTO @List (strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal = ISNULL(dblTotal, 0)
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId = CASE WHEN strType = 'Purchase Priced' THEN 1
						WHEN strType = 'Sale Priced' THEN 2
						WHEN strType = 'Purchase HTA' THEN 3
						WHEN strType = 'Sale HTA' THEN 4
						WHEN strType = 'Purchase Basis' THEN 19
						WHEN strType = 'Sale Basis' THEN 20
						WHEN strType = 'Purchase DP (Priced Later)' THEN 17
						WHEN strType = 'Sale DP (Priced Later)' THEN 18
						WHEN strType = 'Purchase Unit' THEN 22
						WHEN strType = 'Sale Unit' THEN 21 END
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @FinalList 
WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')
ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

INSERT INTO @List (strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, strContractEndMonth
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId
	, strType
	, strInventoryType
	, strTransactionReferenceId
	, intTransactionReferenceId)
SELECT strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, 'Near By' COLLATE Latin1_General_CI_AS
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId = 7
	, 'Delayed Pricing' COLLATE Latin1_General_CI_AS
	, strInventoryType
	, strTransactionReferenceId
	, intTransactionReferenceId
FROM @InventoryStock
WHERE strInventoryType IN ('Delayed Pricing')

INSERT INTO @List (strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, strContractEndMonth
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId
	, strType
	, strInventoryType
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId)
SELECT strCommodityCode
	, strItemNo
	, strCategory
	, dblTotal
	, 'Near By' COLLATE Latin1_General_CI_AS
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId = 8
	, 'Company Titled' COLLATE Latin1_General_CI_AS
	, strInventoryType
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId
FROM @InventoryStock
WHERE strInventoryType IN ('Company Titled', 'Collateral','Purchase In-Transit','Sales In-Transit')


INSERT INTO @List (strCommodityCode
	, dblTotal
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId
	, strType
	, strInventoryType
	, intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strContractNumber
	, intSeqNo
	, strContractEndMonth
	, strContractEndMonthNearBy
	, intContractHeaderId)
SELECT strCommodityCode
	, dblTotal
	, strLocationName
	, intCommodityId
	, intFromCommodityUnitMeasureId
	, intOrderId = 9
	, strType = 'Net Physical Position' COLLATE Latin1_General_CI_AS
	, strInventoryType
	, intPricingTypeId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strContractNumber
	, intSeqNo
	, strContractEndMonth
	, strContractEndMonthNearBy = strContractEndMonth
	, intContractHeaderId
FROM @List WHERE intOrderId in(1, 2, 3, 4, 5, 6, 7, 8)

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, 'Net Futures' COLLATE Latin1_General_CI_AS
	, strLocationName
	, strContractEndMonth
	, dtmFutureMonthsDate
	, HedgedQty
	, intUnitMeasureId
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId = 12
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM (
	SELECT DISTINCT oc.strCommodityCode
		, oc.strInternalTradeNo
		, oc.intFutOptTransactionHeaderId
		, th.intCommodityId
		, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
									ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblOpenContract, 0) * m.dblContractSize)
		, l.strLocationName
		, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
								ELSE LEFT(fm.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, m.intUnitMeasureId
		, UOM.strUnitMeasure
		, (oc.strBroker+ '-' + oc.strBrokerAccount) COLLATE Latin1_General_CI_AS strAccountNumber
		, strTranType = strNewBuySell
		, oc.intBrokerageAccountId
		, strInstrumentType = oc.strInstrumentType
		, dblNoOfLot = ISNULL(dblOpenContract, 0)
		, m.intFutureMarketId
		, oc.strFutureMarket
		, fm.intFutureMonthId
		, fm.strFutureMonth
		, oc.strBrokerTradeNo
		, oc.strNotes
		, oc.ysnPreCrush
	FROM @tblGetOpenFutureByDate oc
	JOIN tblICCommodity th ON th.strCommodityCode = oc.strCommodityCode
	JOIN tblSMCompanyLocation l ON l.strLocationName = oc.strLocationName
	JOIN tblRKFutureMarket m ON m.strFutMarketName = oc.strFutureMarket
	JOIN tblSMCurrency cu ON cu.intCurrencyID = m.intCurrencyId
	JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c) AND m.intUnitMeasureId = cuc1.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
	INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = oc.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
	WHERE th.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
		AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
		AND ISNULL(oc.ysnPreCrush, 0) = 0) t

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, dblDelta
	, intOrderId
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, 'Delta Adjusted Options' COLLATE Latin1_General_CI_AS
	, strLocationName
	, strContractEndMonth
	, dtmFutureMonthsDate
	, HedgedQty
	, intUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, dblDelta
	, intOrderId = 15
	, intFutureMarketId
	, strFutureMarket
	, intFutureMonthId
	, strFutureMonth
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM (
	SELECT DISTINCT oc.strCommodityCode
		, oc.strInternalTradeNo
		, oc.intFutOptTransactionHeaderId
		, th.intCommodityId
		, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + om.strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
									ELSE LEFT(om.strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, HedgedQty = dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
												FROM tblRKFuturesSettlementPrice sp
												INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
												WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
													AND oc.dblStrike = mm.dblStrike
												ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize
		, l.strLocationName
		, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + om.strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
								ELSE LEFT(om.strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
		, m.intUnitMeasureId
		, oc.strBroker + '-' + oc.strBrokerAccount COLLATE Latin1_General_CI_AS strAccountNumber
		, strTranType = strNewBuySell
		, oc.intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot = CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END
		, dblDelta = ISNULL((SELECT TOP 1 dblDelta
							FROM tblRKFuturesSettlementPrice sp
							INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
							WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
								AND oc.dblStrike = mm.dblStrike
							ORDER BY dtmPriceDate DESC), 0)
		, m.intFutureMarketId
		, oc.strFutureMarket
		, om.intFutureMonthId
		, strFutureMonth = om.strOptionMonth
		, oc.strBrokerTradeNo
		, oc.strNotes
		, oc.ysnPreCrush
	FROM @tblGetOpenFutureByDate oc
	JOIN tblICCommodity th ON th.strCommodityCode = oc.strCommodityCode
	JOIN tblSMCompanyLocation l ON l.strLocationName = oc.strLocationName
	JOIN tblRKFutureMarket m ON m.strFutMarketName = oc.strFutureMarket
	JOIN tblICCommodityUnitMeasure cuc1 ON th.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
	JOIN tblRKOptionsMonth om ON om.strOptionMonth = oc.strOptionMonth
	AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	WHERE th.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
		AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
		AND ISNULL(oc.ysnPreCrush, 0) = 0) t

-- Crush records
IF ((SELECT TOP 1 ysnPreCrush FROM tblRKCompanyPreference) = 1)
BEGIN
	INSERT INTO @List (strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, intFromCommodityUnitMeasureId
		, strAccountNumber
		, strTranType
		, intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot
		, intOrderId
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, 'Crush' COLLATE Latin1_General_CI_AS
		, strLocationName
		, strFutureMonth
		, dtmFutureMonthsDate
		, HedgedQty
		, intUnitMeasureId
		, strAccountNumber
		, strTranType
		, intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot
		, 14 intOrderId
		, intFutureMarketId
		, strFutureMarket
		, intFutureMonthId
		, strFutureMonth
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM (
		SELECT oc.strCommodityCode
			, oc.strInternalTradeNo
			, oc.intFutOptTransactionHeaderId
			, th.intCommodityId
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS dtmFutureMonthsDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0)
																															ELSE ISNULL(dblOpenContract, 0) END * m.dblContractSize) AS HedgedQty
			, l.strLocationName
			, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
					else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS strFutureMonth
			, m.intUnitMeasureId
			, oc.strBroker + '-' + oc.strBrokerAccount COLLATE Latin1_General_CI_AS strAccountNumber
			, strNewBuySell AS strTranType
			, oc.intBrokerageAccountId
			, strInstrumentType
			, CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END dblNoOfLot
			, m.intFutureMarketId
			, oc.strFutureMarket
			, fm.intFutureMonthId
			, oc.strBrokerTradeNo
			, oc.strNotes
			, oc.ysnPreCrush
		FROM @tblGetOpenFutureByDate oc
		JOIN tblICCommodity th ON th.strCommodityCode = oc.strCommodityCode
		JOIN tblSMCompanyLocation l ON l.strLocationName = oc.strLocationName
		JOIN tblRKFutureMarket m ON m.strFutMarketName = oc.strFutureMarket
		JOIN tblSMCurrency cu ON cu.intCurrencyID = m.intCurrencyId
		JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c) AND m.intUnitMeasureId = cuc1.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = oc.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
		WHERE th.intCommodityId IN (SELECT DISTINCT intCommodity FROM @Commodity c)
			AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
			AND ISNULL(oc.ysnPreCrush, 0) = 1) t

	IF NOT EXISTS (SELECT TOP 1 1 FROM @List WHERE intOrderId = 14)
	BEGIN
		INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
		SELECT 	TOP 1 strCommodityCode,0,'Near By' COLLATE Latin1_General_CI_AS,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,14,'Crush' COLLATE Latin1_General_CI_AS,'Buy' COLLATE Latin1_General_CI_AS FROM @List
	END
END

----------------

INSERT INTO @List (strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType = 'Net Hedge' COLLATE Latin1_General_CI_AS
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal = SUM(dblTotal)
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, 16
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @List WHERE intOrderId IN (12, 14, 15)
GROUP BY strCommodityCode
	, intCommodityId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, intFromCommodityUnitMeasureId
	, strAccountNumber
	, strTranType
	, intBrokerageAccountId
	, strInstrumentType
	, dblNoOfLot
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,23 intOrderId,'Net Unpriced Position' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure from @List where intOrderId in(19, 20, 21, 22)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,25 intOrderId,'Basis Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @List where intOrderId in(1, 2, 8, 19, 20)

INSERT INTO @List (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,26 intOrderId,'Price Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @List where intOrderId in(9, 16)

DECLARE @ListFinal AS TABLE (intRowNumber1 INT IDENTITY
	, intRowNumber INT
	, intContractHeaderId INT
	, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intFutOptTransactionHeaderId INT
	, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, intCommodityId INT
	, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
	, strType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strLocationName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strContractEndMonthNearBy NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, dblTotal DECIMAL(24, 10)
	, intSeqNo INT
	, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, intFromCommodityUnitMeasureId INT
	, intToCommodityUnitMeasureId INT
	, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strTranType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, dblNoOfLot NUMERIC(24, 10)
	, dblDelta NUMERIC(24, 10)
	, intBrokerageAccountId INT
	, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intOrderId int
	, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intItemId INT
	, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intCategoryId INT
	, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMarketId INT
	, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intFutureMonthId INT
	, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
	, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, ysnPreCrush BIT
	, strTransactionReferenceId NVARCHAR(100) COLLATE Latin1_General_CI_AS
	, intTransactionReferenceId INT
	, intTransactionReferenceDetailId INT
	)

DECLARE @MonthOrderList AS TABLE (		
		strContractEndMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS)

insert into @MonthOrderList
SELECT distinct  strContractEndMonth FROM @List where strContractEndMonth <> 'Near By' 

DECLARE @MonthOrderListFinal AS TABLE (		
		strContractEndMonth NVARCHAR(100))

INSERT INTO @MonthOrderListFinal 
SELECT 'Near By' COLLATE Latin1_General_CI_AS
INSERT INTO @MonthOrderListFinal 
SELECT  strContractEndMonth FROM @MonthOrderList ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) 

DECLARE @TopRowRec AS TABLE (		
		strType NVARCHAR(100) COLLATE Latin1_General_CI_AS,
		strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS)
INSERT INTO @TopRowRec 
SELECT TOP 1 strType,strCommodityCode from @List 

INSERT INTO @ListFinal(
		 strCommodityCode		
		,strType		
		,strContractEndMonth
		,dblTotal)
SELECT   strCommodityCode		
		,strType		
		,strContractEndMonth		
		,0.0 dblTotal
	FROM @TopRowRec t
	CROSS JOIN @MonthOrderListFinal t1
	
INSERT INTO @ListFinal(intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId)
SELECT intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId
FROM @List
WHERE (ISNULL(dblTotal,0) <> 0 OR strType = 'Crush') AND strContractEndMonth = 'Near By'

INSERT INTO @ListFinal(intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId)
SELECT intSeqNo
	, intRowNumber
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
	, strTransactionReferenceId
	, intTransactionReferenceId
	, intTransactionReferenceDetailId
FROM @List 
WHERE (ISNULL(dblTotal,0) <> 0 OR strType = 'Crush') and strContractEndMonth not in ( 'Near By') order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

UPDATE @ListFinal SET strFutureMonth = CASE 
	WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
	WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
	WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
END COLLATE Latin1_General_CI_AS
	, strDeliveryDate = CT.strDeliveryDate
FROM @ListFinal F
LEFT JOIN (
	SELECT intFutOptTransactionHeaderId
		,strInternalTradeNo
		,strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
	FROM vyuRKFutOptTransaction
)FOT ON FOT.intFutOptTransactionHeaderId = F.intFutOptTransactionHeaderId AND FOT.strInternalTradeNo COLLATE Latin1_General_CI_AS = F.strInternalTradeNo COLLATE Latin1_General_CI_AS
LEFT JOIN (
	SELECT intContractHeaderId
	,REPLACE(strSequenceNumber,' ','') COLLATE Latin1_General_CI_AS AS strContractNumber
	,dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') COLLATE Latin1_General_CI_AS AS strDeliveryDate
	,ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS AS strFutureMonth
	,strContractType
	FROM vyuCTContractDetailView
)CT ON CT.intContractHeaderId = F.intContractHeaderId
	AND CT.strContractNumber = (CASE WHEN PATINDEX('%,%', F.strContractNumber) = 0 THEN F.strContractNumber ELSE LEFT(F.strContractNumber, PATINDEX('%,%', F.strContractNumber) - 1)END)
	
UPDATE @ListFinal SET strContractEndMonthNearBy = CASE 
		WHEN @strPositionBy = 'Futures Month'  THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
		WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
		WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
	END

UPDATE @ListFinal SET strContractEndMonthNearBy = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''

INSERT INTO @ListFinal (strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, intOrderId
	, strType
	, strContractEndMonth
	, dblTotal
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush)
SELECT DISTINCT strCommodityCode
	, strContractNumber = NULL
	, intContractHeaderId = NULL
	, strInternalTradeNo = NULL
	, intFutOptTransactionHeaderId = NULL
	, intOrderId
	, strType
	, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
	, NULL
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @ListFinal
WHERE intOrderId IS NOT NULL

--==================================
-- Insert into temporary log table
--==================================
IF (ISNULL(@ysnLogDPR, 0) = 1)
BEGIN
--Get the Run Number
	DECLARE @intRunNumber INT
		, @strVendorCustomer NVARCHAR(200)
	
	IF @intVendorId IS NOT NULL 
	BEGIN
		SELECT @strVendorCustomer = strName FROM tblEMEntity WHERE intEntityId = @intVendorId
	END

	---- Delete Previous Log of same instance. This is just a refresh of the screen.
	--IF (ISNULL(@ysnRefresh, 0) = 1)
	--BEGIN
	--	SELECT * FROM tblRKTempDPRDetailLog
	--	WHERE CAST(FLOOR(CAST(dtmRunDateTime AS FLOAT)) AS DATETIME) = CAST(FLOOR(CAST(GETDATE() AS FLOAT)) AS DATETIME)
	--		AND intUserId = @intUserId
	--		AND dtmDPRDate = @dtmToDate
	--		AND strDPRPositionIncludes = @strPositionIncludes
	--		AND strDPRPositionBy = @strPositionBy
	--		AND strDPRPurchaseSale = @strPurchaseSales
	--		AND strDPRVendorCustomer = @strVendorCustomer
	--END

	SELECT TOP 1 @intRunNumber = ISNULL(MAX(intRunNumber),0) + 1 
	FROM tblRKTempDPRDetailLog

	INSERT INTO tblRKTempDPRDetailLog (intRunNumber 
		, dtmRunDateTime
		, intUserId
		, dtmDPRDate	
		, strDPRPositionIncludes	
		, strDPRPositionBy	
		, strDPRPurchaseSale
		, strDPRVendorCustomer
		, intSeqNo
		, strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intOrderId
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
		, strTransactionReferenceId
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
	)
	select 
			intRunNumber = @intRunNumber
		, dtmRunDateTime = GETDATE()
		, intUserId = @intUserId
		, dtmDPRDate = @dtmToDate	
		, strDPRPositionIncludes = @strPositionIncludes
		, strDPRPositionBy = @strPositionBy
		, strDPRPurchaseSale = @strPurchaseSales
		, strDPRVendorCustomer = @strVendorCustomer
		, intSeqNo
		, strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
		, intOrderId
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strDeliveryDate
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
		, strTransactionReferenceId
		, intTransactionReferenceId
		, intTransactionReferenceDetailId
	FROM @ListFinal
	WHERE intOrderId IS NOT NULL
		AND ((dblTotal IS NULL OR dblTotal <> 0) OR strType = 'Crush')
		AND dblTotal IS NOT NULL
	ORDER BY intOrderId
END


SELECT intSeqNo
	, intRowNumber = CONVERT(INT, ROW_NUMBER() OVER (ORDER BY intSeqNo)) 
	, strCommodityCode
	, strContractNumber
	, intContractHeaderId
	, strInternalTradeNo
	, intFutOptTransactionHeaderId
	, strType
	, strLocationName
	, strContractEndMonth
	, strContractEndMonthNearBy
	, dblTotal
	, strUnitMeasure
	, strAccountNumber
	, strTranType
	, dblNoOfLot
	, dblDelta
	, intBrokerageAccountId
	, strInstrumentType
	, strEntityName
	, intOrderId
	, intItemId
	, strItemNo
	, intCategoryId
	, strCategory
	, intFutureMarketId
	, strFutMarketName
	, intFutureMonthId
	, strFutureMonth
	, strDeliveryDate
	, strBrokerTradeNo
	, strNotes
	, ysnPreCrush
FROM @ListFinal WHERE ((dblTotal IS NULL OR dblTotal <> 0) OR strType = 'Crush')
ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME, '01 ' + strContractEndMonth) END
	, intOrderId
	, strType