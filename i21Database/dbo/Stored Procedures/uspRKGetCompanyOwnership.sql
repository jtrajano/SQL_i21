CREATE PROC [dbo].[uspRKGetCompanyOwnership]
          @dtmFromTransactionDate datetime = null,
          @dtmToTransactionDate datetime = null,
          @intCommodityId int =  null,
          @intItemId int= null,
		  @strPositionIncludes nvarchar(100) = NULL
AS

DECLARE @tblResult TABLE (
	Id INT identity(1, 1)
	,dtmDate DATETIME
	,strItemNo NVARCHAR(50)
	,dblUnpaidIn NUMERIC(24, 10)
	,dblUnpaidOut NUMERIC(24, 10)
	,dblUnpaidBalance NUMERIC(24, 10)
	,strDistributionOption NVARCHAR(50)
	,InventoryBalanceCarryForward NUMERIC(24, 10)
	,strReceiptNumber NVARCHAR(50)
	,intReceiptId INT
	)
DECLARE @intCommodityUnitMeasureId INT = NULL

SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
FROM tblICCommodityUnitMeasure
WHERE intCommodityId = @intCommodityId AND ysnDefault = 1

INSERT INTO @tblResult (
	dblUnpaidBalance
	,InventoryBalanceCarryForward
	)
SELECT sum(dblUnpaidBalance)
	,sum(InventoryBalanceCarryForward)
FROM (
	SELECT sum(dblUnpaidIn) - sum(dblUnpaidIn - dblUnpaidOut) dblUnpaidBalance
		,(
			SELECT sum(BalanceForward)
			FROM (
				SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId, @intCommodityUnitMeasureId, dblQty) BalanceForward
				FROM tblICInventoryTransaction it
				JOIN tblICItem i ON i.intItemId = it.intItemId AND it.intTransactionTypeId IN (4, 5, 10, 23)
				JOIN tblICItemUOM u ON it.intItemId = u.intItemId AND u.intItemUOMId = it.intItemUOMId
				JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = @intCommodityId AND u.intUnitMeasureId = ium.intUnitMeasureId
				JOIN tblICItemLocation il ON it.intItemLocationId = il.intItemLocationId AND isnull(il.strDescription, '') <> 'In-Transit' AND il.intLocationId IN (
						SELECT intCompanyLocationId
						FROM tblSMCompanyLocation
						WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
						)
				WHERE i.intCommodityId = @intCommodityId AND convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(i.strType, '') <> 'Other Charge'
				) t
			) InventoryBalanceCarryForward
	FROM (
		SELECT dblInQty dblUnpaidIn
			,dblOutQty dblUnpaidOut
		FROM (
			SELECT DISTINCT CONVERT(VARCHAR(10), b.dtmDate, 110) dtmDate
				,dblUnitCost dblUnitCost1
				,ir.intInventoryReceiptItemId
				,i.strItemNo
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(bd.dblQtyReceived, 0)) dblInQty
				,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(
					bd.dblTotal - isnull((
							SELECT CASE WHEN sum(pd.dblPayment) - max(dblTotal) = 0 THEN bd.dblTotal ELSE sum(pd.dblPayment) END
							FROM tblAPPaymentDetail pd
							WHERE pd.intBillId = b.intBillId AND intConcurrencyId <> 0
							), 0)
					) / CASE WHEN isnull(bd.dblCost, 0) = 0 THEN 1 ELSE dblCost END) AS dblOutQty
				,strDistributionOption
				,b.strBillId AS strReceiptNumber
				,b.intBillId AS intReceiptId
			FROM tblAPBill b
			JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId
			JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId AND b.intShipToId IN (
					SELECT intCompanyLocationId
					FROM tblSMCompanyLocation
					WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
					)
			JOIN tblICItem i ON i.intItemId = bd.intItemId
			join tblICItemUOM u on i.intItemId=u.intItemId and u.intItemUOMId=bd.intWeightUOMId 
			JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
			LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
			WHERE CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
			) t
		) t2
	
	UNION
	
	select sum(dblUnpaidBalance) dblUnpaidBalance,null InventoryBalanceCarryForward from(
	SELECT dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,st.dblGrossUnits) AS dblUnpaidBalance		
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
	JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
	JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId   
	WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) < convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge' AND i.intCommodityId = @intCommodityId
	) t3)t4

INSERT INTO @tblResult (
	strItemNo
	,dtmDate
	,dblUnpaidIn
	,dblUnpaidOut
	,dblUnpaidBalance
	,strDistributionOption
	,strReceiptNumber
	,intReceiptId
	)
SELECT strItemNo
	,dtmDate
	,dblUnpaidIn
	,dblUnpaidIn - dblUnpaidOut dblUnpaidOut
	,dblUnpaidOut dblUnpaidBalance
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
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,isnull(bd.dblQtyReceived, 0)) dblInQty
			,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,(
				bd.dblTotal - isnull((
						SELECT CASE WHEN sum(pd.dblPayment) - max(dblTotal) = 0 THEN bd.dblTotal ELSE sum(pd.dblPayment) END
						FROM tblAPPaymentDetail pd
						WHERE pd.intBillId = b.intBillId AND intConcurrencyId <> 0
						), 0)
				) / CASE WHEN isnull(bd.dblCost, 0) = 0 THEN 1 ELSE dblCost END) AS dblOutQty
			,strDistributionOption
			,b.strBillId AS strReceiptNumber
			,b.intBillId AS intReceiptId
		FROM tblAPBill b
		JOIN tblAPBillDetail bd ON b.intBillId = bd.intBillId AND b.intShipToId IN (
				SELECT intCompanyLocationId
				FROM tblSMCompanyLocation
				WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'licensed storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
				)
		JOIN tblICInventoryReceiptItem ir ON bd.intInventoryReceiptItemId = ir.intInventoryReceiptItemId
		JOIN tblICItem i ON i.intItemId = bd.intItemId
		JOIN tblICItemUOM u on i.intItemId=u.intItemId and u.intItemUOMId=bd.intWeightUOMId 
		JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId  
		LEFT JOIN tblSCTicket st ON st.intTicketId = ir.intSourceId
		WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110), 110) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110), 110) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
		) t
	) t2

UNION

SELECT i.strItemNo
	,CONVERT(VARCHAR(10), dtmTicketDateTime, 110) AS dtmDate
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,st.dblGrossUnits) AS dblUnpaidIn
	,0 AS dblUnpaidOut
	,dbo.fnCTConvertQuantityToTargetCommodityUOM(intCommodityUnitMeasureId,@intCommodityUnitMeasureId,st.dblGrossUnits)  AS dblUnpaidBalance
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
JOIN tblICItemUOM u on st.intItemId=u.intItemId and u.ysnStockUnit=1
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=@intCommodityId AND u.intUnitMeasureId=ium.intUnitMeasureId   
WHERE convert(DATETIME, CONVERT(VARCHAR(10), dtmTicketDateTime, 110)) BETWEEN convert(DATETIME, CONVERT(VARCHAR(10), @dtmFromTransactionDate, 110)) AND convert(DATETIME, CONVERT(VARCHAR(10), @dtmToTransactionDate, 110)) AND i.intCommodityId = @intCommodityId AND i.intItemId = CASE WHEN isnull(@intItemId, 0) = 0 THEN i.intItemId ELSE @intItemId END AND isnull(strType, '') <> 'Other Charge'
ORDER BY dtmDate

SELECT convert(INT, ROW_NUMBER() OVER (
			ORDER BY dtmDate
			)) intRowNum
	,dtmDate dtmDate
	,strDistributionOption [strDistribution]
	,dblUnpaidIn [dblUnpaidIN]
	,dblUnpaidOut [dblUnpaidOut]
	,dblUnpaidBalance [dblUnpaidBalance]
	,InventoryBalanceCarryForward dblInventoryBalanceCarryForward
	,strReceiptNumber
	,intReceiptId
FROM @tblResult T1
ORDER BY dtmDate
	,strReceiptNumber ASC
