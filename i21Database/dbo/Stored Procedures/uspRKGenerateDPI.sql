CREATE PROCEDURE [dbo].[uspRKGenerateDPI]
	@dtmFromTransactionDate DATE = null
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = null
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL
	, @GUID UNIQUEIDENTIFIER = NULL

AS

BEGIN
	DECLARE @intDPIHeaderId INT
	SELECT intCompanyLocationId
	INTO #LicensedLocations
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END
	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END

	SELECT TOP 1 @intDPIHeaderId = intDPIHeaderId FROM tblRKDPIHeader WHERE imgReportId = @GUID
	IF ISNULL(@intDPIHeaderId, 0) = 0
	BEGIN
		INSERT INTO tblRKDPIHeader(imgReportId
			, strPositionIncludes
			, dtmStartDate
			, dtmEndDate
			, intCommodityId
			, intItemId
			, intLocationId)
		VALUES (@GUID
			, @strPositionIncludes
			, @dtmFromTransactionDate
			, @dtmToTransactionDate
			, @intCommodityId
			, @intItemId
			, @intLocationId)

		SET @intDPIHeaderId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE tblRKDPIHeader
		SET strPositionIncludes = @strPositionIncludes
			, dtmStartDate = @dtmFromTransactionDate
			, dtmEndDate = @dtmToTransactionDate
			, intCommodityId = @intCommodityId
			, intItemId = @intItemId
			, intLocationId = @intItemId
		WHERE intDPIHeaderId = @intDPIHeaderId

		DELETE FROM tblRKDPISummary WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPIInventory WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPICompanyOwnership WHERE intDPIHeaderId = @intDPIHeaderId
	END

	------------------------------------
	---- Generate Company Ownership ----
	------------------------------------
	DECLARE @dtmOrigFromTransactionDate DATETIME

	--Grab the original start date AND assinged to a varialbe to be used laster on.
	SET @dtmOrigFromTransactionDate = @dtmFromTransactionDate
	--Set the Start date as the beggining date "1900"
	SET @dtmFromTransactionDate = '1900-01-01 00:00:00'
	
	DECLARE @intCommodityUnitMeasureId INT = NULL
			, @ysnIncludeDPPurchasesInCompanyTitled BIT
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
	
	SELECT TOP 1 @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference

	SELECT strItemNo
		, dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance = dblUnpaidIn - dblUnpaidOut
		, dblPaidBalance = (CASE WHEN ysnPaid = 0 AND dblUnpaidOut = 0 THEN 0 ELSE dblUnpaidOut END)
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	INTO #tempResult
	FROM (
		--From Settle Storage
		SELECT *
			, ROUND(dblInQty, 2) dblUnpaidIn
			, ROUND(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT dtmDate = CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110)
				, dblUnitCost1 = gr.dblUnits
				, intInventoryReceiptItemId = ''
				, i.strItemNo
				, dblInQty = ISNULL(bd.dblQtyReceived, 0)
				, dblOutQty = (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue)
				, strDistributionOption = gs.strStorageTypeCode
				, strReceiptNumber = b.strBillId
				, intReceiptId = b.intBillId
				, b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			INNER JOIN tblGRStorageHistory gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRCustomerStorage grs ON gr.intCustomerStorageId = grs.intCustomerStorageId
			INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=grs.intStorageTypeId 
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110)
				AND i.intCommodityId = @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND ISNULL(i.strType, '') <> 'Other Charge'
				AND b.intShipToId = ISNULL(@intLocationId, b.intShipToId)
				AND gs.strStorageTypeCode NOT IN ('CNT', CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 'DP' ELSE '' END)
		) t
	) t2
	
	UNION ALL SELECT i.strItemNo
		, dtmDate = CONVERT(VARCHAR(10), dtmTicketDateTime, 110)
		, dblUnpaidIn = dblGrossUnits
		, dblUnpaidOut = 0
		, dblUnpaidBalance = dblGrossUnits
		, dblPaidBalance = dblGrossUnits
		, strDistributionOption 
		, r.strReceiptNumber
		, r.intInventoryReceiptId
	FROM tblICInventoryReceiptItem ir
	JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
	JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	JOIN tblICItem i ON i.intItemId = ir.intItemId
	JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND ISNULL(ysnDPOwnedType, 0) = 1
	WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110))
		AND i.intCommodityId = @intCommodityId
		AND i.intItemId = ISNULL(@intItemId, i.intItemId)
		AND ISNULL(strType, '') <> 'Other Charge'
		AND ir.intSubLocationId = ISNULL(@intLocationId, ir.intSubLocationId)
		AND st.strDistributionOption NOT IN ('CNT', CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 'DP' ELSE '' END)
	
	--IS decressing the Unpaid Balance AND Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblUnpaidIn = 0
		, dblUnpaidOut = 0
		, dblUnpaidBalance = 0
		, dblPaidBalance = dblInQty
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, SI.dblUnitPrice dblUnitCost1
			, SI.intInventoryShipmentItemId
			, I.strItemNo
			, ABS(ISNULL(SI.dblQuantity, 0)) * -1 dblInQty
			, dblOutQty = 0
			, strDistributionOption = CASE WHEN SI.intStorageScheduleTypeId IS NULL AND SI.intOrderId IS NULL THEN 'SPT' COLLATE Latin1_General_CI_AS WHEN SI.intOrderId IS NOT NULL THEN ST.strDistributionOption ELSE STT.strStorageTypeCode END
			, strReceiptNumber = CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.strInvoiceNumber ELSE S.strShipmentNumber END
			, intReceiptId = CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN Inv.intInvoiceId ELSE S.intInventoryShipmentId END
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

	--IR decressing the Unpaid Balance AND Company Owned
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, dblUnitCost1 = RI.dblUnitCost
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, dblInQty = ISNULL(RI.dblNet, 0)
			, dblOutQty = 0
			, strDistributionOption = GST.strStorageTypeCode
			, strReceiptNumber = R.strReceiptNumber
			, intReceiptId = R.intInventoryReceiptId
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
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot AND DP
			AND RI.dblBillQty = 0
			AND R.intSourceType = 1
			AND RI.intInventoryReceiptItemId NOT IN (SELECT intInventoryReceiptItemId FROM tblGRSettleStorage gr
													INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
													INNER JOIN vyuSCGetScaleDistribution sc ON grt.intCustomerStorageId = sc.intCustomerStorageId)
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
			, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
			, IT.strTransactionId strAdjustmentNo
			, IT.intTransactionId intInventoryAdjustmentId
			, strItemNo
		FROM tblICInventoryTransaction IT
		INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId AND u.ysnStockUnit=1
		INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		WHERE IT.intTransactionTypeId IN (10,15,47) AND IT.ysnIsUnposted = 0
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND IT.intItemId = ISNULL(@intItemId, IT.intItemId)
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
	)a

	--Inventory Transfers
	UNION ALL SELECT strItemNo
		, dtmDate
		, 0 AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, dblTransferQty as dblPaidBalance
		, '' COLLATE Latin1_General_CI_AS as strDistributionOption
		, strTransactionId as strReceiptNumber
		, intTransactionId as intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
			, dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(SUM(it.dblQty),0)) dblTransferQty
			, it.intTransactionId
			, i.strItemNo
			, it.strTransactionId
		FROM tblICInventoryTransaction it 
		JOIN tblICItem i on i.intItemId=it.intItemId AND it.ysnIsUnposted=0 AND it.intTransactionTypeId in(12)
		JOIN tblICItemUOM u on it.intItemId=u.intItemId AND u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId 
		JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND ISNULL(il.strDescription,'') <> 'In-Transit'
		WHERE i.intCommodityId=@intCommodityId 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		GROUP BY dtmDate, strItemNo, it.intTransactionId, it.strTransactionId, intCommodityUnitMeasureId
	)a WHERE dblTransferQty <> 0

	--Delivery Sheet
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblInQty AS dblUnpaidBalance
		, 0 as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptId
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
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot AND DP
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
		, intReceiptId
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
			AND ST.intItemId = ISNULL(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = ISNULL(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND Bill.ysnPosted = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot AND DP
			AND RI.dblBillQty <> 0
	)t

	--Direct from Invoice
	UNION ALL SELECT strItemNo
		, dtmDate
		, dblInQty AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, 0 AS dblUnpaidBalance
		, ABS(dblInQty) + ABS(ISNULL(dblOutQty, 0)) * CASE WHEN dblOutQty < 0 THEN 1 ELSE -1 END as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
			, 0 dblUnitCost1
			, I.intInvoiceId intInventoryReceiptItemId
			, Itm.strItemNo
			, CASE WHEN I.strTransactionType = 'Credit Memo' THEN ISNULL(ID.dblQtyShipped, 0) ELSE 0.0 END dblInQty
			, CASE WHEN I.strTransactionType = 'Credit Memo' THEN 0.0 ELSE ISNULL(ID.dblQtyShipped, 0) END dblOutQty
			, '' strDistributionOption
			, I.strInvoiceNumber AS strReceiptNumber
			, I.intInvoiceId AS intReceiptId
		FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblICItemLocation ItmLoc ON Itm.intItemId = ItmLoc.intItemId AND I.intCompanyLocationId = ItmLoc.intLocationId
		WHERE I.ysnPosted = 1
			AND ID.intInventoryShipmentItemId IS NULL
			AND ID.intInventoryShipmentChargeId IS NULL
			AND Itm.strType IN ('Inventory', 'Raw Material', 'Finished Good')
			AND I.strTransactionType NOT IN ('Customer Prepayment')
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND ID.intItemId = ISNULL(@intItemId, ID.intItemId)
			AND I.intCompanyLocationId = ISNULL(@intLocationId, I.intCompanyLocationId)
			AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND (( (ID.[dblTotal] <> 0 OR dbo.fnGetItemAverageCost(ID.[intItemId], ItmLoc.[intItemLocationId], ID.[intItemUOMId]) <> 0)) ) 
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
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.strInvoiceNumber ELSE S.strShipmentNumber END AS strReceiptNumber
			, CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.intInvoiceId ELSE S.intInventoryShipmentId END AS intReceiptId
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
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.strBillId ELSE R.strReceiptNumber END AS strReceiptNumber
			, CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.intBillId ELSE R.intInventoryReceiptId END AS intReceiptId
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
		SELECT CONVERT(VARCHAR(10),SH.dtmDistributionDate,110) dtmDate
			, S.strStorageTypeCode strDistributionOption
			, 0 AS dblOutQty
			, CASE WHEN SH.strType = 'Settlement' THEN ABS(dblUnits)
					WHEN SH.strType = 'Reverse Settlement' THEN ABS(dblUnits) * -1
					ELSE 0 END AS dblInQty
			, S.intStorageScheduleTypeId
			, SH.intSettleStorageId as intInventoryReceiptItemId
			, SH.strSettleTicket as strReceiptNumber
			, I.strItemNo
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
		INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
		INNER JOIN tblICItem I ON CS.intItemId = I.intItemId
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmDistributionDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND CS.intCommodityId = @intCommodityId
			AND CS.intItemId = ISNULL(@intItemId, CS.intItemId)
			AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
			AND SH.strType IN ('Settlement','Reverse Settlement')
			AND S.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN NULL ELSE 1 END
			AND SH.intBillId IS NULL
	) t

	----Get Balance Forward
	--INSERT INTO @tblResult (dblUnpaidBalance
	--	, InventoryBalanceCarryForward)
	--select SUM(dblUnpaidBalance), SUM(dblPaidBalance) from #tempResult WHERE dtmDate < @dtmOrigFromTransactionDate

	INSERT INTO tblRKDPICompanyOwnership(intDPIHeaderId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId)
	SELECT @intDPIHeaderId
		, dtmDate = ISNULL(dtmDate,'')
		, strDistribution = strDistributionOption
		, dblUnpaidIN = dblUnpaidIn
		, dblUnpaidOut = dblUnpaidOut
		, dblUnpaidBalance = dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward = InventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM #tempResult T1
	WHERE dtmDate BETWEEN @dtmOrigFromTransactionDate AND @dtmToTransactionDate
	ORDER BY intRowNum
		, dtmDate DESC
		, strReceiptNumber DESC

	SET @dtmFromTransactionDate = @dtmOrigFromTransactionDate
	
	--------------------------------------------
	---- Generate Inventory Balance Headers ----
	--------------------------------------------
	DECLARE @tblDateList TABLE (Id INT IDENTITY
		, DateData DATETIME)

	DECLARE @StartDateTime DATETIME
		, @EndDateTime DATETIME

	SET @StartDateTime = @dtmFromTransactionDate
	SET @EndDateTime = @dtmToTransactionDate;

	WITH DateRange(DateData) AS (
		SELECT @StartDateTime AS DATE
		UNION ALL
		SELECT DATEADD(d,1,DateData)
		FROM DateRange 
		WHERE DateData < @EndDateTime
	)
	INSERT INTO @tblDateList(DateData)
	SELECT DateData FROM DateRange
	OPTION (MAXRECURSION 0)

	DECLARE @tblResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, [Distribution] nvarchar(50) COLLATE Latin1_General_CI_AS
		, [Unpaid IN] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, [InventoryBalanceCarryForward] NUMERIC(24,10)
		, strReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, intReceiptId int)

	DECLARE @tblFirstResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, tranShipQty NUMERIC(24,10)
		, tranRecQty NUMERIC(24,10)
		, dblAdjustmentQty NUMERIC(24,10)
		, dblCountQty NUMERIC(24,10)
		, dblInvoiceQty NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	DECLARE @tblResultFinal TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, dblUnpaidBalance NUMERIC(24,10)
		, dblPaidBalance NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10))

	-- Customer Ownership
	EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	-- Company ownershiip
	INSERT INTO @tblResult (intRowNum
		, dtmDate
		, [Distribution]
		, [Unpaid IN]
		, [Unpaid Out]
		, [Unpaid Balance]
		, [Paid Balance]
		, InventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId)
	SELECT intDPICompanyOwnershipId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM tblRKDPICompanyOwnership
	WHERE intDPIHeaderId = @intDPIHeaderId

	INSERT INTO @tblFirstResult (dtmDate
		, tranShipQty
		, tranRecQty
		, dblAdjustmentQty
		, dblCountQty
		, dblInvoiceQty
		, BalanceForward
		, dblSalesInTransit
		, tranDSInQty)
	EXEC uspRKGetInventoryBalance @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	INSERT INTO @tblResultFinal (dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, BalanceForward
		, dblUnpaidBalance
		, dblPaidBalance
		, InventoryBalanceCarryForward)
	SELECT dtmDate
		, SUM([Unpaid IN]) tranRecQty
		, SUM([Unpaid Out]) tranShipQty
		, SUM([Unpaid Balance]) dblUnpaidBalance
		, (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(T1.dtmDate,'01/01/1900')) AS [Unpaid Balance]
		, SUM(T1.[Paid Balance]) dblPaidBalance
		, SUM(InventoryBalanceCarryForward) InventoryBalanceCarryForward
	FROM @tblResult T1 
	GROUP BY dtmDate

	DECLARE @tblConsolidatedResult TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, [Receive In] NUMERIC(24,10)
		, [Ship Out] NUMERIC(24,10)
		, [Adjustments] NUMERIC(24,10)
		, [dblCount] NUMERIC(24,10)
		, [dblInvoiceQty] NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10)
		, [Unpaid In] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, [Balance] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	INSERT INTO @tblConsolidatedResult (dtmDate
		, [Receive In]
		, [Ship Out]
		, [Adjustments]
		, dblCount
		, dblInvoiceQty
		, BalanceForward
		, InventoryBalanceCarryForward
		, [Unpaid In]
		, [Unpaid Out]
		, [Balance]
		, [Unpaid Balance]
		, [Paid Balance]
		, dblSalesInTransit
		, tranDSInQty)
	SELECT ISNULL(a.dtmDate,b.dtmDate) [Date]
		, ISNULL(a.tranRecQty, 0) [Receive In]
		, ISNULL(a.tranShipQty, 0) [Ship Out]
		, ISNULL(dblAdjustmentQty, 0) [Adjustments]
		, ISNULL(dblCountQty, 0) as dblCount
		, ISNULL(dblInvoiceQty, 0) dblInvoiceQty
		, ISNULL(a.BalanceForward, 0) BalanceForward
		, ISNULL(b.InventoryBalanceCarryForward, 0)
		, ISNULL(b.dblUnpaidIn, 0) [Unpaid In]
		, ISNULL(b.dblUnpaidOut, 0) [Unpaid Out]
		, ISNULL(b.dblUnpaidBalance, 0) as [Balance1]
		, null [Unpaid Balance] 
		, ISNULL(b.dblPaidBalance, 0) + ISNULL(b.InventoryBalanceCarryForward, 0)
		, a.dblSalesInTransit
		, a.tranDSInQty
	FROM @tblFirstResult a
	FULL JOIN @tblResultFinal b on a.dtmDate = b.dtmDate ORDER BY b.dtmDate, a.dtmDate asc

	SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
		, *
	INTO #final
	FROM (
		SELECT DISTINCT dtmDate
			, [Receive In] + ISNULL(tranDSInQty, 0) as [dblReceiveIn]
			, ISNULL([Ship Out], 0) as [dblShipOut]
			, Adjustments as dblAdjustments
			, dblCount,dblInvoiceQty
			, ISNULL([InventoryBalance], 0) as [dblInventoryBalance]
			, [Unpaid In] as dblUnpaidIn
			, [Unpaid Out] dblUnpaidOut
			, [Balance] dblBalance
			, ISNULL([Paid Balance], 0) [dblPaidBalance]
			, [dblTotalCompanyOwned]
			, ISNULL(ISNULL([Unpaid In], 0)-ISNULL([Unpaid Out], 0), 0) dblUnpaidBalance
			, dblSalesInTransit
		FROM (
			SELECT dtmDate
				, [Receive In]
				, tranDSInQty
				, [Ship Out]
				, [Adjustments]
				, dblCount
				, dblInvoiceQty
				, BalanceForward
				, InventoryBalanceCarryForward
				, (SELECT SUM(BalanceForward) + SUM(ISNULL(tranDSInQty, 0)) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900')) AS [InventoryBalance]
				, (CASE WHEN ISNULL([Unpaid In], 0)=0 AND ISNULL([Unpaid Out], 0)=0 then
							  (SELECT top 1 Balance FROM @tblConsolidatedResult AS T2 WHERE Balance > 0 AND ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900') order by ISNULL(T2.dtmDate,'01/01/1900') desc) 
					ELSE [Balance] END) [Balance]
				, [Unpaid In]
				, [Unpaid Out]
				, (SELECT SUM([Paid Balance]) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900'))[Paid Balance] 
				, dblSalesInTransit
				, (SELECT SUM([Paid Balance]) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900')) [dblTotalCompanyOwned]
			FROM (
				SELECT DateData dtmDate
					, [Receive In]
					, tranDSInQty
					, [Ship Out]
					, [Adjustments]
					, dblCount
					, dblInvoiceQty
					, BalanceForward
					, InventoryBalanceCarryForward
					, [Unpaid In]
					, [Unpaid Out]
					, [Balance]
					, [Paid Balance]
					, T1.dblSalesInTransit
				FROM @tblConsolidatedResult T1
				FULL JOIN @tblDateList list on T1.dtmDate=list.DateData
			)t 
		)t1
	)t2 ORDER BY dtmDate

	INSERT INTO tblRKDPISummary(intDPIHeaderId
		, dtmTransactionDate
		, dblReceiveIn
		, dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance
		, dblSalesInTransit
		, strDistributionA
		, dblAIn
		, dblAOut
		, dblANet
		, strDistributionB
		, dblBIn
		, dblBOut
		, dblBNet
		, strDistributionC
		, dblCIn
		, dblCOut
		, dblCNet
		, strDistributionD
		, dblDIn
		, dblDOut
		, dblDNet
		, strDistributionE
		, dblEIn
		, dblEOut
		, dblENet
		, strDistributionF
		, dblFIn
		, dblFOut
		, dblFNet
		, strDistributionG
		, dblGIn
		, dblGOut
		, dblGNet
		, strDistributionH
		, dblHIn
		, dblHOut
		, dblHNet
		, strDistributionI
		, dblIIn
		, dblIOut
		, dblINet
		, strDistributionJ
		, dblJIn
		, dblJOut
		, dblJNet
		, strDistributionK
		, dblKIn
		, dblKOut
		, dblKNet
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, dblPaidBalance
		, dblTotalCompanyOwned
		, dblUnpaidBalance)
	SELECT @intDPIHeaderId
		, dtmDate
		, dblReceiveIn
		, dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance
		, dblSalesInTransit
		, strDistributionA,[dblAIn],[dblAOut], [dblANet]
		, strDistributionB,[dblBIn],[dblBOut], [dblBNet]
		, strDistributionC,[dblCIn],[dblCOut], [dblCNet]
		, strDistributionD,[dblDIn],[dblDOut], [dblDNet]
		, strDistributionE,[dblEIn],[dblEOut], [dblENet]
		, strDistributionF,[dblFIn],[dblFOut], [dblFNet]
		, strDistributionG,[dblGIn],[dblGOut], [dblGNet]
		, strDistributionH,[dblHIn],[dblHOut], [dblHNet]
		, strDistributionI,[dblIIn],[dblIOut], [dblINet]
		, strDistributionJ,[dblJIn],[dblJOut], [dblJNet]
		, strDistributionK,[dblKIn],[dblKOut], [dblKNet]
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, ISNULL(dblPaidBalance, 0) dblPaidBalance
		, (ISNULL(dblBalance, 0) + ISNULL(dblTotalCompanyOwned, 0)) dblTotalCompanyOwned
		, dblUnpaidBalance
	FROM (
		SELECT intRowNum
			, list.dtmDate dtmDate
			, dblReceiveIn
			, abs(dblShipOut) dblShipOut
			, dblAdjustments
			, dblCount
			, dblInvoiceQty
			, dblInventoryBalance
			, abs(ISNULL(list.dblSalesInTransit, 0)) dblSalesInTransit
			, (CASE WHEN strDistributionA is null then (SELECT DISTINCT TOP 1 strDistributionA FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionA,'') <>'') else strDistributionA end) strDistributionA
			, [dblAIn],[dblAOut],(SELECT SUM(dblANet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblANet]
			, (CASE WHEN strDistributionB is null then (SELECT DISTINCT TOP 1 strDistributionB FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionB,'') <>'') else strDistributionB end) strDistributionB
			, [dblBIn],[dblBOut],(SELECT SUM(dblBNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblBNet]
			, (CASE WHEN strDistributionC is null then (SELECT DISTINCT TOP 1 strDistributionC FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionC,'') <>'') else strDistributionC end) strDistributionC
			, [dblCIn],[dblCOut],(SELECT SUM(dblCNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblCNet]
			, (CASE WHEN strDistributionD is null then (SELECT DISTINCT TOP 1 strDistributionD FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionD,'') <>'') else strDistributionD end) strDistributionD
			, [dblDIn],[dblDOut],(SELECT SUM(dblDNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblDNet]
			, (CASE WHEN strDistributionE is null then (SELECT DISTINCT TOP 1 strDistributionE FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionE,'') <>'') else strDistributionE end) strDistributionE
			, [dblEIn],[dblEOut],(SELECT SUM(dblENet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblENet]
			, (CASE WHEN strDistributionF is null then (SELECT DISTINCT TOP 1 strDistributionF FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionF,'') <>'') else strDistributionF end) strDistributionF
			, [dblFIn],[dblFOut],(SELECT SUM(dblFNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblFNet]
			, (CASE WHEN strDistributionG is null then (SELECT DISTINCT TOP 1 strDistributionG FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionG,'') <>'') else strDistributionG end) strDistributionG
			, [dblGIn],[dblGOut],(SELECT SUM(dblGNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblGNet]
			, (CASE WHEN strDistributionH is null then (SELECT DISTINCT TOP 1 strDistributionH FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionH,'') <>'') else strDistributionH end) strDistributionH
			, [dblHIn],[dblHOut],(SELECT SUM(dblHNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblHNet]
			, (CASE WHEN strDistributionI is null then (SELECT DISTINCT TOP 1 strDistributionI FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionI,'') <>'') else strDistributionI end) strDistributionI
			, [dblIIn],[dblIOut],(SELECT SUM(dblINet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblINet]
			, (CASE WHEN strDistributionJ is null then (SELECT DISTINCT TOP 1 strDistributionJ FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionJ,'') <>'') else strDistributionJ end) strDistributionJ
			, [dblJIn],[dblJOut],(SELECT SUM(dblJNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblJNet]
			, (CASE WHEN strDistributionK is null then (SELECT DISTINCT TOP 1 strDistributionK FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionK,'') <>'') else strDistributionK end) strDistributionK
			, [dblKIn],[dblKOut],(SELECT SUM(dblKNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblKNet]
			, dblUnpaidIn
			, dblUnpaidOut
			, dblBalance
			, dblPaidBalance
			, dblTotalCompanyOwned
			, dblUnpaidBalance
		FROM #final list
		FULL JOIN tblRKDailyPositionForCustomer t ON ISNULL(t.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
	)t 
	ORDER BY dtmDate

	----------------------------------
	---- Generate Grain Inventory ----
	----------------------------------
	DECLARE @tblInvResult TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, tranShipmentNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, tranShipQty NUMERIC(24,10)
		, tranReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, tranRecQty NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, tranAdjNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblAdjustmentQty NUMERIC(24,10)
		, tranInvoiceNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblInvoiceQty NUMERIC(24,10)
		, tranCountNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblCountQty NUMERIC(24,10)
		, strDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
		, strShipDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
		, strAdjDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
		, strCountDistributionOption nvarchar(50) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId int
		, intInventoryShipmentId int
		, intInventoryAdjustmentId int
		, intInventoryCountId int
		, intInvoiceId int
		, intDeliverySheetId int
		, deliverySheetNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, intTicketId int
		, ticketNumber nvarchar(50) COLLATE Latin1_General_CI_AS)

	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END
	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END

	INSERT INTO @tblInvResult(dtmDate
		, strDistributionOption
		, strShipDistributionOption
		, strAdjDistributionOption
		, strCountDistributionOption
		, tranShipmentNumber
		, tranShipQty
		, tranReceiptNumber
		, tranRecQty
		, tranAdjNumber
		, dblAdjustmentQty
		, tranCountNumber
		, dblCountQty
		, tranInvoiceNumber
		, dblInvoiceQty
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, deliverySheetNumber
		, intTicketId
		, ticketNumber
		, BalanceForward)
	SELECT *
		, ROUND(ISNULL(tranShipQty,0)+ISNULL(tranRecQty,0)+ISNULL(dblAdjustmentQty,0)+ISNULL(dblCountQty,0),6) BalanceForward
	FROM (
		SELECT dtmDate
			, strDistributionOption strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' tranShipmentNumber
			, 0.0 tranShipQty
			, strReceiptNumber tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intInventoryReceiptId
			, null intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN ri.dblOpenReceive ELSE 0 END) ,6) dblInQty
				, r.strReceiptNumber
				, strDistributionOption
				, r.intInventoryReceiptId
			FROM tblSCTicket st
			JOIN tblICItem i on i.intItemId=st.intItemId 
			JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
			JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=st.intStorageScheduleTypeId 
			JOIN tblICItemUOM u on st.intItemId=u.intItemId AND u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId = @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND ISNULL(strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				AND r.intSourceType = 1 AND st.intDeliverySheetId IS NULL
		) a
	
		UNION ALL --Delivery Sheet
		SELECT dtmDate,strDistributionOption strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' tranShipmentNumber
			, 0.0 tranShipQty
			, strReceiptNumber tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intInventoryReceiptId
			, null intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='I' THEN ri.dblOpenReceive ELSE 0 END) ,6) dblInQty
				, r.strReceiptNumber
				, gs.strStorageTypeCode strDistributionOption
				, r.intInventoryReceiptId
			FROM vyuSCTicketView st
			JOIN tblICItem i on i.intItemId=st.intItemId
			JOIN tblICInventoryReceiptItem ri on ri.intSourceId=st.intTicketId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			JOIN tblICInventoryReceipt r on r.intInventoryReceiptId=ri.intInventoryReceiptId
			JOIN tblGRStorageHistory gsh on gsh.intInventoryReceiptId = r.intInventoryReceiptId
			JOIN tblGRCustomerStorage gh on gh.intCustomerStorageId = gsh.intCustomerStorageId
			JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId = gh.intStorageTypeId 
			JOIN tblICItemUOM u on st.intItemId=u.intItemId AND u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=1 AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId= @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND ISNULL(i.strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
				AND r.intSourceType = 1 AND st.intDeliverySheetId IS NOT NULL
		) a

		UNION ALL --Inventory Adjustments
		SELECT dtmDate
			, '' strDistributionOption
			, '' strShipDistributionOption
			, 'ADJ' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' tranShipmentNumber
			, 0.0 tranShipQty
			, '' tranReceiptNumber
			, 0.0 tranRecQty
			, strAdjustmentNo tranAdjNumber
			, dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, null intInventoryReceiptId
			, null intInventoryShipmentId
			, intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			--Own
			SELECT CONVERT(VARCHAR(10),IT.dtmDate,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,IT.dblQty) ,6) dblAdjustmentQty
				, IT.strTransactionId strAdjustmentNo
				, IT.intTransactionId intInventoryAdjustmentId
			FROM tblICInventoryTransaction IT
			INNER JOIN tblICItem Itm ON IT.intItemId = Itm.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId AND u.ysnStockUnit=1
			INNER JOIN tblICItemLocation il on IT.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			WHERE IT.intTransactionTypeId IN (10,15,47)
				AND IT.ysnIsUnposted = 0
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId 
				AND IT.intItemId = ISNULL(@intItemId, IT.intItemId)
				AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
		
			--Storage
			UNION ALL SELECT CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
				, ROUND(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
				, IA.strAdjustmentNo strAdjustmentNo
				, IA.intInventoryAdjustmentId intInventoryAdjustmentId
			FROM tblICInventoryAdjustment IA
			INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
			INNER JOIN tblICItem Itm ON IAD.intItemId = Itm.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			WHERE IAD.intOwnershipType = 2 --Storage
				AND IA.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId 
				AND IAD.intItemId = ISNULL(@intItemId, IAD.intItemId)
				AND IA.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		) a
	
		UNION SELECT dtmDate
			, '' strDistributionOption
			, strDistributionOption strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, strShipmentNumber tranShipmentNumber
			, dblOutQty tranShipQty
			, '' tranReceiptNumber
			, 0.0 tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, null intInventoryReceiptId
			, intInventoryShipmentId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,CASE WHEN strInOutFlag='O' THEN ri.dblQuantity ELSE 0 END) ,6) dblOutQty
				, r.strShipmentNumber
				, CASE WHEN ri.intStorageScheduleTypeId IS NULL AND ri.intOrderId IS NULL THEN 'SPT' WHEN ri.intOrderId IS NOT NULL THEN st.strDistributionOption ELSE gs.strStorageTypeCode END strDistributionOption,r.intInventoryShipmentId
			FROM tblSCTicket st
			JOIN tblICItem i on i.intItemId=st.intItemId AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			JOIN tblICInventoryShipmentItem ri on ri.intSourceId=st.intTicketId
			JOIN tblICInventoryShipment r on r.intInventoryShipmentId=ri.intInventoryShipmentId
			LEFT JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=ri.intStorageScheduleTypeId 
			JOIN tblICItemUOM u on st.intItemId=u.intItemId AND u.ysnStockUnit=1
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND i.intCommodityId = @intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND ISNULL(strType,'') <> 'Other Charge'
				AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
		) a
	
		UNION ALL --On Hold without Delivery Sheet
		SELECT CONVERT(VARCHAR(10),st.dtmTicketDateTime,110) dtmDate
			, st.strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' as tranShipmentNumber
			, (CASE WHEN strInOutFlag='O' THEN dblNetUnits ELSE 0 END) tranShipQty
			, '' tranReceiptNumber
			, (CASE WHEN strInOutFlag='I' THEN dblNetUnits ELSE 0 END) tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, null intInventoryReceiptId
			, NULL intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber 
			, st.intTicketId
			, st.strTicketNumber AS ticketNumber
		FROM tblSCTicket st
		JOIN tblICItem i on i.intItemId=st.intItemId
		WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),st.dtmTicketDateTime,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND i.intCommodityId= @intCommodityId
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			AND ISNULL(strType,'') <> 'Other Charge'
			AND st.intProcessingLocationId = ISNULL(@intLocationId, st.intProcessingLocationId)
			AND st.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND st.intDeliverySheetId IS NULL AND st.strTicketStatus = 'H'
		
		UNION ALL --Direct IR
		SELECT dtmDate
			, strDistributionOption strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, '' tranShipmentNumber
			, 0.0 tranShipQty
			, strReceiptNumber tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intInventoryReceiptId
			, null intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),R.dtmReceiptDate,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(u.intUnitMeasureId,@intCommodityUnitMeasureId,RI.dblOpenReceive) ,6) dblInQty
				, R.strReceiptNumber
				, '' strDistributionOption
				, R.intInventoryReceiptId
			FROM tblICInventoryReceiptItem RI
			INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
			INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE R.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId
				AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
				AND R.intLocationId = ISNULL(@intLocationId, R.intLocationId)
				AND R.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND RI.intOwnershipType = 1 
				AND R.intSourceType = 0
		) t
	
		UNION ALL --Direct IS
		SELECT dtmDate
			, '' strDistributionOption
			, strDistributionOption strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, strShipmentNumber tranShipmentNumber
			, dblOutQty tranShipQty
			, '' tranReceiptNumber
			, 0.0 tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, null intInventoryReceiptId
			, intInventoryShipmentId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),S.dtmShipDate,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,SI.dblQuantity) ,6) dblOutQty
				, S.strShipmentNumber
				, '' strDistributionOption
				, S.intInventoryShipmentId
			FROM tblICInventoryShipmentItem SI
			INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
			INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE S.ysnPosted = 1
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId 
				AND Itm.intItemId = ISNULL(@intItemId, Itm.intItemId)
				AND S.intShipFromLocationId = ISNULL(@intLocationId, S.intShipFromLocationId)
				AND S.intShipFromLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND SI.intOwnershipType = 1
				AND S.intSourceType = 0 
		)a
		
		--Direct Invoice
		UNION ALL SELECT dtmDate
			, '' strDistributionOption
			, strDistributionOption strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, strShipmentNumber tranShipmentNumber
			, CASE WHEN strTransactionType = 'Credit Memo' THEN 0.0 ELSE ISNULL(dblOutQty, 0) END tranShipQty
			, '' tranReceiptNumber
			, CASE WHEN strTransactionType = 'Credit Memo' THEN ISNULL(dblOutQty, 0) ELSE 0.0 END tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, null intInventoryReceiptId
			, null intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),I.dtmPostDate,110) dtmDate
				, ROUND(dbo.fnCTConvertQuantityToTargetCommodityUOM(intUnitMeasureId,@intCommodityUnitMeasureId,ID.dblQtyShipped) ,6) dblOutQty
				, I.strInvoiceNumber strShipmentNumber
				, '' strDistributionOption
				, I.intInvoiceId
				, I.strTransactionType
			FROM tblARInvoice I
			INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
			INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
			INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
			INNER JOIN tblICItemUOM u on Itm.intItemId=u.intItemId AND u.ysnStockUnit=1
			WHERE I.ysnPosted = 1
				AND ID.intInventoryShipmentItemId IS NULL
				AND ISNULL(ID.strShipmentNumber,'') = ''
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
				AND C.intCommodityId = @intCommodityId
				AND ID.intItemId = ISNULL(@intItemId, ID.intItemId)
				AND I.intCompanyLocationId = ISNULL(@intLocationId, I.intCompanyLocationId)
				AND I.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		)a

		--Consume, Produce AND Outbound Shipment
		UNION ALL SELECT dtmDate
			, '' strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, tranShipmentNumber
			, tranShipQty
			, tranReceiptNumber
			, tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intTransactionId intInventoryReceiptId
			, intTransactionId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
				, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId = 46 THEN it.strTransactionId ELSE '' END tranShipmentNumber
				, CASE WHEN it.intTransactionTypeId = 8 OR it.intTransactionTypeId = 46 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranShipQty
				, CASE WHEN it.intTransactionTypeId = 9 THEN it.strTransactionId ELSE '' END tranReceiptNumber
				, CASE WHEN it.intTransactionTypeId = 9 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SUM(ISNULL(it.dblQty,0))) ELSE 0.0 END tranRecQty
				, it.intTransactionId
			FROM tblICInventoryTransaction it
			JOIN tblICItem i on i.intItemId=it.intItemId AND it.ysnIsUnposted=0 AND it.intTransactionTypeId in(8,9,46)
			JOIN tblICItemUOM u on it.intItemId=u.intItemId AND u.intItemUOMId=it.intItemUOMId
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId 
			JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND ISNULL(il.strDescription,'') <> 'In-Transit'
			WHERE i.intCommodityId=@intCommodityId
				AND i.intItemId = ISNULL(@intItemId, i.intItemId)
				AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
				AND CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			group by dtmDate, intTransactionTypeId,strTransactionId,ium.intCommodityUnitMeasureId,intTransactionId
		) a

		--Inventory Transfer
		UNION ALL SELECT dtmDate
			, '' strDistributionOption
			, '' strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, tranShipmentNumber
			, tranShipQty
			, tranReceiptNumber
			, tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intTransactionId intInventoryReceiptId
			, intTransactionId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),dtmDate,110) dtmDate
				, CASE WHEN it.dblQty < 0 THEN it.strTransactionId ELSE '' END tranShipmentNumber
				, CASE WHEN it.dblQty < 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(ABS(it.dblQty),0)) ELSE 0.0 END tranShipQty
				, CASE WHEN it.dblQty > 0 THEN it.strTransactionId ELSE '' END tranReceiptNumber
				, CASE WHEN it.dblQty > 0 THEN dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,ISNULL(it.dblQty,0)) ELSE 0.0 END tranRecQty
				, it.intTransactionId
			FROM tblICInventoryTransaction it 
			JOIN tblICItem i on i.intItemId=it.intItemId AND it.ysnIsUnposted=0 AND it.intTransactionTypeId in(12)
			JOIN tblICItemUOM u on it.intItemId=u.intItemId AND u.intItemUOMId=it.intItemUOMId 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId 
			JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND ISNULL(il.strDescription,'') <> 'In-Transit'
			WHERE i.intCommodityId=@intCommodityId 
			AND i.intItemId = ISNULL(@intItemId, i.intItemId)
			AND il.intLocationId = ISNULL(@intLocationId, il.intLocationId)
			AND CONVERT(DATETIME, CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		) t

		--Storage Transfer
		UNION ALL SELECT dtmDate
			, strDistributionOption
			, strDistributionOption strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, strTransferTicket tranShipmentNumber
			, dblOutQty tranShipQty
			, strTransferTicket tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intTransferStorageId intInventoryReceiptId
			, intTransferStorageId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
				, S.strStorageTypeCode strDistributionOption
				, CASE WHEN strType = 'From Transfer' THEN dblUnits
						ELSE 0 END AS dblInQty
				, CASE WHEN strType = 'Transfer' THEN ABS(dblUnits)
						ELSE 0 END AS dblOutQty
				, S.intStorageScheduleTypeId
				, SH.intTransferStorageId
				, SH.strTransferTicket
			FROM tblGRCustomerStorage CS
			INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
			INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110)
				BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND CS.intCommodityId = @intCommodityId
				AND CS.intItemId = ISNULL(@intItemId, CS.intItemId)
				AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
				AND strType IN ('From Transfer','Transfer')
		) a

		--Storage Settlement 
		UNION ALL SELECT dtmDate
			, strDistributionOption
			, strDistributionOption strShipDistributionOption
			, '' as strAdjDistributionOption
			, '' as strCountDistributionOption
			, strSettleTicket tranShipmentNumber
			, dblOutQty tranShipQty
			, strSettleTicket tranReceiptNumber
			, dblInQty tranRecQty
			, '' tranAdjNumber
			, 0.0 dblAdjustmentQty
			, '' tranCountNumber
			, 0.0 dblCountQty
			, '' tranInvoiceNumber
			, 0.0 dblInvoiceQty
			, intSettleStorageId intInventoryReceiptId
			, intSettleStorageId intInventoryShipmentId
			, null intInventoryAdjustmentId
			, null intInventoryCountId
			, null intInvoiceId
			, null intDeliverySheetId
			, '' AS deliverySheetNumber
			, null intTicketId
			, '' AS ticketNumber
		FROM (
			SELECT CONVERT(VARCHAR(10),SH.dtmHistoryDate,110) dtmDate
				, S.strStorageTypeCode strDistributionOption
				, CASE WHEN strType = 'Reverse Settlement' THEN ABS(dblUnits)
						ELSE 0 END AS dblOutQty
				, CASE WHEN strType = 'Settlement' THEN ABS(dblUnits)
						ELSE 0 END AS dblInQty
				, S.intStorageScheduleTypeId
				, SH.intSettleStorageId
				, SH.strSettleTicket
			FROM tblGRCustomerStorage CS
			INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
			INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10),SH.dtmHistoryDate,110),110) BETWEEN CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND CONVERT(DATETIME, CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
				AND CS.intCommodityId = @intCommodityId
				AND CS.intItemId = ISNULL(@intItemId, CS.intItemId)
				AND CS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				AND CS.intCompanyLocationId = ISNULL(@intLocationId, CS.intCompanyLocationId)
				AND strType IN ('Settlement','Reverse Settlement')
				AND SH.intSettleStorageId IS NULL
				AND S.ysnDPOwnedType <> 1
		) a
	)t
	
	INSERT INTO tblRKDPIInventory(intDPIHeaderId
		, dtmTransactionDate
		, strReceiptNumber
		, strDistribution
		, dblIn
		, strShipTicketNo
		, dblOut
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, strDeliverySheetNumber
		, intTicketId
		, strTicketNumber)
	SELECT @intDPIHeaderId
		, dtmDate
		, strReceiptNumber
		, strDistribution
		, dblIN
		, strShipTicketNo
		, dblOUT
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, deliverySheetNumber
		, intTicketId
		, ticketNumber
	FROM (
		SELECT DISTINCT dtmDate [dtmDate]
			, case when ISNULL(tranReceiptNumber,'') <> '' then tranReceiptNumber
					when ISNULL(tranShipmentNumber,'') <> '' then tranShipmentNumber
					when ISNULL(tranAdjNumber,'') <> '' then tranAdjNumber
					when ISNULL(tranInvoiceNumber,'') <> '' then tranInvoiceNumber
					when ISNULL(tranCountNumber,'') <> '' then tranCountNumber
					when ISNULL(deliverySheetNumber,'') <> '' then deliverySheetNumber
					when ISNULL(ticketNumber,'') <> '' then ticketNumber end [strReceiptNumber]
			, CASE WHEN ISNULL(strDistributionOption,'') <> '' THEN strDistributionOption
					WHEN ISNULL(strShipDistributionOption,'') <> '' then strShipDistributionOption
					WHEN ISNULL(strAdjDistributionOption,'') <> '' then strAdjDistributionOption END strDistribution
			, tranRecQty [dblIN]
			, ISNULL(tranShipmentNumber,'') [strShipTicketNo]
			, ISNULL(tranShipQty,0) + ISNULL(dblInvoiceQty,0) [dblOUT]
			, tranAdjNumber [strAdjNo]
			, dblAdjustmentQty [dblAdjQty]
			, tranCountNumber [strCountNumber]
			, dblCountQty [dblCountQty]
			, BalanceForward dblDummy
			, (SELECT SUM(BalanceForward) FROM @tblInvResult AS T2 WHERE T2.Id <= T1.Id) AS dblBalanceForward
			, strShipDistributionOption
			, intInventoryReceiptId
			, intInventoryShipmentId
			, intInventoryAdjustmentId
			, intInventoryCountId
			, intInvoiceId
			, intDeliverySheetId
			, deliverySheetNumber
			, intTicketId
			, ticketNumber
		FROM @tblInvResult T1
	)t order by dtmDate desc,strReceiptNumber desc

	DROP TABLE #LicensedLocations

END