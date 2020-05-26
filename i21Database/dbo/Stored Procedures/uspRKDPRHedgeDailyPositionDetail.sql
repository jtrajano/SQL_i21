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

	DECLARE @CrushReport BIT = 1
	--IF (ISNULL(@strPositionBy, '') = 'Delivery Month' OR ISNULL(@strPositionBy, '') = 'Futures Month')
	--BEGIN
	--	SET @CrushReport = 1
	--END
	
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

	IF ISNULL(@strPurchaseSales, '') <> '' AND @strPurchaseSales <> 'Both'
	BEGIN
		IF @strPurchaseSales = 'Purchase'
		BEGIN
			SET @strPurchaseSales = 'Sale'
		END
		ELSE
		BEGIN
			SET @strPurchaseSales = 'Purchase'
		END
	END

	
	DECLARE @tempFinal AS TABLE (intRow INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strSubType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptItemId INT
		, intTicketId INT
		, strTicketType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmTicketDateTime DATETIME
		, strCustomerReference NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strDistributionOption NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblUnitCost NUMERIC(24, 10)
		, dblQtyReceived NUMERIC(24, 10)
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, intCommodityId INT
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCompanyLocationId INT
		, intInvoiceId INT
		, strInvoiceNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intBillId INT
		, strBillId NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strShipmentNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, intContractTypeId INT
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
	DECLARE @Final AS TABLE (intRow INT IDENTITY
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutOptTransactionHeaderId INT
		, strInternalTradeNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strSubType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptItemId INT
		, intTicketId INT
		, strTicketType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmTicketDateTime DATETIME
		, strCustomerReference NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strDistributionOption NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblUnitCost NUMERIC(24, 10)
		, dblQtyReceived NUMERIC(24, 10)
		, dblTotal DECIMAL(24,10)
		, strUnitMeasure NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intSeqNo INT
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, intCommodityId INT
		, strAccountNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId INT
		, strInstrumentType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dblNoOfContract NUMERIC(24, 10)
		, dblContractSize NUMERIC(24, 10)
		, strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInvoiceId INT
		, strInvoiceNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intBillId INT
		, strBillId NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strShipmentNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, intContractTypeId INT
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDeliveryDate NVARCHAR(100) COLLATE Latin1_General_CI_AS)
	
	DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmEndDate DATETIME
		, dblBalance DECIMAL(24,10)
		, intUnitMeasureId INT
		, intPricingTypeId INT
		, intContractTypeId INT
		, intCompanyLocationId INT
		, strContractType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strPricingType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intContractDetailId INT
		, intContractStatusId INT
		, intEntityId INT
		, intCurrencyId INT
		, strType NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strCategory NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, dtmContractDate datetime
		, strEntityName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, strCurrency NVARCHAR(200) COLLATE Latin1_General_CI_AS)
	
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
		, strCommodityCode = CD.strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber = CD.strContract
		, strLocationName
		--, dtmEndDate = (CASE WHEN ISNULL(strFutureMonth,'') <> '' THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) ELSE dtmEndDate END)
		, dtmEndDate = dtmSeqEndDate
		, dblBalance = CD.dblQtyinCommodityStockUOM
		, intUnitMeasureId
		, intPricingTypeId
		, intContractTypeId
		, intCompanyLocationId
		, strContractType
		, strPricingType = CD.strPricingTypeDesc
		, CD.intContractDetailId
		, intContractStatusId
		, intEntityId
		, intCurrencyId
		, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) COLLATE Latin1_General_CI_AS
		, intItemId
		, strItemNo
		, strCategory
		, strEntityName = CD.strCustomer
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strCurrency
	FROM tblCTContractBalance CD
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate
	
	DECLARE @tblGetOpenFutureByDate TABLE (intFutOptTransactionId INT
		, dblOpenContract NUMERIC(18, 6)
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
	
	DECLARE @tempCommId INT
	SELECT DISTINCT intCommodity
	INTO #tempCommodity
	FROM @Commodity
	WHERE ISNULL(intCommodity, '') <> ''

	WHILE EXISTS(SELECT TOP 1 1 FROM #tempCommodity)
	BEGIN
		SELECT TOP 1 @tempCommId = intCommodity FROM #tempCommodity

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
		FROM fnRKGetOpenFutureByDate( @tempCommId, '1/1/1900', @dtmToDate, @CrushReport)

		DELETE FROM #tempCommodity WHERE intCommodity = @tempCommId
	END

	DROP TABLE #tempCommodity

	SELECT *
	INTO #tblGetStorageDetailByDate
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
			AND i.intCommodityId IN (SELECT intCommodity FROM @Commodity)
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
			AND i.intCommodityId IN (SELECT intCommodity FROM @Commodity)
			AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
	)t
	
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
		--AND ISNULL(strDistributionOption,'') <> CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN '@#$%' ELSE 'DP' END
	
	SELECT * INTO #tempCollateral
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intCollateralId ORDER BY c.dtmOpenDate DESC)
			, c.intCollateralId
			, cl.strLocationName
			, ch.intItemId
			, ch.strItemNo
			, ch.strCategory
			, ch.strEntityName
			, c.strReceiptNo
			, ch.intContractHeaderId
			, strContractNumber
			, c.dtmOpenDate
			, dblOriginalQuantity = ISNULL(c.dblOriginalQuantity, 0)
			, dblRemainingQuantity = ISNULL(c.dblOriginalQuantity, 0) - ISNULL(ca.dblAdjustmentAmount,0)
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
		LEFT JOIN (
			SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			GROUP BY intCollateralId

		) ca on c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodity co ON co.intCommodityId = c.intCommodityId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
		WHERE c.intCommodityId IN (SELECT intCommodity FROM @Commodity)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND c.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND c.ysnIncludeInPriceRiskAndCompanyTitled = 1
	) a where a.intRowNum = 1
	
	DECLARE @mRowNumber INT
		, @intCommodityId1 INT
		, @strCommodityCode NVARCHAR(200)
		, @intOneCommodityId INT
		, @intCommodityUnitMeasureId INT
		, @intCommodityStockUOMId INT
		, @ysnExchangeTraded BIT
		
	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity
	
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strCommodityCode = strCommodityCode
			, @ysnExchangeTraded = ysnExchangeTraded
		FROM tblICCommodity	WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId, @intCommodityStockUOMId = intUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
		
		IF (@intCommodityId > 0)
		BEGIN
			IF ISNULL(@intVendorId,0) = 0
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
						, strContractType = 'Physical Contract' COLLATE Latin1_General_CI_AS
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
						, dblTotal = cd.dblBalance
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
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId IN (1,2) AND cd.intCommodityId = @intCommodityId
						AND cd.intContractStatusId <> 3 
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
					, 'Net Hedge' COLLATE Latin1_General_CI_AS
					, strContractType = strInstrumentType
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
						, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblOpenContract * t.dblContractSize)
						, l.strLocationName
						, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) COLLATE Latin1_General_CI_AS
						, m.intUnitMeasureId
						, strAccountNumber = t.strBroker + '-' + t.strBrokerAccount COLLATE Latin1_General_CI_AS
						, strTranType = strNewBuySell
						, t.intBrokerageAccountId
						, strInstrumentType = strInstrumentType
						, dblNoOfLot = dblOpenContract
						, cu.strCurrency
						, m.intFutureMarketId
						, t.strFutureMarket
						, fm.intFutureMonthId
						, t.strBrokerTradeNo
						, t.strNotes
						, t.ysnPreCrush
					FROM @tblGetOpenFutureByDate t
					JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
					JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
					JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
					JOIN tblSMCurrency cu ON cu.intCurrencyID = m.intCurrencyId
					JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
					INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
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
					, 'Net Hedge' COLLATE Latin1_General_CI_AS
					, 'Option' COLLATE Latin1_General_CI_AS
					, t.strLocationName
					, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear) COLLATE Latin1_General_CI_AS
					, dblNoOfContract = dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
																FROM tblRKFuturesSettlementPrice sp
																INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
																WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
																	AND t.dblStrike = mm.dblStrike
																ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize
					, m.intUnitMeasureId
					, th.intCommodityId 
					, strAccountNumber = t.strBroker + '-' + t.strBrokerAccount COLLATE Latin1_General_CI_AS
					, strTranType = strNewBuySell
					, dblNoOfLot = dblOpenContract
					, dblDelta = ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND t.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
					, t.intBrokerageAccountId
					, strInstrumentType = 'Option' COLLATE Latin1_General_CI_AS
					, strCurrency 
					, m.intFutureMarketId
					, t.strFutureMarket
					, fm.intFutureMonthId
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
				INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
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
						, 'Crush' COLLATE Latin1_General_CI_AS
						, strContractType = 'Crush' COLLATE Latin1_General_CI_AS
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

					----Include Crush in Price Risk
					--INSERT INTO @tempFinal(strCommodityCode
					--	, strType
					--	, strContractType
					--	, dblTotal
					--	, intContractHeaderId
					--	, strContractNumber
					--	, intFromCommodityUnitMeasureId
					--	, intCommodityId
					--	, strLocationName
					--	, intFutOptTransactionHeaderId
					--	, strInternalTradeNo

					--	)
					--SELECT strCommodityCode
					--	, 'Price Risk' COLLATE Latin1_General_CI_AS
					--	, strContractType
					--	, dblTotal
					--	, intContractHeaderId
					--	, strContractNumber
					--	, intFromCommodityUnitMeasureId
					--	, intCommodityId
					--	, strLocationName
					--	, intFutOptTransactionHeaderId
					--	, strInternalTradeNo
					--FROM @tempFinal
					--WHERE intCommodityId = @intCommodityId AND strType  = 'Crush'


					--Include Crush in Net Hedge
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
						, 'Net Hedge' COLLATE Latin1_General_CI_AS
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
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Inventory' COLLATE Latin1_General_CI_AS
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

				--=========================================
				-- Includes DP based on Company Preference
				--========================================
				If ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference)=0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
				BEGIN
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
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'Inventory'
						, dblTotal = -SUM(dblTotal)
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency = NULL
					FROM (
						SELECT DISTINCT intTicketId
							, strTicketType
							, strTicketNumber
							, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
							, ch.intCompanyLocationId
							, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, intItemId
							, strItemNo
							, intCategoryId
							, strCategory
						FROM #tblGetStorageDetailByDate ch
						WHERE ch.intCommodityId  = @intCommodityId
							AND ysnDPOwnedType = 1
							AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
						)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					GROUP BY intTicketId
						, strTicketType
						, strTicketNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
				END
				ELSE
				BEGIN
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
					SELECT @strCommodityCode
						, strType = 'Price Risk'
						, strContractType = 'DP'
						, dblTotal = -SUM(dblTotal)
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, strCurrency = NULL
					FROM (
						SELECT DISTINCT intTicketId
							, strTicketType
							, strTicketNumber
							, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
							, ch.intCompanyLocationId
							, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
							, intCommodityId
							, strLocationName
							, intItemId
							, strItemNo
							, intCategoryId
							, strCategory
						FROM #tblGetStorageDetailByDate ch
						WHERE ch.intCommodityId  = @intCommodityId
							AND ysnDPOwnedType = 1
							AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
						)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					GROUP BY intTicketId
						, strTicketType
						, strTicketNumber
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, strLocationName
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
				END

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
					, 'Price Risk' COLLATE Latin1_General_CI_AS
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
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
					, - dblQuantity
					, intInventoryReceiptId = BD.intTransactionId
					, strReceiptNumber = BD.strTransactionId
					, intCommodityUnitMeasureId = NULL
					, BD.intCommodityId 
					, strLocationName = BD.strCompanyLocation
					, cur.strCurrency
					, BD.intItemId
					, BD.strItemNo
					, cat.strCategoryCode
					, fm.intFutureMarketId
					, fm.strFutMarketName
					, mnt.intFutureMonthId
					, mnt.strFutureMonth
				FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
					INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
					INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
					INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
					INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
					INNER JOIN tblSMCurrency cur ON cur.intCurrencyID = BD.intCurrencyId
				WHERE BD.intCommodityId = @intCommodityId
					AND strContractType = 'Purchase'
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND BD.ysnOpenGetBasisDelivery = 1

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
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
					, dblQuantity = dblQuantity
					, intInventoryShipmentId = BD.intTransactionId
					, strShipmentNumber = BD.strTransactionId
					, intCommodityUnitMeasureId = NULL
					, BD.intCommodityId
					, strLocationName = BD.strCompanyLocation
					, cur.strCurrency
					, BD.intItemId
					, BD.strItemNo
					, cat.strCategoryCode
					, fm.intFutureMarketId
					, fm.strFutMarketName
					, mnt.intFutureMonthId
					, mnt.strFutureMonth
				FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
					INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
					INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
					INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
					INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
					INNER JOIN tblSMCurrency cur ON cur.intCurrencyID = BD.intCurrencyId
				WHERE BD.intCommodityId = @intCommodityId
					AND strContractType = 'Sale'
					AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND BD.ysnOpenGetBasisDelivery = 1

				--INSERT INTO @tempFinal(strCommodityCode
				--	, strType
				--	, strContractType
				--	, dblTotal
				--	, intInventoryReceiptId
				--	, strReceiptNumber
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
				--	, strFutureMonth)
				--SELECT @strCommodityCode
				--	, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
				--	, strContractType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
				--	, SUM(dblTotal)
				--	, intInventoryShipmentId
				--	, strShipmentNumber
				--	, intCommodityUnitMeasureId
				--	, intCommodityId
				--	, strLocationName
				--	, strCurrency
				--	, intItemId
				--	, strItemNo
				--	, strCategoryCode
				--	, intFutureMarketId
				--	, strFutMarketName
				--	, intFutureMonthId
				--	, strFutureMonth
				--FROM (
				--		SELECT DISTINCT dblTotal = dbo.fnCTConvertQuantityToTargetItemUOM(cd.intItemId,iuom.intUnitMeasureId,@intCommodityStockUOMId,isnull(ri.dblQuantity, 0))
				--			, r.intInventoryShipmentId
				--			, r.strShipmentNumber
				--			, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
				--			, i.intCommodityId
				--			, cl.strLocationName
				--			, cl.intCompanyLocationId
				--			, v.strCurrency
				--			, cd.intItemId
				--			, i.strItemNo
				--			, cat.strCategoryCode
				--			, cd.intFutureMarketId
				--			, fm.strFutMarketName
				--			, cd.intFutureMonthId
				--			, mnt.strFutureMonth
				--	FROM vyuRKGetInventoryValuation v
				--	JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
				--	INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId AND ri.intInventoryShipmentItemId =  v.intTransactionDetailId
				--	INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
				--	INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId  AND ch.intContractTypeId = 2
				--	INNER JOIN tblICItem i on cd.intItemId = i.intItemId
				--	INNER JOIN tblICItemUOM iuom on iuom.intItemId = i.intItemId and iuom.intItemUOMId = ri.intItemUOMId
				--	INNER JOIN tblICCategory cat on i.intCategoryId = cat.intCategoryId
				--	INNER JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
				--	INNER JOIN tblRKFuturesMonth mnt on cd.intFutureMonthId = mnt.intFutureMonthId
				--	INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
				--	LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				--	LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
				--	LEFT JOIN tblCTPriceFixationDetail pfd ON invD.intInvoiceDetailId = pfd.intInvoiceDetailId
				--	WHERE ch.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
				--		AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
				--		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
				--		AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(inv.dtmDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
				--		AND CONVERT(DATETIME, @dtmToDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(pfd.dtmFixationDate,DATEADD(DAY,1,@dtmToDate)), 110), 110)
				--) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				--GROUP BY intInventoryShipmentId
				--	, strShipmentNumber
				--	, intCommodityUnitMeasureId
				--	, intCommodityId
				--	, strLocationName
				--	, strCurrency
				--	, intItemId
				--	, strItemNo
				--	, strCategoryCode
				--	, intFutureMarketId
				--	, strFutMarketName
				--	, intFutureMonthId
				--	, strFutureMonth

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
					, strDeliveryDate
					, strContractEndMonth)
				SELECT strCommodityCode
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Open Contract' COLLATE Latin1_General_CI_AS
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
					, strContractEndMonth
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
						, strDeliveryDate = strDeliveryDate
						, strContractEndMonth
					FROM @tempFinal cd
					WHERE cd.intCommodityId = @intCommodityId and strType IN('Sale Priced', 'Purchase Priced', 'Purchase HTA', 'Sale HTA') 
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
					, strContractEndMonth
				
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
					, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
					, strContractType = 'Collateral' COLLATE Latin1_General_CI_AS
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
						, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
						, strContractType = 'OffSite' COLLATE Latin1_General_CI_AS
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
				
				IF ((SELECT TOP 1 ysnIncludeInTransitInCompanyTitled FROM tblRKCompanyPreference) = 1)
				BEGIN

					INSERT INTO @tempFinal(	strCommodityCode
						, strType
						, strContractType
						, dblTotal			
						, strLocationName		
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, intContractHeaderId
						, strContractNumber
						)
					SELECT 
						  strCommodityCode = @strCommodityCode
						, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
						, strContractType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0))
						, strLocationName
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId = intUnitMeasureId
						, intCommodityId = @intCommodityId		
						, intContractHeaderId
						, strContractNumber
					FROM (
						SELECT i.intUnitMeasureId
							, ReserveQty = ISNULL(i.dblPurchaseContractShippedQty, 0)
							, i.strLocationName
							, i.intItemId
							, i.strItemNo
							, i.intCategoryId
							, i.strCategory
							, i.intContractHeaderId
							, i.intContractDetailId
							, i.strContractNumber
							, i.intCompanyLocationId
						FROM vyuRKPurchaseIntransitView i
						WHERE i.intCommodityId = @intCommodityId
							AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
							AND i.intPurchaseSale = 1 -- 1.Purchase 2. Sales
							AND i.intEntityId = ISNULL(@intVendorId, i.intEntityId)					
					) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

					INSERT INTO @tempFinal(	strCommodityCode
						, strType
						, strContractType
						, dblTotal			
						, strLocationName		
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId
						, intCommodityId
						, intContractHeaderId
						, strContractNumber
						, intTicketId
						, strTicketNumber
						, strShipmentNumber
						, intInventoryShipmentId
						)
					SELECT 
						  strCommodityCode = @strCommodityCode
						, strType = 'Price Risk' COLLATE Latin1_General_CI_AS
						, strContractType = 'Sales In-Transit' COLLATE Latin1_General_CI_AS
						, dblTotal = ISNULL(dblBalanceToInvoice, 0)
						, strLocationName
						, intItemId
						, strItemNo
						, intCategoryId
						, strCategory
						, intFromCommodityUnitMeasureId 
						, intCommodityId = @intCommodityId		
						, intContractHeaderId
						, strContractNumber
						, intTicketId
						, strTicketNumber
						, strShipmentNumber
						, intInventoryShipmentId
					FROM (
						SELECT intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId
							, dblBalanceToInvoice
							, i.strLocationName
							, i.intItemId
							, i.strItemNo
							, i.intCategoryId
							, i.strCategory
							, i.intContractHeaderId
							, i.strContractNumber
							, i.intCompanyLocationId
							, intTicketId
							, strTicketNumber
							, strShipmentNumber
							, intInventoryShipmentId
						FROM #tblGetSalesIntransitWOPickLot i
						WHERE i.intCommodityId = @intCommodityId
					AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)		
					AND i.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					) t 

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
					, strType = 'Basis Risk' COLLATE Latin1_General_CI_AS
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
				FROM @tempFinal WHERE strType = 'Price Risk' AND strContractType IN ('Inventory', 'Collateral',  'OffSite' , 'Purchase In-Transit','Sales In-Transit') AND @ysnExchangeTraded = 1
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
						, strType = 'Basis Risk' COLLATE Latin1_General_CI_AS
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
					, strType = 'Avail for Spot Sale' COLLATE Latin1_General_CI_AS
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
						, strType = 'Avail for Spot Sale' COLLATE Latin1_General_CI_AS
						, strContractType
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
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
					, dblNoOfContract
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
					, um.strUnitMeasure
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
					, dblNoOfContract
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
				WHERE t.intCommodityId = @intCommodityId 
				
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
						, strContractType = 'Physical' COLLATE Latin1_General_CI_AS
						, strLocationName
						, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
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
						, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
					FROM @tblGetOpenContractDetail cd
					WHERE cd.intContractTypeId IN (1, 2)
						AND cd.intCommodityId = @intCommodityId
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
						AND cd.intEntityId = @intVendorId
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				
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
					, dblNoOfContract
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
					, dblTotal
					, um.strUnitMeasure
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
					, dblNoOfContract
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
				WHERE t.intCommodityId = @intCommodityId 
				
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
					, um.strUnitMeasure
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
					, dblNoOfContract
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
				WHERE t.intCommodityId = @intCommodityId
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
			, dblNoOfContract
			, dblContractSize
			, dblNoOfContract
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
			, dblNoOfContract
			, dblContractSize
			, dblNoOfContract
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
		ORDER BY intSeqNo
			, strType ASC
			, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
	END
END
END
