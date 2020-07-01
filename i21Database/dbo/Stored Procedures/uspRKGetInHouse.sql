CREATE PROCEDURE [dbo].[uspRKGetInHouse]
	 @dtmFromTransactionDate DATE = null
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = null
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL

AS
BEGIN

			SELECT intCompanyLocationId
			INTO #LicensedLocation
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
			WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 
			ELSE isnull(ysnLicensed, 0) END


			DECLARE @intCommodityUnitMeasureId AS INT
					, @intCommodityStockUOMId INT
			SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
					,@intCommodityStockUOMId = intUnitMeasureId
			FROM tblICCommodityUnitMeasure
			WHERE intCommodityId = @intCommodityId AND ysnStockUnit = 1

			--=============================
			-- Inventory Valuation
			--=============================
			SELECT dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
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
			INTO #invQty
			FROM vyuRKGetInventoryValuation s
			JOIN tblICItem i ON i.intItemId = s.intItemId
			JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
			JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = @intCommodityStockUOMId
			LEFT JOIN tblSCTicket t ON s.intSourceId = t.intTicketId
			LEFT JOIN tblCTContractDetail cd ON cd.intContractDetailId = s.intTransactionDetailId 
			LEFT JOIN tblCTContractHeader ch on cd.intContractHeaderId = ch.intContractHeaderId
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
				WHERE i1.intCommodityId  = @intCommodityId 
					AND i1.intItemId = ISNULL(@intItemId, i1.intItemId)
					and isnull(st.intDeliverySheetId,0) =0
					AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
					--AND ISNULL(st.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(st.intEntityId, 0))
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), st.dtmTicketDateTime, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
					AND ISNULL(strTicketStatus,'') = 'H'
			) t WHERE intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			AND t.intSeqId = 1


			DECLARE @tblResult TABLE (Id INT identity(1,1)
				, dtmDate datetime
				, dblTotal NUMERIC(18,6)
				, strTransactionType NVARCHAR(100)
				, strTransactionId NVARCHAR(50)
				, intTransactionId INT
				, strDistribution NVARCHAR(50)
				)

			INSERT INTO @tblResult (
				dtmDate
				,dblTotal
				,strTransactionType
				,strTransactionId
				,intTransactionId
				,strDistribution
			)
			SELECT 
				CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
				,dblTotal
				,strTransactionType
				,strTransactionId 
				,intTransactionId
				,strDistributionOption 
			FROM #invQty Inv
			WHERE Inv.strTransactionType NOT IN ( 'Storage Settlement', 'Transfer Storage')
			
			UNION ALL
			SELECT 
				CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
				,dblTotal
				,strTransactionType
				,strTransactionId 
				,intTransactionId
				,ST.strStorageTypeCode 
			FROM #invQty Inv
			inner join vyuGRSettleStorageTicketNotMapped SS ON Inv.intTransactionId = SS.intSettleStorageId
			left join tblGRStorageType ST ON SS.intStorageTypeId = ST.intStorageScheduleTypeId
			WHERE Inv.strTransactionType = 'Storage Settlement'

			UNION ALL
			SELECT 
				CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110)
				,dblTotal
				,strTransactionType
				,strTransactionId 
				,intTransactionId
				,strStorageTypeCode = CASE WHEN dblTotal < 0 THEN STFr.strStorageTypeCode ELSE STTo.strStorageTypeCode END
			FROM #invQty Inv
			inner join vyuGRTransferStorageSearchView SS ON Inv.intTransactionId = SS.intTransferStorageId
			left join tblGRStorageType STFr ON SS.intFromStorageTypeId = STFr.intStorageScheduleTypeId
			left join tblGRStorageType STTo ON SS.intToStorageTypeId = STTo.intStorageScheduleTypeId
			WHERE Inv.strTransactionType = 'Transfer Storage'
			

			INSERT INTO @tblResult (
				dtmDate
				,dblTotal
				,strTransactionType
				,strTransactionId
				,intTransactionId
				,strDistribution
			)
			SELECT 
				CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110)
				,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId,dblBalance)
				,strTicketType
				,strTransactionId = CASE WHEN strTicketType IN( 'Scale Storage','Customer/Maintain Storage','Storage Adjustment') THEN 
						CASE WHEN strReceiptNumber <> '' THEN strReceiptNumber ELSE strShipmentNumber END
					WHEN strTicketType IN( 'Settle Storage', 'Transfer Storage') THEN
						strTicketNumber
					END
				,intTransactionId = CASE WHEN strTicketType IN( 'Scale Storage','Customer/Maintain Storage','Storage Adjustment') THEN 
						ISNULL(intInventoryReceiptId,intInventoryShipmentId)
					WHEN strTicketType IN( 'Settle Storage', 'Transfer Storage')THEN
						BD.intTicketId
					END
				,ST.strStorageTypeCode 
			FROM #tblGetStorageDetailByDate BD
			left join tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
			left join tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
			WHERE BD.intCommodityId = @intCommodityId
					AND BD.intCompanyLocationId = ISNULL(@intLocationId, BD.intCompanyLocationId)
					AND BD.ysnDPOwnedType <> 1 AND BD.strOwnedPhysicalStock <> 'Company' --Remove DP type storage in in-house. Stock already increases in IR.
					AND BD.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			INSERT INTO @tblResult (
				dtmDate
				,dblTotal
				,strTransactionType
				,strTransactionId
				,intTransactionId
				,strDistribution
			)
			SELECT 
				CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110), 110)
				,dblTotal
				,'On Hold' 
				,strTicketNumber
				,intTicketId
				,'HLD'
			FROM #tempOnHold

			
			DECLARE @tblResultInventory TABLE (Id INT identity(1,1)
				, dtmDate datetime
				, dblInvIn NUMERIC(18,6)
				, dblInvOut NUMERIC(18,6)
				, dblAdjustments NUMERIC(18,6)
				, dblInventoryCount NUMERIC(18,6)
				, dblSalesInTransit NUMERIC(18,6)
				, dblBalanceInv NUMERIC(18,6)
				, strTransactionId NVARCHAR(50)
				, intTransactionId INT
				, strDistribution NVARCHAR(50)
				, strTransactionType NVARCHAR(100)
				)

			

			;WITH N1 (N) AS (SELECT 1 FROM (VALUES (1), (1), (1), (1), (1), (1), (1), (1), (1), (1)) n (N)),
			N2 (N) AS (SELECT 1 FROM N1 AS N1 CROSS JOIN N1 AS N2),
			N3 (N) AS (SELECT 1 FROM N2 AS N1 CROSS JOIN N2 AS N2),
			Dates AS
			(	SELECT TOP (DATEDIFF(DAY,  DATEADD(day,-1,@dtmFromTransactionDate), @dtmToTransactionDate))
						Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY N), DATEADD(day,-1,@dtmFromTransactionDate))
				FROM N3
			)

			SELECT	Date
			INTO #tempDateRange
			FROM	Dates AS d


			declare @tblBalanceInvByDate as table (
				dtmDate  DATE  NULL
				,dblBalanceInv  NUMERIC(18,6)
				,dblSalesInTransit NUMERIC(18,6)
			)
			
			Declare @date date
			DECLARE @dblSalesInTransitAsOf  NUMERIC(18,6)
			DECLARE @dblSalesInTransit  NUMERIC(18,6)
			DECLARE @dblSalesInTransitBeginBal  NUMERIC(18,6)

			select @dblSalesInTransitBeginBal =  sum(isnull(dblQuantityInStockUOM,0))  
			from vyuICGetInventoryValuation 
			where ysnInTransit = 1 
			and intItemId = ISNULL(@intItemId, intItemId)
			and intLocationId = ISNULL(@intLocationId, intLocationId)
			and intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			and intCommodityId = @intCommodityId 
			and dtmDate <= DATEADD(day, -1, convert(date, @dtmFromTransactionDate))
			
			
			While (Select Count(*) From #tempDateRange) > 0
			Begin

				Select Top 1 @date = Date From #tempDateRange

				insert into @tblBalanceInvByDate(
					dtmDate
					,dblBalanceInv
				)
				select @date,sum(dblTotal) from @tblResult WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)


				select @dblSalesInTransit =  sum(isnull(dblQuantityInStockUOM,0))   
				from vyuICGetInventoryValuation 
				where ysnInTransit = 1 
				and intItemId = ISNULL(@intItemId, intItemId)
				and intLocationId = ISNULL(@intLocationId, intLocationId)
				and intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				and intCommodityId = @intCommodityId 
				and dtmDate = @date

				set @dblSalesInTransit  = isnull(@dblSalesInTransit,0) + isnull(@dblSalesInTransitBeginBal,0)
				set @dblSalesInTransitBeginBal = isnull(@dblSalesInTransit,0)
				set @dblSalesInTransitAsOf = @dblSalesInTransitBeginBal
					
				--SELECT 
				--@dblSalesInTransitAsOf = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(cum.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull((InTran.dblInTransitQty),0)),0))
				--FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @date) InTran
				--	INNER JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = InTran.intItemUOMId
				--	INNER JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
				--	INNER JOIN tblICItemLocation IL ON IL.intItemLocationId = InTran.intItemLocationId
				--	INNER JOIN tblICCommodityUnitMeasure cum ON cum.intCommodityId = @intCommodityId AND cum.intUnitMeasureId = UOM.intUnitMeasureId
				--WHERE InTran.intItemId = ISNULL(@intItemId, InTran.intItemId)	
				--	AND IL.intLocationId = ISNULL(@intLocationId, IL.intLocationId ) 
				--	AND IL.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

				
				IF @dblSalesInTransitAsOf <> 0 
				BEGIN
					update @tblBalanceInvByDate
					set dblSalesInTransit = @dblSalesInTransitAsOf
					where dtmDate = @date
				END

				Delete #tempDateRange Where Date = @date

			End



			INSERT INTO @tblResultInventory(
				 dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution
				, strTransactionType)
			SELECT 
				  dtmDate
				, dblTotal
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Inventory Receipt')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t 
			WHERE dblTotal <> 0

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Storage Settlement')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t 
			
			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Credit Memo')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t 
		
		
			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Inventory Transfer')
				AND dblTotal > 0
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 	
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Inventory Transfer')
				AND dblTotal < 0
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					 dtmDate  
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType = 'On Hold'
				AND dblTotal  > 0
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution ='PRDC' 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Produce')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t 


			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					 dtmDate 
					, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType = 'On Hold' 
				AND dblTotal < 0
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t


			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, ABS(dblTotal)
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Inventory Shipment')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t
			WHERE dblTotal <> 0

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, ABS(dblTotal)
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution  = 'CNSM'
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Consume')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t
			WHERE dblTotal <> 0

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, ABS(dblTotal)
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution  = ''
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Outbound Shipment')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t
			WHERE dblTotal <> 0

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN ('Invoice', 'Cash')
				AND dblTotal < 0
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t


			INSERT INTO @tblResultInventory(
				dtmDate
				, dblAdjustments
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution  = CASE WHEN ISNULL(strDistribution,'') <> '' THEN strDistribution ELSE 'ADJ' END
					, strTransactionType = 'Inventory Adjustment'
				FROM @tblResult
				WHERE strTransactionType LIKE 'Inventory Adjustment -%'
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
			) t

			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInventoryCount
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT
					dtmDate 
					, dblTotal = SUM(ISNULL(dblTotal, 0))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult
				WHERE strTransactionType IN('Inventory Count')
				GROUP By
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
			) t


			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvIn
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT 
					dtmDate 
					,dblTotal =  sum(dblTotal)
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType = 'Customer/Maintain Storage'
				FROM @tblResult s
				WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
					AND dblTotal > 0
				GROUP BY
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
			) t

			
			INSERT INTO @tblResultInventory(
				dtmDate
				, dblInvOut
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution
				, strTransactionType
			FROM (
				SELECT 
					dtmDate 
					,dblTotal =  sum(ABS(dblTotal))
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType = 'Customer/Maintain Storage'
				FROM @tblResult s
				WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
					AND dblTotal < 0
				GROUP BY
					dtmDate
					, strTransactionId
					, intTransactionId
					, strDistribution 
			) t


			INSERT INTO @tblResultInventory(
				dtmDate
				, dblAdjustments
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			)
			SELECT 
				dtmDate
				, dblTotal 
				, strTransactionId
				, intTransactionId
				, strDistribution 
				, strTransactionType
			FROM (
				SELECT 
					dtmDate 
					,dblTotal =  dblTotal
					, strTransactionId
					, intTransactionId
					, strDistribution 
					, strTransactionType
				FROM @tblResult s
				WHERE strTransactionType IN ( 'Storage Adjustment')
			) t


			--==============================
			-- FINAL SELECT
			--===============================
			SELECT * FROM (
			SELECT 
				r.dtmDate
				, ri.dblInvIn
				, ri.dblInvOut
				, ri.dblAdjustments
				, ri.dblInventoryCount
				, ri.strTransactionId
				, ri.intTransactionId
				, ri.strDistribution
				, r.dblBalanceInv 
				, r.dblSalesInTransit
				, ri.strTransactionType
				, intCommodityId = @intCommodityId
			FROM @tblResultInventory ri
			FULL join @tblBalanceInvByDate r on ri.dtmDate = r.dtmDate
			

			UNION ALL--Insert Company Title Beginning Balance
			SELECT
				NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
				sum(dblTotal)
				,NULL 
				,NULL
				,NULL
			FROM @tblResult WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(day,-1,@dtmFromTransactionDate))
			) t
			WHERE dblBalanceInv IS NOT NULL 


	drop table #LicensedLocation
	drop table #invQty
	drop table #tblGetStorageDetailByDate
	drop table #tempOnHold
	drop table #tempDateRange
END