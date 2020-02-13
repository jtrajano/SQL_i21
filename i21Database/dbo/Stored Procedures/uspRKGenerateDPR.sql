CREATE PROCEDURE [dbo].[uspRKGenerateDPR]
	@intCommodityId INT
	, @intLocationId INT = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(250) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL
	, @strPositionBy NVARCHAR(50) = NULL

AS

BEGIN
--DECLARE
--@intCommodityId INT
--	, @intLocationId INT = NULL
--	, @intVendorId INT = NULL
--	, @strPurchaseSales NVARCHAR(250) = NULL
--	, @strPositionIncludes NVARCHAR(100) = NULL
--	, @dtmToDate DATETIME = NULL
--	, @strByType NVARCHAR(50) = NULL
--	, @strPositionBy NVARCHAR(50) = NULL

	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)

	IF ISNULL(@intLocationId, 0) = 0
	BEGIN
		SET @intLocationId = NULL
	END
	IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		SET @intVendorId = NULL
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

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE isnull(ysnLicensed, 0) END

	DECLARE @ysnDisplayAllStorage BIT
		, @ysnIncludeDPPurchasesInCompanyTitled BIT
		, @ysnHideNetPayableAndReceivable BIT
		, @ysnPreCrush BIT
		, @ysnIncludeOffsiteInventoryInCompanyTitled BIT
		, @ysnIncludeInTransitInCompanyTitled BIT

	SELECT @ysnDisplayAllStorage = ISNULL(ysnDisplayAllStorage, 0)
		, @ysnIncludeDPPurchasesInCompanyTitled = ISNULL(ysnIncludeDPPurchasesInCompanyTitled, 0)
		, @ysnHideNetPayableAndReceivable = ISNULL(ysnHideNetPayableAndReceivable, 0)
		, @ysnPreCrush = ISNULL(ysnPreCrush, 0)
		, @ysnIncludeOffsiteInventoryInCompanyTitled = ISNULL(ysnIncludeOffsiteInventoryInCompanyTitled, 0)
		, @ysnIncludeInTransitInCompanyTitled = ISNULL(ysnIncludeInTransitInCompanyTitled, 0)
	FROM tblRKCompanyPreference

	------------------------------------------
	-------------- Inventory -----------------
	------------------------------------------

	DECLARE @Final AS TABLE (intRow INT IDENTITY PRIMARY KEY
		, intSeqId INT
		, strSeqHeader NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intCollateralId INT
		, strLocationName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, strCustomerName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, strReceiptNo NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDistributionOption NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDPAReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblDiscDue DECIMAL(24,10)
		, dblStorageDue DECIMAL(24,10)
		, dtmLastStorageAccrueDate datetime
		, strScheduleId NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTicketId INT
		, strTicketType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dtmOpenDate DATETIME
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dtmTicketDateTime DATETIME
		, dblOriginalQuantity DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strTruckName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDriverName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCompanyLocationId INT
		, intStorageScheduleTypeId INT		
		, strShipmentNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId INT
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS 
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS)
		
	DECLARE @FinalTable AS TABLE (intRow INT IDENTITY PRIMARY KEY
		, intSeqId INT
		, strSeqHeader NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal DECIMAL(24,10)
		, intCollateralId INT
		, strLocationName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, strCustomerName NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, strReceiptNo NVARCHAR(250) COLLATE Latin1_General_CI_AS
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCustomerReference NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDistributionOption NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDPAReceiptNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblDiscDue DECIMAL(24,10)
		, dblStorageDue DECIMAL(24,10)
		, dtmLastStorageAccrueDate DATETIME
		, strScheduleId NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intTicketId INT
		, strTicketType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dtmOpenDate DATETIME
		, strDeliveryDate NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dtmTicketDateTime DATETIME
		, dblOriginalQuantity  DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strUnitMeasure NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strTruckName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strDriverName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCompanyLocationId INT
		, strShipmentNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intInventoryShipmentId INT
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intCategoryId INT
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strBrokerTradeNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strNotes NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, ysnPreCrush BIT
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS)

	DECLARE @tblGetOpenContractDetail TABLE (intRowNum INT
		, strCommodityCode NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, intCommodityId INT
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
		, strContractEndMonth NVARCHAR(50) COLLATE Latin1_General_CI_AS
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
	
	DECLARE @strCommodityCode NVARCHAR(250)
		, @intCommodityUnitMeasureId INT
		, @intCommodityStockUOMId INT
		, @ysnExchangeTraded BIT
	
	SELECT @strCommodityCode = strCommodityCode
		, @ysnExchangeTraded = ysnExchangeTraded
	FROM tblICCommodity WHERE intCommodityId = @intCommodityId
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		, @intCommodityStockUOMId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

	IF OBJECT_ID('tempdb..#tblGetStorageDetailByDate') IS NOT NULL
		DROP TABLE #tblGetStorageDetailByDate
	IF OBJECT_ID('tempdb..#tblGetStorageOffSiteDetail') IS NOT NULL
		DROP TABLE #tblGetStorageOffSiteDetail
	IF OBJECT_ID('tempdb..#tblGetSalesIntransitWOPickLot') IS NOT NULL
		DROP TABLE #tblGetSalesIntransitWOPickLot
	IF OBJECT_ID('tempdb..#tempDeliverySheet') IS NOT NULL
		DROP TABLE #tempDeliverySheet
	IF OBJECT_ID('tempdb..#tempCollateral') IS NOT NULL
		DROP TABLE #tempCollateral
	IF OBJECT_ID('tempdb..#invQty') IS NOT NULL
		DROP TABLE #invQty
	IF OBJECT_ID('tempdb..#tempOnHold') IS NOT NULL
		DROP TABLE #tempOnHold
	IF OBJECT_ID('tempdb..#tempTransfer') IS NOT NULL
		DROP TABLE #tempTransfer
		
	INSERT INTO @tblGetOpenContractDetail(intRowNum
		, strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber
		, strLocationName
		, strContractEndMonth
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
		, intCurrencyId
		, strType
		, intItemId
		, strItemNo
		, dtmContractDate
		, intEntityId
		, strEntityName
		, strCategory
		, intFutureMonthId
		, intFutureMarketId
		, strFutMarketName
		, strFutureMonth
		, strCurrency)
	SELECT intRowNum
		, strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber
		, strLocationName
		, strContractEndMonth
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
		, intCurrencyId
		, strType
		, intItemId
		, strItemNo
		, dtmContractDate
		, intEntityId
		, strEntityName
		, strCategory
		, intFutureMonthId
		, intFutureMarketId
		, strFutMarketName
		, strFutureMonth
		, strCurrency
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY CD.intContractDetailId ORDER BY dtmContractDate DESC)
			, dtmContractDate
			, strCommodityCode = strCommodityCode
			, intCommodityId
			, intContractHeaderId
			, strContractNumber = strContract
			, strLocationName
			, strContractEndMonth = (RIGHT(CONVERT(VARCHAR(11), CD.dtmSeqEndDate, 106), 8)) COLLATE Latin1_General_CI_AS
			, dtmEndDate = CD.dtmSeqEndDate
			, dblBalance = CD.dblQuantity
			, intUnitMeasureId
			, intPricingTypeId
			, intContractTypeId
			, intCompanyLocationId
			, strContractType
			, strPricingType = CD.strPricingTypeDesc
			, CD.intContractDetailId
			, intContractStatusId
			, intCurrencyId
			, strType = (CD.strContractType + ' ' + CD.strPricingTypeDesc) COLLATE Latin1_General_CI_AS
			, intItemId
			, strItemNo
			, intEntityId
			, strEntityName = CD.strCustomer
			, strCategory
			, intFutureMonthId
			, intFutureMarketId
			, strFutMarketName
			, strFutureMonth
			, strCurrency
		FROM tblCTContractBalance CD
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), CD.dtmEndDate, 110), 110) = @dtmToDate
			AND intCommodityId = @intCommodityId
			AND CD.dblQuantity <> 0
	)t

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
			, intContractNumber = t.intContractId
			, strContractNumber = ISNULL((SELECT strContractNumber FROM tblCTContractHeader WHERE intContractHeaderId = t.intContractId), '')
			, intTransactionTypeId
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
		JOIN tblICCommodity CM ON CM.intCommodityId = i.intCommodityId
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
			, intContractNumber = NULL
			, strContractNumber = ''
			, intTransactionTypeId
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
		JOIN tblICCommodity CM ON CM.intCommodityId = i.intCommodityId
		WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
	)t
		
	--=============================
	-- Storage Off Site
	--=============================
	SELECT * INTO #tblGetStorageOffSiteDetail
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY sh.intStorageHistoryId ORDER BY intStorageHistoryId ASC)
			, a.intCustomerStorageId
			, a.intCompanyLocationId
			, strLocationName = sl.strSubLocationName
			, strContractEndMonth = (RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8)) COLLATE Latin1_General_CI_AS
			, strDeliveryDate = (RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8)) COLLATE Latin1_General_CI_AS
			, a.intEntityId
			, strCustomerName = E.strName
			, a.strDPARecieptNumber [Receipt]
			, dblDiscDue = a.dblDiscountsDue
			, a.dblStorageDue
			, dblBalance = sh.dblUnits
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
			, ysnExternal = ISNULL(ysnExternal, 0)
			, i.intItemId
			, i.strItemNo
			, i.intCategoryId
			, strCategory = Category.strCategoryCode
			, dtmDistributionDate = sh.dtmHistoryDate
			, r.intInventoryReceiptId
			, r.strReceiptNumber
			, intTicketId = (CASE WHEN sh.intTransactionTypeId = 1 THEN sh.intTicketId
								WHEN sh.intTransactionTypeId = 4 THEN sh.intSettleStorageId
								WHEN sh.intTransactionTypeId = 3 THEN sh.intTransferStorageId
								ELSE sh.intCustomerStorageId END)
			, strTicketType = (CASE WHEN sh.intTransactionTypeId = 1 THEN 'Scale Storage'
								WHEN sh.intTransactionTypeId = 4 THEN 'Settle Storage'
								WHEN sh.intTransactionTypeId = 3 THEN 'Transfer Storage'
								ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
			, strTicketNumber = (CASE WHEN sh.intTransactionTypeId = 1 THEN NULL
								WHEN sh.intTransactionTypeId = 4 THEN sh.strSettleTicket
								WHEN sh.intTransactionTypeId = 3 THEN sh.strTransferTicket
								ELSE a.strStorageTicketNumber END)
			, strFutureMonth = '' COLLATE Latin1_General_CI_AS
		FROM tblICInventoryReceipt r
		JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		JOIN tblSCTicket sc ON sc.intTicketId = ri.intSourceId
		LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = sc.intSubLocationId AND sl.intCompanyLocationId = sc.intProcessingLocationId
		JOIN tblICItem i ON i.intItemId = sc.intItemId
		JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
		JOIN tblGRStorageHistory sh ON sh.intTicketId = sc.intTicketId
		JOIN tblGRCustomerStorage a ON a.intCustomerStorageId = sh.intCustomerStorageId
		JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId AND b.ysnCustomerStorage = 1
		JOIN tblICCommodity CM ON CM.intCommodityId = i.intCommodityId
		JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
		LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			AND ISNULL(strTicketStatus, '') <> 'V'
			AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
	) t WHERE t.intRowNum = 1
		
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
	FROM (
		SELECT strShipmentNumber = InTran.strTransactionId
			, intInventoryShipmentId = InTran.intTransactionId
			, strContractNumber = SI.strOrderNumber + '-' + CONVERT(NVARCHAR, SI.intContractSeq) COLLATE Latin1_General_CI_AS 
			, intContractHeaderId = SI.intOrderId 
			, strTicketNumber = SI.strSourceNumber
			, intTicketId = SI.intSourceId
			, dtmTicketDateTime = InTran.dtmDate
			, intCompanyLocationId = Inv.intLocationId
			, strLocationName = Inv.strLocationName
			, strUOM = InTran.strUnitMeasure
			, Inv.intEntityId
			, strCustomerReference = SI.strCustomerName
			, Com.intCommodityId
			, Itm.intItemId
			, Itm.strItemNo
			, strCategory = Cat.strCategoryCode
			, Cat.intCategoryId
			, dblBalanceToInvoice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((InTran.dblInTransitQty),0)) 
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), InTran.dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
			, strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblCTContractDetail cd INNER JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId =  fmnt.intFutureMonthId WHERE intContractHeaderId = SI.intLineNo)
			, strDeliveryDate =  (SELECT TOP 1 dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') FROM tblCTContractDetail WHERE intContractHeaderId = SI.intLineNo)
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
		
	SELECT * INTO #tempCollateral
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intCollateralId ORDER BY c.dtmOpenDate DESC)
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,c.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount,0))
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
			, dblOriginalQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0))
			, dblRemainingQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,c.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount,0))
			, intCommodityId = @intCommodityId
			, strCommodityCode = @strCommodityCode
			, c.intUnitMeasureId
			, intCompanyLocationId = c.intLocationId
			, intContractTypeId = CASE WHEN c.strType = 'Purchase' THEN 1 ELSE 2 END
			, c.intLocationId
			, intEntityId
			, ch.intFutureMarketId
			, ch.intFutureMonthId
			, ch.strFutMarketName
			, ch.strFutureMonth
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), ch.dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
			, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), ch.dtmEndDate, 106), 8) COLLATE Latin1_General_CI_AS
			, c.ysnIncludeInPriceRiskAndCompanyTitled
		FROM tblRKCollateral c
		LEFT JOIN (
			SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			GROUP BY intCollateralId
		) ca on c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		LEFT JOIN @tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
			and cl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	) a WHERE a.intRowNum = 1

	--=============================
	-- Inventory Valuation
	--=============================
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
		, strCustomer = s.strEntity
		, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
		, strDeliveryDate = dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
		, s.strLocationName
		, i.intItemId
		, s.strItemNo
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, strTruckName = ''
		, strDriverName = ''
		, dblStorageDue = NULL
		, s.intLocationId
		, intTransactionId
		, strTransactionId
		, strTransactionType
		, s.intCategoryId
		, s.strCategory
		, t.strDistributionOption
		, t.dtmTicketDateTime
		, t.intTicketId
		, t.strTicketNumber
		, intContractHeaderId = ch.intContractHeaderId
		, strContractNumber = ch.strContractNumber
		, strFutureMonth = fmnt.strFutureMonth
		, s.strCurrency
	INTO #invQty
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i ON i.intItemId = s.intItemId
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intCommodityStockUOMId
	LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = s.intTransactionDetailId 
	LEFT JOIN tblCTContractHeader ch on cd.intContractHeaderId = ch.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId
	WHERE i.intCommodityId = @intCommodityId  AND ISNULL(s.dblQuantity, 0) <> 0
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
		AND ISNULL(strTicketStatus, '') <> 'V'
		AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToDate)
		AND ysnInTransit = 0
		AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--=============================
	-- Transfer
	--=============================
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
		, strCustomer = s.strEntity
		, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
		--, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), dtmDate, 106), 8)
		, strDeliveryDate = dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
		, s.strLocationName
		, i.intItemId
		, s.strItemNo
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, strTruckName = ''
		, strDriverName = ''
		, dblStorageDue = NULL
		, s.intLocationId
		, intTransactionId
		, strTransactionId
		, strTransactionType
		, s.intCategoryId
		, s.strCategory
		, t.strDistributionOption
		, t.dtmTicketDateTime
		, t.intTicketId
		, t.strTicketNumber
		, intContractHeaderId = ch.intContractHeaderId
		, strContractNumber = ch.strContractNumber
		, strFutureMonth = fmnt.strFutureMonth
	INTO #tempTransfer
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i ON i.intItemId = s.intItemId
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intCommodityStockUOMId
	LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = s.intTransactionDetailId 
	LEFT JOIN tblCTContractHeader ch on cd.intContractHeaderId = ch.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId
	LEFT JOIN tblICInventoryReceiptItem IRI ON s.intTransactionId = IRI.intInventoryTransferId --Join here to determine if an IT has a corresponding transfer in
	WHERE i.intCommodityId = @intCommodityId  AND ISNULL(s.dblQuantity, 0) <> 0
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
		AND ISNULL(strTicketStatus, '') <> 'V'
		AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToDate)
		AND ysnInTransit = 1
		AND strTransactionForm IN('Inventory Transfer')
		AND IRI.intInventoryReceiptItemId IS NULL
		AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--=============================
	-- On Hold
	--=============================
	SELECT * INTO #tempOnHold
	FROM (
		SELECT intSeqId = ROW_NUMBER() OVER (PARTITION BY st.intTicketId ORDER BY st.dtmTicketDateTime DESC)
			, dblTotal = (CASE WHEN st.strInOutFlag = 'I' THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(st.dblNetUnits, 0))
							ELSE ABS(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(st.dblNetUnits, 0))) * -1 END)
			, strCustomerName = strName
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmTicketDateTime, 106), 8) COLLATE Latin1_General_CI_AS
			, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), dtmTicketDateTime, 106), 8) COLLATE Latin1_General_CI_AS
			, cl.strLocationName
			, i1.intItemId
			, i1.strItemNo
			, i1.intCategoryId
			, strCategory = Category.strCategoryCode
			, intCommodityId = @intCommodityId
			, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, strTruckName
			, strDriverName
			, dblStorageDue = NULL
			, intLocationId = st.intProcessingLocationId
			, strCustomerReference
			, strDistributionOption
			, e.intEntityId
			, intDeliverySheetId
			, st.dtmTicketDateTime
			, st.intTicketId
			, strTicketType = 'Scale Ticket' COLLATE Latin1_General_CI_AS
			, st.strTicketNumber
		FROM tblSCTicket st
		JOIN tblEMEntity e on e.intEntityId= st.intEntityId
		JOIN tblSMCompanyLocation  cl on cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
		JOIN tblICItem i1 on i1.intItemId=st.intItemId
		JOIN tblICCategory Category ON Category.intCategoryId = i1.intCategoryId
		JOIN tblICItemUOM iuom on i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE i1.intCommodityId  = @intCommodityId and isnull(st.intDeliverySheetId,0) =0
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
			AND ISNULL(st.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(st.intEntityId, 0))
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND ISNULL(strTicketStatus,'') = 'H'
	) t WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	AND t.intSeqId = 1
		
	--Inventory
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, strCustomerName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strReceiptNumber
		, intInventoryReceiptId
		, strDistributionOption
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, intTicketId
		, dtmTicketDateTime
		, strTransactionType
		, intContractHeaderId
		, strContractNumber
		, strFutureMonth)
	SELECT 1 AS intSeqId
		, strSeqHeader = 'In-House' COLLATE Latin1_General_CI_AS
		, strCommodityCode = @strCommodityCode
		, strType = 'Receipt' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, strLocationName
		, strCustomer
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, intCompanyLocationId = intLocationId
		, strTransactionId
		, intTransactionId
		, strDistributionOption
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, intTicketId
		, dtmTicketDateTime
		, strTransactionType
		, intContractHeaderId
		, strContractNumber
		, strFutureMonth
	FROM #invQty
	WHERE intCommodityId = @intCommodityId

	--Transfer
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, strCustomerName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strReceiptNumber
		, intInventoryReceiptId
		, strDistributionOption
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, intTicketId
		, dtmTicketDateTime
		, strTransactionType
		, intContractHeaderId
		, strContractNumber
		, strFutureMonth)
	SELECT 1 AS intSeqId
		, strSeqHeader = 'Transfer' COLLATE Latin1_General_CI_AS
		, strCommodityCode = @strCommodityCode
		, strType = 'Transfer' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, strLocationName
		, strCustomer
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, intCompanyLocationId = intLocationId
		, strTransactionId
		, intTransactionId
		, strDistributionOption
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, intTicketId
		, dtmTicketDateTime
		, strTransactionType
		, intContractHeaderId
		, strContractNumber
		, strFutureMonth
	FROM #tempTransfer
	WHERE intCommodityId = @intCommodityId

	--From Storages
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intInventoryReceiptId
		, intInventoryShipmentId
		, strReceiptNumber
		, strShipmentNumber
		, strDistributionOption
		, dtmTicketDateTime
		, intStorageScheduleTypeId
		, intContractHeaderId
		, strContractNumber)
	SELECT 1 AS intSeqId
		, strSeqHeader = 'In-House' COLLATE Latin1_General_CI_AS
		, strCommodityCode = @strCommodityCode
		, strType = strStorageType
		, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblBalance)
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, intCompanyLocationId
		, s.intInventoryReceiptId
		, s.intInventoryShipmentId
		, s.strReceiptNumber
		, s.strShipmentNumber
		, 'Storage' COLLATE Latin1_General_CI_AS
		, dtmTicketDateTime
		, intStorageScheduleTypeId
		,intContractNumber
		,strContractNumber
	FROM #tblGetStorageDetailByDate s
	JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
	WHERE intCommodityId = @intCommodityId
		AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		AND ysnDPOwnedType <> 1 AND strOwnedPhysicalStock <> 'Company' --Remove DP type storage in in-house. Stock already increases in IR.
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, dblStorageDue
		, intCompanyLocationId
		, dtmTicketDateTime)
	SELECT intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal = SUM(dblTotal)
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
		, dblStorageDue
		, intCompanyLocationId
		, dtmTicketDateTime
	FROM (
		SELECT DISTINCT intSeqId = 1
			, strSeqHeader = 'In-House' COLLATE Latin1_General_CI_AS
			, strCommodityCode = @strCommodityCode
			, strType = 'On-Hold' COLLATE Latin1_General_CI_AS
			, dblTotal
			, strCustomerName
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strContractEndMonth
			, strDeliveryDate
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intCommodityId
			, intCommodityUnitMeasureId
			, strTruckName
			, strDriverName
			, dblStorageDue
			, intCompanyLocationId = intLocationId
			, dtmTicketDateTime
		FROM #tempOnHold
		WHERE intCommodityId = @intCommodityId
	)t
	GROUP BY intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intCommodityUnitMeasureId
		, dblStorageDue
		, intCompanyLocationId
		, dtmTicketDateTime

	INSERT INTO @Final (intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId 
		, strLocationName
		, strItemNo
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, strCustomerName
		, strDPAReceiptNo
		, dblDiscDue
		, dblStorageDue
		, dtmLastStorageAccrueDate
		, strScheduleId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intInventoryReceiptId
		, strReceiptNumber)
	SELECT 2
		, 'Off-Site' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, 'Off-Site' COLLATE Latin1_General_CI_AS
		, dblTotal
		, intCommodityId
		, strLocationName
		, strItemNo
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, strCustomerName
		, strDPAReceiptNo
		, dblDiscDue
		, dblStorageDue
		, dtmLastStorageAccrueDate
		, strScheduleId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, intCompanyLocationId
		, intInventoryReceiptId
		, strReceiptNumber
	FROM (
		SELECT dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (dblBalance))
			, r.intCommodityId
			, strLocationName
			, r.intItemId
			, i.strItemNo
			, r.intCategoryId
			, r.strCategory
			, strContractEndMonth
			, strDeliveryDate
			, r.intTicketId
			, r.strTicketType
			, r.strTicketNumber
			, strCustomerName
			, strDPAReceiptNo = Receipt
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intCompanyLocationId
			, intInventoryReceiptId
			, strReceiptNumber
		FROM #tblGetStorageOffSiteDetail r
		JOIN tblICItem i ON r.intItemId = i.intItemId
		JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
		WHERE ysnReceiptedStorage = 1 AND ysnExternal = 1 AND strOwnedPhysicalStock = 'Customer' AND r.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	) t
	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	--========================
	--Customer Storage
	--==========================
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intInventoryReceiptId
		, intInventoryShipmentId
		, strReceiptNumber
		, strShipmentNumber
		, dtmTicketDateTime
		, intStorageScheduleTypeId)
	SELECT intSeqId = 5
		, strSeqHeader = strStorageType
		, strCommodityCode = @strCommodityCode
		, strType = strStorageType
		, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblBalance)
		, strCustomerName
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId = @intCommodityId
		, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
		, intCompanyLocationId
		, s.intInventoryReceiptId
		, s.intInventoryShipmentId
		, s.strReceiptNumber
		, s.strShipmentNumber
		, dtmTicketDateTime
		, intStorageScheduleTypeId
	FROM #tblGetStorageDetailByDate s
	JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
	WHERE s.strOwnedPhysicalStock = 'Customer' AND intCommodityId = @intCommodityId
		AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	IF (@ysnDisplayAllStorage = 1)
	BEGIN
		INSERT INTO @Final (intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, intCommodityId)
		SELECT DISTINCT 5
			, strStorageType = strStorageTypeDescription
			, @strCommodityCode
			, strStorageTypeDescription
			, 0.00
			, @intCommodityId
		FROM tblGRStorageScheduleRule SSR
		INNER JOIN tblGRStorageType ST ON SSR.intStorageType = ST.intStorageScheduleTypeId
		WHERE SSR.intCommodity = @intCommodityId
			AND ISNULL(ysnActive, 0) = 1 AND intStorageScheduleTypeId > 0 AND ysnReceiptedStorage = 0
			AND intStorageScheduleTypeId NOT IN (SELECT DISTINCT ISNULL(intStorageScheduleTypeId, 0) FROM @Final WHERE intSeqId = 5)
	END
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strCustomerName
		, strContractEndMonth
		, strDeliveryDate
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, dblStorageDue
		, intCompanyLocationId
		, intTicketId
		, strTicketType
		, strTicketNumber
		, dtmTicketDateTime
		, intInventoryReceiptId
		, intInventoryShipmentId
		, strReceiptNumber
		, strShipmentNumber)
	SELECT * FROM (
		SELECT intSeqId = 7
			, strSeqHeader = 'Total Non-Receipted' COLLATE Latin1_General_CI_AS
			, strCommodityCode = @strCommodityCode
			--, strStorageType = 'Total Non-Receipted'
			, r.strStorageType
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblBalance, 0))
			, r.strCustomerName
			, strContractEndMonth
			, strDeliveryDate
			, strLocationName
			, r.intItemId
			, r.strItemNo
			, r.intCategoryId
			, r.strCategory
			, intCommodityId = @intCommodityId
			, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, dblStorageDue
			, intCompanyLocationId
			, r.intTicketId
			, r.strTicketType
			, strTicketNumber
			, dtmTicketDateTime
			, r.intInventoryReceiptId
			, r.intInventoryShipmentId
			, r.strReceiptNumber
			, r.strShipmentNumber
		FROM #tblGetStorageDetailByDate r
		WHERE ysnReceiptedStorage = 0
			AND strOwnedPhysicalStock = 'Customer'
			AND r.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	) t
	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
	--Collatral Sale
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCollateralId
		, strLocationName
		, intItemId
		, strItemNo
		, strCategory
		, strCustomerName
		, strReceiptNo
		, intContractHeaderId
		, strContractNumber
		, dtmOpenDate
		, dblOriginalQuantity
		, dblRemainingQuantity
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strContractEndMonth
		, strDeliveryDate
		, strFutureMonth)
	SELECT * FROM (
		SELECT intSeqId = 8
			, strSeqHeader = CASE WHEN ysnIncludeInPriceRiskAndCompanyTitled = 1 THEN 'Warehouse Receipts - Sales' ELSE 'Collateral Receipts - Sales' END COLLATE Latin1_General_CI_AS
			, strCommodityCode = @strCommodityCode
			, strType = CASE WHEN ysnIncludeInPriceRiskAndCompanyTitled = 1 THEN 'Warehouse Receipts - Sales' ELSE 'Collateral Receipts - Sales' END COLLATE Latin1_General_CI_AS
			, dblTotal
			, intCollateralId
			, strLocationName
			, intItemId
			, strItemNo
			, strCategory
			, strEntityName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, intUnitMeasureId
			, intCompanyLocationId
			, intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strContractEndMonth
			, strDeliveryDate
			, strFutureMonth
		FROM #tempCollateral
		WHERE intContractTypeId = 2 AND intCommodityId = @intCommodityId
			AND intLocationId = ISNULL(@intLocationId, intLocationId)
	)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	-- Collatral Purchase
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCollateralId
		, strLocationName
		, intItemId
		, strItemNo
		, strCategory
		, strCustomerName
		, strReceiptNo
		, intContractHeaderId
		, strContractNumber
		, dtmOpenDate
		, dblOriginalQuantity
		, dblRemainingQuantity
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth)
	SELECT * FROM (
		SELECT intSeqId = 9 
			, strSeqHeader = CASE WHEN ysnIncludeInPriceRiskAndCompanyTitled = 1 THEN 'Warehouse Receipts - Purchase' ELSE 'Collateral Receipts - Purchase' END COLLATE Latin1_General_CI_AS
			, strCommodityCode = @strCommodityCode
			, strType = CASE WHEN ysnIncludeInPriceRiskAndCompanyTitled = 1 THEN 'Warehouse Receipts - Purchase' ELSE 'Collateral Receipts - Purchase' END COLLATE Latin1_General_CI_AS
			, dblTotal
			, intCollateralId
			, strLocationName
			, intItemId
			, strItemNo
			, strCategory
			, strEntityName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, intUnitMeasureId
			, intCompanyLocationId
			, intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strFutureMonth
		FROM #tempCollateral
		WHERE intContractTypeId = 1 AND intCommodityId = @intCommodityId
			AND intLocationId = ISNULL(@intLocationId, intLocationId)
	)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	INSERT INTO @Final (intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strContractEndMonth
		, strDeliveryDate
		, intTicketId
		, strTicketType
		, strTicketNumber
		, strCustomerName
		, strDPAReceiptNo
		, dblDiscDue
		, dblStorageDue
		, dtmLastStorageAccrueDate
		, strScheduleId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intInventoryReceiptId
		, strReceiptNumber)
	SELECT * FROM (
		SELECT intSeqId = 10
			, strStorageType
			, strCommodityCode = @strCommodityCode
			, strType = strStorageType
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(dblBalance))
			, r.intCommodityId 
			, strLocationName
			, r.intItemId
			, r.strItemNo
			, r.intCategoryId
			, r.strCategory
			, strContractEndMonth
			, strDeliveryDate
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strCustomerName
			, strDPAReceiptNo = Receipt
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, intCompanyLocationId
			, intInventoryReceiptId
			, strReceiptNumber
		FROM #tblGetStorageOffSiteDetail r
		JOIN tblICItem i ON r.intItemId = i.intItemId
		JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
		WHERE ysnReceiptedStorage = 1 AND ysnExternal <> 1 AND strOwnedPhysicalStock = 'Customer'
			AND r.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, strLocationName)
	SELECT intSeqId = 11
		, 'Total Receipted' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Collateral Purchase' COLLATE Latin1_General_CI_AS
		, dblTotal = - ISNULL(dblTotal, 0)
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strLocationName
	FROM @Final WHERE intSeqId = 9
		
	UNION ALL SELECT intSeqId = 11
		, 'Total Receipted' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Collateral Sale' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strLocationName
	FROM @Final WHERE intSeqId = 8
		
	UNION ALL SELECT intSeqId = 11
		, 'Total Receipted' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Collateral Receipted' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strLocationName
	FROM @Final WHERE intSeqId = 10
		
	INSERT INTO @Final (intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strContractEndMonth
		, strDeliveryDate
		, strTicketNumber
		, strCustomerName
		, strDPAReceiptNo
		, dblDiscDue
		, dblStorageDue
		, dtmLastStorageAccrueDate
		, strScheduleId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, intTicketId
		, dtmTicketDateTime)
	SELECT DISTINCT * FROM (
		SELECT intSeqId = 12
			, strStorageType
			, strCommodityCode = @strCommodityCode
			, strType = strStorageType
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblBalance, 0))
			, r.intCommodityId 
			, strLocationName
			, r.intItemId
			, r.strItemNo
			, r.intCategoryId
			, r.strCategory
			, strContractEndMonth
			, strDeliveryDate
			, strTicketNumber
			, strCustomerName
			, strDPAReceiptNo = Receipt
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, intCompanyLocationId
			, r.intTicketId
			, dtmTicketDateTime
		FROM #tblGetStorageDetailByDate r
		JOIN tblICItem i ON r.intItemId = i.intItemId
		JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
		WHERE ysnDPOwnedType = 1 AND r.intCommodityId = @intCommodityId
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
	)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	INSERT INTO @Final (intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strTicketNumber
		, dtmTicketDateTime
		, strDistributionOption
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strDPAReceiptNo
		, strContractNumber
		, intContractHeaderId
		, intInventoryReceiptId
		, strReceiptNumber
		, intFutureMonthId
		, intFutureMarketId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate)
	SELECT intSeqId = 13
		, strSeqHeader = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
		, strCommodityCode
		, strType = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
		, dblTotal = dblQuantity
		, BD.intCommodityId
		, strLocationName = BD.strCompanyLocation
		, BD.intItemId
		, BD.strItemNo
		, cat.intCategoryId
		, strCategory = cat.strCategoryCode
		, strTicketNumber = ''
		, dtmTicketDateTime = dtmDate
		, strDistributionOption = 'CNT' COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId = NULL
		, intCompanyLocationId
		, strDPAReceiptNo = BD.strTransactionId
		, strContractNumber = strContractNumber + '-' +LTRIM(intContractSeq) COLLATE Latin1_General_CI_AS
		, intContractHeaderId
		, intInventoryReceiptId = intTransactionId
		, strReceiptNumber = BD.strTransactionId
		, BD.intFutureMarketId
		, BD.intFutureMonthId
		, fm.strFutMarketName
		, mnt.strFutureMonth
		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
		, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
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
		
	INSERT INTO @Final (intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, strCategory
		, dtmTicketDateTime
		, strDistributionOption
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strDPAReceiptNo
		, intContractHeaderId
		, strContractNumber
		, intInventoryShipmentId
		, strShipmentNumber
		, strTicketNumber
		, intTicketId
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate)
	SELECT intSeqId = 14
		, strSeqHeader = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
		, strCommodityCode
		, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
		, dblTotal = dblQuantity
		, BD.intCommodityId
		, strLocationName = BD.strCompanyLocation
		, intItemId = BD.intItemId
		, strItemNo = BD.strItemNo
		, strCategory = cat.strCategoryCode
		, dtmTicketDateTime = dtmDate
		, strDistributionOption = 'CNT' COLLATE Latin1_General_CI_AS
		, intUnitMeasureId = NULL
		, intCompanyLocationId
		, strDPAReceiptNo = BD.strTransactionId
		, intContractHeaderId
		, strContractNumber
		, intInventoryShipmentId = BD.intTransactionId
		, strShipmentNumber = BD.strTransactionId
		, strTicketNumber = ''
		, intTicketId = NULL
		, BD.intFutureMarketId
		, BD.intFutureMonthId
		, fm.strFutMarketName
		, mnt.strFutureMonth
		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
		, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
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

	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intContractHeaderId
		, strContractNumber
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, strContractEndMonth)
	SELECT intSeqId = 3 
		, 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
		, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ReserveQty, 0))
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intContractHeaderId
		, strContractNumber
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strContractEndMonth
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
			, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
		FROM vyuRKPurchaseIntransitView i
		WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
			-- Not sure why this part doesn't default to zero values for non-value
			AND i.intPurchaseSale = 1 -- 1.Purchase 2. Sales
			AND i.intEntityId = ISNULL(@intVendorId, i.intEntityId)					
	) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strShipmentNumber
		, intInventoryShipmentId
		, strCustomerName
		, strCustomerReference
		, intContractHeaderId
		, strContractNumber
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, dtmTicketDateTime
		, intTicketId
		, strTicketNumber
		, strContractEndMonth
		, strFutureMonth
		, strDeliveryDate)
	SELECT intSeqId = 4
		, 'Sales In-Transit' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Sales In-Transit' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblBalanceToInvoice, 0)
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strShipmentNumber
		, intInventoryShipmentId
		, strCustomerReference
		, strCustomerReference
		, intContractHeaderId
		, strContractNumber
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, intCompanyLocationId
		, dtmTicketDateTime
		, intTicketId
		, strTicketNumber
		, strContractEndMonth
		, strFutureMonth
		, strDeliveryDate
	FROM (
		SELECT dblBalanceToInvoice 
			, i.strLocationName
			, i.intItemId
			, i.strItemNo
			, i.intCategoryId
			, i.strCategory
			, strContractNumber
			, intContractHeaderId
			, strShipmentNumber
			, intInventoryShipmentId
			, strCustomerReference
			, i.intCompanyLocationId
			, dtmTicketDateTime
			, intTicketId
			, strTicketNumber
			, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
			, strFutureMonth
			, strDeliveryDate
		FROM #tblGetSalesIntransitWOPickLot i
		WHERE i.intCommodityId = @intCommodityId
			AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
			AND i.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	)t

	--Company Title from Inventory Valuation
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, strCustomerName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strReceiptNumber
		, strShipmentNumber
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intTicketId
		, strTicketType
		, strTicketNumber
		, dtmTicketDateTime
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate
		, strContractNumber
		, intContractHeaderId)
	SELECT intSeqId = 15
		, strSeqHeader = 'Company Titled Stock' COLLATE Latin1_General_CI_AS
		, strCommodityCode
		, strType = 'Receipt' COLLATE Latin1_General_CI_AS
		, dblTotal
		, strLocationName
		, strCustomerName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strReceiptNumber
		, strShipmentNumber
		, f.intInventoryReceiptId
		, intInventoryShipmentId
		, intTicketId
		, strTicketType
		, strTicketNumber
		, dtmTicketDateTime
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate
		, strContractNumber
		, intContractHeaderId
	FROM @Final f
	WHERE strSeqHeader = 'In-House' AND strType = 'Receipt' AND intCommodityId = @intCommodityId --AND isnull(Strg.ysnDPOwnedType,0) = 0
		AND strReceiptNumber NOT IN (SELECT strTransactionId FROM #tempTransfer)
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth)
	SELECT * FROM (
		SELECT DISTINCT intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal = sum(dblTotal)
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strFutureMonth
		FROM (
			SELECT intSeqId = 15
				, strSeqHeader = 'Company Titled Stock' COLLATE Latin1_General_CI_AS
				, strCommodityCode = @strCommodityCode
				, strType
				, dblTotal = CASE WHEN strType = 'Warehouse Receipts - Purchase' THEN ISNULL(dblTotal, 0) ELSE - ISNULL(dblTotal, 0) END
				, intCommodityId = @intCommodityId
				, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, intFutureMonthId
				, strFutMarketName
				, strFutureMonth
				, strContractEndMonth
				, strDeliveryDate
				, strContractNumber
				, intContractHeaderId
			FROM @Final
			WHERE intSeqId IN (9,8) AND strType IN ('Warehouse Receipts - Purchase','Warehouse Receipts - Sales') AND intCommodityId = @intCommodityId
		) t GROUP BY intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, intFutureMonthId
			, strFutMarketName
			, strFutureMonth
			, strContractEndMonth
			, strDeliveryDate
			, strContractNumber
			, intContractHeaderId
	) t WHERE dblTotal <> 0	
		
	IF (@ysnIncludeOffsiteInventoryInCompanyTitled = 1)
	BEGIN
		INSERT INTO @Final (intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, intCommodityId
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strContractEndMonth
			, strDeliveryDate
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strCustomerName
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intFromCommodityUnitMeasureId
			, intCompanyLocationId
			, intInventoryReceiptId
			, strReceiptNumber
			, dtmTicketDateTime)
		SELECT intSeqId = 15
			, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
			, @strCommodityCode
			, 'Off-Site' COLLATE Latin1_General_CI_AS
			, dblTotal
			, intCommodityId
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strContractEndMonth
			, strDeliveryDate
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strCustomerName
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, intCompanyLocationId
			, intTicketId
			, strTicketNumber
			, dtmTicketDateTime
		FROM (
			SELECT dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (dblBalance))
				, CH.intCommodityId
				, strLocationName
				, CH.intItemId
				, CH.strItemNo
				, CH.intCategoryId
				, CH.strCategory
				, strContractEndMonth
				, strDeliveryDate
				, strCustomerName
				, strDPAReceiptNo = Receipt
				, dblDiscDue
				, dblStorageDue
				, dtmLastStorageAccrueDate
				, strScheduleId
				, intCompanyLocationId
				, intTicketId
				, strTicketType
				, strTicketNumber
				, dtmTicketDateTime
			FROM #tblGetStorageDetailByDate CH
			JOIN tblICItem i ON CH.intItemId = i.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			WHERE ysnCustomerStorage = 1 AND strOwnedPhysicalStock = 'Company' AND ysnDPOwnedType <> 1
				AND CH.intCommodityId = @intCommodityId
				AND CH.intCompanyLocationId = ISNULL(@intLocationId, CH.intCompanyLocationId)
		)t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	END
		
	--=========================================
	-- Includes DP based on Company Preference
	--========================================
	If (@ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
	BEGIN
		INSERT INTO @Final(intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, intTicketId
			, strTicketType
			, strTicketNumber
			, intFromCommodityUnitMeasureId
			, intCommodityId
			, strLocationName
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory)
		SELECT intSeqId = 15
			, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
			, @strCommodityCode
			, 'DP'
			, dblTotal = -sum(dblTotal)
			, intTicketId
			, strTicketType
			, strTicketNumber
			, intFromCommodityUnitMeasureId
			, intCommodityId
			, strLocationName
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
		FROM (
			SELECT DISTINCT intTicketId
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
			FROM #tblGetStorageDetailByDate ch
			WHERE ch.intCommodityId  = @intCommodityId
				AND ysnDPOwnedType = 1
				AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
		)t
		WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		GROUP BY intTicketId
			, strTicketType
			, strTicketNumber
			, intFromCommodityUnitMeasureId
			, intCommodityId
			, strLocationName
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
	END
		
	INSERT INTO @Final(intSeqId
		, strSeqHeader
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, dtmTicketDateTime
		, intTicketId
		, strTicketType
		, strTicketNumber)
	SELECT intSeqId = 15
		, strSeqHeader = 'On-Hold' COLLATE Latin1_General_CI_AS
		, strCommodityCode
		, strType
		, dblTotal
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, dtmTicketDateTime
		, intTicketId
		, strTicketType
		, strTicketNumber
	FROM @Final WHERE strSeqHeader = 'In-House' AND strType = 'On-Hold'

	--=========================================
	-- Includes intransit based on Company Preference
	--========================================

	IF (@ysnIncludeInTransitInCompanyTitled = 1)
	BEGIN
		INSERT INTO @Final(intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strShipmentNumber
			, intInventoryShipmentId
			, strCustomerReference
			, intContractHeaderId
			, strContractNumber
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, intCompanyLocationId
			, dtmTicketDateTime
			, intTicketId
			, strTicketNumber
			, strContractEndMonth
			, strFutureMonth
			, strDeliveryDate)
		SELECT intSeqId = 15
			, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
			, @strCommodityCode
			,'Sales In-Transit' COLLATE Latin1_General_CI_AS
			, dblTotal
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strShipmentNumber
			, intInventoryShipmentId
			, strCustomerReference
			, intContractHeaderId
			, strContractNumber
			, @intCommodityId
			, @intCommodityUnitMeasureId
			, intCompanyLocationId
			, dtmTicketDateTime
			, intTicketId
			, strTicketNumber
			, strContractEndMonth
			, strFutureMonth
			, strDeliveryDate
		FROM @Final WHERE strSeqHeader = 'Sales In-Transit' AND strType = 'Sales In-Transit'

		INSERT INTO @Final(intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intContractHeaderId
			, strContractNumber
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strContractEndMonth)
		SELECT intSeqId = 15
			, 'Company Titled Stock' COLLATE Latin1_General_CI_AS
			, @strCommodityCode
			, strType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
			, dblTotal
			, strLocationName
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intContractHeaderId
			, strContractNumber
			, @intCommodityId
			, @intCommodityUnitMeasureId
			, strContractEndMonth
		FROM @Final WHERE strSeqHeader = 'Purchase In-Transit' AND strType = 'Purchase In-Transit'
	END
		
	IF @ysnDisplayAllStorage = 0
	BEGIN
		INSERT INTO @FinalTable (intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strShipmentNumber
			, intInventoryShipmentId
			, strTransactionType
			, strFutureMonth)
		SELECT intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, um.strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, t.intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strShipmentNumber
			, intInventoryShipmentId
			, strTransactionType
			, strFutureMonth
		FROM @Final t
		LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId AND ISNULL(dblTotal, 0) <> 0
		ORDER BY intSeqId, strContractEndMonth, strDeliveryDate
	END
	ELSE
	BEGIN
		INSERT INTO @FinalTable (intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strShipmentNumber
			, intInventoryShipmentId
			, strTransactionType
			, strFutureMonth)
		SELECT intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, um.strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, t.intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strShipmentNumber
			, intInventoryShipmentId
			, strTransactionType
			, strFutureMonth
		FROM @Final t
		LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId AND intSeqId <> 5 AND dblTotal <> 0
			
		UNION ALL SELECT intSeqId
			, strSeqHeader
			, strCommodityCode
			, strType
			, dblTotal
			, um.strUnitMeasure
			, intCollateralId
			, strLocationName
			, strCustomerName
			, strReceiptNo
			, intContractHeaderId
			, strContractNumber
			, dtmOpenDate
			, dblOriginalQuantity
			, dblRemainingQuantity
			, t.intCommodityId
			, strCustomerReference
			, strDistributionOption
			, strDPAReceiptNo
			, dblDiscDue
			, dblStorageDue
			, dtmLastStorageAccrueDate
			, strScheduleId
			, strContractEndMonth
			, strDeliveryDate
			, dtmTicketDateTime
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, strTruckName
			, strDriverName
			, intInventoryReceiptId
			, strReceiptNumber
			, intTicketId
			, strTicketType
			, strTicketNumber
			, strShipmentNumber
			, intInventoryShipmentId
			, strTransactionType
			, strFutureMonth
		FROM @Final t
		LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId AND intSeqId = 5
		ORDER BY intSeqId, strContractEndMonth, strDeliveryDate
	END

	UPDATE @FinalTable SET strFutureMonth = CASE WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
												WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth)) END COLLATE Latin1_General_CI_AS
	FROM @FinalTable F
	
	UPDATE @FinalTable SET strContractEndMonth = CASE WHEN @strPositionBy = 'Futures Month'  THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
													WHEN @strPositionBy = 'Delivery Month' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By') END
	WHERE ISNULL(intContractHeaderId, '') <> ''

	UPDATE @FinalTable SET strContractEndMonth = NULL
						, strFutureMonth = NULL
						, strDeliveryDate = NULL
	WHERE ISNULL(intContractHeaderId, '') = ''

	IF (@strByType = 'ByLocation')
	BEGIN
		SELECT strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal = SUM(dblTotal)
			, intCommodityId
			, strLocationName
			, strTransactionType
		FROM @FinalTable
		WHERE strSeqHeader IN ('Company Titled Stock', 'In-House')
		GROUP BY strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, intCommodityId
			, strLocationName
			, strTransactionType
	END
	ELSE IF (@strByType = 'ByCommodity')
	BEGIN
		SELECT strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal = SUM(dblTotal)
			, intCommodityId
			, strTransactionType
		FROM @FinalTable
		WHERE strSeqHeader IN ('Company Titled Stock', 'In-House')
		GROUP BY strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, intCommodityId
			, strTransactionType
	END
	ELSE
	BEGIN
		IF ISNULL(@intVendorId, 0) = 0
		BEGIN
			SELECT intRow
				, intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal
				, strUnitMeasure
				, intCollateralId
				, strLocationName
				, strCustomerName
				, strReceiptNo
				, intContractHeaderId
				, strContractNumber
				, dtmOpenDate
				, dblOriginalQuantity
				, dblRemainingQuantity
				, intCommodityId
				, strCustomerReference
				, strDistributionOption
				, strDPAReceiptNo
				, dblDiscDue
				, dblStorageDue
				, dtmLastStorageAccrueDate
				, strScheduleId
				, intTicketId
				, strTicketType
				, strTicketNumber = ISNULL(strTicketNumber, '')
				, strContractEndMonth
				, strDeliveryDate
				, dtmTicketDateTime
				, intItemId
				, strItemNo
				, strTruckName
				, strDriverName
				, intInventoryReceiptId
				, strReceiptNumber = ISNULL(strReceiptNumber, '')
				, strShipmentNumber = ISNULL(strShipmentNumber, '')
				, intInventoryShipmentId
				, strTransactionType
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM @FinalTable
			ORDER BY strCommodityCode
				, intSeqId ASC
				, intContractHeaderId DESC
		END
		ELSE
		BEGIN
			SELECT intRow
				, intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal
				, strUnitMeasure
				, intCollateralId
				, strLocationName
				, strCustomerName
				, strReceiptNo
				, intContractHeaderId
				, strContractNumber
				, dtmOpenDate
				, dblOriginalQuantity
				, dblRemainingQuantity
				, intCommodityId
				, strCustomerReference
				, strDistributionOption
				, strDPAReceiptNo
				, dblDiscDue
				, dblStorageDue
				, dtmLastStorageAccrueDate
				, strScheduleId
				, intTicketId
				, strTicketType
				, strTicketNumber = ISNULL(strTicketNumber, '')
				, strContractEndMonth
				, strDeliveryDate
				, dtmTicketDateTime
				, intItemId
				, strItemNo
				, strTruckName
				, strDriverName
				, intInventoryReceiptId
				, strReceiptNumber = ISNULL(strReceiptNumber, '')
				, strShipmentNumber = ISNULL(strShipmentNumber, '')
				, intInventoryShipmentId
				, strTransactionType
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, strFutMarketName
				, intFutureMonthId
				, strFutureMonth
				, strBrokerTradeNo
				, strNotes
				, ysnPreCrush
			FROM @FinalTable 
			WHERE strSeqHeader NOT IN ('Company Titled Stock','Sales In-Transit')
				AND strType <> 'Receipt' 
				-- and strType not like '%'+@strPurchaseSales+'%'
			ORDER BY strCommodityCode, intSeqId ASC, intContractHeaderId DESC
		END
	END

	------------------------------------------
	------------ Contract Hedge --------------
	------------------------------------------

	DECLARE @CrushReport BIT = 1
	
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
	
	DECLARE @FinalCH AS TABLE (intRow INT IDENTITY
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
	FROM fnRKGetOpenFutureByDate(@intCommodityId, '1/1/1900', @dtmToDate, @CrushReport)

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
				JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
				LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
				INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = oc.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
				WHERE th.intCommodityId = @intCommodityId
					AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
					AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
					AND ISNULL(oc.ysnPreCrush, 0) = 1) t

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
		If (@ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
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
			, strInternalTradeNo)
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
								
		IF (@ysnIncludeOffsiteInventoryInCompanyTitled = 1)
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
				
		IF (@ysnIncludeInTransitInCompanyTitled = 1)
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
				, strContractNumber)
			SELECT strCommodityCode = @strCommodityCode
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
				, intInventoryShipmentId)
			SELECT strCommodityCode = @strCommodityCode
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
				
		INSERT INTO @FinalCH (intCommodityId
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
				
				
		INSERT INTO @FinalCH (intCommodityId
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
	
	UPDATE @FinalCH SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
	UPDATE @FinalCH SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
	UPDATE @FinalCH SET intSeqNo = 3 WHERE strType = 'Net Hedge'
	UPDATE @FinalCH SET intSeqNo = 4 WHERE strType = 'Crush'
	UPDATE @FinalCH SET intSeqNo = 5 WHERE strType = 'Price Risk'
	UPDATE @FinalCH SET intSeqNo = 6 WHERE strType = 'Basis Risk'
	UPDATE @FinalCH SET intSeqNo = 11 WHERE strType = 'Avail for Spot Sale'
	
	UPDATE @FinalCH SET strFutureMonth = CASE 
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
		WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
	END COLLATE Latin1_General_CI_AS
	FROM @FinalCH F
	LEFT JOIN (
		SELECT intFutOptTransactionHeaderId
			,strInternalTradeNo
			,strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
		FROM vyuRKFutOptTransaction
	)FOT ON FOT.intFutOptTransactionHeaderId = F.intFutOptTransactionHeaderId AND FOT.strInternalTradeNo COLLATE Latin1_General_CI_AS = F.strInternalTradeNo COLLATE Latin1_General_CI_AS
	
	UPDATE @FinalCH SET strContractEndMonth = CASE 
			WHEN @strPositionBy = 'Futures Month'  THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
		END

	UPDATE @FinalCH SET strContractEndMonth = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
	WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''
	
	IF (@strByType = 'ByCommodity')
	BEGIN
		SELECT DISTINCT c.strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal = SUM(dblTotal)
			, c.intCommodityId
		FROM @FinalCH f
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
		FROM @FinalCH f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
		GROUP BY c.strCommodityCode
			, strUnitMeasure
			, strType
			, c.intCommodityId
			, strLocationName
	END
	ELSE
	BEGIN 
		IF ISNULL(@intVendorId, 0) = 0
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
			FROM @FinalCH f
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
			FROM @FinalCH f
			JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
			WHERE dblTotal <> 0 AND strSubType NOT LIKE '%' + @strPurchaseSales + '%'
			ORDER BY intSeqNo
				, strType ASC
				, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
		END
	END

	------------------------------------------
	------- Contract Hedge By Month ----------
	------------------------------------------

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
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		, ysnPreCrush BIT)
	
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
		, dblTotal DECIMAL(24,10)
		, intSeqNo INT
		, strUnitMeasure NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strAccountNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strTranType NVARCHAR(20) COLLATE Latin1_General_CI_AS
		, dblNoOfLot NUMERIC(24, 10)
		, dblDelta NUMERIC(24, 10)
		, intBrokerageAccountId int
		, strInstrumentType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strEntityName NVARCHAR(100) COLLATE Latin1_General_CI_AS
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
		, ysnPreCrush BIT)
	
			
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
		, strFutureMonth)
	SELECT strCommodityCode
		, intCommodityId
		, intContractHeaderId
		, strContractNumber
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal
		, intUnitMeasureId
		, strEntityName
		, intItemId
		, strItemNo
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
	FROM (
		SELECT DISTINCT strCommodityCode
			, CD.intCommodityId
			, intContractHeaderId
			, strContractNumber
			, CD.strType
			, strLocationName
			, strContractEndMonthNearBy = RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8) COLLATE Latin1_General_CI_AS
			, dblTotal = (CASE WHEN intContractTypeId = 1 THEN  ISNULL(CD.dblBalance, 0)
							ELSE - ISNULL(CD.dblBalance, 0) END)
			, CD.intUnitMeasureId
			, CD.strEntityName
			, intItemId
			, strItemNo
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, CD.strContractEndMonth
		FROM @tblGetOpenContractDetail CD
		WHERE intContractTypeId IN (1,2) AND CD.intCommodityId = @intCommodityId
			AND CD.intContractStatusId <> 3
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intLocationId END
			AND  CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END
	) t
			
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
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, strFutMarketName)
	SELECT strCommodityCode
		, intCommodityId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, 'Net Hedge' COLLATE Latin1_General_CI_AS
		, strLocationName
		, strFutureMonth = RIGHT(CONVERT(VARCHAR(11), strFutureMonth, 106), 8) COLLATE Latin1_General_CI_AS
		, dtmFutureMonthsDate = RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8) COLLATE Latin1_General_CI_AS
		, HedgedQty
		, intUnitMeasureId
		, strAccountNumber
		, strTranType
		, intBrokerageAccountId
		, strInstrumentType
		, dblNoOfLot
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, t.strFutureMarket
	FROM (
		SELECT DISTINCT t.strCommodityCode
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, th.intCommodityId
			, dtmFutureMonthsDate
			, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc1.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblOpenContract, 0) * t.dblContractSize)
			, l.strLocationName
			, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2),intYear) COLLATE Latin1_General_CI_AS
			, m.intUnitMeasureId
			, strAccountNumber = e.strName + '-' + ba.strAccountNumber COLLATE Latin1_General_CI_AS
			, strTranType = strNewBuySell
			, ba.intBrokerageAccountId
			, t.strInstrumentType as strInstrumentType
			, dblNoOfLot = ISNULL(dblOpenContract, 0)
			, ysnPreCrush
			, t.strNotes
			, strBrokerTradeNo
			, t.strFutureMarket
		FROM @tblGetOpenFutureByDate t
		JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
		JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
		JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
		LEFT JOIN tblRKBrokerageAccount ba ON ba.strAccountNumber = t.strBrokerAccount
		INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Futures'
		JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
		WHERE th.intCommodityId IN (SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ','))
			AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
			AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	) t
			
	--Option NetHEdge
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
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, ysnPreCrush
		, strNotes
		, strBrokerTradeNo
		, strFutMarketName)
	SELECT DISTINCT t.strCommodityCode
		, th.intCommodityId
		, t.strInternalTradeNo
		, intFutOptTransactionHeaderId
		, 'Net Hedge' COLLATE Latin1_General_CI_AS
		, t.strLocationName
		, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear) COLLATE Latin1_General_CI_AS
		, dtmFutureMonthsDate = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), fm.intYear) COLLATE Latin1_General_CI_AS
		, dblTotal = (dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
												FROM tblRKFuturesSettlementPrice sp
												INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
												WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId 
													AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
													AND t.dblStrike = mm.dblStrike
												ORDER BY dtmPriceDate DESC), 0) * m.dblContractSize)
		, m.intUnitMeasureId 
		, strAccountNumber = e.strName + '-' + strAccountNumber COLLATE Latin1_General_CI_AS
		, TranType = strNewBuySell
		, dblNoOfLot = dblOpenContract
		, dblDelta = ISNULL((SELECT TOP 1 dblDelta
									FROM tblRKFuturesSettlementPrice sp
									INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
									WHERE intFutureMarketId = m.intFutureMarketId AND mm.intOptionMonthId = om.intOptionMonthId
										AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
										AND t.dblStrike = mm.dblStrike
									ORDER BY dtmPriceDate DESC), 0)
		, ba.intBrokerageAccountId
		, strInstrumentType = 'Options' COLLATE Latin1_General_CI_AS
		, ysnPreCrush
		, t.strNotes
		, strBrokerTradeNo
		, t.strFutureMarket
	FROM @tblGetOpenFutureByDate t
	JOIN tblICCommodity th ON th.strCommodityCode = t.strCommodityCode
	JOIN tblSMCompanyLocation l ON l.strLocationName = t.strLocationName
	JOIN tblRKFutureMarket m ON m.strFutMarketName = t.strFutureMarket
	JOIN tblRKOptionsMonth om ON om.strOptionMonth = t.strOptionMonth
	INNER JOIN tblRKBrokerageAccount ba ON t.strBrokerAccount = ba.strAccountNumber
	INNER JOIN tblEMEntity e ON e.strName = t.strBroker AND t.strInstrumentType = 'Options'
	INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = t.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
	WHERE th.intCommodityId = @intCommodityId AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
		AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
		AND e.intEntityId = ISNULL(@intVendorId, e.intEntityId)
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
	--Net Hedge option end			
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
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intFutureMarketId
		, strFutMarketName
		, intFutureMonthId
		, strFutureMonth
		, strContractEndMonth
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @List t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	WHERE t.intCommodityId = @intCommodityId
	
	UPDATE @FinalList SET strContractEndMonth = 'Near By' WHERE CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, GETDATE())
	DELETE FROM @List

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
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal =  isnull(dblTotal, 0)
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
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
	FROM @FinalList
	WHERE strContractEndMonth = 'Near By'

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
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
		, strType
		, strLocationName
		, strContractEndMonth
		, strContractEndMonthNearBy
		, dblTotal = isnull(dblTotal,0)
		, strUnitMeasure
		, strAccountNumber
		, strTranType
		, dblNoOfLot
		, dblDelta
		, intBrokerageAccountId
		, strInstrumentType
		, strEntityName
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
	FROM @FinalList
	WHERE strContractEndMonth <> 'Near By'
	ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

	IF isnull(@intVendorId,0) = 0
	BEGIN
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
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Position' COLLATE Latin1_General_CI_AS
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal = ISNULL(dblTotal,0)
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
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
		FROM @List
	END
	ELSE
	BEGIN
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
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Position' COLLATE Latin1_General_CI_AS
			, strLocationName
			, strContractEndMonth
			, strContractEndMonthNearBy
			, dblTotal = ISNULL(dblTotal,0)
			, strUnitMeasure
			, strAccountNumber
			, strTranType
			, dblNoOfLot
			, dblDelta
			, intBrokerageAccountId
			, strInstrumentType
			, strEntityName
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
		FROM @List
		WHERE strType NOT LIKE '%'+@strPurchaseSales+'%' AND  strType<>'Net Hedge'
	END

	--This is used to insert strType so that it will be displayed properly on Position Report Detail by Month (RM-1902)
	INSERT INTO @List (strCommodityCode
		, strContractNumber
		, intContractHeaderId
		, strInternalTradeNo
		, intFutOptTransactionHeaderId
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
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush)
	SELECT DISTINCT strCommodityCode
		, strContractNumber = NULL
		, intContractHeaderId = NULL
		, strInternalTradeNo = NULL
		, intFutOptTransactionHeaderId = NULL
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
		, strBrokerTradeNo
		, strNotes
		, ysnPreCrush
	FROM @List

	UPDATE @List SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
	UPDATE @List SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
	UPDATE @List SET intSeqNo = 3 WHERE strType = 'Net Hedge'
	UPDATE @List SET intSeqNo = 4 WHERE strType = 'Position'

	DECLARE @strType NVARCHAR(MAX)
	DECLARE @strContractEndMonth NVARCHAR(MAX)
	SELECT TOP 1 @strType = strType
		, @strContractEndMonth = strContractEndMonth
	FROM @List
	ORDER BY intRowNumber ASC

	IF (ISNULL(@intVendorId, 0) = 0)
	BEGIN
		SELECT intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), strContractEndMonth, 106), 8) COLLATE Latin1_General_CI_AS
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
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), strContractEndMonth, 106), 8) COLLATE Latin1_General_CI_AS
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
		WHERE dblTotal IS NULL OR dblTotal <> 0
		ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END
	ELSE
	BEGIN
		SELECT intSeqNo
			, intRowNumber
			, strCommodityCode
			, strContractNumber
			, intContractHeaderId
			, strInternalTradeNo
			, intFutOptTransactionHeaderId
			, strType
			, strLocationName
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11),strContractEndMonth,106),8) COLLATE Latin1_General_CI_AS
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
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate = RIGHT(CONVERT(VARCHAR(11), strContractEndMonth, 106), 8) COLLATE Latin1_General_CI_AS
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM @List
		WHERE (dblTotal IS NULL
			OR dblTotal <> 0)
			AND strType NOT LIKE '%' + @strPurchaseSales + '%'
			AND strType <> 'Net Hedge'
		ORDER BY  CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END

	------------------------------------------
	-------------- Pre Crush -----------------
	------------------------------------------
	
	DECLARE @ListPreCrush AS TABLE (intRowNumber INT IDENTITY
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
		, ysnPreCrush BIT)
	DECLARE @FinalListCrush AS TABLE (intRowNumber INT IDENTITY
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
		, ysnPreCrush BIT)
	DECLARE @InventoryStock AS TABLE (strCommodityCode NVARCHAR(100)
		, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, dblTotal numeric(24,10)
		, strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
		, intCommodityId int
		, intFromCommodityUnitMeasureId int
		, strType nvarchar(100) COLLATE Latin1_General_CI_AS
		, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		, intPricingTypeId int)


	INSERT INTO @ListPreCrush (strCommodityCode
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
			
	INSERT INTO @FinalListCrush (strCommodityCode
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
	FROM @ListPreCrush t
	JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
	JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
	WHERE t.intCommodityId = @intCommodityId

		

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
		, strInventoryType)
	SELECT strCommodityCode
		, strItemNo
		, strCategoryCode
		, dblTotal = dblTotal
		, strLocationName
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, strInventoryType
	FROM (
		SELECT strCommodityCode
			, i.strItemNo
			, Category.strCategoryCode
			, dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
			, strLocationName
			, intCommodityId = @intCommodityId
			, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
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
	If (@ysnIncludeDPPurchasesInCompanyTitled =0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
	BEGIN
		INSERT INTO @InventoryStock(strCommodityCode
			, strItemNo
			, strCategory
			, dblTotal
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strInventoryType)
		SELECT strCommodityCode
			, strItemNo
			, strCategory
			, dblTotal = -sum(dblTotal)
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, 'Company Titled' COLLATE Latin1_General_CI_AS
		FROM (
			SELECT DISTINCT intTicketId
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
			, strInventoryType)
		SELECT strCommodityCode
			, strItemNo
			, strCategory
			, dblTotal = -sum(dblTotal)
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, 'Delayed Pricing' COLLATE Latin1_General_CI_AS
		FROM (
			SELECT DISTINCT intTicketId
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
	END



	INSERT INTO @FinalListCrush(intContractHeaderId
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
		, strDeliveryDate)
	SELECT intContractHeaderId
		, strContractNumber
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

	INSERT INTO @FinalListCrush(intContractHeaderId
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

	IF (@ysnIncludeInTransitInCompanyTitled = 1)
	BEGIN
		INSERT INTO @InventoryStock(strCommodityCode
			, dblTotal
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strInventoryType)
		SELECT strCommodityCode
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
				, i.intCompanyLocationId
				, c.strCommodityCode
				, c.intCommodityId
				, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
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
		SELECT strCommodityCode
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
				, c.strCommodityCode
				, c.intCommodityId
			FROM #tblGetSalesIntransitWOPickLot i
			join tblICCommodity c on i.intCommodityId = c.intCommodityId
			WHERE i.intCommodityId = @intCommodityId
				AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
				AND i.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		) t GROUP BY strCommodityCode
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
	END

	UPDATE @FinalListCrush
	SET strContractEndMonth = 'Near By'
	WHERE strContractEndMonth <> 'Near By'
		AND CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110))

	DELETE FROM @ListPreCrush

	INSERT INTO @ListPreCrush(intContractHeaderId
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
	FROM @FinalListCrush
	WHERE strType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')

	INSERT INTO @ListPreCrush (strCommodityCode
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
	FROM @FinalListCrush
	WHERE strContractEndMonth = 'Near By' AND strType IN ('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')

	INSERT INTO @ListPreCrush (strCommodityCode
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
	FROM @FinalListCrush 
	WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')
	ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

	INSERT INTO @ListPreCrush (strCommodityCode
		, strItemNo
		, strCategory
		, dblTotal
		, strContractEndMonth
		, strLocationName
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intOrderId
		, strType
		, strInventoryType)
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
	FROM @InventoryStock
	WHERE strInventoryType IN ('Delayed Pricing')

	INSERT INTO @ListPreCrush (strCommodityCode
		, strItemNo
		, strCategory
		, dblTotal
		, strContractEndMonth
		, strLocationName
		, intCommodityId
		, intFromCommodityUnitMeasureId
		, intOrderId
		, strType
		, strInventoryType)
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
	FROM @InventoryStock
	WHERE strInventoryType IN ('Company Titled', 'Collateral','Purchase In-Transit','Sales In-Transit')


	INSERT INTO @ListPreCrush (strCommodityCode
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
		, strContractEndMonth
		, strContractEndMonthNearBy = strContractEndMonth
		, intContractHeaderId
	FROM @ListPreCrush WHERE intOrderId in(1, 2, 3, 4, 5, 6, 7, 8)

	INSERT INTO @ListPreCrush (strCommodityCode
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
		JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
		INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = oc.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
		WHERE th.intCommodityId = @intCommodityId
			AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
			AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
			AND ISNULL(oc.ysnPreCrush, 0) = 0) t

	INSERT INTO @ListPreCrush (strCommodityCode
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
		WHERE th.intCommodityId = @intCommodityId
			AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
			AND ISNULL(oc.ysnPreCrush, 0) = 0) t

	-- Crush records
	IF (@ysnPreCrush = 1)
	BEGIN
		INSERT INTO @ListPreCrush (strCommodityCode
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
			JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND m.intUnitMeasureId = cuc1.intUnitMeasureId
			LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
			INNER JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = oc.strFutureMonth AND fm.intFutureMarketId = m.intFutureMarketId
			WHERE th.intCommodityId = @intCommodityId
				AND l.intCompanyLocationId = ISNULL(@intLocationId, l.intCompanyLocationId)
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				AND ISNULL(oc.ysnPreCrush, 0) = 1) t

		IF NOT EXISTS (SELECT TOP 1 1 FROM @ListPreCrush WHERE intOrderId = 14)
		BEGIN
			INSERT INTO @ListPreCrush (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
			SELECT 	TOP 1 strCommodityCode,0,'Near By' COLLATE Latin1_General_CI_AS,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,14,'Crush' COLLATE Latin1_General_CI_AS,'Buy' COLLATE Latin1_General_CI_AS FROM @List
		END
	END

	----------------

	INSERT INTO @ListPreCrush (strCommodityCode
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
	FROM @ListPreCrush WHERE intOrderId IN (12, 14, 15)
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

	INSERT INTO @ListPreCrush (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure)
	SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,23 intOrderId,'Net Unpriced Position' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure from @ListPreCrush where intOrderId in(19, 20, 21, 22)

	INSERT INTO @ListPreCrush (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
	SELECT strCommodityCode,ROUND(dblTotal,2),strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,25 intOrderId,'Basis Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @ListPreCrush where intOrderId in(1, 2, 8, 19, 20)

	INSERT INTO @ListPreCrush (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
	SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,26 intOrderId,'Price Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @ListPreCrush where intOrderId in(9, 16)

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
		, ysnPreCrush BIT)

	DECLARE @MonthOrderList AS TABLE (		
			strContractEndMonth NVARCHAR(100) COLLATE Latin1_General_CI_AS)

	insert into @MonthOrderList
	SELECT distinct  strContractEndMonth FROM @ListPreCrush where strContractEndMonth <> 'Near By' 

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
	SELECT TOP 1 strType,strCommodityCode from @ListPreCrush 

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
		, ysnPreCrush)
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
	FROM @ListPreCrush
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
		, ysnPreCrush)
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
	FROM @ListPreCrush 
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


	SELECT intSeqNo = intOrderId
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
		, intSeqNo
		, strType

	DROP TABLE #LicensedLocation
END