CREATE PROC [dbo].[uspRKGetCompanyOwnership] 
	 @dtmFromTransactionDate DATETIME = NULL
	,@dtmToTransactionDate DATETIME = NULL
	,@intCommodityId INT = NULL
	,@intItemId INT = NULL
	,@strPositionIncludes NVARCHAR(100) = NULL
	,@intLocationId int = null
AS
DECLARE @tblResult TABLE (
	Id INT identity(1, 1)
	,dtmDate DATETIME
	,strItemNo NVARCHAR(50)
	,dblUnpaidIn NUMERIC(24, 10)
	,dblUnpaidOut NUMERIC(24, 10)
	,dblUnpaidBalance NUMERIC(24, 10)
	,dblPaidBalance  NUMERIC(24, 10)
	,strDistributionOption NVARCHAR(50)
	,InventoryBalanceCarryForward NUMERIC(24, 10)
	,strReceiptNumber NVARCHAR(50)
	,intReceiptId INT
	)


INSERT INTO @tblResult (
	dblUnpaidBalance
	,InventoryBalanceCarryForward
)
SELECT 
	sum(dblUnpaidBalance)
	,sum(InventoryBalanceCarryForward)
FROM (
	SELECT 
		sum(dblUnpaidIn) - sum(dblUnpaidIn - dblUnpaidOut) dblUnpaidBalance
		,(SELECT sum(dblQty) BalanceForward
		 FROM tblICInventoryTransaction it
		 JOIN tblICItem i ON i.intItemId = it.intItemId AND it.intTransactionTypeId IN (4, 5, 10, 23,33, 44)
		 JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId AND isnull(il.strDescription, '') <> 'In-Transit' AND il.intLocationId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
		 WHERE intCommodityId = @intCommodityId AND convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(i.strType, '') <> 'Other Charge'
		 AND il.intLocationId = case when isnull(@intLocationId,0)=0 then il.intLocationId else @intLocationId end) InventoryBalanceCarryForward
	FROM (
		SELECT 
			dblInQty dblUnpaidIn
			,dblOutQty dblUnpaidOut
		FROM (
			SELECT DISTINCT 
				CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				,dblUnitCost dblUnitCost1
				,ir.intInventoryReceiptItemId
				,i.strItemNo
				,isnull(bd.dblQtyReceived, 0) dblInQty
				,(bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				,strDistributionOption
				,b.strBillId AS strReceiptNumber
				,b.intBillId AS intReceiptId
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
			LEFT JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId
			JOIN tblICItem i ON i.intItemId = bd.intItemId
			LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge' AND b.intShipToId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
					AND b.intShipToId = case when isnull(@intLocationId,0)=0 then b.intShipToId else @intLocationId end
			) t
		) t2
	
	UNION
	
	SELECT 
		sum(dblGrossUnits) AS dblUnpaidBalance
		,NULL InventoryBalanceCarryForward
	FROM tblICInventoryReceiptItem ir
	JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
	JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	JOIN tblICItem i ON i.intItemId = ir.intItemId
	JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
	JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType, 0) = 1
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge' AND i.intCommodityId = @intCommodityId
		AND ir.intSubLocationId =  case when isnull(@intLocationId,0)=0 then ir.intSubLocationId else @intLocationId end 

	) t3


INSERT INTO @tblResult (
	strItemNo
	,dtmDate
	,dblUnpaidIn
	,dblUnpaidOut
	,dblUnpaidBalance
	,dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intReceiptId
	)
SELECT strItemNo
	,dtmDate
	,dblUnpaidIn
	,dblUnpaidOut
	,dblUnpaidIn - dblUnpaidOut as dblUnpaidBalance
	,CASE WHEN ysnPaid = 0 AND dblUnpaidOut = 0 THEN 0 ELSE  dblUnpaidOut END  as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intReceiptId
FROM (
	SELECT * --From Delivery Sheet
		,round(dblInQty, 2) dblUnpaidIn
		,round(dblOutQty, 2) dblUnpaidOut
	FROM (
		SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
			,dblUnitCost dblUnitCost1
			,iri.intInventoryReceiptItemId
			,i.strItemNo
			,isnull(bd.dblQtyReceived, 0) dblInQty
			,(bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
			,gs.strStorageTypeCode strDistributionOption
			,b.strBillId AS strReceiptNumber
			,b.intBillId AS intReceiptId
			,b.ysnPaid
		FROM tblAPBill b
		JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		INNER JOIN tblICInventoryReceiptItem iri ON bd.intInventoryReceiptItemId = iri.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt ir ON iri.intInventoryReceiptId = ir.intInventoryReceiptId
		INNER JOIN tblICItem i ON i.intItemId = bd.intItemId
		INNER JOIN tblSCDeliverySheet ds ON ds.intDeliverySheetId = iri.intSourceId
		INNER JOIN tblSCDeliverySheetSplit dss ON ds.intDeliverySheetId = dss.intDeliverySheetId
		INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=dss.intStorageScheduleTypeId 
	
		WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
			AND b.intShipToId = case when isnull(@intLocationId,0)=0 then b.intShipToId else @intLocationId end 
		AND ir.intSourceType = 5 AND gs.strStorageTypeCode <> 'OS'
		) t

		UNION --Direct from Scale
		SELECT *
		,round(dblInQty, 2) dblUnpaidIn
		,round(dblOutQty, 2) dblUnpaidOut
	FROM (
		SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
			,dblUnitCost dblUnitCost1
			,iri.intInventoryReceiptItemId
			,i.strItemNo
			,isnull(bd.dblQtyReceived, 0) dblInQty
			,(bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
			,st.strDistributionOption
			,b.strBillId AS strReceiptNumber
			,b.intBillId AS intReceiptId
			,b.ysnPaid
		FROM tblAPBill b
		JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		INNER JOIN tblICInventoryReceiptItem iri ON bd.intInventoryReceiptItemId = iri.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt ir ON iri.intInventoryReceiptId = ir.intInventoryReceiptId
		INNER JOIN tblICItem i ON i.intItemId = bd.intItemId
		INNER JOIN vyuSCTicketView st ON st.intTicketId = iri.intSourceId
		WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
			AND b.intShipToId = case when isnull(@intLocationId,0)=0 then b.intShipToId else @intLocationId end 
		AND ir.intSourceType = 1
		) t

		UNION --From Settle Storage
		SELECT *
			,round(dblInQty, 2) dblUnpaidIn
			,round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				,grt.dblUnits dblUnitCost1
				,'' as intInventoryReceiptItemId--ir.intInventoryReceiptItemId
				,i.strItemNo
				,isnull(bd.dblQtyReceived, 0) dblInQty
				,(bd.dblQtyReceived/b.dblTotal) * (b.dblTotal - b.dblAmountDue) AS dblOutQty
				,gs.strStorageTypeCode strDistributionOption
				,b.strBillId AS strReceiptNumber
				,b.intBillId AS intReceiptId
				,b.ysnPaid
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblGRSettleStorage gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN tblGRCustomerStorage grs ON  grt.intCustomerStorageId = grs.intCustomerStorageId
			INNER JOIN tblGRStorageType gs on gs.intStorageScheduleTypeId=grs.intStorageTypeId 
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
				AND b.intShipToId = case when isnull(@intLocationId,0)=0 then b.intShipToId else @intLocationId end 
			) t

	) t2

UNION

SELECT i.strItemNo
	,CONVERT(VARCHAR(10), dtmTicketDateTime, 110) AS dtmDate
	,dblGrossUnits AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,dblGrossUnits AS dblUnpaidBalance
	,dblGrossUnits as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,ir.intInventoryReceiptId
FROM tblICInventoryReceiptItem ir
JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ir.intInventoryReceiptId AND ysnPosted = 1
JOIN tblSMCompanyLocationSubLocation sl ON ir.intSubLocationId = sl.intCompanyLocationSubLocationId AND sl.intCompanyLocationId IN (
		SELECT intCompanyLocationId
		FROM tblSMCompanyLocation
		WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
		)
JOIN tblICItem i ON i.intItemId = ir.intItemId
JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
JOIN tblGRStorageType s ON st.intStorageScheduleTypeId = s.intStorageScheduleTypeId AND isnull(ysnDPOwnedType, 0) = 1
WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110)) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
	AND ir.intSubLocationId = case when isnull(@intLocationId,0)=0 then ir.intSubLocationId else @intLocationId end 
	AND st.strDistributionOption NOT IN ('DP','CNT')

UNION 
SELECT --IS decressing the Unpaid Balance and Company Owned
 strItemNo
	, dtmDate
	,0 AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,0 AS dblUnpaidBalance
	,dblInQty as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intInventoryShipmentItemId
FROM (
	SELECT 
		CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) dtmDate
		,SI.dblUnitPrice dblUnitCost1
		,SI.intInventoryShipmentItemId
		,I.strItemNo
		,ABS(isnull(SI.dblQuantity, 0)) * -1 dblInQty
		,0 AS dblOutQty
		,ST.strDistributionOption
		,S.strShipmentNumber AS strReceiptNumber
		,S.intInventoryShipmentId AS intReceiptId
		--,Inv.strInvoiceNumber AS strReceiptNumber
		--,Inv.intInvoiceId AS intReceiptId
	FROM vyuSCTicketView ST
	INNER JOIN tblICInventoryShipmentItem SI ON ST.intTicketId = SI.intSourceId
	INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
	INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
	--LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId
	--LEFT JOIN tblARInvoice Inv ON ID.intInvoiceId = Inv.intInvoiceId
	WHERE ST.strTicketStatus = 'C'
	AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
	AND ST.intCommodityId = @intCommodityId 
	AND ST.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
	AND ST.intTicketLocationId = case when isnull(@intLocationId,0)=0 then ST.intTicketLocationId else @intLocationId end 
	AND ST.intTicketLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND SI.intOwnershipType = 1
)t

UNION 
SELECT --IR decressing the Unpaid Balance and Company Owned
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
		,isnull(RI.dblNet, 0) dblInQty
		,0 AS dblOutQty
		,ST.strDistributionOption
		,R.strReceiptNumber AS strReceiptNumber
		,R.intInventoryReceiptId AS intReceiptId
		--,Inv.strInvoiceNumber AS strReceiptNumber
		--,Inv.intInvoiceId AS intReceiptId
	FROM vyuSCTicketView ST
	INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
	WHERE ST.strTicketStatus = 'C'
	AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
	AND ST.intCommodityId = @intCommodityId 
	AND ST.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
	AND ST.intTicketLocationId = case when isnull(@intLocationId,0)=0 then ST.intTicketLocationId else @intLocationId end 
	AND ST.intTicketLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND RI.intOwnershipType = 1
	AND ST.strDistributionOption IN ('DP','CNT', 'SPT')
	AND RI.dblBillQty = 0
	AND RI.intInventoryReceiptItemId NOT IN (select intInventoryReceiptItemId from tblGRSettleStorage gr 
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN vyuSCGetScaleDistribution sc ON  grt.intCustomerStorageId = sc.intCustomerStorageId)
	

)t

UNION
SELECT --Direct from Invoice
 strItemNo
	, dtmDate
	,dblInQty AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,0 AS dblUnpaidBalance
	,ABS(isnull(dblOutQty, 0)) * -1 as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intInventoryReceiptItemId
FROM (
SELECT
	CONVERT(VARCHAR(10), I.dtmPostDate, 110) dtmDate
	,0 dblUnitCost1
	,I.intInvoiceId intInventoryReceiptItemId
	,Itm.strItemNo
	,0.0 dblInQty
	,isnull(ID.dblQtyShipped, 0) AS dblOutQty
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
AND ID.strShipmentNumber = ''
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

UNION
SELECT --Direct Inventory Shipment (This will show the Invoice Number once Shipment is invoiced)
 strItemNo
	, dtmDate
	,0 AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,0 AS dblUnpaidBalance
	,dblInQty as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intInventoryShipmentItemId
FROM (
	SELECT 
		CONVERT(VARCHAR(10), S.dtmShipDate, 110) dtmDate
		,SI.dblUnitPrice dblUnitCost1
		,SI.intInventoryShipmentItemId
		,Itm.strItemNo
		,ABS(isnull(SI.dblQuantity, 0)) * -1 dblInQty
		,0 AS dblOutQty
		,'' strDistributionOption
		,CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.strInvoiceNumber ELSE  S.strShipmentNumber END AS strReceiptNumber
		,CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL THEN I.intInvoiceId ELSE  S.intInventoryShipmentId END  AS intReceiptId
	FROM tblICInventoryShipmentItem SI 
	INNER JOIN tblICInventoryShipment S ON S.intInventoryShipmentId = SI.intInventoryShipmentId
	INNER JOIN tblICItem Itm ON Itm.intItemId = SI.intItemId
	INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
	LEFT JOIN tblARInvoiceDetail ID ON SI.intInventoryShipmentItemId = ID.intInventoryShipmentItemId AND ID.intInventoryShipmentItemId IS NOT NULL
	LEFT JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	WHERE S.ysnPosted = 1
	AND convert(DATETIME, CONVERT(VARCHAR(10), S.dtmShipDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
	AND C.intCommodityId = @intCommodityId 
	AND Itm.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
	AND S.intShipFromLocationId = case when isnull(@intLocationId,0)=0 then S.intShipFromLocationId else @intLocationId end 
	AND S.intShipFromLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND SI.intOwnershipType = 1
	AND S.intSourceType = 0
)t

UNION
SELECT --Direct Inventory Receipt (This will show the Bill Number once Receipt is vouchered)
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
		CONVERT(VARCHAR(10), R.dtmReceiptDate, 110) dtmDate
		,RI.dblUnitCost dblUnitCost1
		,RI.intInventoryReceiptItemId
		,Itm.strItemNo
		,isnull(RI.dblOpenReceive, 0) dblInQty
		,0 AS dblOutQty
		,'' strDistributionOption
		,CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.strBillId ELSE  R.strReceiptNumber END AS strReceiptNumber
		,CASE WHEN BD.intInventoryReceiptItemId IS NOT NULL THEN B.intBillId ELSE  R.intInventoryReceiptId END  AS intReceiptId
	FROM tblICInventoryReceiptItem RI 
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	INNER JOIN tblICItem Itm ON Itm.intItemId = RI.intItemId
	INNER JOIN tblICCommodity C ON Itm.intCommodityId = C.intCommodityId
	LEFT JOIN tblAPBillDetail BD ON RI.intInventoryReceiptItemId = BD.intInventoryReceiptItemId AND BD.intInventoryReceiptItemId IS NOT NULL
	LEFT JOIN tblAPBill B ON BD.intBillId = B.intBillId
	WHERE R.ysnPosted = 1
	AND convert(DATETIME, CONVERT(VARCHAR(10), R.dtmReceiptDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
	AND C.intCommodityId = @intCommodityId 
	AND Itm.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN Itm.intItemId ELSE @intItemId END 
	AND R.intLocationId = case when isnull(@intLocationId,0)=0 then R.intLocationId else @intLocationId end 
	AND R.intLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND RI.intOwnershipType = 1
	AND R.intSourceType = 0
)t

UNION --DP with Settle Storage
SELECT
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
			CASE WHEN SS.intBillId IS NULL THEN CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110) ELSE CONVERT(VARCHAR(10), SS.dtmCreated, 110) END dtmDate
		,RI.dblUnitCost dblUnitCost1
		,intCustomerStorageId as intInventoryReceiptItemId
		,I.strItemNo
		,CASE WHEN SS.intBillId IS NULL THEN isnull(RI.dblNet, 0) ELSE SS.dblOpenBalance END dblInQty
		,0 AS dblOutQty
		,ST.strDistributionOption
		,CASE WHEN SS.strStorageTicketNumber IS NULL THEN R.strReceiptNumber ELSE  SS.strStorageTicketNumber END AS strReceiptNumber
		,CASE WHEN SS.intCustomerStorageId IS NULL THEN R.intInventoryReceiptId ELSE SS.intCustomerStorageId END AS intReceiptId
		--,Inv.strInvoiceNumber AS strReceiptNumber
		--,Inv.intInvoiceId AS intReceiptId
	FROM vyuSCTicketView ST
	INNER JOIN tblICInventoryReceiptItem RI ON ST.intTicketId = RI.intSourceId
	INNER JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = RI.intInventoryReceiptId
	INNER JOIN tblICItem I ON I.intItemId = ST.intItemId
	CROSS APPLY (
		select
			dblSettleUnits,
			gr.dtmCreated,
			cs.intCustomerStorageId, 
			cs.strStorageTicketNumber,
			intBillId ,
			cs.dblOpenBalance
		from tblGRSettleStorage gr 
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN vyuSCGetScaleDistribution sd ON  grt.intCustomerStorageId = sd.intCustomerStorageId
			INNER JOIN tblGRCustomerStorage cs ON sd.intCustomerStorageId = cs.intCustomerStorageId
		where sd.intInventoryReceiptItemId = RI.intInventoryReceiptItemId and intBillId IS NOT NULL
	) SS
	WHERE ST.strTicketStatus = 'C'
	AND convert(DATETIME, CONVERT(VARCHAR(10), ST.dtmTicketDateTime, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) 
	AND ST.intCommodityId = @intCommodityId 
	AND ST.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN ST.intItemId ELSE @intItemId END 
	AND ST.intTicketLocationId = case when isnull(@intLocationId,0)=0 then ST.intTicketLocationId else @intLocationId end 
	AND ST.intTicketLocationId IN (
			SELECT intCompanyLocationId
			FROM tblSMCompanyLocation
			WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
			)
	AND RI.intOwnershipType = 1
	AND ST.strDistributionOption = 'DP'
	AND SS.dblOpenBalance <> 0
) t

SELECT convert(INT, ROW_NUMBER() OVER (
			ORDER BY dtmDate
			)) intRowNum
	,ISNULL(dtmDate,'') dtmDate
	,strDistributionOption [strDistribution]
	,dblUnpaidIn [dblUnpaidIN]
	,dblUnpaidOut [dblUnpaidOut]
	,dblUnpaidBalance [dblUnpaidBalance]
	,dblPaidBalance
	,InventoryBalanceCarryForward dblInventoryBalanceCarryForward
	,strReceiptNumber
	,intReceiptId
FROM @tblResult T1
--WHERE ISNULL(T1.dtmDate ,'') <> '' AND ISNULL(T1.strReceiptNumber,'') <> ''
ORDER BY intRowNum
	,dtmDate DESC,
	strReceiptNumber DESC