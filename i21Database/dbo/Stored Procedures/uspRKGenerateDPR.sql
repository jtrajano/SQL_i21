CREATE PROCEDURE [dbo].[uspRKGenerateDPR]
	@GUID UNIQUEIDENTIFIER = NULL
	, @intCommodityId INT
	, @intLocationId INT = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(250) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL
	, @strPositionBy NVARCHAR(50) = NULL
	, @ysnCrush BIT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY
	--DECLARE @GUID UNIQUEIDENTIFIER = NULL
--  , @intCommodityId INT
--	, @intLocationId INT = NULL
--	, @intVendorId INT = NULL
--	, @strPurchaseSales NVARCHAR(250) = NULL
--	, @strPositionIncludes NVARCHAR(100) = NULL
--	, @dtmToDate DATETIME = NULL
--	, @strByType NVARCHAR(50) = NULL
--	, @strPositionBy NVARCHAR(50) = NULL
--	, @ysnCrush BIT = NULL

	DECLARE @ErrMsg NVARCHAR(MAX)
		, @intDPRHeaderId INT



	IF (ISNULL(@GUID, '') = '')
	BEGIN
		SET @GUID = NEWID()

		INSERT INTO tblRKDPRHeader(imgReportId
			, intCommodityId
			, intLocationId
			, intEntityId
			, strPurchaseSale
			, strPositionIncludes
			, dtmEndDate
			, strPositionBy
			, ysnCrush)
		VALUES (@GUID
			, @intCommodityId
			, @intLocationId
			, @intVendorId
			, @strPurchaseSales
			, @strPositionIncludes
			, @dtmToDate
			, @strPositionBy
			, @ysnCrush)

		SET @intDPRHeaderId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		SELECT TOP 1 @intDPRHeaderId = intDPRHeaderId FROM tblRKDPRHeader WHERE CAST(imgReportId AS NVARCHAR(100)) = CAST(@GUID AS NVARCHAR(100))

		DELETE FROM tblRKDPRInventory WHERE intDPRHeaderId = @intDPRHeaderId
		DELETE FROM tblRKDPRContractHedge WHERE intDPRHeaderId = @intDPRHeaderId
		DELETE FROM tblRKDPRContractHedgeByMonth WHERE intDPRHeaderId = @intDPRHeaderId
		DELETE FROM tblRKDPRYearToDate WHERE intDPRHeaderId = @intDPRHeaderId
	END


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
	IF OBJECT_ID('tempdb..#tmpContractBalance') IS NOT NULL
		DROP TABLE #tmpContractBalance
	IF OBJECT_ID('tempdb..#tempBasisDelivery') IS NOT NULL
		DROP TABLE #tempBasisDelivery
	IF OBJECT_ID('tempdb..#tempFutures') IS NOT NULL
		DROP TABLE #tempFutures
	IF OBJECT_ID('tempdb..#tempPurchaseInTransit') IS NOT NULL
		DROP TABLE #tempPurchaseInTransit
	IF OBJECT_ID('tempdb..#LicensedLocation') IS NOT NULL
		DROP TABLE #LicensedLocation
	
	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE ISNULL(ysnLicensed, 0) END

	------------------------------------------
	-------------- Inventory -----------------
	------------------------------------------
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
	INTO #tmpContractBalance
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
			, dblBalanceToInvoice = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL((InTran.dblInTransitQty), 0)) 
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), InTran.dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
			, strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblCTContractDetail cd INNER JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId WHERE intContractHeaderId = SI.intLineNo)
			, strDeliveryDate = (SELECT TOP 1 dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') FROM tblCTContractDetail WHERE intContractHeaderId = SI.intLineNo)
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
			AND ISNULL(Inv.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(Inv.intEntityId, 0))
			AND Com.intCommodityId = @intCommodityId
			AND Inv.intLocationId = ISNULL(@intLocationId, Inv.intLocationId)
			AND Inv.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	)t
		
	SELECT * INTO #tempCollateral
	FROM (
		SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY c.intCollateralId ORDER BY c.dtmOpenDate DESC)
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,c.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount, 0))
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
			, dblOriginalQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL((c.dblOriginalQuantity), 0))
			, dblRemainingQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,c.dblOriginalQuantity - ISNULL(ca.dblAdjustmentAmount, 0))
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
			, ium.intCommodityUnitMeasureId
		FROM tblRKCollateral c
		LEFT JOIN (
			SELECT intCollateralId, sum(dblAdjustmentAmount) as dblAdjustmentAmount FROM tblRKCollateralAdjustment 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmAdjustmentDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			GROUP BY intCollateralId
		) ca ON c.intCollateralId = ca.intCollateralId
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
		LEFT JOIN #tmpContractBalance ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
		WHERE c.intCommodityId = @intCommodityId AND CONVERT(DATETIME, CONVERT(VARCHAR(10), c.dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
			and cl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	) a WHERE a.intRowNum = 1

	--=============================
	-- Inventory Valuation
	--=============================
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))
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
	LEFT JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId
	WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <> 0
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
		AND ISNULL(strTicketStatus, '') <> 'V'
		AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToDate)
		AND ysnInTransit = 0
		AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--=============================
	-- Transfer
	--=============================
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity , 0)))
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
	LEFT JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId
	LEFT JOIN tblICInventoryReceiptItem IRI ON s.intTransactionId = IRI.intInventoryTransferId --Join here to determine if an IT has a corresponding transfer in
	WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity, 0) <> 0
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
		AND ISNULL(strTicketStatus, '') <> 'V'
		AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToDate)
		AND ysnInTransit = 1
		AND strTransactionForm IN('Inventory Transfer')
		AND IRI.intInventoryReceiptItemId IS NULL
		AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--=============================
	-- ON Hold
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
		JOIN tblEMEntity e ON e.intEntityId= st.intEntityId
		JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
		JOIN tblICItem i1 ON i1.intItemId=st.intItemId
		JOIN tblICCategory Category ON Category.intCategoryId = i1.intCategoryId
		JOIN tblICItemUOM iuom ON i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
		WHERE i1.intCommodityId = @intCommodityId and ISNULL(st.intDeliverySheetId, 0) =0
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
			AND ISNULL(st.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(st.intEntityId, 0))
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
			AND ISNULL(strTicketStatus,'') = 'H'
	) t WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	AND t.intSeqId = 1
	
	DECLARE @ListInventory AS TABLE (intRow INT IDENTITY PRIMARY KEY
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
		
	DECLARE @FinalInventory AS TABLE (intRow INT IDENTITY PRIMARY KEY
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
		, dblOriginalQuantity DECIMAL(24,10)
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
	
	--Inventory
	INSERT INTO @ListInventory(intSeqId
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
	INSERT INTO @ListInventory(intSeqId
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
	INSERT INTO @ListInventory(intSeqId
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
		
	INSERT INTO @ListInventory(intSeqId
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

	INSERT INTO @ListInventory(intSeqId
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
	INSERT INTO @ListInventory(intSeqId
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
		INSERT INTO @ListInventory (intSeqId
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
			AND intStorageScheduleTypeId NOT IN (SELECT DISTINCT ISNULL(intStorageScheduleTypeId, 0) FROM @ListInventory WHERE intSeqId = 5)
	END
		
	INSERT INTO @ListInventory(intSeqId
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
	INSERT INTO @ListInventory(intSeqId
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
	INSERT INTO @ListInventory(intSeqId
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
		
	INSERT INTO @ListInventory (intSeqId
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
		
	INSERT INTO @ListInventory(intSeqId
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
	FROM @ListInventory WHERE intSeqId = 9
		
	UNION ALL SELECT intSeqId = 11
		, 'Total Receipted' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Collateral Sale' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strLocationName
	FROM @ListInventory WHERE intSeqId = 8
		
	UNION ALL SELECT intSeqId = 11
		, 'Total Receipted' COLLATE Latin1_General_CI_AS
		, @strCommodityCode
		, strType = 'Collateral Receipted' COLLATE Latin1_General_CI_AS
		, dblTotal = ISNULL(dblTotal, 0)
		, @intCommodityId
		, @intCommodityUnitMeasureId
		, strLocationName
	FROM @ListInventory WHERE intSeqId = 10
		
	INSERT INTO @ListInventory (intSeqId
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

	SELECT strCommodityCode
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
		, intTransactionId
		, strTransactionId
		, BD.intFutureMarketId
		, BD.intFutureMonthId
		, fm.strFutMarketName
		, mnt.strFutureMonth
		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
		, strDeliveryDate = dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy')
		, strContractType
		, strCurrency
		, BD.strCustomerVendor
		, BD.intContractSeq
	INTO #tempBasisDelivery
	FROM dbo.fnCTGetBasisDelivery(@dtmToDate) BD
	INNER JOIN tblRKFutureMarket fm ON BD.intFutureMarketId = fm.intFutureMarketId
	INNER JOIN tblRKFuturesMonth mnt ON BD.intFutureMonthId = mnt.intFutureMonthId
	INNER JOIN tblICItem i ON BD.intItemId = i.intItemId
	INNER JOIN tblICCategory cat ON i.intCategoryId = cat.intCategoryId
	INNER JOIN tblSMCurrency cur ON cur.intCurrencyID = BD.intCurrencyId
	WHERE BD.intCommodityId = @intCommodityId
		AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		AND BD.ysnOpenGetBasisDelivery = 1
		
	INSERT INTO @ListInventory (intSeqId
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
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, strTicketNumber = ''
		, dtmTicketDateTime
		, strDistributionOption
		, intFromCommodityUnitMeasureId
		, intCompanyLocationId
		, strDPAReceiptNo
		, strContractNumber
		, intContractHeaderId
		, intInventoryReceiptId = intTransactionId
		, strReceiptNumber = strTransactionId
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate
	FROM #tempBasisDelivery
	WHERE strContractType = 'Purchase'
		
	INSERT INTO @ListInventory (intSeqId
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
		, dblTotal
		, intCommodityId
		, strLocationName
		, intItemId
		, strItemNo
		, strCategory
		, dtmTicketDateTime
		, strDistributionOption
		, intUnitMeasureId = NULL
		, intCompanyLocationId
		, strDPAReceiptNo
		, intContractHeaderId
		, strContractNumber
		, intInventoryShipmentId = intTransactionId
		, strShipmentNumber = strTransactionId
		, strTicketNumber = ''
		, intTicketId = NULL
		, intFutureMarketId
		, intFutureMonthId
		, strFutMarketName
		, strFutureMonth
		, strContractEndMonth
		, strDeliveryDate
	FROM #tempBasisDelivery
	WHERE strContractType = 'Sale'

	SELECT intUnitMeasureId
		, dblPurchaseContractShippedQty = ISNULL(dblPurchaseContractShippedQty, 0)
		, strLocationName
		, intItemId
		, strItemNo
		, intCategoryId
		, strCategory
		, intContractHeaderId
		, intContractDetailId
		, strContractNumber
		, intCompanyLocationId
		, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
		, intPurchaseSale
	INTO #tempPurchaseInTransit
	FROM vyuRKPurchaseIntransitView
	WHERE intCommodityId = @intCommodityId
		AND intCompanyLocationId = ISNULL(@intLocationId, intCompanyLocationId)
		AND intEntityId = ISNULL(@intVendorId, intEntityId)			
		AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)		

	INSERT INTO @ListInventory(intSeqId
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
		, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblPurchaseContractShippedQty, 0))
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
	FROM #tempPurchaseInTransit
	WHERE intPurchaseSale = 1
		
	INSERT INTO @ListInventory(intSeqId
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
	)t

	--Company Title from Inventory Valuation
	INSERT INTO @ListInventory(intSeqId
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
	FROM @ListInventory f
	WHERE strSeqHeader = 'In-House' AND strType = 'Receipt' AND intCommodityId = @intCommodityId --AND ISNULL(Strg.ysnDPOwnedType, 0) = 0
		AND strReceiptNumber NOT IN (SELECT strTransactionId FROM #tempTransfer)
		
	INSERT INTO @ListInventory(intSeqId
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
			FROM @ListInventory
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
		INSERT INTO @ListInventory (intSeqId
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
	-- Includes DP based ON Company Preference
	--========================================
	If (@ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
	BEGIN
		INSERT INTO @ListInventory(intSeqId
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
				, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance, 0)))
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
			WHERE ch.intCommodityId = @intCommodityId
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
		
	INSERT INTO @ListInventory(intSeqId
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
	FROM @ListInventory WHERE strSeqHeader = 'In-House' AND strType = 'On-Hold'

	--=========================================
	-- Includes intransit based ON Company Preference
	--========================================

	IF (@ysnIncludeInTransitInCompanyTitled = 1)
	BEGIN
		INSERT INTO @ListInventory(intSeqId
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
		FROM @ListInventory WHERE strSeqHeader = 'Sales In-Transit' AND strType = 'Sales In-Transit'

		INSERT INTO @ListInventory(intSeqId
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
		FROM @ListInventory WHERE strSeqHeader = 'Purchase In-Transit' AND strType = 'Purchase In-Transit'
	END
		
	IF @ysnDisplayAllStorage = 0
	BEGIN
		INSERT INTO @FinalInventory (intSeqId
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
		FROM @ListInventory t
		LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId AND ISNULL(dblTotal, 0) <> 0
		ORDER BY intSeqId, strContractEndMonth, strDeliveryDate
	END
	ELSE
	BEGIN
		INSERT INTO @FinalInventory (intSeqId
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
		FROM @ListInventory t
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
		FROM @ListInventory t
		LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId AND intSeqId = 5
		ORDER BY intSeqId, strContractEndMonth, strDeliveryDate
	END

	UPDATE @FinalInventory SET strFutureMonth = CASE WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
												WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth)) END COLLATE Latin1_General_CI_AS
	FROM @FinalInventory F
	
	UPDATE @FinalInventory SET strContractEndMonth = CASE WHEN @strPositionBy = 'Futures Month' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
													WHEN @strPositionBy = 'Delivery Month' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By') END
	WHERE ISNULL(intContractHeaderId, '') <> ''

	UPDATE @FinalInventory SET strContractEndMonth = NULL
						, strFutureMonth = NULL
						, strDeliveryDate = NULL
	WHERE ISNULL(intContractHeaderId, '') = ''

	IF (@strByType = 'ByLocation')
	BEGIN
		INSERT INTO tblRKDPRInventory(intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal
			, intCommodityId
			, strLocationName
			, strTransactionType)
		SELECT @intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal = SUM(dblTotal)
			, intCommodityId
			, strLocationName
			, strTransactionType
		FROM @FinalInventory
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
		INSERT INTO tblRKDPRInventory(intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal
			, intCommodityId
			, strTransactionType)
		SELECT @intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strSeqHeader
			, dblTotal = SUM(dblTotal)
			, intCommodityId
			, strTransactionType
		FROM @FinalInventory
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
			INSERT INTO tblRKDPRInventory(intDPRHeaderId
				, intRow
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
				, strTicketNumber
				, strContractEndMonth
				, strDeliveryDate
				, dtmTicketDateTime
				, intItemId
				, strItemNo
				, strTruckName
				, strDriverName
				, intInventoryReceiptId
				, strReceiptNumber
				, strShipmentNumber
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
				, ysnCrush
			)
			SELECT @intDPRHeaderId
				, intRow
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
			FROM @FinalInventory
			ORDER BY strCommodityCode
				, intSeqId ASC
				, intContractHeaderId DESC
		END
		ELSE
		BEGIN
			INSERT INTO tblRKDPRInventory(intDPRHeaderId
				, intRow
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
				, strTicketNumber
				, strContractEndMonth
				, strDeliveryDate
				, dtmTicketDateTime
				, intItemId
				, strItemNo
				, strTruckName
				, strDriverName
				, intInventoryReceiptId
				, strReceiptNumber
				, strShipmentNumber
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
				, ysnCrush)
			SELECT @intDPRHeaderId
				, intRow
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
			FROM @FinalInventory 
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
	
	DECLARE @ListContractHedge AS TABLE (intRow INT IDENTITY
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
	
	DECLARE @FinalContractHedge AS TABLE (intRow INT IDENTITY
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
	
	SELECT t.intFutOptTransactionId
		, t.dblOpenContract
		, t.intCommodityId
		, t.strCommodityCode
		, t.strInternalTradeNo
		, t.intLocationId
		, t.strLocationName
		, t.dblContractSize
		, t.intFutureMarketId
		, t.strFutureMarket
		, t.intFutureMonthId
		, t.strFutureMonth
		, t.intOptionMonthId
		, t.strOptionMonth
		, t.dblStrike
		, t.strOptionType
		, t.strInstrumentType
		, t.intBrokerageAccountId
		, t.strBrokerAccount
		, t.intEntityId
		, t.strBroker
		, t.strNewBuySell
		, t.intFutOptTransactionHeaderId
		, t.ysnPreCrush
		, t.strNotes
		, t.strBrokerTradeNo
		, fMon.intYear
		, fMar.intUnitMeasureId
		, cuc1.intCommodityUnitMeasureId
		, strCurrency
		, dtmFutureMonthsDate
		, strUnitMeasure
	INTO #tempFutures
	FROM fnRKGetOpenFutureByDate(@intCommodityId, '1/1/1900', @dtmToDate, @CrushReport) t
	JOIN tblRKFutureMarket fMar ON fMar.intFutureMarketId = t.intFutureMarketId
	JOIN tblRKFuturesMonth fMon ON fMon.intFutureMonthId = t.intFutureMonthId
	JOIN tblICCommodityUnitMeasure cuc1 ON cuc1.intCommodityId = @intCommodityId AND fMar.intUnitMeasureId = cuc1.intUnitMeasureId
	JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = cuc1.intUnitMeasureId
	JOIN tblSMCurrency cur ON cur.intCurrencyID = fMar.intCurrencyId
	WHERE t.intCommodityId = @intCommodityId
		AND t.intLocationId = ISNULL(@intLocationId, t.intLocationId)
		AND t.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)

	IF ISNULL(@intVendorId, 0) = 0
	BEGIN
		INSERT INTO @ListContractHedge (strCommodityCode
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
			FROM #tmpContractBalance cd
			WHERE cd.intContractTypeId IN (1,2) AND cd.intCommodityId = @intCommodityId
				AND cd.intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN cd.intCompanyLocationId ELSE @intLocationId END
		) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
		-- Hedge				
		INSERT INTO @ListContractHedge (strCommodityCode
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
				, intCommodityId
				, dtmFutureMonthsDate
				, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblOpenContract * t.dblContractSize)
				, strLocationName
				, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) COLLATE Latin1_General_CI_AS
				, intUnitMeasureId
				, strAccountNumber = t.strBroker + '-' + t.strBrokerAccount COLLATE Latin1_General_CI_AS
				, strTranType = strNewBuySell
				, t.intBrokerageAccountId
				, strInstrumentType = strInstrumentType
				, dblNoOfLot = dblOpenContract
				, strCurrency
				, intFutureMarketId
				, strFutureMarket
				, intFutureMonthId
				, t.strBrokerTradeNo
				, t.strNotes
				, t.ysnPreCrush
			FROM #tempFutures t
			WHERE intCommodityId = @intCommodityId
				AND intLocationId = ISNULL(@intLocationId, intLocationId)
				AND intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				AND ISNULL(t.ysnPreCrush, 0) = 0
		) t
				
		-- Option NetHEdge
		INSERT INTO @ListContractHedge (strCommodityCode
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
			, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) COLLATE Latin1_General_CI_AS
			, dblNoOfContract = dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
														FROM tblRKFuturesSettlementPrice sp
														INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
														WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
															AND t.dblStrike = mm.dblStrike
														ORDER BY dtmPriceDate DESC), 0) * dblContractSize
			, intUnitMeasureId
			, intCommodityId 
			, strAccountNumber = t.strBroker + '-' + t.strBrokerAccount COLLATE Latin1_General_CI_AS
			, strTranType = strNewBuySell
			, dblNoOfLot = dblOpenContract
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta
								FROM tblRKFuturesSettlementPrice sp
								INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
								WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
									AND t.dblStrike = mm.dblStrike
								ORDER BY dtmPriceDate DESC), 0)
			, intBrokerageAccountId
			, strInstrumentType = 'Option' COLLATE Latin1_General_CI_AS
			, strCurrency 
			, intFutureMarketId
			, strFutureMarket
			, intFutureMonthId
			, strFutureMonth
			, strBrokerTradeNo
			, strNotes
			, ysnPreCrush
		FROM #tempFutures t
		WHERE intCommodityId = @intCommodityId
			AND intLocationId = ISNULL(@intLocationId, intLocationId)
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			AND intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
			AND ISNULL(t.ysnPreCrush, 0) = 0

				
		IF @ysnPreCrush = 1 AND ISNULL(@strPositionBy,'') <> ''
		BEGIN
			--Crush Records
			INSERT INTO @ListContractHedge(strCommodityCode
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
				SELECT strCommodityCode
					, strInternalTradeNo
					, intFutOptTransactionHeaderId
					, intCommodityId
					, case when CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
							else left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS dtmFutureMonthsDate
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0)
																																	ELSE ISNULL(dblOpenContract, 0) END * dblContractSize) AS HedgedQty
					, strLocationName
					, case when CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
							else left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS strFutureMonth
					, intUnitMeasureId
					, strBroker + '-' + strBrokerAccount COLLATE Latin1_General_CI_AS strAccountNumber
					, strNewBuySell AS strTranType
					, intBrokerageAccountId
					, strInstrumentType
					, CASE WHEN strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END dblNoOfLot
					, intFutureMarketId
					, strFutureMarket
					, intFutureMonthId
					, strBrokerTradeNo
					, strNotes
					, ysnPreCrush
				FROM #tempFutures
				WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
					AND ISNULL(ysnPreCrush, 0) = 1) t

			--Include Crush in Net Hedge
			INSERT INTO @ListContractHedge(strCommodityCode
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
			FROM @ListContractHedge
			WHERE intCommodityId = @intCommodityId AND strType = 'Crush'

		END

		-- Net Hedge option end
		INSERT INTO @ListContractHedge(strCommodityCode
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
		-- Includes DP based ON Company Preference
		--========================================
		If (@ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
		BEGIN
			INSERT INTO @ListContractHedge(strCommodityCode
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
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance, 0)))
					, ch.intCompanyLocationId
					, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
				FROM #tblGetStorageDetailByDate ch
				WHERE ch.intCommodityId = @intCommodityId
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
			INSERT INTO @ListContractHedge(strCommodityCode
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
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance, 0)))
					, ch.intCompanyLocationId
					, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
				FROM #tblGetStorageDetailByDate ch
				WHERE ch.intCommodityId = @intCommodityId
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
		INSERT INTO @ListContractHedge(strCommodityCode
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
		FROM @ListContractHedge
		WHERE intCommodityId = @intCommodityId AND strType = 'Net Hedge' AND @ysnExchangeTraded = 1

		INSERT INTO @ListContractHedge(strCommodityCode
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
			, - dblTotal
			, intInventoryReceiptId = intTransactionId
			, strReceiptNumber = strTransactionId
			, intCommodityUnitMeasureId = NULL
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
		FROM #tempBasisDelivery
		WHERE strContractType = 'Purchase'

		INSERT INTO @ListContractHedge(strCommodityCode
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
			, dblQuantity = dblTotal
			, intInventoryShipmentId = intTransactionId
			, strShipmentNumber = strTransactionId
			, intCommodityUnitMeasureId = NULL
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
		FROM #tempBasisDelivery
		WHERE strContractType = 'Sale'

		INSERT INTO @ListContractHedge(strCommodityCode
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
			FROM @ListContractHedge cd
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
				
		INSERT INTO @ListContractHedge(strCommodityCode
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
			INSERT INTO @ListContractHedge(strCommodityCode
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
					AND CH.intCommodityId = @intCommodityId
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
			INSERT INTO @ListContractHedge(	strCommodityCode
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
				, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblPurchaseContractShippedQty, 0))
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFromCommodityUnitMeasureId = intUnitMeasureId
				, intCommodityId = @intCommodityId		
				, intContractHeaderId
				, strContractNumber
			FROM #tempPurchaseInTransit
			WHERE intPurchaseSale = 1

			INSERT INTO @ListContractHedge(	strCommodityCode
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
			) t 
		END
				
		INSERT INTO @ListContractHedge(strCommodityCode
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
		FROM @ListContractHedge WHERE strType = 'Price Risk' AND strContractType IN ('Inventory', 'Collateral', 'OffSite' , 'Purchase In-Transit','Sales In-Transit') AND @ysnExchangeTraded = 1
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
				
		INSERT INTO @ListContractHedge (strCommodityCode
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
			FROM @ListContractHedge
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
				
		INSERT INTO @ListContractHedge(strCommodityCode
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
		FROM @ListContractHedge WHERE strType = 'Basis Risk' AND intCommodityId = @intCommodityId AND @ysnExchangeTraded = 1
				
		INSERT INTO @ListContractHedge (strCommodityCode
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
			FROM #tmpContractBalance cd
			WHERE intContractTypeId = 1 AND strType IN ('Purchase Priced','Purchase Basis') AND cd.intCommodityId = @intCommodityId
				AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
		) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation WHERE @ysnExchangeTraded = 1)
				
		INSERT INTO @FinalContractHedge (intCommodityId
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
		FROM @ListContractHedge t
		JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId 
				
	END
	ELSE--==================== Specific Customer/Vendor =================================================
	BEGIN
		INSERT INTO @ListContractHedge (strCommodityCode
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
			FROM #tmpContractBalance cd
			WHERE cd.intContractTypeId IN (1, 2)
				AND cd.intCommodityId = @intCommodityId
				AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
				AND cd.intEntityId = @intVendorId
		) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				
				
		INSERT INTO @FinalContractHedge (intCommodityId
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
		FROM @ListContractHedge t
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
		FROM @ListContractHedge t
		JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId
	END
	
	UPDATE @FinalContractHedge SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
	UPDATE @FinalContractHedge SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
	UPDATE @FinalContractHedge SET intSeqNo = 3 WHERE strType = 'Net Hedge'
	UPDATE @FinalContractHedge SET intSeqNo = 4 WHERE strType = 'Crush'
	UPDATE @FinalContractHedge SET intSeqNo = 5 WHERE strType = 'Price Risk'
	UPDATE @FinalContractHedge SET intSeqNo = 6 WHERE strType = 'Basis Risk'
	UPDATE @FinalContractHedge SET intSeqNo = 11 WHERE strType = 'Avail for Spot Sale'
	
	UPDATE @FinalContractHedge SET strFutureMonth = CASE 
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
		WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
		WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
	END COLLATE Latin1_General_CI_AS
	FROM @FinalContractHedge F
	LEFT JOIN (
		SELECT intFutOptTransactionHeaderId
			,strInternalTradeNo
			,strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
		FROM vyuRKFutOptTransaction
	)FOT ON FOT.intFutOptTransactionHeaderId = F.intFutOptTransactionHeaderId AND FOT.strInternalTradeNo COLLATE Latin1_General_CI_AS = F.strInternalTradeNo COLLATE Latin1_General_CI_AS
	
	UPDATE @FinalContractHedge SET strContractEndMonth = CASE 
			WHEN @strPositionBy = 'Futures Month' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
			WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
		END

	UPDATE @FinalContractHedge SET strContractEndMonth = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
	WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''
	
	IF (@strByType = 'ByCommodity')
	BEGIN
		INSERT INTO tblRKDPRContractHedge(intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal)
		SELECT DISTINCT @intDPRHeaderId
			, c.strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal = SUM(dblTotal)
			--, c.intCommodityId
		FROM @FinalContractHedge f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
		GROUP BY c.strCommodityCode
			, strUnitMeasure
			, strType
			--, c.intCommodityId
	END
	ELSE IF(@strByType = 'ByLocation')
	BEGIN
		INSERT INTO tblRKDPRContractHedge(intDPRHeaderId
			, strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal
			, strLocationName)
		SELECT DISTINCT @intDPRHeaderId
			, c.strCommodityCode
			, strUnitMeasure
			, strType
			, dblTotal = SUM(dblTotal)
			--, c.intCommodityId
			, strLocationName
		FROM @FinalContractHedge f
		JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
		WHERE dblTotal <> 0
		GROUP BY c.strCommodityCode
			, strUnitMeasure
			, strType
			--, c.intCommodityId
			, strLocationName
	END
	ELSE
	BEGIN 
		IF ISNULL(@intVendorId, 0) = 0
		BEGIN
			INSERT INTO tblRKDPRContractHedge(intDPRHeaderId
				, intSeqNo
				, intRow
				, strCommodityCode
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
				, strTicketType
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
				, dblInvQty
				, dblPurBasisDelivary
				, dblOpenPurQty
				, dblOpenSalQty
				, dblCollateralSales
				, dblSlsBasisDeliveries
				, dblCompanyTitled
				, dblNoOfContract
				, dblContractSize
				, strCurrency
				, intInvoiceId
				, strInvoiceNumber
				, intBillId
				, strBillId
				, intInventoryReceiptId
				, strReceiptNumber
				, intInventoryShipmentId
				, strShipmentNumber
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
				, ysnCrush
				, strEntityName
				, strDeliveryDate
			)
			SELECT @intDPRHeaderId
				, intSeqNo
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
			FROM @FinalContractHedge f
			JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
			WHERE dblTotal <> 0
			ORDER BY intSeqNo
				, strType ASC
				, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
		END
		ELSE
		BEGIN
			INSERT INTO tblRKDPRContractHedge(intDPRHeaderId
				, intSeqNo
				, intRow
				, strCommodityCode
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
				, strTicketType
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
				, dblInvQty
				, dblPurBasisDelivary
				, dblOpenPurQty
				, dblOpenSalQty
				, dblCollateralSales
				, dblSlsBasisDeliveries
				, dblCompanyTitled
				, dblNoOfContract
				, dblContractSize
				, strCurrency
				, intInvoiceId
				, strInvoiceNumber
				, intBillId
				, strBillId
				, intInventoryReceiptId
				, strReceiptNumber
				, intInventoryShipmentId
				, strShipmentNumber
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
				, ysnCrush
				, strEntityName
				, strDeliveryDate
			)
			SELECT @intDPRHeaderId
				, intSeqNo
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
			FROM @FinalContractHedge f
			JOIN tblICCommodity c ON c.intCommodityId = f.intCommodityId
			WHERE dblTotal <> 0 AND strSubType NOT LIKE '%' + @strPurchaseSales + '%'
			ORDER BY intSeqNo
				, strType ASC
				, CASE WHEN ISNULL(intContractHeaderId, 0) = 0 THEN intFutOptTransactionHeaderId ELSE intContractHeaderId END DESC
		END
	END

	IF (ISNULL(@ysnCrush, 0) = 0 )
	BEGIN
		------------------------------------------
		------- Contract Hedge By Month ----------
		------------------------------------------

		DECLARE @ListHedgeByMonth AS TABLE (intRowNumber INT IDENTITY
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

		DECLARE @FinalHedgeByMonth AS TABLE (intRowNumber INT IDENTITY
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
	
		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
				, dblTotal = (CASE WHEN intContractTypeId = 1 THEN ISNULL(CD.dblBalance, 0)
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
			FROM #tmpContractBalance CD
			WHERE intContractTypeId IN (1,2) AND CD.intCommodityId = @intCommodityId
				AND CD.intContractStatusId <> 3
				AND intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND intCompanyLocationId = CASE WHEN ISNULL(@intLocationId, 0) = 0 THEN intCompanyLocationId ELSE @intLocationId END
				AND CD.intEntityId = CASE WHEN ISNULL(@intVendorId, 0) = 0 THEN CD.intEntityId ELSE @intVendorId END
		) t
			
		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
				, intCommodityId
				, dtmFutureMonthsDate
				, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblOpenContract, 0) * t.dblContractSize)
				, strLocationName
				, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2),intYear) COLLATE Latin1_General_CI_AS
				, intUnitMeasureId
				, strAccountNumber = strBroker + '-' + strBrokerAccount COLLATE Latin1_General_CI_AS
				, strTranType = strNewBuySell
				, intBrokerageAccountId
				, t.strInstrumentType as strInstrumentType
				, dblNoOfLot = ISNULL(dblOpenContract, 0)
				, ysnPreCrush
				, t.strNotes
				, strBrokerTradeNo
				, t.strFutureMarket
			FROM #tempFutures t
			WHERE strInstrumentType = 'Futures'
		) t
			
		--Option NetHEdge
		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
			, intCommodityId
			, t.strInternalTradeNo
			, intFutOptTransactionHeaderId
			, 'Net Hedge' COLLATE Latin1_General_CI_AS
			, t.strLocationName
			, strFutureMonth = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) COLLATE Latin1_General_CI_AS
			, dtmFutureMonthsDate = LEFT(t.strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) COLLATE Latin1_General_CI_AS
			, dblTotal = (dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
													FROM tblRKFuturesSettlementPrice sp
													INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
													WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId 
														AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
														AND t.dblStrike = mm.dblStrike
													ORDER BY dtmPriceDate DESC), 0) * dblContractSize)
			, intUnitMeasureId 
			, strAccountNumber = strBroker + '-' + strBrokerAccount COLLATE Latin1_General_CI_AS
			, TranType = strNewBuySell
			, dblNoOfLot = dblOpenContract
			, dblDelta = ISNULL((SELECT TOP 1 dblDelta
										FROM tblRKFuturesSettlementPrice sp
										INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
										WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId
											AND mm.intTypeId = CASE WHEN t.strOptionType = 'Put' THEN 1 ELSE 2 END
											AND t.dblStrike = mm.dblStrike
										ORDER BY dtmPriceDate DESC), 0)
			, intBrokerageAccountId
			, strInstrumentType = 'Options' COLLATE Latin1_General_CI_AS
			, ysnPreCrush
			, t.strNotes
			, strBrokerTradeNo
			, t.strFutureMarket
		FROM #tempFutures t
		WHERE strInstrumentType = 'Options'
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExercisedAssigned)
			AND t.intFutOptTransactionId NOT IN (SELECT intFutOptTransactionId FROM tblRKOptionsPnSExpired)
			
		--Net Hedge option end			
		INSERT INTO @ListHedgeByMonth (strCommodityCode
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
		FROM @FinalHedgeByMonth t
		JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId
	
		UPDATE @ListHedgeByMonth SET strContractEndMonth = 'Near By' WHERE CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, GETDATE())
		DELETE FROM @FinalHedgeByMonth

		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
			, dblTotal = ISNULL(dblTotal, 0)
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
		FROM @ListHedgeByMonth
		WHERE strContractEndMonth = 'Near By'

		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
			, dblTotal = ISNULL(dblTotal, 0)
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
		FROM @ListHedgeByMonth
		WHERE strContractEndMonth <> 'Near By'
		ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

		IF ISNULL(@intVendorId, 0) = 0
		BEGIN
			INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
				, dblTotal = ISNULL(dblTotal, 0)
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
			FROM @FinalHedgeByMonth
		END
		ELSE
		BEGIN
			INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
				, dblTotal = ISNULL(dblTotal, 0)
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
			FROM @FinalHedgeByMonth
			WHERE strType NOT LIKE '%'+@strPurchaseSales+'%' AND strType<>'Net Hedge'
		END

		--This is used to insert strType so that it will be displayed properly ON Position Report Detail by Month (RM-1902)
		INSERT INTO @FinalHedgeByMonth (strCommodityCode
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
		FROM @FinalHedgeByMonth

		UPDATE @FinalHedgeByMonth SET intSeqNo = 1 WHERE strType LIKE 'Purchase%'
		UPDATE @FinalHedgeByMonth SET intSeqNo = 2 WHERE strType LIKE 'Sale%'
		UPDATE @FinalHedgeByMonth SET intSeqNo = 3 WHERE strType = 'Net Hedge'
		UPDATE @FinalHedgeByMonth SET intSeqNo = 4 WHERE strType = 'Position'

		DECLARE @strType NVARCHAR(MAX)
		DECLARE @strContractEndMonth NVARCHAR(MAX)
		SELECT TOP 1 @strType = strType
			, @strContractEndMonth = strContractEndMonth
		FROM @FinalHedgeByMonth
		ORDER BY intRowNumber ASC

		IF (ISNULL(@intVendorId, 0) = 0)
		BEGIN
			INSERT INTO tblRKDPRContractHedgeByMonth(intDPRHeaderId
				, intSeqNo
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
				, ysnCrush)
			SELECT @intDPRHeaderId
				, intSeqNo
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
			FROM @FinalHedgeByMonth
			WHERE dblTotal IS NULL OR dblTotal <> 0
			ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
				, intSeqNo
				, strType
		END
		ELSE
		BEGIN
			INSERT tblRKDPRContractHedgeByMonth(intDPRHeaderId
				, intSeqNo
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
				, ysnCrush)
			SELECT @intDPRHeaderId
				, intSeqNo
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
			FROM @FinalHedgeByMonth
			WHERE (dblTotal IS NULL
				OR dblTotal <> 0)
				AND strType NOT LIKE '%' + @strPurchaseSales + '%'
				AND strType <> 'Net Hedge'
			ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME,'01 ' + strContractEndMonth) END
				, intSeqNo
				, strType
		END
	END
	ELSE
	BEGIN
		------------------------------------------
		-------------- Pre Crush -----------------
		------------------------------------------
	
		DECLARE @ListCrushDetail AS TABLE (intRowNumber INT IDENTITY
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

		DECLARE @ListCrushAll AS TABLE (intRowNumber INT IDENTITY
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

		INSERT INTO @ListCrushDetail (strCommodityCode
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
				, dblTotal = CASE WHEN intContractTypeId = 1 THEN ISNULL(CD.dblBalance, 0) ELSE - ISNULL(CD.dblBalance, 0) END
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
			FROM #tmpContractBalance CD
			WHERE intContractTypeId IN (1, 2) AND CD.intCommodityId = @intCommodityId
				AND CD.intContractStatusId <> 3
				AND CD.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				AND CD.intCompanyLocationId = ISNULL(@intLocationId, CD.intCompanyLocationId)
				AND CD.intEntityId = ISNULL(@intVendorId, CD.intEntityId)
		) t WHERE dblTotal <> 0
			
		INSERT INTO @ListCrushAll (strCommodityCode
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
		FROM @ListCrushDetail t
		JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
		JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
		WHERE t.intCommodityId = @intCommodityId

		-- inventory
		INSERT INTO @InventoryStock(strCommodityCode
			, strItemNo
			, strCategory
			, dblTotal
			, strLocationName
			, intCommodityId
			, intFromCommodityUnitMeasureId
			, strInventoryType)
		SELECT strCommodityCode = @strCommodityCode
			, strItemNo
			, strCategory
			, dblTotal = dblTotal
			, strLocationName
			, intCommodityId = @intCommodityId
			, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
			, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
		FROM #invQty

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
			, @intCommodityUnitMeasureId
			, strInventoryType = 'Collateral' COLLATE Latin1_General_CI_AS
		FROM #tempCollateral
		WHERE ysnIncludeInPriceRiskAndCompanyTitled = 1
		GROUP BY strCommodityCode
			, strLocationName
			, intCommodityId
	
			
		--=========================================
		-- Includes DP based ON Company Preference
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
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance, 0)))
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
				WHERE ch.intCommodityId = @intCommodityId
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
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance, 0)))
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
				WHERE ch.intCommodityId = @intCommodityId
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
		
		INSERT INTO @ListCrushAll(intContractHeaderId
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
			, intCommodityId
			, strCommodityCode
			, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
			, strLocationName
			, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
			, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
			, dblTotal
			, intContractSeq
			, strUnitMeasure = NULL
			, intFromCommodityUnitMeasureId = NULL
			, strEntityName = strCustomerVendor
			, intOrderId = 6
			, intItemId
			, strItemNo
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate
		FROM #tempBasisDelivery
		WHERE strContractType = 'Sale'

		INSERT INTO @ListCrushAll(intContractHeaderId
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
			, strType = 'Purchase Basis Deliveries' COLLATE Latin1_General_CI_AS
			, strLocationName
			, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
			, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
			, dblTotal = dblTotal * -1
			, intContractSeq
			, strUnitMeasure = ''
			, intFromCommodityUnitMeasureId = ''
			, strEntityName = strCustomerVendor
			, intOrderId = 5
			, intItemId
			, strItemNo
			, intCategoryId
			, strCategory
			, intFutureMarketId
			, strFutMarketName
			, intFutureMonthId
			, strFutureMonth
			, strDeliveryDate
		FROM #tempBasisDelivery
		WHERE strContractType = 'Purchase'

		IF (@ysnIncludeInTransitInCompanyTitled = 1)
		BEGIN
			INSERT INTO @InventoryStock(intCommodityId
				, strCommodityCode
				, dblTotal
				, strLocationName
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT @intCommodityId
				, @strCommodityCode
				, dblTotal = SUM(dblPurchaseContractShippedQty)
				, strLocationName
				, @intCommodityUnitMeasureId
				, strInventoryType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
			FROM #tempPurchaseInTransit
			WHERE intPurchaseSale = 1
			GROUP BY strLocationName

			INSERT INTO @InventoryStock(strCommodityCode
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType)
			SELECT @strCommodityCode
				, dblTotal = SUM(dblBalanceToInvoice)
				, strLocationName
				, intCommodityId
				, @intCommodityUnitMeasureId
				, strInventoryType = 'Sales In-Transit' COLLATE Latin1_General_CI_AS
			FROM #tblGetSalesIntransitWOPickLot
			GROUP BY strLocationName
				, intCommodityId
		END

		UPDATE @ListCrushAll
		SET strContractEndMonth = 'Near By'
		WHERE strContractEndMonth <> 'Near By'
			AND CONVERT(DATETIME, '01 ' + strContractEndMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110))

		DELETE FROM @ListCrushDetail

		INSERT INTO @ListCrushDetail(intContractHeaderId
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
		FROM @ListCrushAll
		WHERE strType IN ('Sales Basis Deliveries', 'Purchase Basis Deliveries')

		INSERT INTO @ListCrushDetail (strCommodityCode
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
		FROM @ListCrushAll
		WHERE strContractEndMonth = 'Near By' AND strType IN ('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')

		INSERT INTO @ListCrushDetail (strCommodityCode
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
		FROM @ListCrushAll 
		WHERE strContractEndMonth <> 'Near By' and strType in('Purchase Priced' ,'Sale Priced','Purchase HTA','Sale HTA','Purchase Basis','Sale Basis','Purchase DP (Priced Later)','Sale DP (Priced Later)','Purchase Unit','Sale Unit')
		ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) ASC

		INSERT INTO @ListCrushDetail (strCommodityCode
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

		INSERT INTO @ListCrushDetail (strCommodityCode
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

		INSERT INTO @ListCrushDetail (strCommodityCode
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
		FROM @ListCrushDetail WHERE intOrderId in(1, 2, 3, 4, 5, 6, 7, 8)

		INSERT INTO @ListCrushDetail (strCommodityCode
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
				, intCommodityId
				, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
											ELSE LEFT(strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
				, HedgedQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblOpenContract, 0) * dblContractSize)
				, strLocationName
				, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
										ELSE LEFT(strFutureMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
				, intUnitMeasureId
				, strUnitMeasure
				, (oc.strBroker+ '-' + oc.strBrokerAccount) COLLATE Latin1_General_CI_AS strAccountNumber
				, strTranType = strNewBuySell
				, oc.intBrokerageAccountId
				, strInstrumentType = oc.strInstrumentType
				, dblNoOfLot = ISNULL(dblOpenContract, 0)
				, intFutureMarketId
				, strFutureMarket
				, intFutureMonthId
				, strFutureMonth
				, oc.strBrokerTradeNo
				, oc.strNotes
				, oc.ysnPreCrush
			FROM #tempFutures oc
			WHERE ISNULL(oc.ysnPreCrush, 0) = 0
		) t

		INSERT INTO @ListCrushDetail (strCommodityCode
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
				, intCommodityId
				, dtmFutureMonthsDate = CASE WHEN CONVERT(DATETIME, '01 ' + strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
											ELSE LEFT(strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
				, HedgedQty = dblOpenContract * ISNULL((SELECT TOP 1 dblDelta
														FROM tblRKFuturesSettlementPrice sp
														INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
														WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
															AND oc.dblStrike = mm.dblStrike
														ORDER BY dtmPriceDate DESC), 0) * dblContractSize
				, strLocationName
				, strContractEndMonth = CASE WHEN CONVERT(DATETIME, '01 ' + strOptionMonth) < CONVERT(DATETIME, CONVERT(DATETIME, CONVERT(VARCHAR(10), GETDATE(), 110), 110)) THEN 'Near By'
										ELSE LEFT(strOptionMonth, 4) + '20' + CONVERT(NVARCHAR(2), intYear) END COLLATE Latin1_General_CI_AS
				, intUnitMeasureId
				, oc.strBroker + '-' + oc.strBrokerAccount COLLATE Latin1_General_CI_AS strAccountNumber
				, strTranType = strNewBuySell
				, oc.intBrokerageAccountId
				, strInstrumentType
				, dblNoOfLot = CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END
				, dblDelta = ISNULL((SELECT TOP 1 dblDelta
									FROM tblRKFuturesSettlementPrice sp
									INNER JOIN tblRKOptSettlementPriceMarketMap mm ON sp.intFutureSettlementPriceId = mm.intFutureSettlementPriceId
									WHERE intFutureMarketId = intFutureMarketId AND mm.intOptionMonthId = intOptionMonthId AND mm.intTypeId = CASE WHEN oc.strOptionType = 'Put' THEN 1 ELSE 2 END
										AND oc.dblStrike = mm.dblStrike
									ORDER BY dtmPriceDate DESC), 0)
				, intFutureMarketId
				, oc.strFutureMarket
				, intFutureMonthId
				, strFutureMonth = strOptionMonth
				, oc.strBrokerTradeNo
				, oc.strNotes
				, oc.ysnPreCrush
			FROM #tempFutures oc
			WHERE ISNULL(oc.ysnPreCrush, 0) = 0
		) t

		-- Crush records
		IF (@ysnPreCrush = 1)
		BEGIN
			INSERT INTO @ListCrushDetail (strCommodityCode
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
					, intCommodityId
					, case when CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
							else left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS dtmFutureMonthsDate
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0)
																																	ELSE ISNULL(dblOpenContract, 0) END * dblContractSize) AS HedgedQty
					, strLocationName
					, case when CONVERT(DATETIME, '01 ' + strFutureMonth) < CONVERT(DATETIME, convert(DATETIME, CONVERT(VARCHAR(10), getdate(), 110), 110)) then 'Near By'
							else left(strFutureMonth, 4) + '20' + convert(NVARCHAR(2), intYear) end COLLATE Latin1_General_CI_AS strFutureMonth
					, intUnitMeasureId
					, oc.strBroker + '-' + oc.strBrokerAccount COLLATE Latin1_General_CI_AS strAccountNumber
					, strNewBuySell AS strTranType
					, oc.intBrokerageAccountId
					, strInstrumentType
					, CASE WHEN oc.strNewBuySell = 'Buy' THEN ISNULL(dblOpenContract, 0) ELSE ISNULL(dblOpenContract, 0) END dblNoOfLot
					, intFutureMarketId
					, oc.strFutureMarket
					, intFutureMonthId
					, oc.strBrokerTradeNo
					, oc.strNotes
					, oc.ysnPreCrush
				FROM #tempFutures oc
				WHERE ISNULL(oc.ysnPreCrush, 0) = 1
			) t

			IF NOT EXISTS (SELECT TOP 1 1 FROM @ListCrushDetail WHERE intOrderId = 14)
			BEGIN
				INSERT INTO @ListCrushDetail (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType)
				SELECT TOP 1 strCommodityCode, 0, 'Near By' COLLATE Latin1_General_CI_AS,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,14,'Crush' COLLATE Latin1_General_CI_AS,'Buy' COLLATE Latin1_General_CI_AS FROM @ListCrushDetail
			END
		END

		----------------

		INSERT INTO @ListCrushDetail (strCommodityCode
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
		FROM @ListCrushDetail WHERE intOrderId IN (12, 14, 15)
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

		INSERT INTO @ListCrushDetail (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure)
		SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,23 intOrderId,'Net Unpriced Position' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy, strItemNo, strCategory, strEntityName, strFutMarketName, strUnitMeasure from @ListCrushDetail where intOrderId in(19, 20, 21, 22)

		INSERT INTO @ListCrushDetail (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
		SELECT strCommodityCode,ROUND(dblTotal,2),strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,25 intOrderId,'Basis Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @ListCrushDetail where intOrderId in(1, 2, 8, 19, 20)

		INSERT INTO @ListCrushDetail (strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,intOrderId,strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy)
		SELECT strCommodityCode,dblTotal,strContractEndMonth,strLocationName,intCommodityId,intFromCommodityUnitMeasureId,26 intOrderId,'Price Risk' COLLATE Latin1_General_CI_AS strType,strInventoryType, intContractHeaderId, strContractNumber, intFutOptTransactionHeaderId, strInternalTradeNo, strFutureMonth, strDeliveryDate, strContractEndMonthNearBy from @ListCrushDetail where intOrderId in(9, 16)

		DECLARE @FinalCrush AS TABLE (intRowNumber1 INT IDENTITY
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

		IF OBJECT_ID('tempdb..#monthList') IS NOT NULL
			DROP TABLE #monthList

		SELECT DISTINCT strContractEndMonth
		INTO #monthList
		FROM @ListCrushDetail WHERE strContractEndMonth <> 'Near By'
		
		DECLARE @MonthOrderListFinal AS TABLE (strContractEndMonth NVARCHAR(100))

		INSERT INTO @MonthOrderListFinal 
		SELECT 'Near By' COLLATE Latin1_General_CI_AS
		INSERT INTO @MonthOrderListFinal
		SELECT strContractEndMonth FROM #monthList ORDER BY CONVERT(DATETIME, '01 ' + strContractEndMonth) 

		DECLARE @TopRowRec AS TABLE (strType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strCommodityCode NVARCHAR(100) COLLATE Latin1_General_CI_AS)
		INSERT INTO @TopRowRec 
		SELECT TOP 1 strType, strCommodityCode from @ListCrushDetail
		
		INSERT INTO @FinalCrush(strCommodityCode
			, strType
			, strContractEndMonth
			, dblTotal)
		SELECT strCommodityCode
			, strType
			, strContractEndMonth
			, 0.0 dblTotal
		FROM @TopRowRec t
		CROSS JOIN @MonthOrderListFinal t1
	
		INSERT INTO @FinalCrush(intSeqNo
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
		FROM @ListCrushDetail
		WHERE (ISNULL(dblTotal, 0) <> 0 OR strType = 'Crush') AND strContractEndMonth = 'Near By'

		INSERT INTO @FinalCrush(intSeqNo
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
		FROM @ListCrushDetail 
		WHERE (ISNULL(dblTotal, 0) <> 0 OR strType = 'Crush') and strContractEndMonth not in ( 'Near By') order by CONVERT(DATETIME, '01 ' + strContractEndMonth) 

		UPDATE @FinalCrush SET strFutureMonth = CASE 
			WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) = 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN dbo.fnRKFormatDate(CONVERT(DATETIME, '1' + LTRIM(RTRIM(F.strFutureMonth))), 'MMM yyyy')
			WHEN LEN(LTRIM(RTRIM(F.strFutureMonth))) > 6 AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') <> '' THEN LTRIM(RTRIM(F.strFutureMonth))
			WHEN ISNULL(F.intFutOptTransactionHeaderId, '') <> '' AND ISNULL(LTRIM(RTRIM(F.strFutureMonth)), '') = '' THEN FOT.strFutureMonth
		END COLLATE Latin1_General_CI_AS
			, strDeliveryDate = CT.strDeliveryDate
		FROM @FinalCrush F
		LEFT JOIN (
			SELECT intFutOptTransactionHeaderId
				, strInternalTradeNo
				, strFutureMonth = ISNULL(dbo.fnRKFormatDate(CONVERT(DATETIME,'01 '+ strFutureMonth), 'MMM yyyy'),'Near By') COLLATE Latin1_General_CI_AS
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
	
		UPDATE @FinalCrush SET strContractEndMonthNearBy = CASE 
				WHEN @strPositionBy = 'Futures Month' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
				WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intContractHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strDeliveryDate)),''),'Near By')
				WHEN @strPositionBy = 'Delivery Month' AND ISNULL(intFutOptTransactionHeaderId, '') <> '' THEN ISNULL(NULLIF(LTRIM(RTRIM(strFutureMonth)),''),'Near By')
			END

		UPDATE @FinalCrush SET strContractEndMonthNearBy = NULL, strFutureMonth = NULL, strDeliveryDate = NULL
		WHERE ISNULL(intContractHeaderId, '') = '' AND ISNULL(strInternalTradeNo, '') = ''

		INSERT INTO @FinalCrush (strCommodityCode
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
		FROM @FinalCrush
		WHERE intOrderId IS NOT NULL

		INSERT INTO tblRKDPRContractHedgeByMonth(intDPRHeaderId
			, intSeqNo
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
			, ysnCrush)
		SELECT @intDPRHeaderId
			, intSeqNo = intOrderId
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
		FROM @FinalCrush WHERE ((dblTotal IS NULL OR dblTotal <> 0) OR strType = 'Crush')
		ORDER BY CASE WHEN strContractEndMonth NOT IN ('Near By','Total') THEN CONVERT(DATETIME, '01 ' + strContractEndMonth) END
			, intSeqNo
			, strType
	END

	-------------------------------------
	----------- Year To Date ------------
	-------------------------------------
	IF (ISNULL(@intVendorId, 0) <> 0)
	BEGIN
		DECLARE @NetValue NUMERIC(18,6)
			, @PurchasedValue NUMERIC(18,6)
			, @SoldValue NUMERIC(18,6)
			, @PaidValue NUMERIC(18,6)
			, @NetPayablesValue NUMERIC(18,6)
			, @NetReceivablesValue NUMERIC(18,6)

		--===================================
		--			PURCHASE
		--===================================
		SELECT * INTO #tmpSourcePurchase
		FROM (
			SELECT intEntityId = IR.intEntityVendorId
				, T.intCommodityId
				, FieldName = 'Paid' COLLATE Latin1_General_CI_AS
				, dblTotal = SUM(CASE WHEN Bill.dblTotal = Bill.dblAmountDue THEN BD.dblQtyReceived
									ELSE (BD.dblQtyReceived/Bill.dblTotal) * (Bill.dblTotal - Bill.dblAmountDue) END)
				, intSorting = 0
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId
			WHERE BD.intInventoryReceiptChargeId IS NULL
				AND Bill.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId, T.intCommodityId
		
			UNION ALL SELECT intEntityId = IR.intEntityVendorId
				, T.intCommodityId
				, FieldName = 'Purchased' COLLATE Latin1_General_CI_AS
				, dblTotal = SUM(BD.dblQtyReceived)
				, intSorting = 1
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId
			WHERE BD.intInventoryReceiptChargeId IS NULL
				AND Bill.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId,T.intCommodityId
		
			UNION ALL SELECT IR.intEntityVendorId
				, T.intCommodityId
				, 'Net' COLLATE Latin1_General_CI_AS as FieldName
				, SUM(BD.dblTotal) as dblTotal
				, 7 as intSorting
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId
			WHERE BD.intInventoryReceiptChargeId IS NULL
				AND Bill.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId,T.intCommodityId
		
			UNION ALL SELECT IR.intEntityVendorId
				, T.intCommodityId
				, 'Tax' COLLATE Latin1_General_CI_AS as FieldName
				, SUM(ISNULL(BD.dblTax, 0)) as dblTotal
				, 5 as intSorting
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			LEFT JOIN tblICItem Itm ON INVRCPTITEM.intItemId = Itm.intItemId
			WHERE Bill.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId,T.intCommodityId
		
			UNION ALL SELECT IR.intEntityVendorId
				, T.intCommodityId
				, 'Discounts' COLLATE Latin1_General_CI_AS
				, SUM(BD.dblTotal) as dblDiscount
				, 3 as intSorting
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
			INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE BD.intInventoryReceiptChargeId IS NOT NULL
				AND Bill.ysnPosted = 1
				AND Itm.strCostType = 'Grain Discount'
				AND Itm.intItemId <> SS.intDefaultFeeItemId
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId,T.intCommodityId
		
			UNION ALL SELECT IR.intEntityVendorId
				, T.intCommodityId
				, 'Fees' COLLATE Latin1_General_CI_AS
				, SUM(BD.dblTotal) as dblFees
				, 6 as intSorting
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
			INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE BD.intInventoryReceiptChargeId IS NOT NULL
				AND Bill.ysnPosted = 1
				AND Itm.strCostType = 'Other Charges'
				AND Itm.intItemId = SS.intDefaultFeeItemId 
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId,T.intCommodityId
		
			UNION ALL SELECT IR.intEntityVendorId
				, T.intCommodityId
				, Itm.strItemNo
				, SUM(BD.dblTotal) as dblTotal
				, 9 as intSorting
			FROM tblICInventoryReceipt IR
			INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON INVRCPTITEM.intInventoryReceiptId = IR.intInventoryReceiptId
			INNER JOIN vyuSCGetScaleDistribution SC ON INVRCPTITEM.intInventoryReceiptItemId = SC.intInventoryReceiptItemId
			INNER JOIN tblAPBillDetail BD ON BD.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			INNER JOIN tblAPBill Bill ON Bill.intBillId = BD.intBillId
			INNER JOIN tblICInventoryReceiptCharge InvCharge ON BD.intInventoryReceiptChargeId = InvCharge.intInventoryReceiptChargeId
			INNER JOIN tblICItem Itm ON InvCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE BD.intInventoryReceiptChargeId IS NOT NULL
				AND Bill.ysnPosted = 1
				AND Itm.strCostType <> 'Grain Discount'
				AND BD.intItemId <> SS.intDefaultFeeItemId
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Bill.dtmDate, 110), 110) <= @dtmToDate
				AND IR.intEntityVendorId = ISNULL(@intVendorId, IR.intEntityVendorId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY IR.intEntityVendorId, Itm.strItemNo, T.intCommodityId
		
			UNION ALL SELECT T.intEntityId as intEntityVendorId
				, T.intCommodityId
				, 'Storage' COLLATE Latin1_General_CI_AS
				, SUM(ISNULL(ID.dblTotal, 0)) as dblTotal
				, 4 as intSorting
			FROM vyuSCGetScaleDistribution SC
			INNER JOIN tblSCTicket T ON T.intTicketId = SC.intTicketId
			INNER JOIN tblGRCustomerStorage CS ON SC.intTicketId = CS.intTicketId
			INNER JOIN tblARInvoiceDetail ID ON CS.intCustomerStorageId = ID.intCustomerStorageId
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			WHERE I.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), T.dtmTicketDateTime, 110), 110) <= @dtmToDate
				AND T.intEntityId = ISNULL(@intVendorId, T.intEntityId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY T.intEntityId,T.intCommodityId
		) src
	
		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourcePurchase WHERE FieldName = 'Discounts' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Discounts' COLLATE Latin1_General_CI_AS, 0, 3)
		END
			
		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourcePurchase WHERE FieldName = 'Storage' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Storage' COLLATE Latin1_General_CI_AS, 0, 4)
		END
			
		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourcePurchase WHERE FieldName = 'Tax' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Tax' COLLATE Latin1_General_CI_AS, 0, 5)
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourcePurchase WHERE FieldName = 'Fees' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourcePurchase (intEntityId,intCommodityId,FieldName,dblTotal,intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Fees' COLLATE Latin1_General_CI_AS, 0, 6)
		END

		INSERT INTO #tmpSourcePurchase (intEntityId
			, intCommodityId
			, FieldName
			, dblTotal
			, intSorting)
		VALUES (@intVendorId
			, @intCommodityId
			, 'Gross Dollars' COLLATE Latin1_General_CI_AS
			, (SELECT SUM(dblTotal) FROM #tmpSourcePurchase WHERE FieldName IN ('Net', 'Discounts', 'Tax', 'Storage', 'Fees') AND intCommodityId = @intCommodityId)
			, 2)
				
		SELECT @NetValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Net' AND intCommodityId = @intCommodityId
		SELECT @PurchasedValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Purchased' AND intCommodityId = @intCommodityId
		SELECT @PaidValue = dblTotal FROM #tmpSourcePurchase WHERE FieldName = 'Paid' AND intCommodityId = @intCommodityId
		SET @NetPayablesValue = (SELECT SUM(dblTotal) FROM #tmpSourcePurchase WHERE FieldName NOT IN ('Purchased', 'Paid', 'W.A.P', 'Gross Dollars', 'Discounts', 'Tax', 'Storage', 'Fees') AND intCommodityId = @intCommodityId)
			
		INSERT INTO #tmpSourcePurchase (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'W.A.P' COLLATE Latin1_General_CI_AS, @NetValue / @PurchasedValue, 8)

		INSERT INTO #tmpSourcePurchase (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'Net Payables' COLLATE Latin1_General_CI_AS, @NetPayablesValue, 99)
	
		INSERT INTO #tmpSourcePurchase (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'Unpaid Qty' COLLATE Latin1_General_CI_AS, ABS(@PurchasedValue - @PaidValue), 100)
	
		SELECT 1 AS intRowNumber
			, strType = 'Purchase'
			, t.intEntityId
			, t.intCommodityId
			, c.strCommodityCode
			, t.FieldName
			, t.dblTotal
		INTO #tmpYearToDate
		FROM #tmpSourcePurchase t
		INNER JOIN tblICCommodity c ON t.intCommodityId = c.intCommodityId
		WHERE FieldName NOT IN('Paid') 
			AND ISNULL(dblTotal, 0) != 0 --Remove all the fields that has 0 value
		ORDER BY intSorting

		--===================================
		--			SALE
		--===================================
		SELECT *
		INTO #tmpSourceSales
		FROM (
			SELECT intEntityId= InvShp.intEntityCustomerId
				, T.intCommodityId
				, FieldName = 'Paid' COLLATE Latin1_General_CI_AS
				, dblTotal = SUM(CASE WHEN I.dblInvoiceTotal = I.dblPayment THEN ID.dblQtyShipped
									ELSE (ID.dblQtyShipped/I.dblInvoiceTotal) * I.dblPayment END)
				, intSorting = 0
			FROM tblICInventoryShipment InvShp 
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId
			WHERE ID.intInventoryShipmentChargeId IS NULL
				AND I.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT intEntityId = InvShp.intEntityCustomerId
				, T.intCommodityId
				, FieldName = 'Sold' COLLATE Latin1_General_CI_AS
				, dblTotal = SUM(ID.dblQtyShipped)
				, intSorting = 1
			FROM tblICInventoryShipment InvShp
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId
			WHERE ID.intInventoryShipmentChargeId IS NULL
				AND I.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT intEntityId = InvShp.intEntityCustomerId
				, T.intCommodityId
				, FieldName = 'Net' COLLATE Latin1_General_CI_AS
				, dblTotal = SUM(ID.dblTotal)
				, intSorting = 7
			FROM tblICInventoryShipment InvShp
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId
			WHERE ID.intInventoryShipmentChargeId IS NULL
				AND I.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT InvShp.intEntityCustomerId as intEntityId
				, T.intCommodityId
				, 'Tax' COLLATE Latin1_General_CI_AS as FieldName
				, SUM(I.dblTax) as dblTotal
				, 5 as intSorting
			FROM tblICInventoryShipment InvShp
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentItemId = InvShpItm.intInventoryShipmentItemId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			LEFT JOIN tblICItem Itm ON InvShpItm.intItemId = Itm.intItemId
			WHERE ID.intInventoryShipmentChargeId IS NULL
				AND I.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT intEntityId = InvShp.intEntityCustomerId
				, T.intCommodityId
				, 'Discounts' COLLATE Latin1_General_CI_AS
				, dblDiscount = SUM(ID.dblTotal)
				, intSorting = 3
			FROM tblICInventoryShipment InvShp 
			INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE ID.intInventoryShipmentChargeId IS NOT NULL
				AND I.ysnPosted = 1
				AND Itm.strCostType = 'Grain Discount'
				AND Itm.intItemId <> SS.intDefaultFeeItemId
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT intEntityId = InvShp.intEntityCustomerId
				, T.intCommodityId
				, 'Fees' COLLATE Latin1_General_CI_AS
				, dblFees = SUM(ID.dblTotal)
				, intSorting = 6
			FROM tblICInventoryShipment InvShp
			INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE ID.intInventoryShipmentChargeId IS NOT NULL
				AND I.ysnPosted = 1
				AND Itm.strCostType = 'Other Charges'
				AND Itm.intItemId = SS.intDefaultFeeItemId 
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmDate, 110), 110) <= @dtmToDate
				AND InvShp.intEntityCustomerId = ISNULL(@intVendorId, InvShp.intEntityCustomerId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId
		
			UNION ALL SELECT intEntityId = InvShp.intEntityCustomerId
				, T.intCommodityId
				, Itm.strItemNo
				, dblTotal = SUM(ID.dblTotal)
				, intSorting = 9
			FROM tblICInventoryShipment InvShp
			INNER JOIN tblICInventoryShipmentCharge ShpCharge ON InvShp.intInventoryShipmentId = ShpCharge.intInventoryShipmentId
			INNER JOIN tblICInventoryShipmentItem InvShpItm ON InvShpItm.intInventoryShipmentId = InvShp.intInventoryShipmentId
			INNER JOIN tblSCTicket T ON T.intTicketId = InvShpItm.intSourceId
			INNER JOIN tblARInvoiceDetail ID ON ID.intInventoryShipmentChargeId = ShpCharge.intInventoryShipmentChargeId
			INNER JOIN tblARInvoice I ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem Itm ON ShpCharge.intChargeId = Itm.intItemId
			INNER JOIN tblSCScaleSetup SS ON T.intScaleSetupId = SS.intScaleSetupId
			WHERE ID.intInventoryShipmentChargeId IS NOT NULL
				AND I.ysnPosted = 1
				AND Itm.strCostType <> 'Grain Discount'
				AND ID.intItemId <> SS.intDefaultFeeItemId
				AND T.intEntityId = ISNULL(@intVendorId, T.intEntityId)
				AND T.intCommodityId = ISNULL(@intCommodityId, T.intCommodityId)
			GROUP BY InvShp.intEntityCustomerId,T.intCommodityId,Itm.strItemNo
		) src

		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourceSales WHERE FieldName = 'Discounts' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Discounts' COLLATE Latin1_General_CI_AS, 0, 3)
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourceSales WHERE FieldName = 'Storage' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Storage' COLLATE Latin1_General_CI_AS, 0, 4)
		END
		
		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourceSales WHERE FieldName = 'Tax' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
			VALUES (@intVendorId, @intCommodityId, 'Tax' COLLATE Latin1_General_CI_AS, 0, 5)
		END

		IF NOT EXISTS (SELECT TOP 1 1 FROM #tmpSourceSales WHERE FieldName = 'Fees' AND intCommodityId = @intCommodityId)
		BEGIN
			INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting	)
			VALUES (@intVendorId, @intCommodityId, 'Fees' COLLATE Latin1_General_CI_AS, 0, 6)
		END
		
		INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'Gross Dollars' COLLATE Latin1_General_CI_AS, (SELECT SUM(dblTotal)
																								FROM #tmpSourceSales
																								WHERE FieldName IN ('Net', 'Discounts', 'Tax', 'Storage', 'Fees')
																									AND intCommodityId = @intCommodityId), 2)

		SELECT @NetValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Net' AND intCommodityId = @intCommodityId
		SELECT @SoldValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Sold' AND intCommodityId = @intCommodityId
		SELECT @PaidValue = dblTotal FROM #tmpSourceSales WHERE FieldName = 'Paid' AND intCommodityId = @intCommodityId
		SET @NetReceivablesValue = (SELECT SUM(dblTotal) FROM #tmpSourceSales WHERE FieldName NOT IN ('Sold', 'Paid', 'W.A.P', 'Gross Dollars', 'Discounts', 'Tax', 'Storage', 'Fees') AND intCommodityId = @intCommodityId)
	
		INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'W.A.P' COLLATE Latin1_General_CI_AS, @NetValue / @SoldValue, 8)

		INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'Net Receivables' COLLATE Latin1_General_CI_AS, @NetReceivablesValue, 99)
	
		INSERT INTO #tmpSourceSales (intEntityId, intCommodityId, FieldName, dblTotal, intSorting)
		VALUES (@intVendorId, @intCommodityId, 'Unpaid Qty' COLLATE Latin1_General_CI_AS, ABS(@SoldValue - @PaidValue), 100)
		
		INSERT INTO #tmpYearToDate(intRowNumber
			, strType
			, intEntityId
			, intCommodityId
			, strCommodityCode
			, FieldName
			, dblTotal)
		SELECT intRowNumber = 2
			, 'Sale'
			, t.intEntityId
			, t.intCommodityId
			, c.strCommodityCode
			, t.FieldName
			, t.dblTotal
		FROM #tmpSourceSales t
		INNER JOIN tblICCommodity c ON t.intCommodityId = c.intCommodityId
		WHERE FieldName NOT IN('Paid')
			AND ISNULL(dblTotal, 0) != 0 --Remove all the fields that has 0 value
		ORDER BY intSorting
		
		INSERT INTO tblRKDPRYearToDate(intDPRHeaderId
			, intRowNumber
			, strType
			, intEntityId
			, intCommodityId
			, strCommodityCode
			, strFieldName
			, dblTotal)
		SELECT @intDPRHeaderId
			, intRowNumber
			, strType
			, intEntityId
			, intCommodityId
			, strCommodityCode
			, FieldName
			, dblTotal
		FROM #tmpYearToDate
		WHERE strType <> @strPurchaseSales
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	SET @ErrMsg = @ErrMsg
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH