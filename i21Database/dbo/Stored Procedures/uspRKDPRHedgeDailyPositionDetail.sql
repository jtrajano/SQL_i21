CREATE PROCEDURE [dbo].[uspRKDPRHedgeDailyPositionDetail] 
	@intCommodityId NVARCHAR(MAX)
	, @intLocationId INT = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(250) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL
	, @strPositionBy NVARCHAR(50) = NULL
AS

BEGIN
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

	IF (@intLocationId = 0) SET @intLocationId = NULL
	IF (@intVendorId = 0) SET @intVendorId = NULL

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE ISNULL(ysnLicensed, 0) END
	
	DECLARE @ysnIncludeDPPurchasesInCompanyTitled BIT
		, @ysnHideNetPayableAndReceivable BIT
		,@ysnPreCrush BIT
	
	SELECT @ysnIncludeDPPurchasesInCompanyTitled = ISNULL(ysnIncludeDPPurchasesInCompanyTitled, 0)
		, @ysnHideNetPayableAndReceivable = ISNULL(ysnHideNetPayableAndReceivable, 0)
		, @ysnPreCrush = ISNULL(ysnPreCrush, 0)
	FROM tblRKCompanyPreference
	
	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodity INT)
	
	IF (@strByType = 'ByCommodity')
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT intCommodityId FROM tblICCommodity
	END
	ELSE
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT Item COLLATE Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')
	END
	
	DECLARE @tempFinal AS TABLE (intRow INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(200)
		, strSubType NVARCHAR(200)
		, strContractType NVARCHAR(200)
		, strLocationName NVARCHAR(200)
		, strContractEndMonth NVARCHAR(200)
		, intInventoryReceiptItemId INT
		, intTicketId INT
		, strTicketType NVARCHAR(100)
		, strTicketNumber NVARCHAR(200)
		, dtmTicketDateTime DATETIME
		, strCustomerReference NVARCHAR(200)
		, strDistributionOption NVARCHAR(200)
		, dblUnitCost NUMERIC(24, 10)
		, dblQtyReceived NUMERIC(24, 10)
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, intCommodityId INT
		, strAccountNumber NVARCHAR(200)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(200)
		, intNoOfContract NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, strCurrency NVARCHAR(200)
		, intCompanyLocationId INT
		, intInvoiceId INT
		, strInvoiceNumber NVARCHAR(200)
		, intBillId INT
		, strBillId NVARCHAR(200)
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(200)
		, strShipmentNumber NVARCHAR(200)
		, intInventoryShipmentId INT
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT
		, intContractTypeId INT
		, strEntityName NVARCHAR(100)
		, strDeliveryDate NVARCHAR(100))
	
	DECLARE @Final AS TABLE (intRow INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200)
		, strCommodityCode NVARCHAR(200)
		, strType NVARCHAR(200)
		, strSubType NVARCHAR(200)
		, strContractType NVARCHAR(200)
		, strLocationName NVARCHAR(200)
		, strContractEndMonth NVARCHAR(200)
		, intInventoryReceiptItemId INT
		, intTicketId INT
		, strTicketType NVARCHAR(100)
		, strTicketNumber NVARCHAR(200)
		, dtmTicketDateTime DATETIME
		, strCustomerReference NVARCHAR(200)
		, strDistributionOption NVARCHAR(200)
		, dblUnitCost NUMERIC(24, 10)
		, dblQtyReceived NUMERIC(24, 10)
		, dblTotal DECIMAL(24,10)
		, strUnitMeasure NVARCHAR(200)
		, intSeqNo INT
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, intCommodityId INT
		, strAccountNumber NVARCHAR(200)
		, strTranType NVARCHAR(20)
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(200)
		, intNoOfContract NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, strCurrency NVARCHAR(200)
		, intInvoiceId INT
		, strInvoiceNumber NVARCHAR(200)
		, intBillId INT
		, strBillId NVARCHAR(200)
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(200)
		, strShipmentNumber NVARCHAR(200)
		, intInventoryShipmentId INT
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT
		, intContractTypeId INT
		, strEntityName NVARCHAR(100)
		, strDeliveryDate NVARCHAR(100))
	
	DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
		, strCommodityCode NVARCHAR(200)
		, intCommodityId INT
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200)
		, strLocationName NVARCHAR(200)
		, dtmEndDate DATETIME
		, dblBalance DECIMAL(24,10)
		, intUnitMeasureId INT
		, intPricingTypeId INT
		, intContractTypeId INT
		, intCompanyLocationId INT
		, strContractType NVARCHAR(200)
		, strPricingType NVARCHAR(200)
		, intContractDetailId INT
		, intContractStatusId INT
		, intEntityId INT
		, intCurrencyId INT
		, strType NVARCHAR(200)
		, intItemId INT
		, strItemNo NVARCHAR(200)
		, strCategory NVARCHAR(200)
		, dtmContractDate datetime
		, strEntityName NVARCHAR(200)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT
		, strCurrency NVARCHAR(200))
	
	INSERT INTO @tblGetOpenContractDetail(intRowNum
		, strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber
		, strLocationName
		, dtmEndDate
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
		, strCategory
		, strEntityName
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strCurrency)
	SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC)
		, strCommodityCode = CD.strCommodity
		, intCommodityId
		, intContractHeaderId
		, strContractNumber = CD.strContract
		, strLocationName
		--, dtmEndDate = (CASE WHEN ISNULL(strFutureMonth,'') <> '' THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) ELSE dtmEndDate END)
		, dtmEndDate
		, dblBalance = CD.dblQuantity
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCompanyLocationId
		, strContractType
		, strPricingType
		, CD.intContractDetailId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strType = CD.strContractType + ' ' + CD.strPricingType
		, intItemId
		, strItemNo
		, strCategory
		, strEntityName = CD.strCustomer
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strCurrency
	FROM dbo.fnCTGetContractBalance(null,null,null,'01-01-1900',@dtmToDate,NULL,NULL,NULL,NULL) CD
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
	
	DECLARE @tblGetOpenFutureByDate TABLE (intRowNum INT
		, dtmTransactionDate DATETIME
		, intFutOptTransactionId INT
		, intOpenContract INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblContractSize NUMERIC(24,10)
		, strFutureMarket NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strFutureMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strOptionMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblStrike NUMERIC(24,10)
		, strOptionType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strBrokerAccount NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strBroker NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strNewBuySell NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, intFutureMarketId INT
		, intFutureMonthId INT
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	
	INSERT INTO @tblGetOpenFutureByDate
	SELECT *
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intFutOptTransactionId ORDER BY dtmTransactionDate DESC)
			, *
		FROM (
			--Futures Buy
			SELECT FOT.dtmTransactionDate
				, intFutOptTransactionId
				, intOpenContract
				, FOT.strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, FOT.dblContractSize
				, FOT.strFutMarketName
				, FOT.strFutureMonth AS strFutureMonth
				, FOT.strOptionMonthYear AS strOptionMonth
				, dblStrike
				, strOptionType
				, FOT.strInstrumentType
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.intFutureMarketId
				, FOT.intFutureMonthId
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			WHERE FOT.strBuySell = 'Buy' AND FOT.strInstrumentType = 'Futures'
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--AND ISNULL(FOT.ysnPreCrush, 0) = 0
			
			UNION ALL
			--Futures Sell
			SELECT FOT.dtmTransactionDate
				, intFutOptTransactionId
				, intOpenContract
				, FOT.strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, FOT.dblContractSize
				, FOT.strFutMarketName
				, FOT.strFutureMonth AS strFutureMonth
				, FOT.strOptionMonthYear AS strOptionMonth
				, dblStrike
				, strOptionType
				, FOT.strInstrumentType
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.intFutureMarketId
				, FOT.intFutureMonthId
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Futures'
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--AND ISNULL(FOT.ysnPreCrush, 0) = 0
			
			UNION ALL
			--Options Buy
			SELECT FOT.dtmTransactionDate
				, intFutOptTransactionId
				, intOpenContract
				, FOT.strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, FOT.dblContractSize
				, FOT.strFutMarketName
				, FOT.strFutureMonth AS strFutureMonth
				, FOT.strOptionMonthYear AS strOptionMonth
				, dblStrike
				, strOptionType
				, FOT.strInstrumentType
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.intFutureMarketId
				, FOT.intFutureMonthId
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			WHERE FOT.strBuySell = 'BUY' AND FOT.strInstrumentType = 'Options'
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--AND ISNULL(FOT.ysnPreCrush, 0) = 0
				
			UNION ALL
			--Options Sell
			SELECT FOT.dtmTransactionDate
				, intFutOptTransactionId
				, intOpenContract
				, FOT.strCommodityCode
				, strInternalTradeNo
				, strLocationName
				, FOT.dblContractSize
				, FOT.strFutMarketName
				, FOT.strFutureMonth AS strFutureMonth
				, FOT.strOptionMonthYear AS strOptionMonth
				, dblStrike
				, strOptionType
				, FOT.strInstrumentType
				, FOT.strBrokerageAccount AS strBrokerAccount
				, FOT.strName AS strBroker
				, strBuySell
				, FOTH.intFutOptTransactionHeaderId
				, FOT.intFutureMarketId
				, FOT.intFutureMonthId
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM tblRKFutOptTransactionHeader FOTH
			INNER JOIN vyuRKFutOptTransaction FOT ON FOTH.intFutOptTransactionHeaderId = FOT.intFutOptTransactionHeaderId
			WHERE FOT.strBuySell = 'Sell' AND FOT.strInstrumentType = 'Options'
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), FOT.dtmTransactionDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--AND ISNULL(FOT.ysnPreCrush, 0) = 0
		)t2 
	)t3 WHERE t3.intRowNum = 1

	SELECT *
	INTO #tblGetStorageDetailByDate
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC)
			, a.intCustomerStorageId
			, a.intCompanyLocationId
			, c.strLocationName
			, dtmDeliveryDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), a.dtmDeliveryDate, 110), 110)
			, a.intEntityId
			, strCustomerName = E.strName
			, strReceipt = a.strDPARecieptNumber
			, a.dblDiscountsDue
			, a.dblStorageDue
			, dblBalance = (CASE WHEN gh.strType = 'Reduced By Inventory Shipment' THEN - gh.dblUnits ELSE gh.dblUnits END)
			, a.intStorageTypeId
			, strStorageType = b.strStorageTypeDescription
			, a.intCommodityId
			, CM.strCommodityCode
			, strCommodityDescription = CM.strDescription
			, b.strOwnedPhysicalStock
			, b.ysnReceiptedStorage
			, b.ysnDPOwnedType
			, b.ysnGrainBankType
			, ysnCustomerStorage = b.ysnActive
			, a.strCustomerReference
			, a.dtmLastStorageAccrueDate
			, c1.strScheduleId
			, ium.intCommodityUnitMeasureId
			, i.intItemId
			, i.strItemNo
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
								WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
								WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
								ELSE gh.intCustomerStorageId END)
			, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
								WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
								WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
								ELSE 'Customer/Maintain Storage' END)
			, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
								WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
								WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
								ELSE a.strStorageTicketNumber END)
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
		JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
		WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND i.intCommodityId IN (SELECT intCommodity FROM @Commodity)
	
		UNION ALL
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC)
			, a.intCustomerStorageId
			, a.intCompanyLocationId
			, c.strLocationName
			, dtmDeliveryDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), a.dtmDeliveryDate, 110), 110)
			, a.intEntityId
			, strCustomerName = E.strName
			, strReceipt = a.strDPARecieptNumber
			, dblDiscDue = a.dblDiscountsDue
			, dblStorageDue = a.dblStorageDue
			, dblBalance = (CASE WHEN gh.strType = 'Reduced By Inventory Shipment' THEN - gh.dblUnits ELSE gh.dblUnits END)
			, a.intStorageTypeId
			, strStorageType = b.strStorageTypeDescription
			, a.intCommodityId
			, CM.strCommodityCode
			, strCommodityDescription = CM.strDescription
			, b.strOwnedPhysicalStock
			, b.ysnReceiptedStorage
			, b.ysnDPOwnedType
			, b.ysnGrainBankType
			, ysnCustomerStorage = b.ysnActive
			, a.strCustomerReference
			, a.dtmLastStorageAccrueDate
			, c1.strScheduleId
			, ium.intCommodityUnitMeasureId
			, i.intItemId
			, i.strItemNo
			, Category.intCategoryId
			, strCategory = Category.strCategoryCode
			, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
								WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
								WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
								ELSE gh.intCustomerStorageId END)
			, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
								WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
								WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
								ELSE 'Customer/Maintain Storage' END)
			, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN NULL
								WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
								WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
								ELSE a.strStorageTicketNumber END)
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
		WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND i.intCommodityId IN (SELECT intCommodity FROM @Commodity)
	) t
	
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
		, t.strTicketNumber
		, s.strLocationName
		, s.strItemNo
		, i.intCommodityId
		, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
		, s.intLocationId
		, strTransactionId
		, strTransactionType
		, i.intItemId
		, s.intCategoryId
		, s.strCategory
		, s.strCurrency
	INTO #invQty
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i ON i.intItemId = s.intItemId
	JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
	LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
	WHERE i.intCommodityId IN (SELECT intCommodity FROM @Commodity)
		AND ysnInTransit = 0 AND ISNULL(s.dblQuantity, 0) <> 0
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
		AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		AND ISNULL(strDistributionOption,'') <> CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN '@#$%' ELSE 'DP' END
	
	SELECT * INTO #tempCollateral
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmOpenDate DESC)
			, c.intCollateralId
			, cl.strLocationName
			, ch.intItemId
			, ch.strItemNo
			, ch.strCategory
			, ch.strEntityName
			, c.intReceiptNo
			, ch.intContractHeaderId
			, strContractNumber
			, c.dtmOpenDate
			, dblOriginalQuantity = ISNULL(c.dblOriginalQuantity, 0)
			, dblRemainingQuantity = ISNULL(c.dblRemainingQuantity, 0)
			, c.intCommodityId as intCommodityId
			, c.intUnitMeasureId
			, c.intLocationId intCompanyLocationId
			, intContractTypeId = CASE WHEN c.strType = 'Purchase' THEN 1 ELSE 2 END
			, c.intLocationId
			, intEntityId
			, ch.intFutureMarketId
			, ch.strFutMarketName
			, ch.intFutureMonthId
			, ch.strFutureMonth
		FROM tblRKCollateral c
		JOIN tblICCommodity co ON co.intCommodityId = c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
		WHERE c.intCommodityId IN (SELECT intCommodity FROM @Commodity)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND c.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	) a where a.intRowNum = 1
	
	DECLARE @mRowNumber INT
		, @intCommodityId1 INT
		, @strCommodityCode NVARCHAR(200)
		, @intOneCommodityId INT
		, @intCommodityUnitMeasureId INT
		, @intUnitMeasureId INT
		, @ysnExchangeTraded BIT
		, @strUnitMeasure NVARCHAR(200)
		
	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
	
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strCommodityCode = strCommodityCode
			, @ysnExchangeTraded = ysnExchangeTraded
		FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
		
		IF (@intCommodityId > 0)
		BEGIN
			IF ISNULL(@intVendorId,0) = 0
			BEGIN
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate)
				SELECT strCommodityCode
						, intContractHeaderId
						, strContractNumber
						, strType
						, strContractType
						, strLocationName
						, strContractEndMonth
						, dblTotal
						, intUnitMeasureId
						, intCommodityId
						, intCompanyLocationId
						, strCurrency
						, intContractTypeId
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strEntityName
						, strDeliveryDate
				FROM (
					SELECT DISTINCT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, cd.strType
						, strContractType = 'Physical Contract'
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
						, dblTotal =  ISNULL((cd.dblBalance), 0)
						, cd.intUnitMeasureId
						, intCommodityId = @intCommodityId
						, cd.intCompanyLocationId
						, strCurrency
						, intContractTypeId
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, intContractDetailId
						, strEntityName
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId IN (1,2) AND cd.intCommodityId = @intCommodityId
						AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN cd.intCompanyLocationId ELSE @intLocationId END
				) t WHERE intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				-- Hedge
				INSERT INTO @tempFinal (strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strAccountNumber
					, strTranType
					, intBrokerageAccountId
					, strInstrumentType
					, dblNoOfLot
					, strCurrency
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, 'Net Hedge'
					, strContractType = 'Future'
					, strLocationName
					, strFutureMonth
					, HedgedQty
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, intCommodityId = @intCommodityId
					, strAccountNumber
					, strTranType
					, intBrokerageAccountId
					, strInstrumentType
					, dblNoOfLot
					, strCurrency
					, intFutureMarketId
					, strFutureMarket
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM (
					SELECT DISTINCT t.strCommodityCode
						, strInternalTradeNo
						, t.intFutOptTransactionHeaderId
						, th.intCommodityId
						, dtmFutureMonthsDate
						, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, intOpenContract * t.dblContractSize)
						, l.strLocationName
						, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear)
						, m.intUnitMeasureId
						, strAccountNumber = t.strBroker + '-' + t.strBrokerAccount
						, strTranType = strNewBuySell
						, ba.intBrokerageAccountId
						, strInstrumentType = 'Future'
						, dblNoOfLot = intOpenContract
						, cu.strCurrency
						, t.intFutureMarketId
						, t.strFutureMarket
						, t.intFutureMonthId
						, t.strBrokerTradeNo
						, t.strNotes
						, t.ysnPreCrush
					FROM @tblGetOpenFutureByDate t
					JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
					JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
					JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
					JOIN tblSMCurrency cu ON cu.intCurrencyID = m.intCurrencyId
					LEFT JOIN tblRKBrokerageAccount ba ON ba.strAccountNumber = t.strBrokerAccount
					INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Futures'
					JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
					INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
					WHERE th.intCommodityId = @intCommodityId
						AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
						AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
						AND ISNULL(t.ysnPreCrush, 0) = 0
				) t
				
				-- Option NetHEdge
				INSERT INTO @tempFinal (strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, strCurrency
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT DISTINCT t.strCommodityCode
					, t.strInternalTradeNo
					, intFutOptTransactionHeaderId
					, 'Net Hedge'
					, 'Option'
					, t.strLocationName
					, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear)
					, dblNoOfContract = intOpenContract * ISNULL((SELECT TOP 1 dblDelta
																FROM tblRKFuturesSettlementPrice sp
																INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
																WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
																	AND t.dblStrike = mm.dblStrike
																ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize
					, m.intUnitMeasureId
					, th.intCommodityId
					, strAccountNumber = e.strName + '-' + strAccountNumber
					, strTranType = strNewBuySell
					, dblNoOfLot = intOpenContract
					, dblDelta = ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND t.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
					, ba.intBrokerageAccountId
					, strInstrumentType = 'Option'
					, strCurrency
					, t.intFutureMarketId
					, t.strFutureMarket
					, t.intFutureMonthId
					, t.strFutureMonth
					, t.strBrokerTradeNo
					, t.strNotes
					, t.ysnPreCrush
				FROM @tblGetOpenFutureByDate t
				JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
				JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
				JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
				JOIN tblSMCurrency cu ON cu.intCurrencyID = m.intCurrencyId
				JOIN tblRKOptionsMonth om ON om.strOptionMonth = t.strOptionMonth
				INNER JOIN tblRKBrokerageAccount ba ON t.strBrokerAccount = ba.strAccountNumber
				INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Options'
				INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId AND fm.ysnExpired = 0
				WHERE th.intCommodityId = @intCommodityId
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
					AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
					AND ISNULL(t.ysnPreCrush, 0) = 0

				
				IF @ysnPreCrush = 1 AND ISNULL(@strPositionBy,'') <> ''
				BEGIN
					--Crush Records
					INSERT INTO @tempFinal(strCommodityCode
						, strInternalTradeNo
						, intFutOptTransactionHeaderId
						, strType
						, strContractType
						, strLocationName
						, strContractEndMonth
						, dblTotal
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strAccountNumber
						, strTranType
						, intBrokerageAccountId
						, strInstrumentType
						, dblNoOfLot
						--, strCurrency
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush)
					SELECT strCommodityCode
						, strInternalTradeNo
						, intFutOptTransactionHeaderId
						, 'Crush'
						, strContractType = 'Crush'
						, strLocationName
						, strFutureMonth
						, HedgedQty
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
						, intCommodityId = @intCommodityId
						, strAccountNumber
						, strTranType
						, intBrokerageAccountId
						, strInstrumentType
						, dblNoOfLot
						--, strCurrency
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
							, f.intCommodityId
							, cuc1.intCommodityUnitMeasureId
							, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
									else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end dtmFutureMonthsDate
							, dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0)
																																			ELSE ISNULL(intOpenContract, 0) END * m.dblContractSize) AS HedgedQty
							, l.strLocationName
							, case when CONVERT(DATETIME, '01 ' + fm.strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
									else left(fm.strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end strFutureMonth
							, m.intUnitMeasureId
							, e.strName + '-' + ba.strAccountNumber strAccountNumber
							, strBuySell AS strTranType
							, f.intBrokerageAccountId
							,CASE WHEN f.intInstrumentTypeId = 1 THEN 'Futures' ELSE 'Options ' END AS strInstrumentType
							,CASE WHEN f.strBuySell = 'Buy' THEN ISNULL(intOpenContract, 0) ELSE ISNULL(intOpenContract, 0) END dblNoOfLot
							, f.intFutureMarketId
							, oc.strFutureMarket
							, f.intFutureMonthId
							, oc.strBrokerTradeNo
							, oc.strNotes
							, oc.ysnPreCrush
						FROM @tblGetOpenFutureByDate oc
						JOIN tblRKFutOptTransaction f ON oc.intFutOptTransactionId = f.intFutOptTransactionId AND oc.intOpenContract <> 0 and isnull(f.ysnPreCrush,0)=1
						INNER JOIN tblRKFutureMarket m ON f.intFutureMarketId = m.intFutureMarketId
						JOIN tblICCommodityUnitMeasure cuc1 ON f.intCommodityId = cuc1.intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
						INNER JOIN tblRKFuturesMonth fm ON fm.intFutureMonthId = f.intFutureMonthId
						INNER JOIN tblSMCompanyLocation l ON f.intLocationId = l.intCompanyLocationId
						AND intCompanyLocationId IN (
							SELECT intCompanyLocationId
							FROM tblSMCompanyLocation
							WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END)
						INNER JOIN tblRKBrokerageAccount ba ON f.intBrokerageAccountId = ba.intBrokerageAccountId
						INNER JOIN tblEMEntity e ON e.intEntityId = f.intEntityId AND f.intInstrumentTypeId = 1
						WHERE f.intCommodityId = @intCommodityId
							AND f.intLocationId = ISNULL(@intLocationId, f.intLocationId)
					) t

					--Include Crush in Price Risk
					INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intContractHeaderId
						, strContractNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intFutOptTransactionHeaderId
						, strInternalTradeNo

						)
					SELECT strCommodityCode
						, 'Price Risk'
						, strContractType
						, dblTotal
						, intContractHeaderId
						, strContractNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intFutOptTransactionHeaderId
						, strInternalTradeNo
					FROM @tempFinal
					WHERE intCommodityId = @intCommodityId AND strType  = 'Crush'

				END

				-- Net Hedge option end
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency)
				SELECT DISTINCT @strCommodityCode
					, strType = 'Price Risk'
					, strContractType = 'Inventory'
					, dblTotal = SUM(dblTotal)
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
				FROM #invQty
				WHERE intCommodityId = @intCommodityId AND @ysnExchangeTraded = 1
					AND intLocationId = ISNULL(@intLocationId, intLocationId)
				GROUP BY intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFromCommodityUnitMeasureId
					, strLocationName
					, intCommodityId
					, strCurrency


				--Net Hedge Derivative Entry (Futures AND Options)
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intFutOptTransactionHeaderId
					, strInternalTradeNo

					)
				SELECT strCommodityCode
					, 'Price Risk'
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
				FROM @tempFinal
				WHERE intCommodityId = @intCommodityId AND strType  = 'Net Hedge' AND @ysnExchangeTraded = 1


				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intInventoryReceiptId
					, strReceiptNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth)
				SELECT @strCommodityCode
					, strType = 'Price Risk'
					, strContractType = 'PurBasisDelivary'
					, - SUM(dblTotal)
					, intInventoryReceiptId
					, strReceiptNumber
					, intCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
				FROM (
					SELECT dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(v.dblQuantity, 0))
						, r.intInventoryReceiptId
						, strReceiptNumber
						, ium.intCommodityUnitMeasureId
						, cd.intCommodityId
						, cd.strLocationName
						, cd.intCompanyLocationId
						, cd.strCurrency
						, cd.intItemId
						, cd.strItemNo
						, cd.strCategory
						, cd.intFutureMarketId
						, cd.strFutMarketName
						, cd.intFutureMonthId
						, cd.strFutureMonth
					FROM vyuRKGetInventoryValuation v
					JOIN tblICInventoryReceipt r ON r.strReceiptNumber = v.strTransactionId
					INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
					INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId AND strDistributionOption IN ('CNT') AND ISNULL(ysnInTransit, 0) = 0
					INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId=cd.intCommodityId AND cd.intUnitMeasureId=ium.intUnitMeasureId
					INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
					WHERE v.strTransactionType = 'Inventory Receipt' AND cd.intCommodityId = @intCommodityId AND ISNULL(strTicketStatus,'') <> 'V'
						AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				GROUP BY intInventoryReceiptId
					, strReceiptNumber
					, intCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
				
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate)
				SELECT strCommodityCode
					, strType = 'Price Risk'
					, strContractType = 'Open Contract'
					, dblTotal = CASE WHEN intContractTypeId = 1 THEN SUM(dblTotal) ELSE - SUM(dblTotal) END
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate
				FROM (
					SELECT strCommodityCode
						, dblTotal = ISNULL(cd.dblTotal, 0)
						, intContractHeaderId
						, strContractNumber
						, cd.intCommodityId
						, strLocationName
						, intCompanyLocationId
						, intContractTypeId
						, strCurrency
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strEntityName
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmTicketDateTime, 106), 8)
					FROM @tempFinal cd
					WHERE cd.intCommodityId = @intCommodityId and strType IN('Sale Priced', 'Purchase Priced') 
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
				) t	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				GROUP BY strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strLocationName
					, intContractTypeId
					, strCurrency
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate
				
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth)
				SELECT @strCommodityCode
					, strType = 'Price Risk'
					, strContractType = 'Collateral'
					, dblTotal = SUM(dblRemainingQuantity)
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
				FROM(
					SELECT dblRemainingQuantity = CASE WHEN ISNULL(intContractTypeId, 1) = 2 THEN - dblRemainingQuantity ELSE dblRemainingQuantity END
						, intContractHeaderId
						, strContractNumber
						, intFromCommodityUnitMeasureId = intUnitMeasureId
						, intCommodityId
						, strLocationName
						, intCollateralId
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
					FROM #tempCollateral c1
					WHERE c1.intLocationId = ISNULL(@intLocationId, c1.intLocationId)
				) t GROUP BY intCommodityId
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
				
				--INSERT INTO @tempFinal(strCommodityCode
				--	, strType
				--	, strContractType
				--	, dblTotal
				--	, strShipmentNumber
				--	, intInventoryShipmentId
				--	, intFromCommodityUnitMeasureId
				--	, intCommodityId
				--	, strLocationName
				--	, strCurrency
				--	, intItemId
				--	, strItemNo
				--	, strCategory
				--	, intFutureMarketId
				--	, strFutMarketName
				--	, intFutureMonthId
				--	, strFutureMonth
				--	, strDeliveryDate)
				--SELECT DISTINCT strCommodityCode
				--	, strType = 'Price Risk'
				--	, strContractType = 'Sales Basis Deliveries'
				--	, dblTotal = ISNULL(ri.dblQuantity, 0)
				--	, r.strShipmentNumber
				--	, r.intInventoryShipmentId
				--	, intFromCommodityUnitMeasureId = ium.intCommodityUnitMeasureId
				--	, cd.intCommodityId
				--	, cl.strLocationName
				--	, cd.strCurrency
				--	, cd.intItemId
				--	, cd.strItemNo
				--	, cd.strCategory
				--	, cd.intFutureMarketId
				--	, cd.strFutMarketName
				--	, cd.intFutureMonthId
				--	, cd.strFutureMonth
				--	, dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
				--FROM vyuRKGetInventoryValuation v
				--JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
				--INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
				--INNER JOIN @tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
				--JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
				--INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
				--LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				--INNER JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
				--WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
				--	AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
				--	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--	AND ISNULL(inv.ysnPosted, 0) = 0
				--	AND @ysnExchangeTraded = 1
				--	and cl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				IF ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled FROM tblRKCompanyPreference) = 1)
				BEGIN
					INSERT INTO @tempFinal(strCommodityCode
						, strType
						, strContractType
						, dblTotal
						, intTicketId
						, strTicketType
						, strTicketNumber
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName)
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'OffSite'
						, dblTotal = SUM(dblTotal)
						, intTicketId
						, strTicketType
						, strTicketNumber
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
					FROM (
						SELECT intTicketId
							, strTicketType
							, strTicketNumber
							, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblBalance, 0))
							, CH.intCompanyLocationId
							, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, intItemId
							, strItemNo
							, intCategoryId
							, strCategory
						FROM #tblGetStorageDetailByDate CH
						WHERE ysnCustomerStorage = 1
							AND strOwnedPhysicalStock = 'Company'
							AND ysnDPOwnedType <> 1
							AND CH.intCommodityId  = @intCommodityId
							AND CH.intCompanyLocationId = ISNULL(@intLocationId, CH.intCompanyLocationId)
						) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1
					) GROUP BY intTicketId
						, strTicketType
						, strTicketNumber
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
				END
				
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT strCommodityCode
					, strType = 'Basis Risk'
					, strContractType
					, dblTotal = SUM(dblTotal)
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM @tempFinal WHERE strType = 'Price Risk' AND strContractType IN ('Inventory', 'Collateral', 'DP', 'Sales Basis Deliveries', 'OffSite') AND @ysnExchangeTraded = 1
				GROUP BY strCommodityCode
					, strContractType
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate)
				SELECT strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal = SUM(dblTotal)
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				FROM (
					SELECT strCommodityCode
						, intContractHeaderId
						, strContractNumber
						, strType = 'Basis Risk'
						, strContractType
						, strLocationName
						, strContractEndMonth
						, dblTotal = (CASE WHEN intContractTypeId = 1 THEN (dblTotal) ELSE - (dblTotal) END)
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, intCompanyLocationId
						, strCurrency
						, intContractTypeId
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strBrokerTradeNo
						, strNotes
						, ysnPreCrush
						, strEntityName
						, strDeliveryDate
					FROM @tempFinal
					WHERE strContractType IN ('Physical Contract') AND strType IN ('Purchase Priced', 'Purchase Basis', 'Sale Priced', 'Sale Basis')
				) t GROUP BY strType
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strContractType
					, strLocationName
					, strContractEndMonth
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intBillId
					, strBillId
					, strCustomerReference)
				SELECT @strCommodityCode
					, strType = 'Net Payable ($)'
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strDistributionOption
					, dblUnitCost1
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intBillId
					, strBillId
					, strCustomerReference
				FROM (
					SELECT DISTINCT B.intBillId
						, strBillId
						, strLocationName
						, t.strTicketNumber
						, t.dtmTicketDateTime
						, strDistributionOption
						, dblUnitCost = dblCost
						, dblQtyReceived = SUM(BD.dblQtyReceived) OVER (PARTITION BY B.intBillId)
						, dblTotal = SUM(B.dblTotal) OVER (PARTITION BY B.intBillId)
						, BD.dblCost
						, dblAmountDue
						, dblCost dblUnitCost1
						, c.intCommodityId
						, intContractHeaderId = NULL
						, strContractNumber = NULL
						, Cur.strCurrency
						, strCustomerReference = strName
					FROM tblAPBill B
					JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
					JOIN tblICItem I ON BD.intItemId = I.intItemId AND BD.intInventoryReceiptChargeId IS NULL AND I.strType = 'Inventory'
					JOIN tblICCommodity c ON I.intCommodityId = c.intCommodityId
					JOIN tblSMCurrency Cur ON B.intCurrencyId = Cur.intCurrencyID
					JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = B.intShipToId
					LEFT JOIN tblSCTicket t ON BD.intScaleTicketId = t.intTicketId
					LEFT JOIN tblEMEntity e ON t.intEntityId = e.intEntityId
					WHERE B.ysnPosted = 1 AND c.intCommodityId = @intCommodityId AND ISNULL(strTicketStatus, '') <> 'V'
						AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), B.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				)t WHERE dblTotal <> 0
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber)
				SELECT @strCommodityCode
					, strType = 'Net Receivable ($)'
					, I.dblAmountDue
					, L.strLocationName
					, CT.intContractHeaderId 
					, CT.strContractNumber 
					, T.strTicketNumber
					, I.dtmDate
					, E.strName
					, strDistributionOption = ''
					, dblUCost = null
					, dblQtyReceived = SUM(ID.dblQtyShipped)
					, intCommodityId
					, Cur.strCurrency
					, I.intInvoiceId
					, I.strInvoiceNumber
				FROM tblARInvoice I
				INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId AND intInventoryShipmentChargeId IS NULL
				INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
				INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
				INNER JOIN tblEMEntity E ON I.intEntityCustomerId = E.intEntityId
				INNER JOIN tblSMCurrency Cur ON I.intCurrencyId = Cur.intCurrencyID
				OUTER APPLY( 
				    SELECT TOP 1 intTicketId, intItemId, CONTRACT.intContractHeaderId, strContractNumber = TICKET.strContractNumber + '-' + CONVERT(NVARCHAR(100), intContractSequence)  
					FROM vyuSCTicketView TICKET
					LEFT JOIN (
						SELECT intContractHeaderId, strContractNumber FROM tblCTContractHeader
					)CONTRACT ON TICKET.strContractNumber = CONTRACT.strContractNumber
					WHERE TICKET.strTicketNumber = T.strTicketNumber
				) CT 
				WHERE I.ysnPosted = 1
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND dblAmountDue <> 0 AND intCommodityId = @intCommodityId
					AND L.intCompanyLocationId = ISNULL(@intLocationId, L.intCompanyLocationId)
					AND L.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY I.dblAmountDue
					, L.strLocationName
					, T.strTicketNumber
					, I.dtmDate
					, E.strName
					, intCommodityId
					, Cur.strCurrency
					, I.intInvoiceId
					, I.strInvoiceNumber
					, CT.intContractHeaderId
					, CT.strContractNumber
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intBillId
					, strBillId
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT strCommodityCode
					, strType = 'NP Un-Paid Quantity'
					, dblQtyReceived
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intBillId
					, strBillId
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM @tempFinal WHERE strType = 'Net Payable ($)' AND intCommodityId = @intCommodityId
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intInventoryReceiptItemId
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intInvoiceId
					, strInvoiceNumber
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT @strCommodityCode
					, strType = 'NR Un-Paid Quantity'
					, dblQtyReceived
					, intInventoryReceiptItemId
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intInvoiceId
					, strInvoiceNumber
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM @tempFinal WHERE strType = 'Net Receivable ($)' AND intCommodityId = @intCommodityId
				
				INSERT INTO @tempFinal(strCommodityCode
					, strType
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
					, strContractEndMonth)
				SELECT strCommodityCode
					, strType = 'Avail for Spot Sale'
					, strContractType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strShipmentNumber
					, intInventoryShipmentId
					, intTicketId
					, strTicketNumber
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, strCurrency
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
					, strContractEndMonth
				FROM @tempFinal WHERE strType = 'Basis Risk' AND intCommodityId = @intCommodityId AND @ysnExchangeTraded = 1
				
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, strCurrency
					, intContractTypeId
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate)
				SELECT *
				FROM (
					SELECT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, strType = 'Avail for Spot Sale'
						, strContractType
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
						, dblTotal = - (cd.dblBalance)
						, cd.intUnitMeasureId
						, intCommodityId = @intCommodityId
						, cd.intCompanyLocationId
						, strCurrency
						, intContractTypeId
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strEntityName
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
					FROM @tblGetOpenContractDetail cd
					WHERE intContractTypeId = 1 AND strType IN ('Purchase Priced','Purchase Basis') AND cd.intCommodityId = @intCommodityId
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				
				SELECT @intUnitMeasureId = NULL
				SELECT @strUnitMeasure = NULL
				SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
				SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId

				INSERT INTO @Final (intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strContractType
					, strContractEndMonth
					, dblTotal
					, strUnitMeasure
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intInventoryReceiptId
					, strReceiptNumber
					, intTicketId
					, strShipmentNumber
					, intInventoryShipmentId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate)
				SELECT t.intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strContractType
					, strContractEndMonth
					, dblTotal = (CASE WHEN (ISNULL(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN dblTotal ELSE CONVERT(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, cuc1.intCommodityUnitMeasureId, dblTotal)) END)
					, strUnitMeasure = (CASE WHEN ISNULL(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END)
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intInventoryReceiptId
					, strReceiptNumber
					, intTicketId
					, strShipmentNumber
					, intInventoryShipmentId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				FROM @tempFinal t
				JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND strType NOT IN ('Net Payable ($)', 'Net Receivable ($)')
				
				INSERT INTO @Final (intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strContractType
					, strContractEndMonth
					, dblTotal
					, strUnitMeasure
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intInventoryReceiptId
					, strReceiptNumber
					, intTicketId
					, strShipmentNumber
					, intInventoryShipmentId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate)
				SELECT t.intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strContractType
					, strContractEndMonth
					, dblTotal
					, strUnitMeasure = (CASE WHEN ISNULL(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END)
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intInventoryReceiptId
					, strReceiptNumber
					, intTicketId
					, strShipmentNumber
					, intInventoryShipmentId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				FROM @tempFinal t
				JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND strType IN ('Net Payable ($)', 'Net Receivable ($)')
			END
			ELSE--==================== Specific Customer/Vendor =================================================
			BEGIN
				INSERT INTO @tempFinal (strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, strType
					, strSubType
					, strContractType
					, strLocationName
					, strContractEndMonth
					, dblTotal
					, intFromCommodityUnitMeasureId
					, intCommodityId
					, intCompanyLocationId
					, intItemId
					, strItemNo
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strEntityName
					, strDeliveryDate)
				SELECT *
				FROM (
					SELECT cd.strCommodityCode
						, cd.intContractHeaderId
						, strContractNumber
						, cd.strType
						, strSubType = strType
						, strContractType = 'Physical'
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
						, dblTotal = ISNULL((cd.dblBalance), 0)
						, cd.intUnitMeasureId
						, intCommodityId = @intCommodityId
						, cd.intCompanyLocationId
						, intItemId
						, strItemNo
						, strCategory
						, intFutureMarketId
						, strFutMarketName
						, intFutureMonthId
						, strFutureMonth
						, strEntityName
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId IN (1, 2)
						AND cd.intCommodityId IN (SELECT intCommodityId FROM @Commodity)
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
						AND intEntityId = @intVendorId
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intBillId
					, strBillId
					, strCustomerReference
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory)
				SELECT @strCommodityCode
					, strType = 'Net Payable ($)'
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strDistributionOption
					, dblUnitCost1
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intBillId
					, strBillId
					, strCustomerReference
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
				FROM (
					SELECT DISTINCT B.intBillId
						, B.strBillId
						, strLocationName
						, t.strTicketNumber
						, t.dtmTicketDateTime
						, strDistributionOption
						, dblUnitCost = dblCost
						, dblQtyReceived = SUM(BD.dblQtyReceived) OVER (PARTITION BY B.intBillId)
						, dblTotal = SUM(B.dblTotal) OVER (PARTITION BY B.intBillId)
						, BD.dblCost
						, dblAmountDue
						, dblUnitCost1 = dblCost
						, c.intCommodityId
						, intContractHeaderId = NULL
						, strContractNumber = NULL
						, Cur.strCurrency
						, strCustomerReference = strName
						, I.intItemId
						, I.strItemNo
						, Category.intCategoryId
						, strCategory = Category.strCategoryCode
					FROM tblAPBill B
					JOIN tblAPBillDetail BD ON B.intBillId = BD.intBillId
					JOIN tblICItem I ON BD.intItemId = I.intItemId AND BD.intInventoryReceiptChargeId IS NULL AND I.strType = 'Inventory'
					JOIN tblICCategory Category ON Category.intCategoryId = I.intCategoryId
					JOIN tblICCommodity c ON I.intCommodityId = c.intCommodityId
					JOIN tblSMCurrency Cur ON B.intCurrencyId = Cur.intCurrencyID
					JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = B.intShipToId
					LEFT JOIN tblSCTicket t ON BD.intScaleTicketId = t.intTicketId
					LEFT JOIN tblEMEntity e ON t.intEntityId = e.intEntityId
					WHERE c.intCommodityId = @intCommodityId AND ISNULL(strTicketStatus,'') <> 'V'
						AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
						AND B.intEntityVendorId = @intVendorId
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), B.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
						AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				) t WHERE dblTotal <> 0
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory)
				SELECT @strCommodityCode
					, strType = 'Net Receivable ($)'
					, I.dblAmountDue
					, L.strLocationName
					, intContractHeaderId = NULL
					, strContractNumber = ''
					, T.strTicketNumber
					, I.dtmDate
					, E.strName
					, strDistributionOption = ''
					, dblUCost = NULL
					, dblQtyReceived = SUM(ID.dblQtyShipped)
					, T.intCommodityId
					, Cur.strCurrency
					, I.intInvoiceId
					, I.strInvoiceNumber
					, Item.intItemId
					, Item.strItemNo
					, Category.intCategoryId
					, strCategory = Category.strCategoryCode
				FROM tblARInvoice I
				INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId AND intInventoryShipmentChargeId IS NULL
				INNER JOIN tblICItem Item ON Item.intItemId = ID.intItemId AND Item.strType = 'Inventory'
				INNER JOIN tblICCategory Category ON Category.intCategoryId = Item.intCategoryId
				INNER JOIN tblSMCompanyLocation L ON I.intCompanyLocationId = L.intCompanyLocationId
				INNER JOIN tblSCTicket T ON ID.intTicketId = T.intTicketId
				INNER JOIN tblEMEntity E ON I.intEntityCustomerId = E.intEntityId
				INNER JOIN tblSMCurrency Cur ON I.intCurrencyId = Cur.intCurrencyID
				WHERE I.ysnPosted = 1 AND dblAmountDue <> 0 AND T.intCommodityId = @intCommodityId
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= CONVERT(datetime,@dtmToDate)
					AND L.intCompanyLocationId = ISNULL(@intLocationId, L.intCompanyLocationId)
					AND L.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND I.intEntityCustomerId = @intVendorId
				GROUP BY I.dblAmountDue
					, L.strLocationName
					, T.strTicketNumber
					, I.dtmDate
					, E.strName
					, T.intCommodityId
					, Cur.strCurrency
					, I.intInvoiceId
					, I.strInvoiceNumber
					, Item.intItemId
					, Item.strItemNo
					, Category.intCategoryId
					, Category.strCategoryCode
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intBillId
					, strBillId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT strCommodityCode
					, strType = 'NP Un-Paid Quantity'
					, dblQtyReceived
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intBillId
					, strBillId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM @tempFinal WHERE strType = 'Net Payable ($)' AND intCommodityId = @intCommodityId
				
				INSERT INTO @tempFinal (strCommodityCode
					, strType
					, dblTotal
					, intInventoryReceiptItemId
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intInvoiceId
					, strInvoiceNumber
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush)
				SELECT @strCommodityCode
					, strType = 'NR Un-Paid Quantity'
					, dblQtyReceived
					, intInventoryReceiptItemId
					, strLocationName
					, intContractHeaderId
					, strContractNumber
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, intCommodityId
					, strContractType
					, intInvoiceId
					, strInvoiceNumber
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM @tempFinal WHERE strType = 'Net Receivable ($)' AND intCommodityId = @intCommodityId
				
				SELECT @intUnitMeasureId = NULL
				SELECT @strUnitMeasure = NULL
				SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
				
				SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
				INSERT INTO @Final (intCommodityId
					, strCommodityCode 
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strSubType
					, strContractType
					, strContractEndMonth
					, dblTotal
					, strUnitMeasure
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate)
				SELECT t.intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strSubType
					, strContractType
					, strContractEndMonth
					, dblTotal = CONVERT(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN (ISNULL(@intUnitMeasureId, 0) = 0 OR cuc.intCommodityUnitMeasureId = @intUnitMeasureId) THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
					, strUnitMeasure = CASE WHEN ISNULL(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				FROM @tempFinal t
				JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND strType NOT IN ('Net Payable ($)', 'Net Receivable ($)')
				
				UNION ALL
				SELECT t.intCommodityId
					, strCommodityCode
					, intContractHeaderId
					, strContractNumber
					, intFutOptTransactionHeaderId
					, strInternalTradeNo
					, strType
					, strSubType
					, strContractType
					, strContractEndMonth
					, dblTotal
					, strUnitMeasure = CASE WHEN ISNULL(@strUnitMeasure, '') = '' THEN um.strUnitMeasure ELSE @strUnitMeasure END
					, intInventoryReceiptItemId
					, strLocationName
					, strTicketNumber
					, dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, dblUnitCost
					, dblQtyReceived
					, strAccountNumber
					, strTranType
					, dblNoOfLot
					, dblDelta
					, intBrokerageAccountId
					, strInstrumentType
					, intNoOfContract
					, dblContractSize
					, strCurrency
					, intInvoiceId
					, strInvoiceNumber
					, intBillId
					, strBillId
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, intFutureMarketId
					, strFutMarketName
					, intFutureMonthId
					, strFutureMonth
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
					, strEntityName
					, strDeliveryDate
				FROM @tempFinal t
				JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND strType IN ('Net Payable ($)', 'Net Receivable ($)')
			END
		END
		SELECT @mRowNumber = MIN(intCommodityIdentity)	FROM @Commodity	WHERE intCommodityIdentity > @mRowNumber
	END
	
	UPDATE @Final SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
	UPDATE @Final SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
	UPDATE @Final SET intSeqNo = 3 WHERE strType = 'Net Hedge'
	UPDATE @Final SET intSeqNo = 4 WHERE strType = 'Crush'
	UPDATE @Final SET intSeqNo = 5 WHERE strType = 'Price Risk'
	UPDATE @Final SET intSeqNo = 6 WHERE strType = 'Basis Risk'
	UPDATE @Final SET intSeqNo = 7 WHERE strType = 'Net Payable ($)'
	UPDATE @Final SET intSeqNo = 8 WHERE strType = 'NP Un-Paid Quantity'
	UPDATE @Final SET intSeqNo = 9 WHERE strType = 'Net Receivable ($)'
	UPDATE @Final SET intSeqNo = 10 WHERE strType = 'NR Un-Paid Quantity'
	UPDATE @Final SET intSeqNo = 11 WHERE strType = 'Avail for Spot Sale'
	
	UPDATE @Final SET strFutureMonth = CASE 
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
		WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
	END COLLATE Latin1_General_CI_AS
	FROM @Final F
	LEFT JOIN (
		SELECT intFutOptTransactionHeaderId
			,strInternalTradeNo
			,strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
		FROM vyuRKFutOptTransaction
	)FOT ON FOT.intFutOptTransactionHeaderId = F.intFutOptTransactionHeaderId AND FOT.strInternalTradeNo COLLATE Latin1_General_CI_AS = F.strInternalTradeNo COLLATE Latin1_General_CI_AS
	
	UPDATE @Final SET strContractEndMonth = CASE 
			WHEN @strPositionBy = 'Futures Month'  THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
		END

	UPDATE @Final SET strContractEndMonth = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
	WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''
	
	IF (@strByType = 'ByCommodity')
	BEGIN
		SELECT DISTINCT c.strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal = SUM(dblTotal)
			, c.intCommodityId
		FROM @Final f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Payable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Receivable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NP Un-Paid Quantity' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NR Un-Paid Quantity' ELSE '' END
		GROUP BY c.strCommodityCode
			, strUnitMeasure
			, strType
			, c.intCommodityId
	END
	ELSE IF(@strByType = 'ByLocation')
	BEGIN
		SELECT DISTINCT c.strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal = SUM(dblTotal)
			, c.intCommodityId
			, strLocationName
		FROM @Final f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Payable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Receivable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NP Un-Paid Quantity' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NR Un-Paid Quantity' ELSE '' END
		GROUP BY c.strCommodityCode
			, strUnitMeasure
			, strType
			, c.intCommodityId
			, strLocationName
	END
	ELSE
	BEGIN IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		SELECT intSeqNo
			, intRow
			, c.strCommodityCode
			, intContractHeaderId
			, strContractNumber
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strContractType
			, strContractEndMonth
			, dblTotal
			, strUnitMeasure
			, intInventoryReceiptItemId
			, strLocationName
			, intTicketId
			, strTicketType = ISNULL(strTicketType, '')
			, strTicketNumber = ISNULL(strTicketNumber,'' )
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblUnitCost
			, dblQtyReceived
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, 0.0 invQty
			, 0.0 PurBasisDelivary
			, 0.0 OpenPurQty
			, 0.0 OpenSalQty
			, 0.0 dblCollatralSales
			, 0.0 SlsBasisDeliveries
			, 0.0 CompanyTitled
			, intNoOfContract
			, dblContractSize
			, intNoOfContract
			, dblContractSize
			, strCurrency
			, intInvoiceId
			, strInvoiceNumber = ISNULL(strInvoiceNumber,'')
			, intBillId
			, strBillId = ISNULL(strBillId,'')
			, intInventoryReceiptId
			, strReceiptNumber = ISNULL(strReceiptNumber,'')
			, intInventoryShipmentId
			, strShipmentNumber = ISNULL(strShipmentNumber,'')
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, f.intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
			, strEntityName
			, strDeliveryDate
		FROM @Final f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Payable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Receivable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NP Un-Paid Quantity' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NR Un-Paid Quantity' ELSE '' END
		ORDER BY intSeqNo
			, strType ASC
			, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
	END
	ELSE
	BEGIN
		SELECT intSeqNo
			, intRow
			, c.strCommodityCode
			, intContractHeaderId
			, strContractNumber
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strContractType
			, strContractEndMonth
			, dblTotal
			, strUnitMeasure
			, intInventoryReceiptItemId
			, strLocationName
			, intTicketId
			, strTicketType = ISNULL(strTicketType, '')
			, strTicketNumber = ISNULL(strTicketNumber,'' )
			, dtmTicketDateTime
			, strCustomerReference
			, strDistributionOption
			, dblUnitCost
			, dblQtyReceived
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, 0.0 invQty
			, 0.0 PurBasisDelivary
			, 0.0 OpenPurQty
			, 0.0 OpenSalQty
			, 0.0 dblCollatralSales
			, 0.0 SlsBasisDeliveries
			, 0.0 CompanyTitled
			, intNoOfContract
			, dblContractSize
			, intNoOfContract
			, dblContractSize
			, strCurrency
			, intInvoiceId
			, strInvoiceNumber = ISNULL(strInvoiceNumber,'')
			, intBillId
			, strBillId = ISNULL(strBillId,'')
			, intInventoryReceiptId
			, strReceiptNumber = ISNULL(strReceiptNumber,'')
			, intInventoryShipmentId
			, strShipmentNumber = ISNULL(strShipmentNumber,'')
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, f.intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
			, strEntityName
			, strDeliveryDate
		FROM @Final f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0 AND strSubType NOT LIKE '%' + @strPurchaseSales + '%'
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Payable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'Net Receivable ($)' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NP Un-Paid Quantity' ELSE '' END
			AND strType <> CASE WHEN @ysnHideNetPayableAndReceivable = 1 THEN 'NR Un-Paid Quantity' ELSE '' END
		ORDER BY intSeqNo
			, strType ASC
			, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
	END
END
END