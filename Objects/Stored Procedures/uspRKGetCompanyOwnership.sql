CREATE PROCEDURE [dbo].[uspRKGetCompanyOwnership]
	@dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL

AS

BEGIN

	DECLARE @intCommodityUnitMeasureId INT = NULL
			, @ysnIncludeDPPurchasesInCompanyTitled BIT
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
	
	SELECT TOP 1 @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference

	SELECT intCompanyLocationId
	INTO #LicensedLocations
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END
	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END

	DECLARE @CompanyOwnershipResult TABLE (Id INT identity(1, 1)
		, dtmDate DATETIME
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24, 10)
		, dblUnpaidOut NUMERIC(24, 10)
		, dblUnpaidBalance NUMERIC(24, 10)
		, dblPaidBalance  NUMERIC(24, 10)
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, InventoryBalanceCarryForward NUMERIC(24, 10)
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intReceiptId INT)

	DECLARE @DPTable TABLE (Id INT IDENTITY(1, 1)
		, dtmDate DATETIME
		, dblBalance NUMERIC(24, 10)
		, intStorageTypeId INT
		, strStorageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intCommodityUnitMeasureId INT
		, intTicketId INT
		, strTicketType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId INT
		, intInventoryShipmentId INT
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intStorageScheduleTypeId INT
		, intCommodityId INT
		, intCompanyLocationId INT
		, ysnDPOwnedType BIT
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS)

	IF (@ysnIncludeDPPurchasesInCompanyTitled = 1)
	BEGIN
		INSERT INTO @DPTable
		SELECT DISTINCT *
		FROM (
			SELECT CONVERT(VARCHAR(10), gh.dtmDistributionDate,110) dtmDate
				, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
				, a.intStorageTypeId
				, strStorageType = b.strStorageTypeDescription
				, i.intItemId
				, i.strItemNo
				, ium.intCommodityUnitMeasureId
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
				, a.intCommodityId
				, a.intCompanyLocationId
				, ysnDPOwnedType
				, strDistributionOption = 'DP'
			FROM tblGRStorageHistory gh
			JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			JOIN tblICItem i ON i.intItemId = a.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			LEFT JOIN tblSCTicket t ON t.intTicketId = gh.intTicketId
			WHERE ISNULL(a.strStorageType, '') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) = 0 AND ISNULL(strTicketStatus, '') <> 'V' and gh.intTransactionTypeId IN (1,3,4,5,9)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
				AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND a.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND a.intCompanyLocationId = ISNULL(@intLocationId, a.intCompanyLocationId)
				
			UNION ALL
			SELECT CONVERT(VARCHAR(10), gh.dtmDistributionDate,110) dtmDate
				, dblBalance = (CASE WHEN gh.strType ='Reduced By Inventory Shipment' OR gh.strType = 'Settlement' THEN - gh.dblUnits ELSE gh.dblUnits END)
				, a.intStorageTypeId
				, strStorageType = b.strStorageTypeDescription
				, i.intItemId
				, i.strItemNo
				, ium.intCommodityUnitMeasureId
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
				, a.intCommodityId
				, a.intCompanyLocationId
				, ysnDPOwnedType
				, strDistributionOption = 'DP'
			FROM tblGRStorageHistory gh
			JOIN tblGRCustomerStorage a ON gh.intCustomerStorageId = a.intCustomerStorageId
			JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
			JOIN tblICItem i ON i.intItemId = a.intItemId
			JOIN tblICItemUOM iuom ON i.intItemId = iuom.intItemId AND ysnStockUnit = 1
			JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = i.intCommodityId AND iuom.intUnitMeasureId = ium.intUnitMeasureId
			WHERE ISNULL(a.strStorageType,'') <> 'ITR' AND ISNULL(a.intDeliverySheetId, 0) <> 0 AND gh.intTransactionTypeId IN (1,3,4,5,9)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmHistoryDate, 110), 110) <= CONVERT(DATETIME, @dtmToTransactionDate)
				AND i.intCommodityId = ISNULL(@intCommodityId, i.intCommodityId)
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND a.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND a.intCompanyLocationId = ISNULL(@intLocationId, a.intCompanyLocationId)
		)t
	END	
	
	INSERT INTO @CompanyOwnershipResult (dblUnpaidBalance
		, InventoryBalanceCarryForward)
	SELECT SUM(dblUnpaidBalance)
		, SUM(InventoryBalanceCarryForward)
	FROM (
		SELECT SUM(dblUnpaidIn) - SUM(dblUnpaidIn - dblUnpaidOut) dblUnpaidBalance
			, (SELECT SUM(dblQty) BalanceForward
				FROM tblICInventoryTransaction it
				JOIN tblICItem i ON i.intItemId = it.intItemId AND it.intTransactionTypeId IN (4, 5, 10, 23,33, 44)
				JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId AND ISNULL(il.strDescription, '') <> 'In-Transit'
					AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				WHERE intCommodityId = @intCommodityId AND CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
					AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(i.strType, '') <> 'Other Charge'
					AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)) InventoryBalanceCarryForward
		FROM (
			SELECT dblInQty dblUnpaidIn
				, dblOutQty dblUnpaidOut
			FROM (
				SELECT DISTINCT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
					, dblUnitCost dblUnitCost1
					, ir.intInventoryReceiptItemId
					, i.strItemNo
					, ISNULL(bd.dblQtyReceived, 0) dblInQty
					, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
					, strDistributionOption
					, b.strBillId AS strReceiptNumber
					, b.intBillId AS intReceiptId
				FROM tblAPBill b
				JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
				LEFT JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId
				JOIN tblICItem i ON i.intItemId = bd.intItemId
				LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
					AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge'
					AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
					AND b.intShipToId = ISNULL(@intLocationId, b.intShipToId)
			) t
		) t2
		
		UNION ALL SELECT SUM(dblGrossUnits) AS dblUnpaidBalance
			, NULL InventoryBalanceCarryForward
		FROM tblICInventoryReceiptItem ir
		JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
		JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId
			AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		JOIN tblICItem i ON i.intItemId = ir.intItemId
		JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
		JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND ISNULL(ysnDPOwnedType, 0) = 1
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) < CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110))
			AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge' AND i.intCommodityId = @intCommodityId
			AND ir.intSubLocationId =  ISNULL(@intLocationId, ir.intSubLocationId)
	) t3
	
	INSERT INTO @CompanyOwnershipResult (strItemNo
		, dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId)
	SELECT strItemNo
		, dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidIn - dblUnpaidOut as dblUnpaidBalance
		, CASE WHEN ysnPaid = 0 AND dblUnpaidOut = 0 THEN 0 ELSE  dblUnpaidOut END  as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT *
			, ROUND(dblInQty, 2) dblUnpaidIn
			, ROUND(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				, dblUnitCost dblUnitCost1
				, iri.intInventoryReceiptItemId
				, i.strItemNo
				, ISNULL(bd.dblQtyReceived, 0) dblInQty
				, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				, st.strDistributionOption
				, b.strBillId AS strReceiptNumber
				, b.intBillId AS intReceiptId
				, b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			INNER JOIN tblICInventoryReceiptItem iri ON bd.intInventoryReceiptItemId = iri.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt ir ON iri.intInventoryReceiptId = ir.intInventoryReceiptId
			INNER JOIN tblICItem i ON i.intItemId = bd.intItemId
			INNER JOIN vyuSCTicketView st ON st.intTicketId = iri.intSourceId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge'
				AND b.intShipToId = ISNULL(@intLocationId, b.intShipToId) AND ir.intSourceType = 1
		) t
		
		--From Settle Storage
		UNION SELECT *
			, round(dblInQty, 2) dblUnpaidIn
			, round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				, grt.dblUnits dblUnitCost1
				, '' as intInventoryReceiptItemId--ir.intInventoryReceiptItemId
				, i.strItemNo
				, ISNULL(bd.dblQtyReceived, 0) dblInQty
				, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				, gs.strStorageTypeCode strDistributionOption
				, b.strBillId AS strReceiptNumber
				, b.intBillId AS intReceiptId
				, b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			INNER JOIN tblGRSettleStorage gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN tblGRCustomerStorage grs ON  grt.intCustomerStorageId = grs.intCustomerStorageId
			INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=grs.intStorageTypeId 
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110)
				AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge'
				AND b.intShipToId = ISNULL(@intLocationId, b.intShipToId)
		) t
	) t2
	
	UNION ALL SELECT i.strItemNo
		, CONVERT(VARCHAR(10), dtmTicketDateTime, 110) AS dtmDate
		, dblGrossUnits AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblGrossUnits AS dblUnpaidBalance
		, dblGrossUnits as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, ir.intInventoryReceiptId
	FROM tblICInventoryReceiptItem ir
	JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
	JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	JOIN tblICItem i ON i.intItemId = ir.intItemId
	JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND ISNULL(ysnDPOwnedType, 0) = 1
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110))
		AND i.intCommodityId = @intCommodityId AND i.intItemId = ISNULL(@intItemId, i.intItemId) AND ISNULL(strType, '') <> 'Other Charge'
		AND ir.intSubLocationId = ISNULL(@intLocationId, ir.intSubLocationId)
		AND st.strDistributionOption NOT IN ('','CNT')
	
	--IS decressing the Unpaid Balance and Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblInQty as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, SI.dblUnitPrice dblUnitCost1
			, SI.intInventoryShipmentItemId
			, I.strItemNo
			, ABS(ISNULL(SI.dblQuantity, 0)) * -1 dblInQty
			, 0 AS dblOutQty
			, CASE WHEN SI.intStorageScheduleTypeId IS NULL AND SI.intOrderId IS NULL THEN 'SPT' COLLATE Latin1_General_CI_AS WHEN SI.intOrderId IS NOT NULL THEN ST.strDistributionOption ELSE STT.strStorageTypeCode END strDistributionOption
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.strInvoiceNumber ELSE  S.strShipmentNumber END AS strReceiptNumber
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.intInvoiceId ELSE  S.intInventoryShipmentId END  AS intReceiptId
		FROM vyuSCTicketView ST
		INNER JOIN tblICInventoryShipmentItem SI ON ST.intTicketId = SI.intSourceId
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
		LEFT JOIN tblARInvoice Inv ON ID.intInvoiceId = Inv.intInvoiceId
		LEFT JOIN tblGRStorageType STT ON SI.intStorageScheduleTypeId = STT.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND SI.intOwnershipType = 1
	)t

	--IR decressing the Unpaid Balance and Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, ISNULL(RI.dblNet, 0) dblInQty
			, 0 AS dblOutQty
			, GST.strStorageTypeCode strDistributionOption
			, R.strReceiptNumber AS strReceiptNumber
			, R.intInventoryReceiptId AS intReceiptId
		FROM tblSCTicket ST
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON ST.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
			AND RI.dblBillQty = 0
			AND R.intSourceType = 1
			AND RI.intInventoryReceiptItemId NOT IN (select intInventoryReceiptItemId from tblGRSettleStorage gr 
					INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
					INNER JOIN vyuSCGetScaleDistribution sc ON  grt.intCustomerStorageId = sc.intCustomerStorageId)
	) t
	
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblAdjustmentQty as dblPaidBalance
		, 'ADJ' COLLATE Latin1_General_CI_AS as strDistributionOption
		, strAdjustmentNo as strReceiptNumber
		, intInventoryAdjustmentId as intReceiptId
	FROM (
		--Own
		SELECT CONVERT(VARCHAR(10),IT.dtmDate,110) dtmDate
			, round(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
			, IT.strTransactionId strAdjustmentNo
			, IT.intTransactionId intInventoryAdjustmentId
			, strItemNo
		FROM tblICInventoryTransaction IT
		INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId and u.ysnStockUnit=1
		INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		WHERE IT.intTransactionTypeId IN (10,15,47) AND IT.ysnIsUnposted = 0
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND IT.intItemId = ISNULL(@intItemId, IT.intItemId)
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		
		-- RM-2946 -> Do not include storage ownership type adjustments
		----Storage
		--UNION ALL SELECT CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
		--	, round(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
		--	, IA.strAdjustmentNo strAdjustmentNo
		--	, IA.intInventoryAdjustmentId intInventoryAdjustmentId
		--	, strItemNo
		--FROM tblICInventoryAdjustment IA
		--INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
		--INNER JOIN tblICItem Itm ON IAD.intItemId = Itm.intItemId
		--INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		--WHERE IAD.intOwnershipType = 2 --Storage
		--	AND IA.ysnPosted = 1
		--	AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		--	AND C.intCommodityId = @intCommodityId 
		--	AND IAD.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN IAD.intItemId ELSE @intItemId END 				
		--	AND IA.strDescription NOT LIKE ('%Delivery Sheet Posting%') -- RM-2916/RM-2917
	)a

	--Delivery Sheet
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, ISNULL(RI.dblNet, 0) - ISNULL(RI.dblBillQty,0) dblInQty
			, 0 AS dblOutQty
			, GST.strStorageTypeCode strDistributionOption
			, R.strReceiptNumber
			, R.intInventoryReceiptId
		FROM tblSCDeliverySheetSplit DSS 
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND ST.intCommodityId = @intCommodityId 
		AND ST.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
		AND ST.intProcessingLocationId = case when ISNULL(@intLocationId,0)=0 then ST.intProcessingLocationId else @intLocationId end 
		AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		AND RI.intOwnershipType = 1
		AND R.intSourceType = 1
		AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
		--AND RI.dblBillQty = 0
	)t

	--Delivery Sheet With Voucher
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, ISNULL(BD.dblQtyReceived, 0) dblInQty
			, 0 AS dblOutQty
			, GST.strStorageTypeCode strDistributionOption
			, Bill.strBillId AS strReceiptNumber
			, Bill.intBillId AS intReceiptId
		FROM tblSCDeliverySheetSplit DSS 
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		INNER JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
		INNER JOIN tblAPBill Bill ON BD.intBillId = Bill.intBillId
		WHERE ST.strTicketStatus = 'C'
		AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
		AND ST.intCommodityId = @intCommodityId 
		AND ST.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
		AND ST.intProcessingLocationId = case when ISNULL(@intLocationId,0)=0 then ST.intProcessingLocationId else @intLocationId end 
		AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		AND RI.intOwnershipType = 1
		AND R.intSourceType = 1
		AND Bill.ysnPosted = 1
		AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = NULL)--Contract, Spot and DP
		AND RI.dblBillQty <> 0
	)t

	--Direct from Invoice
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, ABS(dblInQty) + ABS(ISNULL(dblOutQty, 0)) * -1 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
			, 0 dblUnitCost1
			, I.intInvoiceId intInventoryReceiptItemId
			, Itm.strItemNo
			, CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(ID.dblQtyShipped, 0) ELSE 0.0  END dblInQty
			, CASE WHEN I.strTransactionType = 'Credit Memo' THEN 0.0 ELSE ISNULL(ID.dblQtyShipped, 0)  END dblOutQty
			, '' strDistributionOption
			, I.strInvoiceNumber AS strReceiptNumber
			, I.intInvoiceId AS intReceiptId
		FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		WHERE I.ysnPosted = 1
			AND ID.intInventoryShipmentItemId IS NULL
			AND ISNULL(ID.strShipmentNumber,'') = ''
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND ID.intItemId = CASE WHEN ISNULL(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
			AND I.intCompanyLocationId = case when ISNULL(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
			AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	)t

	--Direct Inventory Shipment (This will show the Invoice Number once Shipment is invoiced)
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblInQty as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryShipmentItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), S.dtmShipDate, 110) dtmDate
			, SI.dblUnitPrice dblUnitCost1
			, SI.intInventoryShipmentItemId
			, Itm.strItemNo
			, ABS(ISNULL(SI.dblQuantity, 0)) * -1 dblInQty
			, 0 AS dblOutQty
			, '' strDistributionOption
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.strInvoiceNumber ELSE  S.strShipmentNumber END AS strReceiptNumber
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.intInvoiceId ELSE  S.intInventoryShipmentId END  AS intReceiptId
		FROM tblICInventoryShipmentItem SI 
		INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
		INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId AND ID.intInventoryShipmentItemId IS NOT NULL
		LEFT JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
		WHERE S.ysnPosted = 1
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
			AND S.intShipFromLocationId = ISNULL(@intLocationId, S.intShipFromLocationId)
			AND S.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND SI.intOwnershipType = 1
			AND S.intSourceType = 0
	) t

	--Direct Inventory Receipt (This will show the Bill Number once Receipt is vouchered)
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), R.dtmReceiptDate, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, Itm.strItemNo
			, ISNULL(RI.dblOpenReceive, 0) dblInQty
			, 0 AS dblOutQty
			, '' strDistributionOption
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.strBillId ELSE  R.strReceiptNumber END AS strReceiptNumber
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.intBillId ELSE  R.intInventoryReceiptId END  AS intReceiptId
		FROM tblICInventoryReceiptItem RI 
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId AND BD.intInventoryReceiptItemId IS NOT NULL
		LEFT JOIN tblAPBill B ON BD.intBillId = B.intBillId
		WHERE R.ysnPosted = 1
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
			AND R.intLocationId = ISNULL(@intLocationId, R.intLocationId)
			AND R.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 0
	) t

	--DP with Settle Storage
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CASE WHEN SS.intBillId IS NULL THEN CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) ELSE CONVERT(VARCHAR(10), SS.dtmCreated, 110) END dtmDate
			, RI.dblUnitCost dblUnitCost1
			, intCustomerStorageId as intInventoryReceiptItemId
			, I.strItemNo
			, CASE WHEN SS.intBillId IS NULL THEN ISNULL(RI.dblNet, 0) ELSE SS.dblOpenBalance END dblInQty
			, 0 AS dblOutQty
			, ST.strDistributionOption
			, CASE WHEN SS.strStorageTicketNumber IS NULL THEN R.strReceiptNumber ELSE  SS.strStorageTicketNumber END AS strReceiptNumber
			, CASE WHEN SS.intCustomerStorageId IS NULL THEN R.intInventoryReceiptId ELSE SS.intCustomerStorageId END AS intReceiptId
		FROM vyuSCTicketView ST
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		CROSS APPLY (
			SELECT dblSettleUnits
				, gr.dtmCreated
				, cs.intCustomerStorageId
				, cs.strStorageTicketNumber
				, intBillId
				, cs.dblOpenBalance
			FROM tblGRSettleStorage gr
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN vyuSCGetScaleDistribution sd ON  grt.intCustomerStorageId = sd.intCustomerStorageId
			INNER JOIN tblGRCustomerStorage cs ON sd.intCustomerStorageId = cs.intCustomerStorageId
			where sd.intInventoryReceiptItemId = RI.intInventoryReceiptItemId and intBillId IS NOT NULL
		) SS
		WHERE ST.strTicketStatus = 'C'
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND ST.strDistributionOption = 'DP'
			AND SS.dblOpenBalance <> 0
	) t

	-- DP Table
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblUnpaidIn = SUM(dblTotal)
		, dblUnpaidOut = 0.00
		, dblUnpaidBalance = SUM(dblTotal)
		, dblPaidBalance = 0.00
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId = intInventoryReceiptId
	FROM (
		SELECT intTicketId
			, strTicketType
			, strTicketNumber
			, dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, (ISNULL(dblBalance,0)))
			, intFromCommodityUnitMeasureId = intCommodityUnitMeasureId
			, dtmDate
			, intItemId
			, strItemNo
			, intCompanyLocationId
			, strDistributionOption
			, strReceiptNumber
			, intInventoryReceiptId
		FROM @DPTable ch
		WHERE ch.intCommodityId  = @intCommodityId
			AND ysnDPOwnedType = 1
			AND ch.intCompanyLocationId = ISNULL(@intLocationId, ch.intCompanyLocationId)
		)t 	WHERE intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	GROUP BY strItemNo
		, dtmDate
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptId

	SELECT DISTINCT dtmDate = ISNULL(dtmDate,'')
		, strItemNo
		, strDistribution = strDistributionOption
		, dblUnpaidIN = dblUnpaidIn
		, dblUnpaidOut = dblUnpaidOut
		, dblUnpaidBalance = dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward = InventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM @CompanyOwnershipResult T1
	ORDER BY dtmDate DESC
		, strReceiptNumber DESC

	DROP TABLE #LicensedLocations
END
