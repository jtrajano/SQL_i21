CREATE PROCEDURE [dbo].[uspRKGetInHouse] @dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL 

AS

BEGIN
	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
	
	DECLARE @intCommodityUnitMeasureId AS INT
		, @intCommodityStockUOMId INT
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		, @intCommodityStockUOMId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

	--=============================
	-- Inventory Valuation
	--=============================
	SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity, 0)))
		, s.dtmDate
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
		, strOwnership = 'Company Owned'
	INTO #invQty
	FROM vyuRKGetInventoryValuation s
	JOIN tblICItem i ON i.intItemId = s.intItemId
	JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
	JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intCommodityStockUOMId
	LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
	LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = s.intTransactionDetailId 
	LEFT JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId
	LEFT JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId = fmnt.intFutureMonthId
	WHERE i.intCommodityId = @intCommodityId  
		AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		AND ISNULL(s.dblQuantity, 0) <> 0
		AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
		AND ISNULL(strTicketStatus, '') <> 'V'
		--AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= cONVERT(DATETIME, @dtmToTransactionDate)
		AND ysnInTransit = 0
		AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

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
								WHEN gh.intTransactionTypeId = 9 THEN gh.intInventoryAdjustmentId
								ELSE gh.intCustomerStorageId END)
			, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
								WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
								WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
								WHEN gh.intTransactionTypeId = 9 THEN 'Storage Adjustment'
								ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
			, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
								WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
								WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
								WHEN gh.intTransactionTypeId = 9 THEN gh.strTransactionId
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
			, gh.dtmHistoryDate
			, strOwnership = CASE WHEN b.ysnDPOwnedType = 1 THEN 'Company Owned' ELSE 'Customer Owned' END
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
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
			AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
			--AND (gh.strType IN ('Settlement', 'Reverse Settlement') and  gh.ysnPost = 1 AND b.ysnDPOwnedType <> 1)
				
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
			, dblBalance =  (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement'   THEN - gh.dblUnits ELSE gh.dblUnits END)
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
								WHEN gh.intTransactionTypeId = 9 THEN gh.intInventoryAdjustmentId
								ELSE gh.intCustomerStorageId END)
			, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
								WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
								WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
								WHEN gh.intTransactionTypeId = 9 THEN  'Storage Adjustment'
								ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
			, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN NULL
								WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
								WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
								WHEN gh.intTransactionTypeId = 9 THEN gh.strTransactionId
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
			, gh.dtmHistoryDate
			, strOwnership = CASE WHEN b.ysnDPOwnedType = 1 THEN 'Company Owned' ELSE 'Customer Owned' END
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
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
			AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
			--AND (gh.strType IN ('Settlement', 'Reverse Settlement') and  gh.ysnPost = 1  AND b.ysnDPOwnedType <> 1)
	)t

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
			, strOwnership = CASE WHEN t.ysnDPOwnedType = 1 THEN 'Company Owned' ELSE 'Customer Owned' END
		FROM tblSCTicket st
		JOIN tblEMEntity e ON e.intEntityId= st.intEntityId
		JOIN tblSMCompanyLocation  cl ON cl.intCompanyLocationId=st.intProcessingLocationId and st.strDistributionOption='HLD'
		JOIN tblICItem i1 ON i1.intItemId=st.intItemId
		JOIN tblICCategory Category ON Category.intCategoryId = i1.intCategoryId
		JOIN tblICItemUOM iuom ON i1.intItemId=iuom.intItemId and ysnStockUnit=1
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId=i1.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId
		LEFT JOIN tblGRStorageType t on t.intStorageScheduleTypeId = st.intStorageScheduleTypeId 
		WHERE i1.intCommodityId  = @intCommodityId 
			AND i1.intItemId = ISNULL(@intItemId, i1.intItemId)
			and isnull(st.intDeliverySheetId,0) =0
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
			--AND ISNULL(st.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(st.intEntityId, 0))
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
			AND ISNULL(strTicketStatus,'') = 'H'
	) t WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	AND t.intSeqId = 1
	
	DECLARE @tblResult TABLE (Id INT IDENTITY
		, dtmDate DATETIME
		, dblTotal NUMERIC(18,6)
		, strTransactionType NVARCHAR(50)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(10)
		, strOwnership NVARCHAR(20))

	INSERT INTO @tblResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
		, dblTotal
		, strTransactionType
		, strTransactionId 
		, intTransactionId
		, strDistributionOption 
		, strOwnership
	FROM #invQty Inv
	WHERE Inv.strTransactionType NOT IN ( 'Storage Settlement', 'Transfer Storage')
			
	UNION ALL SELECT CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
		, dblTotal
		, strTransactionType
		, strTransactionId 
		, intTransactionId
		, CASE WHEN SC.intContractDetailId IS NULL THEN '' ELSE 'CNT' END
		, strOwnership
	FROM #invQty Inv
	LEFT JOIN tblGRSettleContract SC ON SC.intSettleStorageId = Inv.intTransactionId
	WHERE Inv.strTransactionType = 'Storage Settlement'

	UNION ALL
	SELECT 
		CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
		,dblTotal
		,strTransactionType
		,strTransactionId 
		,intTransactionId
		,strStorageTypeCode = CASE WHEN dblTotal < 0 THEN SS.strFromStorageTypeDescription ELSE SS.strToStorageTypeDescription END
		,strOwnership
	FROM #invQty Inv
	inner join vyuGRTransferStorageSearchView SS ON Inv.intTransactionId = SS.intTransferStorageId
	WHERE Inv.strTransactionType = 'Transfer Storage'
	
	INSERT INTO @tblResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)
		, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId,dblBalance)
		, strTicketType  = CASE WHEN strTicketType IN('Scale Storage','Customer/Maintain Storage') THEN 
										CASE WHEN strReceiptNumber <> '' THEN 'Inventory Receipt' ELSE 'Inventory Shimpment' END
								ELSE
									strTicketType
								END
		, strTransactionId = CASE WHEN strTicketType IN( 'Scale Storage','Customer/Maintain Storage','Storage Adjustment')
									THEN CASE WHEN strReceiptNumber <> '' THEN strReceiptNumber ELSE strShipmentNumber END
								WHEN strTicketType IN( 'Settle Storage', 'Transfer Storage') THEN strTicketNumber END
		, intTransactionId = CASE WHEN strTicketType IN( 'Scale Storage','Customer/Maintain Storage','Storage Adjustment') THEN ISNULL(intInventoryReceiptId,intInventoryShipmentId)
								WHEN strTicketType IN( 'Settle Storage', 'Transfer Storage') THEN BD.intTicketId END
		, ST.strStorageTypeCode 
		, strOwnership
	FROM #tblGetStorageDetailByDate BD
	LEFT JOIN tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
	LEFT JOIN tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
	WHERE BD.intCommodityId = @intCommodityId
		AND BD.intCompanyLocationId = ISNULL(@intLocationId, BD.intCompanyLocationId)
		AND BD.ysnDPOwnedType <> 1 AND BD.strOwnedPhysicalStock <> 'Company' --Remove DP type storage in in-house. Stock already increases in IR.
		AND BD.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	
	INSERT INTO @tblResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110), 110)
		, dblTotal
		, 'On Hold' 
		, strTicketNumber
		, intTicketId
		, 'HLD'
		, 'HOLD'
	FROM #tempOnHold
			
	DECLARE @tblResultInventory TABLE (Id INT IDENTITY
		, dtmDate DATETIME
		, dblInvIn NUMERIC(18,6)
		, dblInvOut NUMERIC(18,6)
		, dblAdjustments NUMERIC(18,6)
		, dblInventoryCount NUMERIC(18,6)
		, dblSalesInTransit NUMERIC(18,6)
		, dblBalanceInv NUMERIC(18,6)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(10)
		, strTransactionType NVARCHAR(50)
		, strOwnership NVARCHAR(20))
			
	;WITH N1 (N) AS (SELECT 1 FROM (VALUES (1), (1), (1), (1), (1), (1), (1), (1), (1), (1)) n (N)),
	N2 (N) AS (SELECT 1 FROM N1 AS N1 CROSS JOIN N1 AS N2),
	N3 (N) AS (SELECT 1 FROM N2 AS N1 CROSS JOIN N2 AS N2),
	Dates AS
	(	SELECT TOP (DATEDIFF(DAY,  DATEADD(day,-1,@dtmFromTransactionDate), @dtmToTransactionDate))
				Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY N), DATEADD(day,-1,@dtmFromTransactionDate))
		FROM N3
	)
	SELECT Date
	INTO #tempDateRange
	FROM Dates AS d

	SELECT InTran.dtmDate
		, dblInTransitQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId, @intCommodityUnitMeasureId, ISNULL((InTran.dblInTransitQty), 0))
	INTO #InTransitDateRange
	FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmToTransactionDate) InTran
	INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InTran.intItemUOMId
	INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE InTran.intItemId = ISNULL(@intItemId, InTran.intItemId)
		AND InTran.intItemLocationId = ISNULL(@intLocationId, InTran.intItemLocationId) 
		AND InTran.intItemLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
	DECLARE @tblBalanceInvByDate AS TABLE (dtmDate DATE NULL
		, dblBalanceInv NUMERIC(18,6)
		, dblBalanceCompanyOwned NUMERIC(18,6)
		, dblBalanceCustomerOwned NUMERIC(18,6)
		, dblSalesInTransit NUMERIC(18,6))

	DECLARE @date DATE
		, @dblSalesInTransitAsOf NUMERIC(18,6)
		, @dblBalanceCompanyOwned NUMERIC(18,6)
		, @dblBalanceCustomerOwned NUMERIC(18,6)
			
	WHILE EXISTS(SELECT TOP 1 1 FROM #tempDateRange)
	BEGIN
		SELECT TOP 1 @date = Date FROM #tempDateRange
				
		INSERT INTO @tblBalanceInvByDate(dtmDate
			, dblBalanceInv)
		SELECT @date
			, SUM(dblTotal)
		FROM @tblResult WHERE CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		
		SELECT @dblBalanceCompanyOwned = SUM(dblTotal)
		FROM @tblResult 
		WHERE CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		AND strOwnership = 'Company Owned'
		
		SELECT @dblBalanceCustomerOwned = SUM(dblTotal)
		FROM @tblResult 
		WHERE CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		AND strOwnership = 'Customer Owned'

		
				
		SELECT @dblSalesInTransitAsOf = SUM(ISNULL(InTran.dblInTransitQty, 0))
		FROM #InTransitDateRange InTran
		WHERE InTran.dtmDate <= @date

		UPDATE @tblBalanceInvByDate
		SET dblSalesInTransit = @dblSalesInTransitAsOf
			,dblBalanceCompanyOwned = @dblBalanceCompanyOwned
			,dblBalanceCustomerOwned = @dblBalanceCustomerOwned
		WHERE dtmDate = @date
		
		DELETE #tempDateRange WHERE Date = @date
	END
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Inventory Receipt')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Storage Settlement')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 
			
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Credit Memo')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Inventory Transfer')
		AND dblTotal > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 	
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Inventory Transfer')
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate  
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType = 'On Hold'
		AND dblTotal  > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution ='PRDC' 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Produce')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 


	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType = 'On Hold' 
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Inventory Shipment')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = 'CNSM'
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Consume')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory( dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = ''
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Outbound Shipment')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN ('Invoice', 'Cash')
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblAdjustments
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = CASE WHEN ISNULL(strDistribution,'') <> '' THEN strDistribution ELSE 'ADJ' END
			, strTransactionType = 'Inventory Adjustment'
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType LIKE 'Inventory Adjustment -%'
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInventoryCount
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult
		WHERE strTransactionType IN('Inventory Count')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT distinct dtmDate 
			, dblTotal =  sum(dblTotal)
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult s
		WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
			AND dblTotal > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strTransactionType
		, strOwnership
	FROM (
		SELECT distinct dtmDate 
			, dblTotal =  sum(ABS(dblTotal))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult s
		WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
			AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblAdjustments
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal =  dblTotal
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM @tblResult s
		WHERE strTransactionType IN ( 'Storage Adjustment')
	) t

	--==============================
	-- FINAL SELECT
	--===============================
	SELECT * FROM (
		SELECT r.dtmDate
			, ri.dblInvIn
			, ri.dblInvOut
			, ri.dblAdjustments
			, ri.dblInventoryCount
			, ri.strTransactionId
			, ri.intTransactionId
			, ri.strDistribution
			, r.dblBalanceInv
			, r.dblBalanceCompanyOwned
			, r.dblBalanceCustomerOwned 
			, r.dblSalesInTransit
			, ri.strTransactionType
			, intCommodityId = @intCommodityId
			, strOwnership
		FROM @tblResultInventory ri
		FULL JOIN @tblBalanceInvByDate r ON ri.dtmDate = r.dtmDate
		
		--Insert Company Title Beginning Balance
		UNION SELECT NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, (SELECT sum(dblTotal) 
				FROM @tblResult 
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				) --dblBalanceInv
			, (SELECT sum(dblTotal) 
				FROM @tblResult 
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				AND strOwnership = 'Company Owned'
				)
			, (SELECT sum(dblTotal) 
				FROM @tblResult 
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				AND strOwnership = 'Customer Owned'
				)
			, NULL
			, NULL
			, NULL
			, NULL
		
	) t
	WHERE dblBalanceInv IS NOT NULL 

	DROP TABLE #LicensedLocation
	DROP TABLE #invQty
	DROP TABLE #tblGetStorageDetailByDate
	DROP TABLE #tempOnHold
	DROP TABLE #tempDateRange
	DROP TABLE #InTransitDateRange
END