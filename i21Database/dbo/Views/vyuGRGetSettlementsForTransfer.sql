CREATE VIEW [dbo].[vyuGRGetSettlementsForTransfer]
AS
SELECT * FROM (
SELECT AP.intBillId
	,AP.strBillId
	,AP.strVendorOrderNumber
	,intEntityId = AP.intEntityVendorId
	,intCompanyLocationId = AP.intShipToId
	,dblAmountDue = AP.dblAmountDue - ISNULL(TSR.dblTransferredAmount,0)
	,AP.intCurrencyId
	,AP.dtmDate
	,IC.intCommodityId
	,IC.intItemId
	,IC.strItemNo
	,BD.strMiscDescription
	,dblQtyReceived = ISNULL(BD.dblQtyReceived,0) - ISNULL(TSR.dblTransferredUnits,0)
	,TSR.intBillFromId
	--,TSR.dblTransferredAmount
	--,TSR.dblTransferredUnits
	,BD.intAccountId
	,BD.intBillDetailId
	--,dblQtyReceived2= ISNULL(BD.dblQtyReceived,0)
	--,dblTransferredAmount =ISNULL(TSR.dblTransferredAmount,0)
FROM tblAPBill AP
LEFT JOIN (
	tblAPBillDetail BD
	INNER JOIN tblICItem IC
		ON IC.intItemId = BD.intItemId
			AND IC.strType = 'Inventory'
	)
	ON BD.intBillId = AP.intBillId
LEFT JOIN (
	SELECT intBillAdjId = ISNULL(ADJ.intBillId, ADJS.intBillId)
	FROM tblGRAdjustSettlements ADJ	
	LEFT JOIN tblGRAdjustSettlementsSplit ADJS
		ON ADJS.intAdjustSettlementId = ADJ.intAdjustSettlementId
	WHERE ADJ.intTypeId = 1
) Adjust_Settlements
	ON Adjust_Settlements.intBillAdjId = AP.intBillId
OUTER APPLY (
	SELECT intBillFromId
		,dblTransferredAmount = SUM(dblSettlementAmount)
		,dblTransferredUnits = SUM(dblUnits)
	FROM tblGRTransferSettlementReference
	WHERE intBillFromId = AP.intBillId
		AND intBillDetailFromId = BD.intBillDetailId
	GROUP BY intBillFromId
) TSR
WHERE AP.intTransactionType = 1 
	AND AP.dblAmountDue > 0 
	AND AP.ysnPosted = 1
	AND (BD.intBillId IS NOT NULL OR Adjust_Settlements.intBillAdjId IS NOT NULL)
) A
WHERE dblAmountDue > 0