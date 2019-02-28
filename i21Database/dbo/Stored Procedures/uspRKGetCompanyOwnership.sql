CREATE PROCEDURE [dbo].[uspRKGetCompanyOwnership]
	@dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId int = null

AS

DECLARE @dtmOrigFromTransactionDate DATETIME

--Grab the original start date and assinged to a varialbe to be used laster on.
SET @dtmOrigFromTransactionDate = @dtmFromTransactionDate
--Set the Start date as the beggining date "1900"
SET @dtmFromTransactionDate =  '1900-01-01 00:00:00'

BEGIN
	DECLARE @tblResult TABLE (Id INT identity(1, 1)
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

	DECLARE @intCommodityUnitMeasureId INT= NULL
			,@ysnIncludeDPPurchasesInCompanyTitled BIT
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

	SELECT TOP 1  @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference

	SELECT intCompanyLocationId
	INTO #LicensedLocations
	FROM tblSMCompanyLocation
	WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END
	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END

	SELECT  strItemNo
		, dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidIn - dblUnpaidOut as dblUnpaidBalance
		, CASE WHEN ysnPaid = 0 AND dblUnpaidOut = 0 THEN 0 ELSE  dblUnpaidOut END  as dblPaidBalance
		, strDistributionOption
		, strReceiptNumber
		, intReceiptId
	INTO #tempResult
	FROM (
		--From Settle Storage
		SELECT *
			, round(dblInQty, 2) dblUnpaidIn
			, round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110) dtmDate
				, gr.dblUnits dblUnitCost1
				, '' as intInventoryReceiptItemId--ir.intInventoryReceiptItemId
				, i.strItemNo
				, isnull(bd.dblQtyReceived, 0) dblInQty
				, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				, gs.strStorageTypeCode  as strDistributionOption
				, b.strBillId AS strReceiptNumber
				, b.intBillId AS intReceiptId
				, b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			INNER JOIN tblGRStorageHistory gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRCustomerStorage grs ON  gr.intCustomerStorageId = grs.intCustomerStorageId
			INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=grs.intStorageTypeId 
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			WHERE convert(DATETIME, CONVERT(VARCHAR(10), gr.dtmHistoryDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110)
				AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(i.strType, '') <> 'Other Charge'
				AND b.intShipToId = isnull(@intLocationId, b.intShipToId)
				AND gs.strStorageTypeCode NOT IN ('CNT', CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 'DP' ELSE '' END)
		) t
	) t2
	
	UNION ALL SELECT i.strItemNo
		, CONVERT(VARCHAR(10), dtmTicketDateTime, 110) AS dtmDate
		, dblGrossUnits AS dblUnpaidIn
		, 0 AS dblUnpaidOut
		, dblGrossUnits AS dblUnpaidBalance
		, dblGrossUnits as dblPaidBalance
		, strDistributionOption 
		, r.strReceiptNumber
		, r.intInventoryReceiptId
	FROM tblICInventoryReceiptItem ir
	JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
	JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
	JOIN tblICItem i ON i.intItemId = ir.intItemId
	JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType, 0) = 1
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110))
		AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge'
		AND ir.intSubLocationId = isnull(@intLocationId, ir.intSubLocationId)
		AND st.strDistributionOption NOT IN ('CNT', CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 'DP' ELSE '' END)
	
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
			, ABS(isnull(SI.dblQuantity, 0)) * -1 dblInQty
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = isnull(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = isnull(@intLocationId, ST.intProcessingLocationId)
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
		, intReceiptId
	FROM (
		SELECT CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			, RI.dblUnitCost dblUnitCost1
			, RI.intInventoryReceiptItemId
			, I.strItemNo
			, isnull(RI.dblNet, 0) dblInQty
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = isnull(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = isnull(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot and DP
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), IT.dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND IT.intItemId = isnull(@intItemId, IT.intItemId)
			AND il.intLocationId = isnull(@intLocationId, il.intLocationId)
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
		JOIN tblICItem i on i.intItemId=it.intItemId and it.ysnIsUnposted=0 and it.intTransactionTypeId in(12)
		join tblICItemUOM u on it.intItemId=u.intItemId and u.intItemUOMId=it.intItemUOMId 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
		JOIN tblICItemLocation il on it.intItemLocationId=il.intItemLocationId AND il.intLocationId IN (SELECT intCompanyLocationId FROM tblSMCompanyLocation
																										WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 
																										WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 
																										ELSE isnull(ysnLicensed, 0) END)
			and isnull(il.strDescription,'') <> 'In-Transit'
		WHERE i.intCommodityId=@intCommodityId  
			and i.intItemId = isnull(@intItemId, i.intItemId)
			and il.intLocationId = isnull(@intLocationId, il.intLocationId)
			and convert(datetime,CONVERT(VARCHAR(10),dtmDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
		group by dtmDate, strItemNo, it.intTransactionId, it.strTransactionId, intCommodityUnitMeasureId
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
			,RI.dblUnitCost dblUnitCost1
			,RI.intInventoryReceiptItemId
			,I.strItemNo
			,isnull(RI.dblNet, 0) - ISNULL(RI.dblBillQty,0) dblInQty
			,0 AS dblOutQty
			,GST.strStorageTypeCode strDistributionOption
			,R.strReceiptNumber
			,R.intInventoryReceiptId
		FROM tblSCDeliverySheetSplit DSS
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		WHERE ST.strTicketStatus = 'C'
			AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId
			AND ST.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END
			AND ST.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then ST.intProcessingLocationId else @intLocationId end
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot and DP
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
		SELECT 
			CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
			,RI.dblUnitCost dblUnitCost1
			,RI.intInventoryReceiptItemId
			,I.strItemNo
			,isnull(BD.dblQtyReceived, 0) dblInQty
			,0 AS dblOutQty
			,GST.strStorageTypeCode strDistributionOption
			,Bill.strBillId AS strReceiptNumber
			,Bill.intBillId AS intReceiptId
		FROM tblSCDeliverySheetSplit DSS 
		INNER JOIN vyuSCTicketView ST ON DSS.intDeliverySheetId = ST.intDeliverySheetId
		INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
		INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
		INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
		INNER JOIN tblGRStorageType GST ON DSS.intStorageScheduleTypeId = GST.intStorageScheduleTypeId
		INNER JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId
		INNER JOIN tblAPBill Bill ON BD.intBillId = Bill.intBillId
		WHERE ST.strTicketStatus = 'C'
			AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId 
			AND ST.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
			AND ST.intProcessingLocationId = case when isnull(@intLocationId,0)=0 then ST.intProcessingLocationId else @intLocationId end 
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND R.intSourceType = 1
			AND Bill.ysnPosted = 1
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN 1 ELSE NULL END)--Contract, Spot and DP
			AND RI.dblBillQty <> 0
	)t

	--Direct from Invoice
	UNION ALL SELECT strItemNo
		, dtmDate
		,dblInQty AS dblUnpaidIn
		,0 AS dblUnpaidOut
		,0 AS dblUnpaidBalance
		,ABS(dblInQty) + ABS(isnull(dblOutQty, 0)) * CASE WHEN dblOutQty < 0 THEN 1 ELSE -1 END as dblPaidBalance
		,strDistributionOption
		,strReceiptNumber
		,intInventoryReceiptItemId
	FROM (
		SELECT CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
			,0 dblUnitCost1
			,I.intInvoiceId intInventoryReceiptItemId
			,Itm.strItemNo
			,CASE WHEN I.strTransactionType = 'Credit Memo' THEN isnull(ID.dblQtyShipped, 0) ELSE 0.0  END dblInQty
			,CASE WHEN I.strTransactionType = 'Credit Memo' THEN 0.0 ELSE isnull(ID.dblQtyShipped, 0)  END dblOutQty
			,'' strDistributionOption
			,I.strInvoiceNumber AS strReceiptNumber
			,I.intInvoiceId AS intReceiptId
		FROM tblARInvoice I
		INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
		INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		LEFT JOIN tblICItemLocation ItmLoc ON  Itm.intItemId = ItmLoc.intItemId AND I.intCompanyLocationId = ItmLoc.intLocationId
		WHERE I.ysnPosted = 1
			AND ID.intInventoryShipmentItemId IS NULL
			AND ID.intInventoryShipmentChargeId IS NULL
			AND Itm.strType IN ('Inventory', 'Raw Material', 'Finished Good')
			AND I.strTransactionType NOT IN  ('Customer Prepayment')
			AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND ID.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
			AND I.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
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
			, ABS(isnull(SI.dblQuantity, 0)) * -1 dblInQty
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId
			AND Itm.intItemId = isnull(@intItemId, Itm.intItemId)
			AND S.intShipFromLocationId = isnull(@intLocationId, S.intShipFromLocationId)
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
			, isnull(RI.dblOpenReceive, 0) dblInQty
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND Itm.intItemId = isnull(@intItemId, Itm.intItemId)
			AND R.intLocationId = isnull(@intLocationId, R.intLocationId)
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
			, 0  AS dblOutQty
			, CASE WHEN SH.strType = 'Settlement' THEN ABS(dblUnits)
					WHEN  SH.strType = 'Reverse Settlement' THEN ABS(dblUnits) * -1
					ELSE 0 END AS dblInQty
			, S.intStorageScheduleTypeId
			, SH.intSettleStorageId as intInventoryReceiptItemId
			, SH.strSettleTicket as strReceiptNumber
			, I.strItemNo
		FROM tblGRCustomerStorage CS
		INNER JOIN tblGRStorageHistory SH ON CS.intCustomerStorageId = SH.intCustomerStorageId
		INNER JOIN tblGRStorageType S ON CS.intStorageTypeId = S.intStorageScheduleTypeId
		INNER JOIN tblICItem I ON CS.intItemId = I.intItemId
		WHERE convert(datetime,CONVERT(VARCHAR(10),SH.dtmDistributionDate,110),110) BETWEEN convert(datetime,CONVERT(VARCHAR(10),@dtmFromTransactionDate,110),110) AND convert(datetime,CONVERT(VARCHAR(10),@dtmToTransactionDate,110),110)
			AND CS.intCommodityId= @intCommodityId
			and CS.intItemId= case when isnull(@intItemId,0)=0 then CS.intItemId else @intItemId end 
			AND  CS.intCompanyLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND CS.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then CS.intCompanyLocationId  else @intLocationId end
			AND SH.strType IN ('Settlement','Reverse Settlement')
			AND S.ysnDPOwnedType = CASE WHEN @ysnIncludeDPPurchasesInCompanyTitled = 1 THEN NULL ELSE 1 END
			AND SH.intBillId IS NULL
	) t

	--Get Balance Forward
	INSERT INTO @tblResult (dblUnpaidBalance
		, InventoryBalanceCarryForward)
	select sum(dblUnpaidBalance), sum(dblPaidBalance) from #tempResult WHERE dtmDate < @dtmOrigFromTransactionDate

	--Filter it by orignal filter date
	INSERT INTO @tblResult (strItemNo
		, dtmDate
		, strDistributionOption
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, strReceiptNumber
		, intReceiptId)
	SELECT strItemNo
		, ISNULL(dtmDate,'') dtmDate
		, strDistributionOption [strDistribution]
		, dblUnpaidIn [dblUnpaidIN]
		, dblUnpaidOut [dblUnpaidOut]
		, dblUnpaidBalance [dblUnpaidBalance]
		, dblPaidBalance
		, strReceiptNumber
		, intReceiptId
	FROM #tempResult T1
	WHERE dtmDate between @dtmOrigFromTransactionDate and @dtmToTransactionDate

	--Return
	SELECT CONVERT(INT, ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
		, ISNULL(dtmDate,'') dtmDate
		, strDistributionOption [strDistribution]
		, dblUnpaidIn [dblUnpaidIN]
		, dblUnpaidOut [dblUnpaidOut]
		, dblUnpaidBalance [dblUnpaidBalance]
		, dblPaidBalance
		, InventoryBalanceCarryForward dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM @tblResult T1
	ORDER BY intRowNum
		,dtmDate DESC,
		strReceiptNumber DESC

	DROP TABLE #LicensedLocations
END