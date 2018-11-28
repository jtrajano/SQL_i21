﻿CREATE PROCEDURE [dbo].[uspRKDPRInvDailyPositionDetail]
	@intCommodityId NVARCHAR(MAX)
	, @intLocationId INT = NULL
	, @intVendorId INT = NULL
	, @strPurchaseSales NVARCHAR(250) = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @dtmToDate DATETIME = NULL
	, @strByType NVARCHAR(50) = NULL

AS

BEGIN
	SET @dtmToDate = CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToDate, 110), 110)
	DECLARE @ysnDisplayAllStorage BIT
		, @ysnIncludeDPPurchasesInCompanyTitled BIT

	IF (@intLocationId = 0) SET @intLocationId = NULL
	IF (@intVendorId = 0) SET @intVendorId = NULL

	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
										ELSE isnull(ysnLicensed, 0) END

	SELECT @ysnDisplayAllStorage = ISNULL(ysnDisplayAllStorage, 0)
		, @ysnIncludeDPPurchasesInCompanyTitled = ISNULL(ysnIncludeDPPurchasesInCompanyTitled, 0)
	FROM tblRKCompanyPreference
	
	DECLARE @Commodity AS TABLE (intCommodityIdentity INT IDENTITY PRIMARY KEY
		, intCommodity INT)
		
	IF (@strByType = 'ByCommodity')
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT intCommodityId from tblICCommodity
	END
	ELSE
	BEGIN
		INSERT INTO @Commodity(intCommodity)
		SELECT Item Collate Latin1_General_CI_AS FROM [dbo].[fnSplitString](@intCommodityId, ',')
	END
	
	IF (ISNULL(@strPurchaseSales, '') <> '')
	BEGIN
		IF @strPurchaseSales = 'Purchase'
		BEGIN
			SELECT @strPurchaseSales = 'Sales'
		END
		ELSE
		BEGIN
			SELECT @strPurchaseSales = 'Purchase'
		END
	END
	
	DECLARE @Final AS TABLE (intRow INT IDENTITY PRIMARY KEY
		, intSeqId INT
		, strSeqHeader NVARCHAR(100)
		, strCommodityCode NVARCHAR(100)
		, strType NVARCHAR(100)
		, dblTotal DECIMAL(24,10)
		, intCollateralId INT
		, strLocationName NVARCHAR(250)
		, strCustomerName NVARCHAR(250)
		, intReceiptNo NVARCHAR(250)
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(100)
		, strCustomerReference NVARCHAR(100)
		, strDistributionOption NVARCHAR(100)
		, strDPAReceiptNo NVARCHAR(100)
		, dblDiscDue DECIMAL(24,10)
		, dblStorageDue DECIMAL(24,10)
		, dtmLastStorageAccrueDate datetime
		, strScheduleId NVARCHAR(100)
		, intTicketId INT
		, strTicketType NVARCHAR(100)
		, strTicketNumber NVARCHAR(100)
		, dtmOpenDate DATETIME
		, dtmDeliveryDate DATETIME
		, dtmTicketDateTime DATETIME
		, dblOriginalQuantity DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strUnitMeasure NVARCHAR(100)
		, intFromCommodityUnitMeasureId INT
		, intToCommodityUnitMeasureId INT
		, strTruckName NVARCHAR(100)
		, strDriverName NVARCHAR(100)
		, intCompanyLocationId INT
		, intStorageScheduleTypeId INT		
		, strShipmentNumber NVARCHAR(100)
		, intInventoryShipmentId INT
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(100)
		, strTransactionType NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
		
	DECLARE @FinalTable AS TABLE (intRow INT IDENTITY PRIMARY KEY
		, intSeqId INT
		, strSeqHeader NVARCHAR(100)
		, strCommodityCode NVARCHAR(100)
		, strType NVARCHAR(100)
		, dblTotal DECIMAL(24,10)
		, intCollateralId INT
		, strLocationName NVARCHAR(250)
		, strCustomerName NVARCHAR(250)
		, intReceiptNo NVARCHAR(250)
		, intContractHeaderId INT
		, strContractNumber NVARCHAR(100)
		, strCustomerReference NVARCHAR(100)
		, strDistributionOption NVARCHAR(100)
		, strDPAReceiptNo NVARCHAR(100)
		, dblDiscDue DECIMAL(24,10)
		, dblStorageDue DECIMAL(24,10)
		, dtmLastStorageAccrueDate DATETIME
		, strScheduleId NVARCHAR(100)
		, intTicketId INT
		, strTicketType NVARCHAR(100)
		, strTicketNumber NVARCHAR(100)		
		, dtmOpenDate DATETIME
		, dtmDeliveryDate DATETIME
		, dtmTicketDateTime DATETIME
		, dblOriginalQuantity  DECIMAL(24,10)
		, dblRemainingQuantity DECIMAL(24,10)
		, intCommodityId INT
		, intItemId INT
		, strItemNo NVARCHAR(100)
		, strUnitMeasure NVARCHAR(100)
		, intFromCommodityUnitMeasureId int
		, intToCommodityUnitMeasureId int
		, strTruckName NVARCHAR(100)
		, strDriverName NVARCHAR(100)
		, intCompanyLocationId INT
		, strShipmentNumber NVARCHAR(100)
		, intInventoryShipmentId INT
		, intInventoryReceiptId INT
		, strReceiptNumber NVARCHAR(100)
		, strTransactionType NVARCHAR(100)
		, intCategoryId INT
		, strCategory NVARCHAR(100)
		, intFutureMarketId INT
		, strFutMarketName NVARCHAR(100)
		, intFutureMonthId INT
		, strFutureMonth NVARCHAR(100)
		, strBrokerTradeNo NVARCHAR(100)
		, strNotes NVARCHAR(100)
		, ysnPreCrush BIT)
	
	DECLARE @mRowNumber INT
		, @strCommodityCode NVARCHAR(250)
		, @intCommodityUnitMeasureId INT
	
	SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity WHERE intCommodity > 0
	
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @intCommodityId = intCommodity FROM @Commodity WHERE intCommodityIdentity = @mRowNumber
		SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity WHERE intCommodityId = @intCommodityId
		SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId FROM tblICCommodityUnitMeasure WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
		
		IF ISNULL(@intCommodityId, 0) > 0
		BEGIN
			IF OBJECT_ID('tempdb..#tblGetOpenContractDetail') IS NOT NULL
				DROP TABLE #tblGetOpenContractDetail
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
				
			SELECT intRowNum
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
				, intCommodityUnitMeasureId
				, intContractDetailId
				, intContractStatusId
				, intEntityId
				, intCurrencyId
				, strType
				, intItemId
				, strItemNo
				, dtmContractDate
				, strEntityName
				, strCustomerContract
				, intCategoryId
				, strCategory
				, intFutureMonthId
				, intFutureMarketId
				, strFutMarketName
				, strFutureMonth
				, strCurrency
			INTO #tblGetOpenContractDetail
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intContractDetailId ORDER BY dtmContractDate DESC)
					, dtmContractDate
					, strCommodityCode
					, intCommodityId
					, intContractHeaderId
					, strContractNumber
					, strLocationName
					, dtmEndDate = CASE  WHEN ISNULL(strFutureMonth,'') <> '' THEN CONVERT(DATETIME, REPLACE(strFutureMonth, ' ', ' 1, ')) ELSE dtmEndDate END
					, dblBalance
					, intUnitMeasureId
					, intPricingTypeId
					, intContractTypeId
					, intCompanyLocationId
					, strContractType
					, strPricingType
					, intCommodityUnitMeasureId
					, intContractDetailId
					, intContractStatusId
					, intEntityId
					, intCurrencyId
					, strType
					, intItemId
					, strItemNo
					, strEntityName
					, strCustomerContract
					, intCategoryId
					, strCategory
					, intFutureMonthId
					, intFutureMarketId
					, strFutMarketName
					, strFutureMonth
					, strCurrency
				FROM vyuRKContractDetail CD
				WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmContractDate, 110), 110) <= @dtmToDate
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
					, dtmDeliveryDate = CASE WHEN gh.strType = 'Transfer' THEN CONVERT(DATETIME, CONVERT(VARCHAR(10), gh.dtmHistoryDate, 110), 110) ELSE CONVERT(DATETIME, CONVERT(VARCHAR(10), a.dtmDeliveryDate, 110), 110) END
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
										ELSE 'Customer/Maintain Storage' END)
					, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
										WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
										WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
										ELSE a.strStorageTicketNumber END)
					, gh.intInventoryReceiptId
					, gh.intInventoryShipmentId
					, strReceiptNumber = ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '')
					, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
					, b.intStorageScheduleTypeId
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
					, dtmDeliveryDate = CASE WHEN gh.strType = 'Transfer' THEN CONVERT(DATETIME, CONVERT(VARCHAR(10), gh.dtmHistoryDate, 110), 110)
											ELSE CONVERT(DATETIME, CONVERT(VARCHAR(10), a.dtmDeliveryDate, 110), 110) END
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
										ELSE 'Customer/Maintain Storage' END)
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
		
			--=============================
			-- Storage Off Site
			--=============================
			SELECT * INTO #tblGetStorageOffSiteDetail
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY sh.intStorageHistoryId ORDER BY intStorageHistoryId ASC)
					, a.intCustomerStorageId
					, a.intCompanyLocationId
					, strLocationName = sl.strSubLocationName
					, a.dtmDeliveryDate
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
										ELSE 'Customer/Maintain Storage' END)
					, strTicketNumber = (CASE WHEN sh.intTransactionTypeId = 1 THEN NULL
										WHEN sh.intTransactionTypeId = 4 THEN sh.strSettleTicket
										WHEN sh.intTransactionTypeId = 3 THEN sh.strTransferTicket
										ELSE a.strStorageTicketNumber END)
				FROM tblICInventoryReceipt r
				JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId
				JOIN tblSCTicket sc ON sc.intTicketId = ri.intSourceId
				LEFT JOIN tblSMCompanyLocationSubLocation sl ON sl.intCompanyLocationSubLocationId = sc.intSubLocationId AND sl.intCompanyLocationId = sc.intProcessingLocationId
				JOIN tblICItem i ON i.intItemId = sc.intItemId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				JOIN tblGRStorageHistory sh ON sh.intTicketId = sc.intTicketId
				JOIN tblGRCustomerStorage a ON a.intCustomerStorageId = sh.intCustomerStorageId
				JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId AND b.ysnCustomerStorage = 1
				JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
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
			INTO #tblGetSalesIntransitWOPickLot
			FROM(
				SELECT 
					strTransactionId AS strShipmentNumber
					,intTransactionId AS intInventoryShipmentId
					,strContractNumber
					,intContractHeaderId
					,strTicketNumber
					,intTicketId
					,dtmDate AS dtmTicketDateTime
					,intLocationId AS intCompanyLocationId
					,strLocationName
					,strUOM
					,intEntityId
					,strEntity AS strCustomerReference
					,intCommodityId
					,intItemId
					,strItemNo
					,strCategory
					,intCategoryId
					,dblBalanceToInvoice 
				FROM (
					SELECT 
						 Inv.strTransactionId
						,Inv.intTransactionId
						,strContractNumber = (SELECT TOP 1 strOrderNumber FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intOrderId IS NOT NULL)
						,intContractHeaderId = (SELECT TOP 1  intOrderId FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intOrderId IS NOT NULL)
						,strTicketNumber = (SELECT TOP 1 strSourceNumber FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intSourceId IS NOT NULL)
						,intTicketId = (SELECT TOP 1  intSourceId FROM vyuICGetInventoryShipmentItem WHERE intInventoryShipmentId = Inv.intTransactionId AND intSourceId IS NOT NULL)
						,Inv.dtmDate
						,Inv.intLocationId
						,Inv.strLocationName
						,Inv.strUOM
						,Inv.intEntityId
						,Inv.strEntity
						,C.intCommodityId
						,Inv.intItemId
						,Inv.strItemNo
						,Inv.strCategory
						,Inv.intCategoryId
						,dblBalanceToInvoice = SUM(Inv.dblQuantity)
						+ ISNULL((SELECT SUM(iv.dblQty)
											FROM tblARInvoiceDetail i 
												JOIN tblICInventoryTransaction iv ON i.intInvoiceDetailId = iv.intTransactionDetailId
											WHERE 
												iv.intInTransitSourceLocationId IS NOT NULL 
												AND intTransactionTypeId = 33 --'Invoice'
												and iv.intItemId = Inv.intItemId
												and i.strDocumentNumber = Inv.strTransactionId), 0)
					FROM vyuRKGetInventoryValuation Inv
					INNER JOIN tblICItem I ON Inv.intItemId = I.intItemId
					INNER JOIN tblICCommodity C ON I.intCommodityId = C.intCommodityId 
					WHERE Inv.ysnInTransit = 1  
						AND Inv.strTransactionType = 'Inventory Shipment'
						AND C.intCommodityId = @intCommodityId
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmToDate)
						AND ISNULL(Inv.intEntityId,0) = CASE WHEN ISNULL(@intVendorId,0)=0 THEN ISNULL(Inv.intEntityId,0) ELSE @intVendorId END
					GROUP BY 
						 Inv.strTransactionId
						,Inv.intTransactionId
						,Inv.dtmDate
						,Inv.intLocationId
						,Inv.strLocationName
						,Inv.strUOM
						,Inv.intEntityId
						,Inv.strEntity
						,C.intCommodityId
						,Inv.intItemId
						,Inv.strItemNo
						,Inv.strCategory
						,Inv.intCategoryId
				) tbl
				WHERE dblBalanceToInvoice <> 0
			)t
		
			SELECT * INTO #tempCollateral
			FROM (
				SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY intCollateralId ORDER BY dtmOpenDate DESC)
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0))
					, c.intCollateralId
					, cl.strLocationName
					, ch.intItemId
					, ch.strItemNo
					, ch.intCategoryId
					, ch.strCategory
					, ch.strEntityName
					, c.intReceiptNo
					, ch.intContractHeaderId
					, strContractNumber
					, c.dtmOpenDate
					, dblOriginalQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblOriginalQuantity),0))
					, dblRemainingQuantity = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((c.dblRemainingQuantity),0))
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
				FROM tblRKCollateral c
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = c.intCommodityId AND c.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = c.intLocationId
				LEFT JOIN #tblGetOpenContractDetail ch ON c.intContractHeaderId = ch.intContractHeaderId AND ch.intContractStatusId <> 3
				WHERE c.intCommodityId = @intCommodityId AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmOpenDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND ISNULL(intEntityId, 0) = ISNULL(@intVendorId, ISNULL(intEntityId, 0))
					and cl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			) a WHERE a.intRowNum = 1
		
			--=============================
			-- Inventory Valuation
			--=============================
			SELECT dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(s.dblQuantity ,0)))
				, strCustomer = ''
				, dtmDeliveryDate = dtmDate
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
				,intContractHeaderId = CT.intContractNumber
				,strContractNumber = CT.strContractNumber
			INTO #invQty
			FROM vyuRKGetInventoryValuation s
			JOIN tblICItem i ON i.intItemId = s.intItemId
			JOIN tblICItemUOM iuom ON s.intItemId = iuom.intItemId AND iuom.ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
			OUTER APPLY(
				SELECT intContractNumber, strContractIds, strContractNumber = strContractNumbers collate Latin1_General_CS_AS 
				FROM dbo.fnRKGetContracts(s.intTransactionId, i.intItemId, s.strTransactionType)
			) CT 
			WHERE i.intCommodityId = @intCommodityId AND iuom.ysnStockUnit = 1 AND ISNULL(s.dblQuantity, 0) <> 0
				AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
				AND ISNULL(strTicketStatus, '') <> 'V'
				AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToDate)
				AND ysnInTransit = 0
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
					, dtmDeliveryDate = dtmTicketDateTime
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
					, strTicketType = 'Scale Ticket'
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
				, dtmDeliveryDate
				, strTicketNumber
				, intTicketId
				, dtmTicketDateTime
				, strTransactionType
				, intContractHeaderId
				, strContractNumber)
			SELECT intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strTransactionId
				, intTransactionId
				, strDistributionOption
				, dtmDeliveryDate
				, strTicketNumber
				, intTicketId
				, dtmTicketDateTime
				, strTransactionType
				, intContractHeaderId
				, strContractNumber
			FROM (
				SELECT 1 AS intSeqId
					, strSeqHeader = 'In-House'
					, strCommodityCode = @strCommodityCode
					, strType = 'Receipt'
					, dblTotal = ISNULL(dblTotal, 0)
					, strLocationName
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
					, dtmDeliveryDate
					, strTicketNumber
					, intTicketId
					, dtmTicketDateTime
					, strTransactionType
					, intContractHeaderId
					, strContractNumber
				FROM #invQty
				WHERE intCommodityId = @intCommodityId
			) t
			GROUP BY intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strTransactionId
				, intTransactionId
				, strDistributionOption
				, dtmDeliveryDate
				, strTicketNumber
				, intTicketId
				, dtmTicketDateTime
				, strTransactionType
				, intContractHeaderId
				, strContractNumber
		
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
				, dtmDeliveryDate
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
				, strSeqHeader = 'In-House'
				, strCommodityCode = @strCommodityCode
				, strType = strStorageType
				, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblBalance)
				, strCustomerName
				, intTicketId
				, strTicketType
				, strTicketNumber
				, dtmDeliveryDate
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
				, 'Storage'
				, dtmTicketDateTime
				, intStorageScheduleTypeId
				,CT.intContractNumber
				,CT.strContractNumber
			FROM #tblGetStorageDetailByDate s
			JOIN tblEMEntity e ON e.intEntityId = s.intEntityId
			OUTER APPLY(
				SELECT intContractNumber, strContractIds, strContractNumber = strContractNumbers collate Latin1_General_CS_AS 
				FROM dbo.fnRKGetContracts(s.intTicketId, s.intItemId, s.strTicketType)
			) CT
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
				, dtmDeliveryDate
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
				, dtmDeliveryDate
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
					, strSeqHeader = 'In-House'
					, strCommodityCode = @strCommodityCode
					, strType = 'On-Hold'
					, dblTotal
					, strCustomerName
					, intTicketId
					, strTicketType
					, strTicketNumber
					, dtmDeliveryDate
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
				where intCommodityId = @intCommodityId
			)t GROUP BY intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, strCustomerName
				, intTicketId
				, strTicketType
				, strTicketNumber
				, dtmDeliveryDate
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
				, dtmDeliveryDate
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
				, 'Off-Site'
				, @strCommodityCode
				, 'Off-Site'
				, dblTotal
				, intCommodityId
				, strLocationName
				, strItemNo
				, dtmDeliveryDate
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
					, dtmDeliveryDate
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
				, intContractHeaderId
				, strContractNumber
				, intCommodityId
				, intFromCommodityUnitMeasureId)
			SELECT intSeqId = 3
				, 'Purchase In-Transit'
				, @strCommodityCode
				, strType = 'Purchase In-Transit'
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
					-- Not sure why this part doesn't default to zero values for non-value
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
				, strCustomerReference
				, intContractHeaderId
				, strContractNumber
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, dtmTicketDateTime
				, intTicketId
				, strTicketNumber)
			SELECT intSeqId = 4
				, 'Sales In-Transit'
				, @strCommodityCode
				, strType = 'Sales In-Transit'
				, dblTotal = ISNULL(dblBalanceToInvoice, 0)
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
				FROM #tblGetSalesIntransitWOPickLot i
				WHERE i.intCommodityId = @intCommodityId
					AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId))t
		
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
				, dtmDeliveryDate
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
				, dtmDeliveryDate
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
				, dtmDeliveryDate
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
					, strSeqHeader = 'Total Non-Receipted'
					, strCommodityCode = @strCommodityCode
					--, strStorageType = 'Total Non-Receipted'
					, r.strStorageType
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL(dblBalance, 0))
					, r.strCustomerName
					, dtmDeliveryDate
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
				) t	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
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
				, intCategoryId
				, strCategory
				, strCustomerName
				, intReceiptNo
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
				SELECT intSeqId = 8
					, strSeqHeader = 'Collateral Receipts - Sales'
					, strCommodityCode = @strCommodityCode
					, strType = 'Collateral Receipts - Sales'
					, dblTotal
					, intCollateralId
					, strLocationName
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, strEntityName
					, intReceiptNo
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
				, intCategoryId
				, strCategory
				, strCustomerName
				, intReceiptNo
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
					, strSeqHeader = 'Collateral Receipts - Purchase'
					, strCommodityCode = @strCommodityCode
					, strType = 'Collateral Receipts - Purchase'
					, dblTotal
					, intCollateralId
					, strLocationName
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, strEntityName
					, intReceiptNo
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
				, dtmDeliveryDate
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
					, dtmDeliveryDate
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
				, 'Total Receipted'
				, @strCommodityCode
				, strType = 'Collateral Purchase'
				, dblTotal = - ISNULL(dblTotal, 0)
				, @intCommodityId
				, @intCommodityUnitMeasureId
				, strLocationName
			FROM @Final WHERE intSeqId = 9
		
			UNION ALL
			SELECT intSeqId = 11
				, 'Total Receipted'
				, @strCommodityCode
				, strType = 'Collateral Sale'
				, dblTotal = ISNULL(dblTotal, 0)
				, @intCommodityId
				, @intCommodityUnitMeasureId
				, strLocationName
			FROM @Final WHERE intSeqId = 8
		
			UNION ALL
			SELECT intSeqId = 11
				, 'Total Receipted'
				, @strCommodityCode
				, strType = 'Collateral Receipted'
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
				, dtmDeliveryDate
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
			SELECT * FROM (
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
					, dtmDeliveryDate
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
				, strCustomerReference
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
				, strFutureMonth)
			SELECT intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, sum(dblTotal)
				, intCommodityId
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, strTicketNumber
				, dtmTicketDateTime
				, strCustomerReference
				, strDistributionOption
				, intCommodityUnitMeasureId 
				, intCompanyLocationId
				, strReceiptNumber 
				, strContractNumber
				, intContractHeaderId
				, intInventoryReceiptId
				, strReceiptNumber
				, intFutureMonthId
				, intFutureMarketId
				, strFutMarketName
				, strFutureMonth
			FROM (
				SELECT 13 intSeqId
					, strSeqHeader = 'Purchase Basis Deliveries'
					, strCommodityCode = @strCommodityCode
					, strType = 'Purchase Basis Deliveries'
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(v.dblQuantity ,0))
					, intCommodityId = @intCommodityId
					, cl.strLocationName
					, v.intItemId
					, v.strItemNo
					, v.intCategoryId
					, v.strCategory
					, strTicketNumber
					, st.dtmTicketDateTime
					, strCustomerReference
					, strDistributionOption
					, intCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, intCompanyLocationId = st.intProcessingLocationId
					, strReceiptNumber
					, cd.strContractNumber
					, cd.intContractHeaderId
					, r.intInventoryReceiptId
					, cd.intFutureMonthId
					, cd.intFutureMarketId
					, cd.strFutMarketName
					, cd.strFutureMonth
				FROM vyuRKGetInventoryValuation v
				JOIN tblICInventoryReceipt r ON r.strReceiptNumber = v.strTransactionId
				INNER JOIN tblICInventoryReceiptItem ri ON r.intInventoryReceiptId = ri.intInventoryReceiptId AND r.strReceiptType = 'Purchase Contract'
				INNER JOIN tblSCTicket st ON st.intTicketId = ri.intSourceId  AND strDistributionOption IN ('CNT') AND ISNULL(ysnInTransit, 0) = 0
				INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
				INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = st.intProcessingLocationId
				WHERE v.strTransactionType = 'Inventory Receipt' AND cd.intCommodityId = @intCommodityId
					AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate) AND ISNULL(strTicketStatus, '') <> 'V'
			) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			GROUP BY intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, intCommodityId
				, strLocationName
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, strTicketNumber
				, dtmTicketDateTime
				, strCustomerReference
				, strDistributionOption
				, intCommodityUnitMeasureId 
				, intCompanyLocationId
				, strReceiptNumber 
				, strContractNumber
				, intContractHeaderId
				, intInventoryReceiptId
				, strReceiptNumber
				, intFutureMarketId
				, intFutureMonthId
				, strFutMarketName
				, strFutureMonth
		
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
				, dtmTicketDateTime
				, strCustomerReference
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
				, strFutureMonth)
			SELECT intSeqId
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
				, dtmTicketDateTime
				, strCustomerReference
				, strDistributionOption
				, intUnitMeasureId
				, intCompanyLocationId
				, strShipmentNumber
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
			FROM (
				SELECT DISTINCT intSeqId = 14
					, strSeqHeader = 'Sales Basis Deliveries'
					, strCommodityCode = @strCommodityCode
					, strType = 'Sales Basis Deliveries'
					, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))
					, cd.intCommodityId
					, cl.strLocationName
					, cd.intItemId
					, cd.strItemNo
					, cd.intCategoryId
					, cd.strCategory
					, intTicketId = cd.intContractDetailId
					, strTicketNumber = cd.strContractNumber
					, dtmTicketDateTime = cd.dtmContractDate
					, strCustomerReference = cd.strCustomerContract
					, strDistributionOption = 'CNT'
					, cd.intUnitMeasureId
					, cl.intCompanyLocationId
					, r.strShipmentNumber
					, cd.intContractHeaderId
					, cd.strContractNumber
					, r.intInventoryShipmentId
					, ri.intSourceId
					, cd.intFutureMarketId
					, cd.intFutureMonthId
					, cd.strFutMarketName
					, cd.strFutureMonth
				FROM vyuRKGetInventoryValuation v
				JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
				INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
				INNER JOIN #tblGetOpenContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3 AND cd.intContractTypeId = 2
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
				INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
				LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
				LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
				WHERE cd.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
					AND cl.intCompanyLocationId = ISNULL(@intLocationId, cl.intCompanyLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToDate)
					AND ISNULL(inv.ysnPosted, 0) = 0
			) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
		
			--Company Title from Inventory Valuation
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
				, strFutureMonth)
			SELECT intSeqId = 15
				, strSeqHeader = 'Company Titled Stock'
				, strCommodityCode
				, strType = 'Receipt'
				, dblTotal
				, strLocationName
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
			FROM @Final f
			LEFT JOIN (
				SELECT strStorageTypeCode,ysnDPOwnedType, intInventoryReceiptId 
				FROM tblGRStorageHistory SH
				INNER JOIN tblGRCustomerStorage CS ON SH.intCustomerStorageId = CS.intCustomerStorageId
				INNER JOIN tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
			) Strg ON f.intInventoryReceiptId = Strg.intInventoryReceiptId    
			WHERE strSeqHeader = 'In-House' AND strType = 'Receipt' AND intCommodityId = @intCommodityId AND isnull(Strg.ysnDPOwnedType,0) = 0
		
			
			--Company Title from DP Settlement
			INSERT INTO @Final(intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal
				, strLocationName
				, intItemId
				, strItemNo
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strReceiptNumber
				, intInventoryReceiptId
				, intTicketId
				, strTicketNumber
				, dtmTicketDateTime)
			SELECT intSeqId = 15
				, strSeqHeader = 'Company Titled Stock'
				, @strCommodityCode
				, strType = 'DP Settlement' 
				, dblTotal 
				, strLocationName
				, intItemId
				, strItemNo
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strReceiptNumber
				, intInventoryReceiptId
				, intTicketId
				, strTicketNumber
				, dtmTicketDateTime 
			FROM(
				SELECT null as intTicketId
					, '' as strTicketNumber
					, CS.intItemId
					, strItemNo
					, strSettleTicket as strReceiptNumber
					, intSettleStorageId as intInventoryReceiptId
					, dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,(isnull(dblUnits,0))) dblTotal
					, CS.intCompanyLocationId
					, intUnitMeasureId intFromCommodityUnitMeasureId
					, CS.intCommodityId
					, strLocationName
					, dtmHistoryDate as dtmTicketDateTime
				FROM tblGRCustomerStorage CS
					inner join vyuGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
					inner join tblICItem I ON CS.intItemId = I.intItemId
				WHERE CS.intStorageTypeId = 2 
					AND intTransactionTypeId = 4 --Settlement & Reverse Settlement
					AND CS.intCommodityId  = @intCommodityId
					AND CS.intCompanyLocationId= case when isnull(@intLocationId,0)=0 then CS.intCompanyLocationId else @intLocationId end
					AND ISNULL(SH.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(SH.intEntityId, 0))
				)t
					WHERE intCompanyLocationId  IN (
							SELECT intCompanyLocationId FROM tblSMCompanyLocation
							WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
							WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
							ELSE isnull(ysnLicensed, 0) END
			)

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
						, strSeqHeader = 'Company Titled Stock'
						, strCommodityCode = @strCommodityCode
						, strType
						, dblTotal = CASE WHEN strType = 'Collateral Receipts - Purchase' THEN ISNULL(dblTotal, 0) ELSE - ISNULL(dblTotal, 0) END
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
					FROM @Final
					WHERE intSeqId IN (9,8) AND strType IN ('Collateral Receipts - Purchase','Collateral Receipts - Sales') AND intCommodityId = @intCommodityId
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
				) t WHERE dblTotal <> 0
		
			INSERT INTO @Final (intSeqId
				, strSeqHeader
				, strCommodityCode
				, strType
				, dblTotal
				, intCommodityId
				, strLocationName
				, intTicketId
				, strTicketType
				, strTicketNumber
				, dtmTicketDateTime
				, strCustomerReference
				, strDistributionOption
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strDPAReceiptNo
				, strContractNumber
				, intInventoryShipmentId
				, strShipmentNumber
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, intFutureMonthId
				, strFutMarketName
				, strFutureMonth)
			SELECT intSeqId = 15
				, strSeqHeader = 'Company Titled Stock'
				, strCommodityCode
				, strType
				, dblTotal
				, intCommodityId
				, strLocationName
				, intTicketId
				, strTicketType
				, strTicketNumber
				, dtmTicketDateTime
				, strCustomerReference
				, strDistributionOption
				, intFromCommodityUnitMeasureId
				, intCompanyLocationId
				, strDPAReceiptNo
				, strContractNumber
				, intInventoryShipmentId
				, strShipmentNumber
				, intItemId
				, strItemNo
				, intCategoryId
				, strCategory
				, intFutureMarketId
				, intFutureMonthId
				, strFutMarketName
				, strFutureMonth
			FROM @Final WHERE intSeqId = 14 AND intCommodityId = @intCommodityId
		
			IF ((SELECT TOP 1 ysnIncludeOffsiteInventoryInCompanyTitled FROM tblRKCompanyPreference) = 1)
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
					, dtmDeliveryDate
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
					, 'Company Titled Stock'
					, @strCommodityCode
					, 'Off-Site'
					, dblTotal
					, intCommodityId
					, strLocationName
					, intItemId
					, strItemNo
					, intCategoryId
					, strCategory
					, dtmDeliveryDate
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
						, dtmDeliveryDate
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
			IF ((SELECT TOP 1 ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference) = 1)
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
					, 'Company Titled Stock'
					, @strCommodityCode
					, 'DP'
					, dblTotal = sum(dblTotal)
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
				, strSeqHeader = 'On-Hold'
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
		
			DECLARE @intUnitMeasureId INT
				, @strUnitMeasure NVARCHAR(250)
			
			SELECT TOP 1 @intUnitMeasureId = intUnitMeasureId FROM tblRKCompanyPreference
			SELECT @strUnitMeasure = strUnitMeasure FROM tblICUnitMeasure WHERE intUnitMeasureId = @intUnitMeasureId
		
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
					, intReceiptNo
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
					, dtmDeliveryDate
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
					, strTransactionType)
				SELECT intSeqId
					, strSeqHeader
					, strCommodityCode
					, strType
					, dblTotal = CONVERT(DECIMAL(24,10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN ISNULL(@intUnitMeasureId,0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
					, strUnitMeasure = isnull(@strUnitMeasure, um.strUnitMeasure)
					, intCollateralId
					, strLocationName
					, strCustomerName
					, intReceiptNo
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
					, dtmDeliveryDate
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
				FROM @Final t
				LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND ISNULL(dblTotal, 0) <> 0
				ORDER BY intSeqId, dtmDeliveryDate
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
					, intReceiptNo
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
					, dtmDeliveryDate
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
					, strTransactionType)
				SELECT intSeqId
					, strSeqHeader
					, strCommodityCode
					, strType
					, dblTotal = CONVERT(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN ISNULL(@intUnitMeasureId,0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
					, strUnitMeasure = ISNULL(@strUnitMeasure, um.strUnitMeasure)
					, intCollateralId
					, strLocationName
					, strCustomerName
					, intReceiptNo
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
					, dtmDeliveryDate
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
				FROM @Final t
				LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND intSeqId <> 5 AND dblTotal <> 0
			
				UNION ALL
				SELECT intSeqId
					, strSeqHeader
					, strCommodityCode
					, strType
					, dblTotal = CONVERT(DECIMAL(24, 10), dbo.fnCTConvertQuantityToTargetCommodityUOM(cuc.intCommodityUnitMeasureId, CASE WHEN ISNULL(@intUnitMeasureId, 0) = 0 THEN cuc.intCommodityUnitMeasureId ELSE cuc1.intCommodityUnitMeasureId END, dblTotal))
					, strUnitMeasure = ISNULL(@strUnitMeasure, um.strUnitMeasure)
					, intCollateralId
					, strLocationName
					, strCustomerName
					, intReceiptNo
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
					, dtmDeliveryDate
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
				FROM @Final t
				LEFT JOIN tblICCommodityUnitMeasure cuc ON t.intCommodityId = cuc.intCommodityId AND cuc.ysnDefault = 1
				LEFT JOIN tblICUnitMeasure um ON um.intUnitMeasureId = cuc.intUnitMeasureId
				LEFT JOIN tblICCommodityUnitMeasure cuc1 ON t.intCommodityId = cuc1.intCommodityId AND @intUnitMeasureId = cuc1.intUnitMeasureId
				WHERE t.intCommodityId = @intCommodityId AND intSeqId = 5
				ORDER BY intSeqId, dtmDeliveryDate
			END
		END
		
		SELECT @mRowNumber = MIN(intCommodityIdentity) FROM @Commodity WHERE intCommodityIdentity > @mRowNumber
	END
END

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
			, intReceiptNo
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
			, dtmDeliveryDate
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
			, intReceiptNo
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
			, dtmDeliveryDate
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
		FROM @FinalTable WHERE strType <> 'Company Titled Stock'-- and strType not like '%'+@strPurchaseSales+'%'
		ORDER BY strCommodityCode, intSeqId ASC, intContractHeaderId DESC
	END
END