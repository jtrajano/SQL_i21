CREATE PROCEDURE [dbo].[uspRKGetCompanyTitled]
	  @dtmFromTransactionDate DATE = NULL
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
			WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1
												WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0
												ELSE isnull(ysnLicensed, 0) END

			DECLARE @intCommodityUnitMeasureId AS INT
			SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
			FROM tblICCommodityUnitMeasure
			WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

			DECLARE @ysnIncludeDPPurchasesInCompanyTitled BIT
			SELECT TOP 1 @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled from tblRKCompanyPreference

		
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
					, gh.dtmHistoryDate
					, gh.intSettleStorageId
					, gh.strVoucher
					, gh.intStorageHistoryId
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
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
					AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
					AND i.intItemId = ISNULL(@intItemId, i.intItemId)
					--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
				
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
					, gh.dtmHistoryDate
					, gh.intSettleStorageId
					, gh.strVoucher
					, gh.intStorageHistoryId
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
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
					AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
					AND i.intItemId = ISNULL(@intItemId, i.intItemId)
					--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
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
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId) AND ISNULL(strTicketStatus,'') <> 'V'
				--AND ISNULL(s.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(s.intEntityId, 0))
				AND convert(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110)<=convert(datetime,@dtmToTransactionDate)
				AND ysnInTransit = 1
				AND strTransactionForm IN('Inventory Transfer')
				AND IRI.intInventoryReceiptItemId IS NULL
				AND s.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)

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
				, dtmDate
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
					,intCompanyLocationId = InTran.intItemLocationId
					,strLocationName = SI.strShipFromLocation
					,strUOM = InTran.strUnitMeasure
					,Inv.intEntityId
					,strCustomerReference = SI.strCustomerName
					,Com.intCommodityId
					,Itm.intItemId
					,Itm.strItemNo
					,strCategory = Cat.strCategoryCode
					,Cat.intCategoryId
					,dblBalanceToInvoice = InTran.dblInTransitQty
					,strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), InTran.dtmDate, 106), 8) COLLATE Latin1_General_CI_AS
					,strFutureMonth = (SELECT TOP 1 strFutureMonth FROM tblCTContractDetail cd INNER JOIN tblRKFuturesMonth fmnt ON cd.intFutureMonthId =  fmnt.intFutureMonthId WHERE intContractHeaderId = SI.intLineNo)
					,strDeliveryDate =  (SELECT TOP 1 dbo.fnRKFormatDate(dtmEndDate, 'MMM yyyy') FROM tblCTContractDetail WHERE intContractHeaderId = SI.intLineNo)
					,Inv.dtmDate
				FROM dbo.fnICOutstandingInTransitAsOf(NULL, @intCommodityId, @dtmToTransactionDate) InTran
					INNER JOIN vyuICGetInventoryValuation Inv ON InTran.intInventoryTransactionId = Inv.intInventoryTransactionId
					INNER JOIN tblICItem Itm ON InTran.intItemId = Itm.intItemId
					INNER JOIN tblICCommodity Com ON Itm.intCommodityId = Com.intCommodityId
					INNER JOIN tblICCategory Cat ON Itm.intCategoryId = Cat.intCategoryId
					LEFT JOIN vyuICGetInventoryShipmentItem SI ON InTran.intTransactionDetailId = SI.intInventoryShipmentItemId
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110) <= CONVERT(DATETIME,@dtmToTransactionDate)
					--AND ISNULL(Inv.intEntityId,0) = CASE WHEN ISNULL(@intVendorId,0)=0 THEN ISNULL(Inv.intEntityId,0) ELSE @intVendorId END	
					AND InTran.intItemLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)			
			)t


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
			, strTransactionType NVARCHAR(50)
			, intTransactionId INT
			, intTransactionDetailId INT
			, intSourceId INT
			, dtmDate DATETIME)


			-- inventory
			INSERT INTO @InventoryStock(strCommodityCode
				, strItemNo
				, strCategory
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, dtmDate
				, strTransactionType
				, intTransactionId
				, intTransactionDetailId
				, intSourceId)
			SELECT strCommodityCode
				, strItemNo
				, strCategoryCode
				, dblTotal = dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, dtmDate
				, strTransactionType
				, intTransactionId
				, intTransactionDetailId
				, intSourceId
			FROM (
				SELECT strCommodityCode
					, i.strItemNo
					, Category.strCategoryCode
					, dblTotal = dbo.fnCalculateQtyBetweenUOM(iuomStck.intItemUOMId, iuomTo.intItemUOMId, (ISNULL(s.dblQuantity ,0)))
					, strLocationName
					, intCommodityId = @intCommodityId
					, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					, strInventoryType = 'Company Titled' COLLATE Latin1_General_CI_AS
					, s.dtmDate
					, s.strTransactionType
					, s.intTransactionId
					, s.intTransactionDetailId
					, s.intSourceId
				FROM vyuRKGetInventoryValuation s
				JOIN tblICItem i ON i.intItemId = s.intItemId
				JOIN tblICCommodityUnitMeasure cuom ON i.intCommodityId = cuom.intCommodityId AND cuom.ysnStockUnit = 1
				JOIN tblICItemUOM iuomStck ON s.intItemId = iuomStck.intItemId AND iuomStck.ysnStockUnit = 1
				JOIN tblICItemUOM iuomTo ON s.intItemId = iuomTo.intItemId AND iuomTo.intUnitMeasureId = cuom.intUnitMeasureId
				JOIN tblICCommodity c ON i.intCommodityId = c.intCommodityId
				JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
				WHERE i.intCommodityId = @intCommodityId AND ISNULL(s.dblQuantity,0) <> 0 AND ysnInTransit = 0
					AND i.intItemId = ISNULL(@intItemId, i.intItemId)
					AND s.intLocationId = ISNULL(@intLocationId, s.intLocationId)
					AND CONVERT(DATETIME, CONVERT(VARCHAR(10), s.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
					AND s.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
					AND strTransactionId NOT IN (SELECT strTransactionId FROM @transfer)
			) t

			--=========================================
			-- Includes DP based on Company Preference
			--========================================
			If ( @ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
			BEGIN
				INSERT INTO @InventoryStock(strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, dtmDate)
				SELECT strCommodityCode
					, strItemNo
					, strCategory
					, dblTotal = -sum(dblTotal)
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, 'Company Titled' COLLATE Latin1_General_CI_AS
					, dtmHistoryDate
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
						, dtmHistoryDate
					FROM #tblGetStorageDetailByDate ch
					WHERE ch.intCommodityId  = @intCommodityId
						AND ch.intItemId = ISNULL(@intItemId, ch.intItemId)
						AND ysnDPOwnedType = 1
						AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
					)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY strCommodityCode
					, strItemNo
					, strCategory
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, dtmHistoryDate
			END

			IF ((SELECT TOP 1 ysnIncludeInTransitInCompanyTitled FROM tblRKCompanyPreference) = 1)
			BEGIN

				SELECT intContractHeaderId
					, strContractNumber
					, intCommodityId
					, strCommodityCode
					, strType
					, strLocationName
					, strContractEndMonth
					, strContractEndMonthNearBy
					, dblTotal
					, intSeqId
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
				INTO #tblSalesBasisDeliveries
				FROM  (
					SELECT DISTINCT cd.intContractHeaderId
						, strContractNumber = ch.strContractNumber + '-' +LTRIM(cd.intContractSeq) COLLATE Latin1_General_CI_AS
						, ch.intCommodityId
						, com.strCommodityCode
						, strType = 'Sales Basis Deliveries' COLLATE Latin1_General_CI_AS
						, cd.intCompanyLocationId
						, v.strLocationName
						, strContractEndMonth = 'Near By' COLLATE Latin1_General_CI_AS
						, strContractEndMonthNearBy = 'Near By' COLLATE Latin1_General_CI_AS
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(ri.dblQuantity, 0))
						, intSeqId = 6
						, um.strUnitMeasure
						, intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
						, strEntityName = v.strEntity
						, intOrderId = 6
						, cd.intItemId
						, i.strItemNo
						, strCategory = cat.strCategoryCode
						, cd.intFutureMarketId
						, fm.strFutMarketName
						, cd.intFutureMonthId
						, mnt.strFutureMonth
						, strDeliveryDate = dbo.fnRKFormatDate(cd.dtmEndDate, 'MMM yyyy')
						--, strDeliveryDate = CASE WHEN @strPositionBy = 'Delivery Month' THEN RIGHT(CONVERT(VARCHAR(11), cd.dtmEndDate, 106), 8)
						--						ELSE RIGHT(CONVERT(VARCHAR(11), CONVERT(DATETIME, REPLACE(cd.strFutureMonth, ' ', ' 1, ')) , 106), 8) END
						, ri.intSourceId
					FROM vyuRKGetInventoryValuation v
					JOIN tblICInventoryShipment r ON r.strShipmentNumber = v.strTransactionId
					INNER JOIN tblICInventoryShipmentItem ri ON r.intInventoryShipmentId = ri.intInventoryShipmentId
					INNER JOIN tblCTContractDetail cd ON cd.intContractDetailId = ri.intLineNo AND cd.intPricingTypeId = 2 AND cd.intContractStatusId <> 3
					INNER JOIN tblCTContractHeader ch ON cd.intContractHeaderId = ch.intContractHeaderId  AND ch.intContractTypeId = 2
					INNER JOIN tblICCommodity com on ch.intCommodityId = com.intCommodityId
					INNER JOIN tblICItem i on cd.intItemId = i.intItemId
					INNER JOIN tblICCategory cat on i.intCategoryId = cat.intCategoryId
					INNER JOIN tblRKFutureMarket fm on cd.intFutureMarketId = fm.intFutureMarketId
					INNER JOIN tblRKFuturesMonth mnt on cd.intFutureMonthId = mnt.intFutureMonthId
					JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = ch.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId
					JOIN tblICUnitMeasure um ON um.intUnitMeasureId = ium.intUnitMeasureId
					INNER JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cd.intCompanyLocationId
					LEFT JOIN tblARInvoiceDetail invD ON ri.intInventoryShipmentItemId = invD.intInventoryShipmentItemId
					LEFT JOIN tblARInvoice inv ON invD.intInvoiceId = inv.intInvoiceId
					LEFT JOIN tblCTPriceFixationDetail pfd ON invD.intInvoiceDetailId = pfd.intInvoiceDetailId
					WHERE ch.intCommodityId = @intCommodityId AND v.strTransactionType = 'Inventory Shipment'
						AND cd.intCompanyLocationId = ISNULL(@intLocationId, cd.intCompanyLocationId)
						AND CONVERT(DATETIME, CONVERT(VARCHAR(10), v.dtmDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
						AND CONVERT(DATETIME, @dtmToTransactionDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(inv.dtmDate,DATEADD(DAY,1,@dtmToTransactionDate)), 110), 110)
						AND CONVERT(DATETIME, @dtmToTransactionDate) < CONVERT(DATETIME, CONVERT(VARCHAR(10), ISNULL(pfd.dtmFixationDate,DATEADD(DAY,1,@dtmToTransactionDate)), 110), 110)
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)


				INSERT INTO @InventoryStock(
					  strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, dtmDate)
				SELECT 
					  strCommodityCode
					, dblTotal = SUM(dblTotal)
					, strLocationName
					, @intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType = 'Purchase In-Transit' COLLATE Latin1_General_CI_AS
					, dtmDateCreated
				FROM (
					SELECT i.intUnitMeasureId
						, dblTotal = ISNULL(i.dblPurchaseContractShippedQty, 0)
						, i.strLocationName
						, i.intItemId
						, i.strItemNo
						, i.intCompanyLocationId, 
						c.strCommodityCode,
						c.intCommodityId,
						intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId,
						dtmDateCreated
					FROM vyuRKPurchaseIntransitView i
					join tblICCommodity c on i.intCommodityId=c.intCommodityId
					WHERE i.intCommodityId = @intCommodityId
						AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
						AND i.intPurchaseSale = 1 -- 1.Purchase 2. Sales
						--AND i.intEntityId = ISNULL(@intVendorId, i.intEntityId)					
				) t WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, dtmDateCreated

				INSERT INTO @InventoryStock(
					strCommodityCode
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, dtmDate)
				SELECT 
						strCommodityCode
					, dblTotal = SUM(dblTotal)
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType = 'Sales In-Transit' COLLATE Latin1_General_CI_AS
					, dtmDate
				FROM (
					SELECT intFromCommodityUnitMeasureId= @intCommodityUnitMeasureId
						, dblTotal = dblBalanceToInvoice
						, i.strLocationName
						, i.intCompanyLocationId
						, c.strCommodityCode
						, c.intCommodityId
						, dtmDate
					FROM #tblGetSalesIntransitWOPickLot i						
					join tblICCommodity c on i.intCommodityId=c.intCommodityId
					WHERE i.intCommodityId = @intCommodityId
				AND i.intCompanyLocationId = ISNULL(@intLocationId, i.intCompanyLocationId)
				AND i.intInventoryShipmentId NOT IN (SELECT intInventoryShipmentId FROM #tblSalesBasisDeliveries WHERE strType = 'Sales Basis Deliveries')			
				) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, dtmDate				

			END


			--========================
			-- Get Company Ownership
			--=========================
			DECLARE @CompanyTitle AS TABLE (
					dtmDate  DATE  NULL
					,dblUnpaidIncrease  NUMERIC(18,6)
					,dblUnpaidDecrease  NUMERIC(18,6)
					,dblUnpaidBalance  NUMERIC(18,6)
					,dblPaidBalance  NUMERIC(18,6)
					,strTransactionId NVARCHAR(50)
					,intTransactionId INT
					,strDistribution NVARCHAR(10)
					,dblCompanyTitled NUMERIC(18,6)
			)

			INSERT INTO @CompanyTitle(
				dtmDate
				,dblUnpaidIncrease
				,dblUnpaidDecrease
				,dblUnpaidBalance
				,dblPaidBalance
				,strTransactionId
				,intTransactionId
				,strDistribution
			)
			SELECT --INVENTORY RECEIPT WITH VOUCHER
				dtmDate
				,dblUnpaidIncrease = dblQtyReceived
				,dblUnpaidDecrease = dblPartialPaidQty
				,dblUnpaidBalance = dblQtyReceived - dblPartialPaidQty
				,dblPaidBalance = dblPartialPaidQty
				,strTransactionId = strBillId
				,intTransactionId = intBillId
				,strDistribution
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,BD.dblQtyReceived
					,dblPartialPaidQty = (BD.dblQtyReceived / B.dblTotal) * dblPayment 
					,B.strBillId
					,B.intBillId
					,strDistribution =  ISNULL(ST.strStorageTypeCode,'SPT')
				from @InventoryStock Inv
				inner join tblAPBillDetail BD on Inv.intTransactionDetailId = BD.intInventoryReceiptItemId 
						AND BD.intInventoryReceiptChargeId IS NULL
				inner join tblAPBill B on BD.intBillId = B.intBillId
				left join tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
				left join tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
				where 
					Inv.strTransactionType = 'Inventory Receipt'
					AND ISNULL(CS.intStorageTypeId,0) <>  2 --Not DP
			) t
			UNION ALL
			SELECT --DIRECT INVENTORY RECEIPT W/O VOUCHER
				dtmDate
				,dblUnpaidIncrease = dblTotal
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = dblTotal
				,dblPaidBalance = 0
				,strTransactionId = strReceiptNumber
				,intTransactionId
				,''
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,IRV.strReceiptNumber
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
				inner join vyuICGetInventoryReceiptVoucher IRV on Inv.intTransactionDetailId = IRV.intInventoryReceiptItemId
				where Inv.strTransactionType = 'Inventory Receipt'
					AND IRV.intBillId IS NULL
					AND IR.intSourceType = 0
			) t
			UNION ALL
			SELECT
				dtmDate
				,dblUnpaidIncrease = dblQtyReceived
				,dblUnpaidDecrease = dblPartialPaidQty
				,dblUnpaidBalance = dblQtyReceived - dblPartialPaidQty
				,dblPaidBalance = dblPartialPaidQty
				,strTransactionId = strBillId
				,intTransactionId = intBillId
				,strDistribution
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110)
					,BD.dblQtyReceived
					,dblPartialPaidQty = (BD.dblQtyReceived / B.dblTotal) * dblPayment 
					,B.strBillId
					,B.intBillId
					,strDistribution =  ST.strStorageTypeCode
				from @InventoryStock Inv
				inner join tblGRSettleStorage SS ON Inv.intTransactionId = SS.intSettleStorageId
				inner join tblAPBill B on SS.intBillId = B.intBillId
				inner join tblAPBillDetail BD on B.intBillId = BD.intBillId 
						AND BD.intItemId = SS.intItemId
				left join tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
				left join tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
				where 
					Inv.strTransactionType = 'Storage Settlement'
			) t

			UNION ALL --INVENTORY SHIPMENT WITH INVOICE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strInvoiceNumber
				,intTransactionId
				,strDistribution
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = ID.dblQtyShipped * -1
					,I.strInvoiceNumber
					,Inv.intTransactionId
					,strDistribution = TV.strDistributionOption
				from @InventoryStock Inv
				inner join tblICInventoryShipment S on Inv.intTransactionId = S.intInventoryShipmentId
				inner join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInventoryShipmentItemId 
						AND ID.intInventoryShipmentChargeId IS NULL
				inner join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId
				left join vyuSCTicketView TV on ID.intTicketId = TV.intTicketId
				where Inv.strTransactionType = 'Inventory Shipment'
					AND I.ysnPosted = 1
					AND S.intSourceType = 1
						
			) t
				
			UNION ALL --INVENTORY SHIPMENT W/O INVOICE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strShipmentNumber
				,intTransactionId
				,strDistribution
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,S.strShipmentNumber
					,Inv.intTransactionId
					,strDistribution = TV.strDistributionOption
				from @InventoryStock Inv
				inner join tblICInventoryShipment S on Inv.intTransactionId = S.intInventoryShipmentId
				inner join vyuICShipmentInvoice SI on Inv.intTransactionDetailId = SI.intInventoryShipmentItemId
				left join vyuSCTicketView TV on Inv.intSourceId = TV.intTicketId
				where Inv.strTransactionType = 'Inventory Shipment'
					AND S.ysnPosted = 1
					AND S.intSourceType = 1
					and SI.strInvoiceNumber IS NULL
			) t

			UNION ALL --DIRECT INVOICE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strInvoiceNumber
				,intTransactionId
				,''
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),I.dtmPostDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strInvoiceNumber
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInvoiceDetailId 
						AND ID.intInventoryShipmentChargeId IS NULL
				inner join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId
				where Inv.strTransactionType IN( 'Invoice','Cash')
					AND I.ysnPosted = 1
						
			) t

				
			UNION ALL --CREDIT MEMO
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strInvoiceNumber
				,intTransactionId
				,'CM'
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strInvoiceNumber
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInvoiceDetailId 
				inner join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId
				where Inv.strTransactionType = 'Credit Memo'
					AND I.ysnPosted = 1
						
			) t

			UNION ALL --INVENTORY COUNT
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strCountNo
				,intTransactionId
				,'IC'
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strCountNo
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblICInventoryCountDetail ID on Inv.intTransactionDetailId = ID.intInventoryCountDetailId 
				inner join tblICInventoryCount I on ID.intInventoryCountId = I.intInventoryCountId
				where Inv.strTransactionType = 'Inventory Count'
					AND I.ysnPosted = 1
						
			) t

			UNION ALL--INVENTORY ADJUSTMENT
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strAdjustmentNo
				,intTransactionId
				,'ADJ'
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strAdjustmentNo
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblICInventoryAdjustmentDetail ID on Inv.intTransactionDetailId = ID.intInventoryAdjustmentDetailId 
				inner join tblICInventoryAdjustment I on ID.intInventoryAdjustmentId = I.intInventoryAdjustmentId
				where Inv.strTransactionType LIKE 'Inventory Adjustment -%'
					AND I.ysnPosted = 1
					AND I.intSourceTransactionTypeId IS NULL
						
			) t

			UNION ALL--INVENTORY TRANSFER
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strTransferNo
				,intTransactionId
				,'IT'
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strTransferNo
					,Inv.intTransactionId
				from @InventoryStock Inv
				inner join tblICInventoryTransferDetail ID on Inv.intTransactionDetailId = ID.intInventoryTransferDetailId 
				inner join tblICInventoryTransfer I on ID.intInventoryTransferId = I.intInventoryTransferId
				where Inv.strTransactionType = 'Inventory Transfer'
					AND I.ysnPosted = 1
						
			) t

			

			

			If (@ysnIncludeDPPurchasesInCompanyTitled = 0)
			BEGIN
				INSERT INTO @CompanyTitle(
					dtmDate
					,dblUnpaidIncrease
					,dblUnpaidDecrease
					,dblUnpaidBalance
					,dblPaidBalance
					,strTransactionId
					,intTransactionId
					,strDistribution
				)
				SELECT
					dtmDate
					,dblUnpaidIncrease = ABS(dblBalance)
					,dblUnpaidDecrease = ABS(dblBalance)
					,dblUnpaidBalance = 0
					,dblPaidBalance = -dblBalance 
					,strTransactionId = strVoucher
					,intTransactionId
					,'DP'
				FROM (
					select 
						dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,dblBalance = SUM(dblBalance)
						,strVoucher
						,intTransactionId = intStorageHistoryId
						,intCompanyLocationId
					from #tblGetStorageDetailByDate
					where intStorageTypeId = 2 --DP
					and intSettleStorageId is not null
					group by
						CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,strVoucher
						,intStorageHistoryId
						,strTicketType
						,intCompanyLocationId
				) t
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

				UNION ALL--INVENTORY ADJUSTMENT FROM STORAGE
				SELECT
					dtmDate
					,dblUnpaidIncrease = 0
					,dblUnpaidDecrease = 0
					,dblUnpaidBalance = 0
					,dblPaidBalance = dblBalance *-1
					,strTransactionId = strTicketNumber
					,intTransactionId
					,'ADJ'
				FROM (
					select 
						dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,dblBalance = SUM(dblBalance)
						,strTicketNumber
						,intTransactionId = intTicketId
						,intCompanyLocationId
					from #tblGetStorageDetailByDate
					where intStorageTypeId = 2 --DP
						and intTicketId is not null
						and strTicketType IN ('Storage Adjustment')
					group by  
						CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,strTicketNumber
						,intTicketId
						,strTicketType
						,intCompanyLocationId
						
				) t
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

				UNION ALL --DP that are Settle and Reverse Settle 
				SELECT
					dtmDate
					,dblUnpaidIncrease = 0
					,dblUnpaidDecrease = 0
					,dblUnpaidBalance = 0
					,dblPaidBalance = dblBalance * -1
					,strTransactionId = strTicketNumber
					,intTransactionId = intTicketId
					,'DP'
				FROM (
					select 
						dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,dblBalance = SUM(dblBalance)
						,strTicketNumber
						,intTicketId
						,intCompanyLocationId
					from #tblGetStorageDetailByDate
					where intStorageTypeId = 2 --DP
						and intSettleStorageId is null
						and strTicketType IN( 'Settle Storage')
					group by
						CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
						,strTicketNumber
						,intTicketId
						,strTicketType
						,intCompanyLocationId
				)t
				WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			END 
			ELSE
			BEGIN

				INSERT INTO @CompanyTitle(
					dtmDate
					,dblUnpaidIncrease
					,dblUnpaidDecrease
					,dblUnpaidBalance
					,dblPaidBalance
					,strTransactionId
					,intTransactionId
					,strDistribution
				)
				SELECT --INVENTORY RECEIPT WITH VOUCHER
					dtmDate
					,dblUnpaidIncrease = dblQtyReceived
					,dblUnpaidDecrease = dblPartialPaidQty
					,dblUnpaidBalance = dblQtyReceived - dblPartialPaidQty
					,dblPaidBalance = dblPartialPaidQty
					,strTransactionId = strBillId
					,intTransactionId = intBillId
					,strDistribution
				FROM (
					select
						 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
						,BD.dblQtyReceived
						,dblPartialPaidQty = (BD.dblQtyReceived / B.dblTotal) * dblPayment 
						,B.strBillId
						,B.intBillId
						,strDistribution =  ISNULL(ST.strStorageTypeCode,'SPT')
					from @InventoryStock Inv
					inner join tblAPBillDetail BD on Inv.intTransactionDetailId = BD.intInventoryReceiptItemId 
							AND BD.intInventoryReceiptChargeId IS NULL
					inner join tblAPBill B on BD.intBillId = B.intBillId
					left join tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
					left join tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
					where 
						Inv.strTransactionType = 'Inventory Receipt'
						AND ISNULL(CS.intStorageTypeId,0) = 2  
				) t
				UNION ALL
				SELECT --INVENTORY RECEIPT W/O VOUCHER
					dtmDate
					,dblUnpaidIncrease = dblTotal
					,dblUnpaidDecrease = 0
					,dblUnpaidBalance = dblTotal
					,dblPaidBalance = 0
					,strTransactionId = strReceiptNumber
					,intTransactionId
					,''
				FROM (
					select
						 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
						,Inv.dblTotal
						,IRV.strReceiptNumber
						,Inv.intTransactionId
					from @InventoryStock Inv
					inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
					inner join vyuICGetInventoryReceiptVoucher IRV on Inv.intTransactionDetailId = IRV.intInventoryReceiptItemId
					where Inv.strTransactionType = 'Inventory Receipt'
						AND IRV.intBillId IS NULL
						AND IR.intSourceType = 1
				) t

				UNION ALL
				SELECT --INVENTORY RECEIPT PARTIALLY VOUCHERD
					dtmDate
					,dblUnpaidIncrease = ROUND(dblTotal,2)
					,dblUnpaidDecrease = 0
					,dblUnpaidBalance = ROUND(dblTotal,2)
					,dblPaidBalance = 0
					,strTransactionId = strReceiptNumber
					,intTransactionId
					,''
				FROM (
					select 
							dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
						,dblTotal = Inv.dblTotal - IRI.dblBillQty
						,IR.strReceiptNumber
						,Inv.intTransactionId
						,intBillId = (select top 1 intBillId from vyuICGetInventoryReceiptVoucher where intInventoryReceiptItemId = Inv.intTransactionDetailId )
					from @InventoryStock Inv
					inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
					inner join tblICInventoryReceiptItem IRI on Inv.intTransactionDetailId = IRI.intInventoryReceiptItemId
					where Inv.strTransactionType = 'Inventory Receipt'
						AND Inv.dblTotal <> dblBillQty
						AND IR.intSourceType = 1
				) t
				WHERE intBillId IS NOT NULL
			END


			--============================ RETURN =============================

		

				--Create the temp table for the date range
			;WITH N1 (N) AS (
				SELECT 1 FROM (
					VALUES (1), (1), (1), (1), (1), (1), (1), (1), (1), (1)) n (N)),
					N2 (N) AS (SELECT 1 FROM N1 AS N1 CROSS JOIN N1 AS N2),
					N3 (N) AS (SELECT 1 FROM N2 AS N1 CROSS JOIN N2 AS N2),
					Dates AS
				(SELECT TOP (DATEDIFF(DAY,  DATEADD(day,-1,@dtmFromTransactionDate), @dtmToTransactionDate))
					Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY N), DATEADD(day,-1,@dtmFromTransactionDate))
				FROM N3
			)

			SELECT	Date
			INTO #tempDateRange
			FROM Dates AS d


			DECLARE @Result AS TABLE (
				dtmDate  DATE  NULL
				,dblCompanyTitled  NUMERIC(18,6)
			)
			
			DECLARE @date DATE

			--Loop through the date range to get the company title per date
			WHILE (Select Count(*) From #tempDateRange) > 0
			BEGIN

				Select Top 1 @date = Date From #tempDateRange

				INSERT INTO @Result(
					dtmDate
					,dblCompanyTitled
				)
				SELECT 
					@date
					,sum(dblTotal) 
				FROM @InventoryStock 
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
			
				Delete #tempDateRange Where Date = @date

			End




			SELECT * FROM (
			SELECT
				 dtmDate = ISNULL(CT.dtmDate, R.dtmDate)
				,dblUnpaidIncrease
				,dblUnpaidDecrease
				,dblUnpaidBalance
				,dblPaidBalance
				,strTransactionId
				,intTransactionId
				,strDistribution
				,R.dblCompanyTitled
			FROM @CompanyTitle CT
			FULL JOIN @Result R ON CT.dtmDate = R.dtmDate
			

			UNION ALL--Insert Company Title Beginning Balance
			SELECT
				NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				,sum(dblTotal) 
			FROM @InventoryStock 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(day,-1,@dtmFromTransactionDate))
			) t
			WHERE dblCompanyTitled IS NOT NULL 

			--=========================================================================

			drop table #LicensedLocation
			drop table #tblGetStorageDetailByDate
			drop table #tblGetSalesIntransitWOPickLot
			drop table #tempDateRange


END