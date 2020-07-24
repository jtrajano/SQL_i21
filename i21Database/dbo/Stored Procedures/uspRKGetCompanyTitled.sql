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
			DECLARE @ysnIncludeInTransitInCompanyTitled BIT
			SELECT TOP 1 
				@ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled 
				,@ysnIncludeInTransitInCompanyTitled = ysnIncludeInTransitInCompanyTitled
			FROM tblRKCompanyPreference

		
			--=============================
			-- Storage Detail By Date
			--=============================
			--SELECT * INTO #tblGetStorageDetailByDate
			--FROM (
			--	SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY gh.intStorageHistoryId ORDER BY gh.intStorageHistoryId ASC)
			--		, a.intCustomerStorageId
			--		, a.intCompanyLocationId
			--		, c.strLocationName
			--		, strContractEndMonth = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
			--		, strDeliveryDate = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
			--		, a.intEntityId
			--		, strCustomerName = E.strName
			--		, a.strDPARecieptNumber [Receipt]
			--		, dblDiscDue = a.dblDiscountsDue
			--		, a.dblStorageDue
			--		, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
			--		, a.intStorageTypeId
			--		, strStorageType = b.strStorageTypeDescription
			--		, a.intCommodityId
			--		, CM.strCommodityCode
			--		, strCommodityDescription = CM.strDescription
			--		, b.strOwnedPhysicalStock
			--		, b.ysnReceiptedStorage
			--		, b.ysnDPOwnedType
			--		, b.ysnGrainBankType
			--		, b.ysnActive ysnCustomerStorage
			--		, a.strCustomerReference
			--		, a.dtmLastStorageAccrueDate
			--		, c1.strScheduleId
			--		, i.intItemId
			--		, i.strItemNo
			--		, i.intCategoryId
			--		, strCategory = Category.strCategoryCode
			--		, ium.intCommodityUnitMeasureId
			--		, t.dtmTicketDateTime
			--		, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
			--							WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
			--							WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
			--							WHEN gh.intTransactionTypeId = 9 THEN gh.intInventoryAdjustmentId
			--							ELSE gh.intCustomerStorageId END)
			--		, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
			--							WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
			--							WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
			--							WHEN gh.intTransactionTypeId = 9 THEN 'Storage Adjustment'
			--							ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
			--		, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN t.strTicketNumber
			--							WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
			--							WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
			--							WHEN gh.intTransactionTypeId = 9 THEN gh.strTransactionId
			--							ELSE a.strStorageTicketNumber END)
			--		, gh.intInventoryReceiptId
			--		, gh.intInventoryShipmentId
			--		, strReceiptNumber = ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '')
			--		, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
			--		, b.intStorageScheduleTypeId
			--		, strFutureMonth = '' COLLATE Latin1_General_CI_AS
			--		, gh.dtmHistoryDate
			--		, gh.intSettleStorageId
			--		, gh.strVoucher
			--		, gh.intBillId
			--		, gh.intStorageHistoryId
			--	FROM tblGRStorageHistory gh
			--	JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			--	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			--	JOIN tblICItem i ON i.intItemId = a.intItemId
			--	JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
			--	JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			--	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			--	LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
			--	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
			--	JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
			--	JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
			--	LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
			--	WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
			--		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
			--		AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			--		AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			--		--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
				
			--	UNION ALL
			--	SELECT intRowNum = ROW_NUMBER() OVER (PARTITION BY gh.intStorageHistoryId ORDER BY gh.intStorageHistoryId ASC)
			--		, a.intCustomerStorageId
			--		, a.intCompanyLocationId
			--		, c.strLocationName
			--		, strContractEndMonth = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
			--		, strDeliveryDate = (CASE WHEN gh.strType = 'Transfer' THEN RIGHT(CONVERT(VARCHAR(11), gh.dtmHistoryDate, 106), 8) ELSE RIGHT(CONVERT(VARCHAR(11), a.dtmDeliveryDate, 106), 8) END) COLLATE Latin1_General_CI_AS
			--		, a.intEntityId
			--		, strCustomerName = E.strName
			--		, [Receipt] = a.strDPARecieptNumber
			--		, dblDiscDue = a.dblDiscountsDue 
			--		, a.dblStorageDue
			--		, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
			--		, a.intStorageTypeId
			--		, strStorageType = b.strStorageTypeDescription
			--		, a.intCommodityId
			--		, CM.strCommodityCode
			--		, strCommodityDescription = CM.strDescription
			--		, b.strOwnedPhysicalStock
			--		, b.ysnReceiptedStorage
			--		, b.ysnDPOwnedType
			--		, b.ysnGrainBankType
			--		, b.ysnActive ysnCustomerStorage
			--		, a.strCustomerReference
			--		, a.dtmLastStorageAccrueDate
			--		, c1.strScheduleId
			--		, i.intItemId
			--		, i.strItemNo
			--		, i.intCategoryId
			--		, strCategory = Category.strCategoryCode
			--		, ium.intCommodityUnitMeasureId
			--		, dtmTicketDateTime = NULL
			--		, intTicketId = (CASE WHEN gh.intTransactionTypeId = 1 THEN gh.intTicketId
			--							WHEN gh.intTransactionTypeId = 4 THEN gh.intSettleStorageId
			--							WHEN gh.intTransactionTypeId = 3 THEN gh.intTransferStorageId
			--							WHEN gh.intTransactionTypeId = 9 THEN gh.intInventoryAdjustmentId
			--							ELSE gh.intCustomerStorageId END)
			--		, strTicketType = (CASE WHEN gh.intTransactionTypeId = 1 THEN 'Scale Storage'
			--							WHEN gh.intTransactionTypeId = 4 THEN 'Settle Storage'
			--							WHEN gh.intTransactionTypeId = 3 THEN 'Transfer Storage'
			--							WHEN gh.intTransactionTypeId = 9 THEN  'Storage Adjustment'
			--							ELSE 'Customer/Maintain Storage' END) COLLATE Latin1_General_CI_AS
			--		, strTicketNumber = (CASE WHEN gh.intTransactionTypeId = 1 THEN NULL
			--							WHEN gh.intTransactionTypeId = 4 THEN gh.strSettleTicket
			--							WHEN gh.intTransactionTypeId = 3 THEN gh.strTransferTicket
			--							WHEN gh.intTransactionTypeId = 9 THEN gh.strTransactionId
			--							ELSE a.strStorageTicketNumber END)
			--		, intInventoryReceiptId = (CASE WHEN gh.strType = 'From Inventory Adjustment' THEN gh.intInventoryAdjustmentId ELSE gh.intInventoryReceiptId END)
			--		, gh.intInventoryShipmentId
			--		, strReceiptNumber = (CASE WHEN gh.strType ='From Inventory Adjustment' THEN gh.strTransactionId
			--								ELSE ISNULL((SELECT strReceiptNumber FROM tblICInventoryReceipt WHERE intInventoryReceiptId = gh.intInventoryReceiptId), '') END)
			--		, strShipmentNumber = ISNULL((SELECT strShipmentNumber FROM tblICInventoryShipment WHERE intInventoryShipmentId = gh.intInventoryShipmentId), '')
			--		, b.intStorageScheduleTypeId
			--		, strFutureMonth = '' COLLATE Latin1_General_CI_AS
			--		, gh.dtmHistoryDate
			--		, gh.intSettleStorageId
			--		, gh.strVoucher
			--		, gh.intBillId
			--		, gh.intStorageHistoryId
			--	FROM tblGRStorageHistory gh
			--	JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			--	JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			--	JOIN tblICItem i ON i.intItemId = a.intItemId
			--	JOIN tblICCategory Category ON Category.intCategoryId = i.intCategoryId
			--	JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			--	JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			--	LEFT JOIN tblGRStorageScheduleRule c1 ON c1.intStorageScheduleRuleId = a.intStorageScheduleId
			--	JOIN tblSMCompanyLocation c ON c.intCompanyLocationId = a.intCompanyLocationId
			--	JOIN tblEMEntity E ON E.intEntityId = a.intEntityId
			--	JOIN tblICCommodity CM ON CM.intCommodityId = a.intCommodityId
			--	WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
			--		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
			--		AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
			--		AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			--		--AND ISNULL(a.intEntityId, 0) = ISNULL(@intVendorId, ISNULL(a.intEntityId, 0))
			--)t

			
			DECLARE @InventoryStock AS TABLE (strCommodityCode NVARCHAR(100)
			, strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, strCategory NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, dblTotal numeric(24,10)
			, strLocationName nvarchar(100) COLLATE Latin1_General_CI_AS
			, intCommodityId int
			, intFromCommodityUnitMeasureId int
			, intItemUOMId int
			, strType nvarchar(100) COLLATE Latin1_General_CI_AS
			, strInventoryType NVARCHAR(100) COLLATE Latin1_General_CI_AS
			, intPricingTypeId int
			, strTransactionType NVARCHAR(50)
			, intTransactionId INT
			, strTransactionId NVARCHAR(50)
			, intTransactionDetailId INT
			, intSourceId INT
			, dtmDate DATETIME)


			
			INSERT INTO @InventoryStock(strCommodityCode
				, strItemNo
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strInventoryType
				, dtmDate
				, strTransactionType
				, intTransactionId
				, strTransactionId
				, intTransactionDetailId
				, intSourceId
				)
			SELECT
				strCommodityCode
				,strItemNo
				,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId, @intCommodityUnitMeasureId, dblTotal)
				,strLocationName
				,intCommodityId
				,intOrigUOMId
				,strInventoryType = 'Company Titled'
				,dtmTransactionDate
				,strTransactionType
				,intTransactionRecordHeaderId
				,strTransactionNumber
				,intTransactionRecordId
				,intTicketId
			FROM dbo.fnRKGetBucketCompanyOwned(@dtmToTransactionDate,@intCommodityId,NULL) CompOwn
			WHERE CompOwn.intItemId = ISNULL(@intItemId, CompOwn.intItemId)
				AND CompOwn.intLocationId = ISNULL(@intLocationId, CompOwn.intLocationId)
				AND CompOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--Collateral
			INSERT INTO @InventoryStock(strCommodityCode
				, dtmDate
				, dblTotal
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strTransactionType
				, intSourceId)
			SELECT strCommodityCode
				, dtmDate
				, dblTotal = SUM(dblTotal)
				, strLocationName
				, intCommodityId
				, intFromCommodityUnitMeasureId
				, strTransactionType
				, intCollateralId
			FROM (
				 select
					strCommodityCode
					,dtmDate = dtmOpenDate
					,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblTotal)
					,strLocationName
					,intCommodityId
					,intFromCommodityUnitMeasureId = @intCommodityUnitMeasureId
					,strTransactionType = 'Collateral' 
					,intCollateralId
				 from dbo.fnRKGetBucketCollateral(@dtmToTransactionDate,@intCommodityId,null)
				 where ysnIncludeInPriceRiskAndCompanyTitled = 1
					and intItemId = ISNULL(@intItemId, intItemId)
					and intLocationId = ISNULL(@intLocationId, intLocationId)
					and intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			) t GROUP BY strCommodityCode
				, strLocationName
				, intCommodityId
				, dtmDate
				, intFromCommodityUnitMeasureId
				, strTransactionType
				, intCollateralId

			--=========================================
			-- Includes DP based on Company Preference
			--========================================
			If ( @ysnIncludeDPPurchasesInCompanyTitled = 0)--DP is already included in Inventory we are going to subtract it here (reverse logic in including DP)
			BEGIN

				INSERT INTO @InventoryStock(strCommodityCode
					, strItemNo
					, dblTotal
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, strInventoryType
					, dtmDate)
				SELECT strCommodityCode
					, strItemNo
					, dblTotal = -sum(dblTotal)
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, 'Company Titled' COLLATE Latin1_General_CI_AS
					, dtmTransactionDate
				FROM (
					SELECT
						strCommodityCode
						, strItemNo
						, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId, @intCommodityUnitMeasureId,dblTotal)
						, strLocationName
						, intLocationId
						, intCommodityId
						, intFromCommodityUnitMeasureId = intOrigUOMId
						, dtmTransactionDate
					FROM dbo.fnRKGetBucketDelayedPricing(@dtmToTransactionDate,@intCommodityId,NULL) DP
					WHERE DP.intItemId = ISNULL(@intItemId, DP.intItemId)
					AND DP.intLocationId = ISNULL(@intLocationId, DP.intLocationId)
					AND DP.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
				)t  GROUP BY strCommodityCode
					, strItemNo
					, strLocationName
					, intCommodityId
					, intFromCommodityUnitMeasureId
					, dtmTransactionDate
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
					,strTransactionType NVARCHAR(50)
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
				,strTransactionType
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
				,strTransactionType
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyReceived = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId, BD.dblQtyReceived)
					,dblPartialPaidQty = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId,(BD.dblQtyReceived / CASE WHEN B.dblTotal = 0 THEN 1 ELSE B.dblTotal END) * dblPayment )
					,B.strBillId 
					,B.intBillId 
					,strDistribution =  ISNULL(ST.strStorageTypeCode,ISNULL(TV.strDistributionOption, ''))
					,strTransactionType = 'Bill' 
				from @InventoryStock Inv
				inner join tblAPBillDetail BD on Inv.intTransactionDetailId = BD.intInventoryReceiptItemId 
						AND BD.intInventoryReceiptChargeId IS NULL
				inner join tblAPBill B on BD.intBillId = B.intBillId
				left join tblGRCustomerStorage CS ON BD.intCustomerStorageId = CS.intCustomerStorageId
				left join tblGRStorageType ST ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
				left join vyuSCTicketView TV on BD.intScaleTicketId = TV.intTicketId
				left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = Inv.intFromCommodityUnitMeasureId
				left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = BD.intItemId
				where 
					Inv.strTransactionType = 'Inventory Receipt'
					AND ISNULL(CS.intStorageTypeId,100) <>  CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 0 ELSE 2 END
			) t
			UNION ALL
			SELECT --INVENTORY RECEIPT W/O VOUCHER (NOT DELIVERY SHEET)
				dtmDate
				,dblUnpaidIncrease = dblTotal
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = dblTotal
				,dblPaidBalance = 0
				,strTransactionId = strReceiptNumber
				,intTransactionId
				,strDistribution = strDistributionOption
				,strTransactionType 
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblTotal  = SUM(ISNULL(Inv.dblTotal,0))
					,IR.strReceiptNumber
					,Inv.intTransactionId
					,TV.strDistributionOption
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
				inner join tblICInventoryReceiptItem IRI on Inv.intTransactionDetailId = IRI.intInventoryReceiptItemId
				left join tblAPBillDetail BD on Inv.intTransactionDetailId = BD.intInventoryReceiptItemId and BD.intInventoryReceiptChargeId IS NULL
				left join vyuSCTicketView TV on IRI.intSourceId = TV.intTicketId
				where Inv.strTransactionType = 'Inventory Receipt'
					AND BD.intBillDetailId IS NULL
					AND ISNULL(TV.strDistributionOption,'NULL') <>  CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN '' ELSE 'DP' END
					--AND TV.intDeliverySheetId IS NULL
				group by Inv.dtmDate
					,IR.strReceiptNumber
					,Inv.intTransactionId
					,TV.strDistributionOption
					,Inv.strTransactionType
			) t
			UNION ALL
			SELECT --INVENTORY RECEIPT W/O VOUCHER (DELIVERY SHEET)
				dtmDate
				,dblUnpaidIncrease = dblTotal
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = dblTotal
				,dblPaidBalance = 0
				,strTransactionId = strReceiptNumber
				,intTransactionId
				,strDistribution = strStorageTypeCode
				,strTransactionType 
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,IR.strReceiptNumber
					,Inv.intTransactionId
					,ST.strStorageTypeCode
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
				inner join tblICInventoryReceiptItem IRI on Inv.intTransactionDetailId = IRI.intInventoryReceiptItemId
				inner join tblGRStorageHistory SH on SH.intInventoryReceiptId = IR.intInventoryReceiptId
				inner join tblGRCustomerStorage CS ON CS.intCustomerStorageId = SH.intCustomerStorageId
				inner join tblGRStorageType ST on ST.intStorageScheduleTypeId = CS.intStorageTypeId 
				left join tblAPBillDetail BD on Inv.intTransactionDetailId = BD.intInventoryReceiptItemId and BD.intInventoryReceiptChargeId IS NULL
				where Inv.strTransactionType = 'Inventory Receipt'
					AND BD.intBillDetailId IS NULL
					AND ISNULL(ST.intStorageScheduleTypeId,100) <>  CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 0 ELSE 2 END
					AND CS.intDeliverySheetId IS NOT NULL
			) t
			UNION ALL
			SELECT
				dtmDate
				,dblUnpaidIncrease 
				,dblUnpaidDecrease 
				,dblUnpaidBalance
				,dblPaidBalance
				,strTransactionId
				,intTransactionId
				,strDistribution
				,strTransactionType
			FROM (
				select distinct
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110)
					,dblUnpaidIncrease = ISNULL(CS.dblUnits,Inv.dblTotal)
					,dblUnpaidDecrease = dblPartialPaidQty
					,dblUnpaidBalance =  ISNULL(CS.dblUnits,Inv.dblTotal) - isnull(dblPartialPaidQty,0)
					,dblPaidBalance = dblPartialPaidQty
					,strTransactionId = ISNULL(CS.strVoucher,Inv.strTransactionId)
					,intTransactionId = ISNULL(CS.intBillId,Inv.intTransactionId)
					,strDistribution = CASE WHEN (SELECT TOP 1 1 FROM tblGRSettleContract WHERE intSettleStorageId = Inv.intTransactionDetailId) = 1 THEN 'CNT' ELSE strDistribution END
					,intTransactionDetailId = ISNULL(CS.intBillId,Inv.intTransactionDetailId)
					,strTransactionType =  CASE WHEN CS.intBillId IS NOT NULL THEN 'Bill'  ELSE 'Storage Settlement' END
				from @InventoryStock Inv
				outer apply (
					select 
						strVoucher
						,intBillId
						,dblUnits = sum(dblUnits)
						,dblPartialPaidQty = sum(dblPartialPaidQty)
						,strDistribution = strStorageTypeCode
					 from (	
					select 
							strVoucher = B.strBillId
							, B.intBillId
							, dblUnits =  BD.dblQtyReceived
							, dblPartialPaidQty = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId,CASE WHEN ISNULL(B.dblTotal, 0) = 0 THEN 0 ELSE (BD.dblQtyReceived / CASE WHEN B.dblTotal = 0 THEN 1 ELSE B.dblTotal END) * B.dblPayment END)		
							, ST.strStorageTypeCode
						from tblGRSettleStorage S 
						inner join tblGRSettleStorageBillDetail SBD on SBD.intSettleStorageId = S.intSettleStorageId
						inner join tblAPBill B on SBD.intBillId = B.intBillId
									inner join tblAPBillDetail BD on B.intBillId = BD.intBillId 
											AND BD.intItemId = S.intItemId 
						left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = Inv.intFromCommodityUnitMeasureId
						left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = BD.intItemId
						left join tblGRCustomerStorage CS ON CS.intCustomerStorageId = BD.intCustomerStorageId
						left join tblGRStorageType ST ON ST.intStorageScheduleTypeId = CS.intStorageTypeId
						where S.intSettleStorageId = Inv.intTransactionDetailId 
					) t
					group by strVoucher, intBillId, strStorageTypeCode
	
				) CS
				where 
					Inv.strTransactionType = 'Storage Settlement'
					and Inv.dblTotal > 0

				union all
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110)
					,dblUnpaidIncrease = NULL
					,dblUnpaidDecrease = Inv.dblTotal * -1
					,dblUnpaidBalance =  Inv.dblTotal
					,dblPaidBalance = NULL
					,strTransactionId = Inv.strTransactionId
					,intTransactionId = Inv.intTransactionId
					,strDistribution = CASE WHEN (SELECT TOP 1 1 FROM tblGRSettleContract WHERE intSettleStorageId = Inv.intTransactionDetailId) = 1 THEN 'CNT' ELSE 'SPT' END
					,intTransactionDetailId = Inv.intTransactionDetailId
					,strTransactionType =   'Storage Settlement'
				from @InventoryStock Inv
				where Inv.strTransactionType = 'Storage Settlement'
					and Inv.dblTotal < 0

				union all
				select 
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10), Inv.dtmDate, 110), 110)
					,dblUnpaidIncrease = (Inv.dblTotal - CS.dblUnits)
					,dblUnpaidDecrease = dblPartialPaidQty
					,dblUnpaidBalance =  (Inv.dblTotal - CS.dblUnits) - isnull(dblPartialPaidQty,0)
					,dblPaidBalance = dblPartialPaidQty
					,strTransactionId = Inv.strTransactionId
					,intTransactionId = Inv.intTransactionId
					,strDistribution = CASE WHEN (SELECT TOP 1 1 FROM tblGRSettleContract WHERE intSettleStorageId = Inv.intTransactionDetailId) = 1 THEN 'CNT' ELSE 'SPT' END
					,intTransactionDetailId = Inv.intTransactionDetailId
					,strTransactionType = Inv.strTransactionType
				from @InventoryStock Inv
				cross apply (
					select 
						dblUnits = sum(dblUnits)
						,dblPartialPaidQty = sum(dblPartialPaidQty)
					 from (	
					select 
							 dblUnits =  BD.dblQtyReceived
							, dblPartialPaidQty = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId,CASE WHEN ISNULL(B.dblTotal, 0) = 0 THEN 0 ELSE (BD.dblQtyReceived / CASE WHEN B.dblTotal = 0 THEN 1 ELSE B.dblTotal END) * B.dblPayment END)		
						from tblGRSettleStorage S 
						inner join tblGRSettleStorageBillDetail SBD on SBD.intSettleStorageId = S.intSettleStorageId
						inner join tblAPBill B on SBD.intBillId = B.intBillId
									inner join tblAPBillDetail BD on B.intBillId = BD.intBillId 
											AND BD.intItemId = S.intItemId
						left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = Inv.intFromCommodityUnitMeasureId
						left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = BD.intItemId
						where S.intSettleStorageId = Inv.intTransactionDetailId 
					) t
				) CS
				where 
					Inv.strTransactionType = 'Storage Settlement'
					and (Inv.dblTotal - CS.dblUnits) > 0
			) t

			UNION ALL --INVENTORY SHIPMENT WITH INVOICE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strInvoiceNumber
				,intTransactionId = intInvoiceId
				,strDistribution
				,strTransactionType
			FROM (
				select distinct
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, IUM.intItemUOMId, ID.dblQtyShipped), 0) * -1
					,I.strInvoiceNumber
					,I.intInvoiceId
					,strDistribution = TV.strDistributionOption
					,Inv.intTransactionDetailId
					,strTransactionType = 'Invoice'
				from @InventoryStock Inv
				inner join tblICInventoryShipment S on Inv.intTransactionId = S.intInventoryShipmentId
				inner join tblICInventoryShipmentItem ISI ON ISI.intInventoryShipmentId = S.intInventoryShipmentId AND ISI.intInventoryShipmentItemId = Inv.intTransactionDetailId
				inner join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInventoryShipmentItemId 
						AND ID.intInventoryShipmentChargeId IS NULL
				inner join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId
				left join vyuSCTicketView TV on ID.intTicketId = TV.intTicketId
				left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = Inv.intFromCommodityUnitMeasureId
				left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = ID.intItemId
				where Inv.strTransactionType = 'Inventory Shipment'
				AND ISI.ysnDestinationWeightsAndGrades = 0

				UNION ALL
				select distinct
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = ISNULL(dbo.fnCalculateQtyBetweenUOM(ID.intItemUOMId, IUM.intItemUOMId,  Inv.dblTotal), 0) 
					,I.strInvoiceNumber
					,I.intInvoiceId
					,strDistribution = TV.strDistributionOption
					,Inv.intTransactionDetailId
					,strTransactionType = 'Invoice'
				from @InventoryStock Inv
				inner join tblICInventoryShipment S on Inv.intTransactionId = S.intInventoryShipmentId
				inner join tblICInventoryShipmentItem ISI ON ISI.intInventoryShipmentId = S.intInventoryShipmentId AND ISI.intInventoryShipmentItemId = Inv.intTransactionDetailId
				inner join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInventoryShipmentItemId 
						AND ID.intInventoryShipmentChargeId IS NULL
				inner join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId and I.strTransactionType = 'Invoice'
				left join vyuSCTicketView TV on ID.intTicketId = TV.intTicketId
				left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = Inv.intFromCommodityUnitMeasureId
				left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = ID.intItemId
				where Inv.strTransactionType = 'Inventory Shipment'
				AND ISI.ysnDestinationWeightsAndGrades = 1

						
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
				,strTransactionType 
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,S.strShipmentNumber
					,Inv.intTransactionId
					,strDistribution = ISNULL(TV.strDistributionOption,'')
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblICInventoryShipment S on Inv.intTransactionId = S.intInventoryShipmentId
				left join tblARInvoiceDetail ID on Inv.intTransactionDetailId = ID.intInventoryShipmentItemId 
						AND ID.intInventoryShipmentChargeId IS NULL
				left join tblARInvoice I on ID.intInvoiceId = I.intInvoiceId
				left join vyuSCTicketView TV on Inv.intSourceId = TV.intTicketId
				where Inv.strTransactionType = 'Inventory Shipment'
					and ID.intInvoiceDetailId IS NULL
					and @ysnIncludeInTransitInCompanyTitled = 0
			) t


			UNION ALL --DIRECT INVOICE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblQtyShipped
				,strTransactionId = strInvoiceNumber
				,intTransactionId = intInvoiceId
				,''
				,strTransactionType
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),I.dtmPostDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strInvoiceNumber
					,I.intInvoiceId
					,Inv.strTransactionType
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
				,intTransactionId = intInvoiceId
				,'CM'
				,strTransactionType
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strInvoiceNumber
					,I.intInvoiceId
					,Inv.strTransactionType
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
				,strTransactionType
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strCountNo
					,Inv.intTransactionId
					,Inv.strTransactionType
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
				,strTransactionType
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strAdjustmentNo
					,Inv.intTransactionId
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblICInventoryAdjustmentDetail ID on Inv.intTransactionDetailId = ID.intInventoryAdjustmentDetailId 
				inner join tblICInventoryAdjustment I on ID.intInventoryAdjustmentId = I.intInventoryAdjustmentId
				where Inv.strTransactionType LIKE 'Inventory Adjustment%'
					AND I.ysnPosted = 1
					AND (I.intSourceTransactionTypeId IS NULL OR I.intSourceTransactionTypeId = 8)
						
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
				,strTransactionType
			FROM (
				select
					 dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,dblQtyShipped = Inv.dblTotal
					,I.strTransferNo
					,Inv.intTransactionId
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblICInventoryTransferDetail ID on Inv.intTransactionDetailId = ID.intInventoryTransferDetailId 
				inner join tblICInventoryTransfer I on ID.intInventoryTransferId = I.intInventoryTransferId
				where Inv.strTransactionType = 'Inventory Transfer'
					AND I.ysnPosted = 1
						
			) t

			UNION ALL --TRANSFER STORAGE
			SELECT
				dtmDate
				,dblUnpaidIncrease = CASE WHEN dblQtyShipped < 0 THEN 0 ELSE dblQtyShipped END
				,dblUnpaidDecrease = CASE WHEN dblQtyShipped < 0 THEN ABS(dblQtyShipped) ELSE 0 END
				,dblUnpaidBalance = dblQtyShipped
				,dblPaidBalance = 0
				,strTransactionId = strTransferStorageTicket
				,intTransactionId
				,strStorageTypeCode
				,strTransactionType
			FROM (
				SELECT DISTINCT dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					  ,dblQtyShipped = Inv.dblTotal
					  ,TS.strTransferStorageTicket
					  ,Inv.intTransactionId	
					  ,ST.strStorageTypeCode
					  ,Inv.strTransactionType
				FROM @InventoryStock Inv
				INNER JOIN tblGRTransferStorage TS ON Inv.intTransactionId = TS.intTransferStorageId
				INNER JOIN tblGRTransferStorageSplit TSS ON Inv.intTransactionDetailId = TSS.intTransferStorageSplitId
				INNER JOIN tblGRStorageType ST ON ST.intStorageScheduleTypeId = TSS.intStorageTypeId
				WHERE Inv.strTransactionType = 'Transfer Storage'
			) T

			UNION ALL--PRODUCE
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblTotal
				,strTransactionId
				,intTransactionId
				,'PRDC'
				,strTransactionType
			FROM (
				select
					dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,strTransactionId = Inv.strTransactionId
					,Inv.intTransactionId 
					,Inv.strTransactionType
				from @InventoryStock Inv
				where Inv.strTransactionType = 'Produce'
						
			) t

			UNION ALL--CONSUME
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblTotal
				,strTransactionId
				,intTransactionId
				,'CNSM'
				,strTransactionType
			FROM (
				select
					dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,strTransactionId = Inv.strTransactionId
					,Inv.intTransactionId 
					,Inv.strTransactionType
				from @InventoryStock Inv
				where Inv.strTransactionType = 'Consume'
						
			) t

			UNION ALL--Outbound Shipment
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblTotal
				,strTransactionId
				,intTransactionId
				,'LG'
				,strTransactionType
			FROM (
				select
					dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,strTransactionId = LG.strLoadNumber
					,Inv.intTransactionId 
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblLGLoad LG on LG.intLoadId = Inv.intTransactionId
				where Inv.strTransactionType = 'Outbound Shipment'
						
			) t

			UNION ALL--COLLATERAL
			SELECT
				dtmDate
				,dblUnpaidIncrease = 0
				,dblUnpaidDecrease = 0
				,dblUnpaidBalance = 0
				,dblPaidBalance = dblTotal
				,strTransactionId
				,intTransactionId
				,'CLT'
				,strTransactionType
			FROM (
				select
						dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
					,Inv.dblTotal
					,strTransactionId = Col.strReceiptNo
					,intTransactionId = Inv.intSourceId
					,Inv.strTransactionType
				from @InventoryStock Inv
				inner join tblRKCollateral Col on Col.intCollateralId = Inv.intSourceId
				where Inv.strTransactionType = 'Collateral'
						
			) t

			

			--IF (@ysnIncludeDPPurchasesInCompanyTitled = 1)
			--BEGIN
			--	--DP Settlement
			--	INSERT INTO @CompanyTitle(
			--		dtmDate
			--		,dblUnpaidIncrease
			--		,dblUnpaidDecrease
			--		,dblUnpaidBalance
			--		,dblPaidBalance
			--		,strTransactionId
			--		,intTransactionId
			--		,strDistribution
			--		,strTransactionType
			--	)
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = dblTotal
			--		,dblUnpaidDecrease = 0
			--		,dblUnpaidBalance = dblTotal
			--		,dblPaidBalance = 0
			--		,strTransactionId  =  strTransactionNumber
			--		,intTransactionId = intTransactionRecordHeaderId
			--		,strDistribution = 'DP'
			--		,strTransactionType
			--	FROM (
			--		select
			--			dtmDate = CONVERT(VARCHAR(10),dtmCreatedDate,110)
			--			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
			--			, strTransactionNumber
			--			, intTransactionRecordHeaderId
			--			, strTransactionType
			--		from dbo.fnRKGetBucketDelayedPricing(@dtmToTransactionDate,@intCommodityId,NULL) OH
			--		where OH.intItemId = ISNULL(@intItemId, OH.intItemId)
			--			and OH.intLocationId = ISNULL(@intLocationId, OH.intLocationId)
			--			and OH.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			--			and strTransactionType = 'Storage Settlement'
			--	) t

			--	UNION ALL
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = dblQtyReceived
			--		,dblUnpaidDecrease = dblPartialPaidQty
			--		,dblUnpaidBalance = dblQtyReceived - dblPartialPaidQty
			--		,dblPaidBalance = dblPartialPaidQty
			--		,strTransactionId  =  strBillId
			--		,intTransactionId = intBillId
			--		,strDistribution = 'DP'
			--		,strTransactionType = 'Bill'
			--	FROM (
			--		select
			--			dtmDate = CONVERT(VARCHAR(10),dtmCreatedDate,110)
			--			, dblQtyReceived = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId,BD.dblQtyReceived)
			--			,dblPartialPaidQty = dbo.fnCalculateQtyBetweenUOM(BD.intUnitOfMeasureId, IUM.intItemUOMId,(BD.dblQtyReceived / CASE WHEN B.dblTotal = 0 THEN 1 ELSE B.dblTotal END) * dblPayment )
			--			, B.strBillId
			--			, B.intBillId
			--			, strTransactionType
			--		from dbo.fnRKGetBucketDelayedPricing(@dtmToTransactionDate,@intCommodityId,NULL) OH
			--		inner join tblAPBillDetail BD on BD.intCustomerStorageId = OH.intTransactionRecordHeaderId
			--		inner join tblAPBill B on B.intBillId = BD.intBillId
			--		left join tblICCommodityUnitMeasure CUM ON CUM.intCommodityUnitMeasureId = OH.intOrigUOMId
			--		left join tblICItemUOM IUM ON IUM.intUnitMeasureId = CUM.intUnitMeasureId AND IUM.intItemId = BD.intItemId
			--		where OH.intItemId = ISNULL(@intItemId, OH.intItemId)
			--			and OH.intLocationId = ISNULL(@intLocationId, OH.intLocationId)
			--			and OH.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			--			and strTransactionType = 'Storage Settlement'
			--	) t

			--END
			

			--If (@ysnIncludeDPPurchasesInCompanyTitled = 0)
			--BEGIN
			--	INSERT INTO @CompanyTitle(
			--		dtmDate
			--		,dblUnpaidIncrease
			--		,dblUnpaidDecrease
			--		,dblUnpaidBalance
			--		,dblPaidBalance
			--		,strTransactionId
			--		,intTransactionId
			--		,strDistribution
			--		,strTransactionType
			--	)
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = ABS(dblBalance)
			--		,dblUnpaidDecrease = ABS(dblBalance)
			--		,dblUnpaidBalance = 0
			--		,dblPaidBalance = -dblBalance 
			--		,strTransactionId = strVoucher
			--		,intTransactionId
			--		,'DP'
			--		,strTransactionType
			--	FROM (
			--		select 
			--			dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),B.dtmDate, 110), 110)
			--			,dblBalance = SUM(SD.dblBalance)
			--			,strVoucher
			--			,intTransactionId = intStorageHistoryId
			--			,intCompanyLocationId
			--			,strTransactionType = ''
			--		from #tblGetStorageDetailByDate SD
			--		inner join tblAPBill B on SD.intBillId = B.intBillId
			--		where intStorageTypeId = 2 --DP
			--		and intSettleStorageId is not null
			--		group by
			--			CONVERT(DATETIME, CONVERT(VARCHAR(10),B.dtmDate, 110), 110)
			--			,strVoucher
			--			,intStorageHistoryId
			--			,strTicketType
			--			,intCompanyLocationId
			--	) t
			--	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--	UNION ALL --DP that are Settle and Reverse Settle 
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = 0
			--		,dblUnpaidDecrease = 0
			--		,dblUnpaidBalance = 0
			--		,dblPaidBalance = dblBalance * -1
			--		,strTransactionId = strTicketNumber
			--		,intTransactionId = intTicketId
			--		,'DP'
			--		,strTransactionType
			--	FROM (
			--		select 
			--			dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,dblBalance = SUM(dblBalance)
			--			,strTicketNumber
			--			,intTicketId
			--			,intCompanyLocationId
			--			,strTransactionType = ''
			--		from #tblGetStorageDetailByDate 
			--		where intStorageTypeId = 2 --DP
			--			and intSettleStorageId is null
			--			and strTicketType IN( 'Settle Storage')
			--		group by
			--			CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,strTicketNumber
			--			,intTicketId
			--			,strTicketType
			--			,intCompanyLocationId
			--	)t
			--	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--END 
			--ELSE
			--BEGIN

			--	INSERT INTO @CompanyTitle(
			--		dtmDate
			--		,dblUnpaidIncrease
			--		,dblUnpaidDecrease
			--		,dblUnpaidBalance
			--		,dblPaidBalance
			--		,strTransactionId
			--		,intTransactionId
			--		,strDistribution
			--		,strTransactionType
			--	)
			--	SELECT --INVENTORY RECEIPT PARTIALLY VOUCHERD
			--		dtmDate
			--		,dblUnpaidIncrease = ROUND(dblTotal,2)
			--		,dblUnpaidDecrease = 0
			--		,dblUnpaidBalance = ROUND(dblTotal,2)
			--		,dblPaidBalance = 0
			--		,strTransactionId = strReceiptNumber
			--		,intTransactionId
			--		,''
			--		,strTransactionType
			--	FROM (
			--		select 
			--				dtmDate =  CONVERT(DATETIME, CONVERT(VARCHAR(10),Inv.dtmDate, 110), 110)
			--			,dblTotal = Inv.dblTotal - IRI.dblBillQty
			--			,IR.strReceiptNumber
			--			,Inv.intTransactionId
			--			,IRV.intBillId
			--			,Inv.strTransactionType
			--		from @InventoryStock Inv
			--		inner join tblICInventoryReceipt IR on Inv.intTransactionId = IR.intInventoryReceiptId
			--		inner join tblICInventoryReceiptItem IRI on Inv.intTransactionDetailId = IRI.intInventoryReceiptItemId
			--		left join vyuICGetInventoryReceiptVoucher IRV on IRV.intInventoryReceiptItemId = Inv.intTransactionDetailId
			--		where Inv.strTransactionType = 'Inventory Receipt'
			--			AND Inv.dblTotal <> dblBillQty
			--			AND IR.intSourceType = 1
			--	) t
			--	WHERE intBillId IS NOT NULL

			--	UNION ALL--INVENTORY ADJUSTMENT FROM STORAGE
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = 0
			--		,dblUnpaidDecrease = ABS(dblBalance)
			--		,dblUnpaidBalance = - ABS(dblBalance)
			--		,dblPaidBalance = 0 
			--		,strTransactionId = strTicketNumber
			--		,intTransactionId
			--		,'ADJ'
			--		,strTransactionType
			--	FROM (
			--		select 
			--			dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,dblBalance = SUM(dblBalance)
			--			,strTicketNumber
			--			,intTransactionId = intTicketId
			--			,intCompanyLocationId
			--			,strTransactionType = ''
			--		from #tblGetStorageDetailByDate
			--		where intStorageTypeId = 2 --DP
			--			and intTicketId is not null
			--			AND intCustomerStorageId NOT IN (
			--				SELECT intCustomerStorageId
			--				FROM #tblGetStorageDetailByDate
			--				WHERE strTicketType = 'Settle Storage'
			--					AND intSettleStorageId IS NOT NULL
			--			)
			--			and strTicketType IN ('Storage Adjustment') 
			--		group by  
			--			CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,strTicketNumber
			--			,intTicketId
			--			,strTicketType
			--			,intCompanyLocationId
						
			--	) t
			--	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--	UNION ALL--INVENTORY ADJUSTMENT (DP Adjustment)
			--	SELECT
			--		dtmDate
			--		,dblUnpaidIncrease = ABS(dblBalance)
			--		,dblUnpaidDecrease = ABS(dblBalance)
			--		,dblUnpaidBalance = 0
			--		,dblPaidBalance = 0 
			--		,strTransactionId = strTicketNumber
			--		,intTransactionId
			--		,'ADJ (DP)'
			--		,strTransactionType
			--	FROM (
			--		select 
			--			dtmDate  = CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,dblBalance = SUM(dblBalance)
			--			,strTicketNumber
			--			,intTransactionId = intTicketId
			--			,intCompanyLocationId
			--			,strTransactionType = ''
			--		from #tblGetStorageDetailByDate
			--		where intStorageTypeId = 2 --DP
			--			and intTicketId is not null
			--			AND intCustomerStorageId IN (
			--				SELECT intCustomerStorageId
			--				FROM #tblGetStorageDetailByDate
			--				WHERE strTicketType = 'Settle Storage'
			--					AND intSettleStorageId IS NOT NULL
			--			)
			--			and strTicketType IN ('Storage Adjustment') 
			--		group by  
			--			CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmHistoryDate, 110), 110)
			--			,strTicketNumber
			--			,intTicketId
			--			,strTicketType
			--			,intCompanyLocationId						
			--	) t
			--	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

			--END

	

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

			SELECT dtmDate = InTran.dtmTransactionDate 
				, dblInTransitQty = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId , @intCommodityUnitMeasureId, ISNULL((InTran.dblTotal), 0))
			INTO #InTransitDateRange
			FROM dbo.fnRKGetBucketInTransit(@dtmToTransactionDate,@intCommodityId,NULL) InTran
			WHERE InTran.strBucketType = 'Sales In-Transit'
				AND @ysnIncludeInTransitInCompanyTitled = 1
				AND InTran.intItemId = ISNULL(@intItemId, InTran.intItemId)
				AND InTran.intLocationId = ISNULL(@intLocationId, InTran.intLocationId ) 
				AND InTran.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)


			DECLARE @Result AS TABLE (
				dtmDate  DATE  NULL
				,dblCompanyTitled  NUMERIC(18,6)
			)
			
			DECLARE @date DATE
			DECLARE @dblSalesInTransitAsOf  NUMERIC(18,6)

			--Loop through the date range to get the company title per date
			WHILE (Select Count(*) From #tempDateRange) > 0
			BEGIN

				Select Top 1 @date = Date From #tempDateRange

				SELECT @dblSalesInTransitAsOf = SUM(ISNULL(InTran.dblInTransitQty, 0))
				FROM #InTransitDateRange InTran
				WHERE InTran.dtmDate <= @date

				INSERT INTO @Result(
					dtmDate
					,dblCompanyTitled
				)
				SELECT 
					@date
					,sum(dblTotal) + isnull(@dblSalesInTransitAsOf,0)
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
				,strTransactionType
				,strDistribution
				,R.dblCompanyTitled
				,intCommodityId = @intCommodityId
			FROM @CompanyTitle CT
			FULL JOIN @Result R ON CT.dtmDate = R.dtmDate
			

			UNION ALL--Insert Company Title Beginning Balance
			SELECT
				NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
				,sum(dblTotal) 
				,NULL
			FROM @InventoryStock 
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(day,-1,@dtmFromTransactionDate))
			) t
			WHERE dblCompanyTitled IS NOT NULL 

			--=========================================================================

			drop table #LicensedLocation
			--drop table #tblGetStorageDetailByDate
			drop table #tempDateRange
			drop table #InTransitDateRange


END