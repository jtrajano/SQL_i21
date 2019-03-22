CREATE PROC [dbo].[uspRKGetCompanyOwnership]
	@dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId int = null

AS

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
	SELECT @intCommodityUnitMeasureId=intCommodityUnitMeasureId from tblICCommodityUnitMeasure where intCommodityId=@intCommodityId AND ysnDefault=1

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

	INSERT INTO @tblResult (dblUnpaidBalance
		, InventoryBalanceCarryForward)
	SELECT sum(dblUnpaidBalance)
		, sum(InventoryBalanceCarryForward)
	FROM (
		SELECT sum(dblUnpaidIn) - sum(dblUnpaidIn - dblUnpaidOut) dblUnpaidBalance
			, (SELECT sum(dblQty) BalanceForward
				FROM tblICInventoryTransaction it
				JOIN tblICItem i ON i.intItemId = it.intItemId AND it.intTransactionTypeId IN (4, 5, 10, 23,33, 44)
				JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId AND isnull(il.strDescription, '') <> 'In-Transit'
					AND il.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
				WHERE intCommodityId = @intCommodityId AND convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
					AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(i.strType, '') <> 'Other Charge'
					AND il.intLocationId = isnull(@intLocationId, il.intLocationId)) InventoryBalanceCarryForward
		FROM (
			SELECT dblInQty dblUnpaidIn
				, dblOutQty dblUnpaidOut
			FROM (
				SELECT DISTINCT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
					, dblUnitCost dblUnitCost1
					, ir.intInventoryReceiptItemId
					, i.strItemNo
					, isnull(bd.dblQtyReceived, 0) dblInQty
					, (bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
					, strDistributionOption
					, b.strBillId AS strReceiptNumber
					, b.intBillId AS intReceiptId
				FROM tblAPBill b
				JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
				LEFT JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId
				JOIN tblICItem i ON i.intItemId = bd.intItemId
				LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
				WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110)
					AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge'
					AND b.intShipToId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
					AND b.intShipToId = isnull(@intLocationId, b.intShipToId)
			) t
		) t2
		
		UNION ALL SELECT sum(dblGrossUnits) AS dblUnpaidBalance
			, NULL InventoryBalanceCarryForward
		FROM tblICInventoryReceiptItem ir
		JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
		JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId
			AND sl.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
		JOIN tblICItem i ON i.intItemId = ir.intItemId
		JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
		JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType, 0) = 1
		WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110))
			AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge' AND i.intCommodityId = @intCommodityId
			AND ir.intSubLocationId =  isnull(@intLocationId, ir.intSubLocationId)
	) t3
	
	INSERT INTO @tblResult (strItemNo
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
			, round(dblInQty, 2) dblUnpaidIn
			, round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				, dblUnitCost dblUnitCost1
				, iri.intInventoryReceiptItemId
				, i.strItemNo
				, isnull(bd.dblQtyReceived, 0) dblInQty
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
			WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId
				AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge'
				AND b.intShipToId = isnull(@intLocationId, b.intShipToId) AND ir.intSourceType = 1
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
				, isnull(bd.dblQtyReceived, 0) dblInQty
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
			WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110)
				AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge'
				AND b.intShipToId = isnull(@intLocationId, b.intShipToId)
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
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType, 0) = 1
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110))
		AND i.intCommodityId = @intCommodityId AND i.intItemId = isnull(@intItemId, i.intItemId) AND isnull(strType, '') <> 'Other Charge'
		AND ir.intSubLocationId = isnull(@intLocationId, ir.intSubLocationId)
		AND st.strDistributionOption NOT IN ('DP','CNT')
	
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
		, intInventoryReceiptItemId
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
			AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = 1)--Contract, Spot and DP
			AND RI.dblBillQty = 0
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
		
		--Storage
		UNION ALL SELECT CONVERT(VARCHAR(10),IA.dtmPostedDate,110) dtmDate
			, round(IAD.dblAdjustByQuantity ,6) dblAdjustmentQty
			, IA.strAdjustmentNo strAdjustmentNo
			, IA.intInventoryAdjustmentId intInventoryAdjustmentId
			, strItemNo
		FROM tblICInventoryAdjustment IA
		INNER JOIN tblICInventoryAdjustmentDetail IAD ON IA.intInventoryAdjustmentId = IAD.intInventoryAdjustmentId
		INNER JOIN tblICItem Itm ON IAD.intItemId = Itm.intItemId
		INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
		WHERE IAD.intOwnershipType = 2 --Storage
			AND IA.ysnPosted = 1
			AND convert(DATETIME, CONVERT(VARCHAR(10), IA.dtmPostedDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND C.intCommodityId = @intCommodityId 
			AND IAD.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN IAD.intItemId ELSE @intItemId END 
			--AND Itm.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end 

		)a

UNION 
SELECT --Delivery Sheet
 strItemNo
	, dtmDate
	,dblInQty AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,dblInQty AS dblUnpaidBalance
	,0 as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intInventoryReceiptItemId
FROM (
	SELECT 
		CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
		,RI.dblUnitCost dblUnitCost1
		,RI.intInventoryReceiptItemId
		,I.strItemNo
		,isnull(RI.dblNet, 0) - ISNULL(RI.dblBillQty,0) dblInQty
		,0 AS dblOutQty
		,GST.strStorageTypeCode strDistributionOption
		,R.strReceiptNumber
        ,R.intInventoryReceiptId
		--,Inv.strInvoiceNumber AS strReceiptNumber
		--,Inv.intInvoiceId AS intReceiptId
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
	AND ST.intProcessingLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND RI.intOwnershipType = 1
	AND R.intSourceType = 1
	AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = 1)--Contract, Spot and DP
	--AND RI.dblBillQty = 0
	

)t

UNION 
SELECT --Delivery Sheet With Voucher
 strItemNo
    , dtmDate
    ,dblInQty AS dblUnpaidIn
    ,0 AS dblUnpaidOut
    ,dblInQty AS dblUnpaidBalance
    ,0 as dblPaidBalance
    ,strDistributionOption
    ,strReceiptNumber
    ,intInventoryReceiptItemId
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
        --,Inv.strInvoiceNumber AS strReceiptNumber
        --,Inv.intInvoiceId AS intReceiptId
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
    AND ST.intProcessingLocationId IN (
            SELECT intCompanyLocationId
            FROM tblSMCompanyLocation
            WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
            )
    AND RI.intOwnershipType = 1
    AND R.intSourceType = 1
    AND Bill.ysnPosted = 1
    AND (GST.intStorageScheduleTypeId IN (-2,-3) OR GST.ysnDPOwnedType = 1)--Contract, Spot and DP
    AND RI.dblBillQty <> 0
    
)t



UNION
SELECT --Direct from Invoice
 strItemNo
	, dtmDate
	,dblInQty AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,0 AS dblUnpaidBalance
	,ABS(dblInQty) + ABS(isnull(dblOutQty, 0)) * -1 as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intInventoryReceiptItemId
FROM (
SELECT
	CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
	,0 dblUnitCost1
	,I.intInvoiceId intInventoryReceiptItemId
	,Itm.strItemNo
	,CASE WHEN I.strTransactionType = 'Credit Memo' THEN isnull(ID.dblQtyShipped, 0) ELSE 0.0  END dblInQty
	,CASE WHEN I.strTransactionType = 'Credit Memo' THEN 0.0 ELSE isnull(ID.dblQtyShipped, 0)  END dblOutQty
	,'' strDistributionOption
	,I.strInvoiceNumber AS strReceiptNumber
	,I.intInvoiceId AS intReceiptId
FROM 
tblARInvoice I
INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
INNER JOIN tblICItem Itm ON ID.intItemId = Itm.intItemId
INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
WHERE I.ysnPosted = 1
AND ID.intInventoryShipmentItemId IS NULL
AND ISNULL(ID.strShipmentNumber,'') = ''
AND convert(DATETIME, CONVERT(VARCHAR(10), I.dtmPostDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
AND C.intCommodityId = @intCommodityId 
AND ID.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ID.intItemId ELSE @intItemId END 
AND I.intCompanyLocationId = case when isnull(@intLocationId,0)=0 then I.intCompanyLocationId else @intLocationId end 
AND I.intCompanyLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
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
		SELECT CASE WHEN SS.intBillId IS NULL THEN CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) ELSE CONVERT(VARCHAR(10), SS.dtmCreated, 110) END dtmDate
			, RI.dblUnitCost dblUnitCost1
			, intCustomerStorageId as intInventoryReceiptItemId
			, I.strItemNo
			, CASE WHEN SS.intBillId IS NULL THEN isnull(RI.dblNet, 0) ELSE SS.dblOpenBalance END dblInQty
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
			AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
			AND ST.intCommodityId = @intCommodityId
			AND ST.intItemId = isnull(@intItemId, ST.intItemId)
			AND ST.intProcessingLocationId = isnull(@intLocationId, ST.intProcessingLocationId)
			AND ST.intProcessingLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocations)
			AND RI.intOwnershipType = 1
			AND ST.strDistributionOption = 'DP'
			AND SS.dblOpenBalance <> 0
	) t

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
