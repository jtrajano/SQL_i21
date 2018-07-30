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
				,(bd.dblTotal - isnull((
							SELECT CASE WHEN sum(pd.dblPayment) - max(dblTotal) = 0 THEN bd.dblTotal ELSE sum(pd.dblPayment) END
							FROM tblAPPaymentDetail pd
							WHERE pd.intBillId = b.intBillId AND intConcurrencyId <> 0
							), 0)
					) / CASE WHEN isnull(bd.dblCost, 0) = 0 THEN 1 ELSE dblCost END AS dblOutQty
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
	,dblUnpaidIn -  dblUnpaidOut as dblPaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intReceiptId
FROM (
	SELECT *
		,round(dblInQty, 2) dblUnpaidIn
		,round(dblOutQty, 2) dblUnpaidOut
	FROM (
		SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
			,dblUnitCost dblUnitCost1
			,ir.intInventoryReceiptItemId
			,i.strItemNo
			,isnull(bd.dblQtyReceived, 0) dblInQty
			,(
				bd.dblTotal - isnull((
						SELECT CASE WHEN sum(pd.dblPayment) - max(dblTotal) = 0 THEN bd.dblTotal ELSE sum(pd.dblPayment) END
						FROM tblAPPaymentDetail pd
						WHERE pd.intBillId = b.intBillId AND intConcurrencyId <> 0
						), 0)
				) / CASE WHEN isnull(bd.dblCost, 0) = 0 THEN 1 ELSE dblCost END AS dblOutQty
			,strDistributionOption
			,b.strBillId AS strReceiptNumber
			,b.intBillId AS intReceiptId
		FROM tblAPBill b
		JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		INNER JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId
		LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
		LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
		WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
			AND b.intShipToId = case when isnull(@intLocationId,0)=0 then b.intShipToId else @intLocationId end 
		) t

		UNION
		
		SELECT *
			,round(dblInQty, 2) dblUnpaidIn
			,round(dblOutQty, 2) dblUnpaidOut
		FROM (
			SELECT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				,grt.dblUnits dblUnitCost1
				,'' as intInventoryReceiptItemId--ir.intInventoryReceiptItemId
				,i.strItemNo
				,isnull(bd.dblQtyReceived, 0) dblInQty
				,(
					bd.dblTotal - isnull((
							SELECT CASE WHEN sum(pd.dblPayment) - max(dblTotal) = 0 THEN bd.dblTotal ELSE sum(pd.dblPayment) END
							FROM tblAPPaymentDetail pd
							WHERE pd.intBillId = b.intBillId AND intConcurrencyId <> 0
							), 0)
					) / CASE WHEN isnull(bd.dblCost, 0) = 0 THEN 1 ELSE dblCost END AS dblOutQty
				,st.strDistributionOption
				,b.strBillId AS strReceiptNumber
				,b.intBillId AS intReceiptId
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			INNER JOIN tblGRSettleStorage gr ON gr.intBillId = b.intBillId
			INNER JOIN tblGRSettleStorageTicket grt ON gr.intSettleStorageId = grt.intSettleStorageId
			INNER JOIN tblGRCustomerStorage grs ON  grt.intCustomerStorageId = grs.intCustomerStorageId
			LEFT JOIN tblICItem i ON i.intItemId = bd.intItemId
			LEFT JOIN vyuSCTicketView st ON st.intTicketId = grs.intTicketId
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

UNION 
SELECT
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
)t




SELECT convert(INT, ROW_NUMBER() OVER (
			ORDER BY dtmDate
			)) intRowNum
	,dtmDate dtmDate
	,strDistributionOption [strDistribution]
	,dblUnpaidIn [dblUnpaidIN]
	,dblUnpaidOut [dblUnpaidOut]
	,dblUnpaidBalance [dblUnpaidBalance]
	,dblPaidBalance
	,InventoryBalanceCarryForward dblInventoryBalanceCarryForward
	,strReceiptNumber
	,intReceiptId
FROM @tblResult T1
WHERE ISNULL(T1.dtmDate ,'') <> '' AND ISNULL(T1.strReceiptNumber,'') <> ''
ORDER BY dtmDate DESC
	,strReceiptNumber DESC