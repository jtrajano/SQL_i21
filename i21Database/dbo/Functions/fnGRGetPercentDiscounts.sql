CREATE FUNCTION [dbo].[fnGRGetPercentDiscounts]
(
	@intInventoryReceiptChargeId INT
	
)
RETURNS @returnTable TABLE 
(
	intInventoryReceiptChargeId INT
	,dblQty DECIMAL(38,20)
)
AS
BEGIN
	
	INSERT INTO @returnTable
	SELECT IRC.intInventoryReceiptChargeId
		,CASE WHEN TD.strCalcMethod = 'Gross Weight' THEN CS.dblGrossQuantity ELSE CS.dblOriginalBalance END
	FROM dbo.tblAPBillDetail R
	INNER JOIN tblAPBill AP
		ON AP.intBillId = R.intBillId
	INNER JOIN tblGRSettleStorageBillDetail SBD
		ON SBD.intBillId = R.intBillId
	INNER JOIN tblGRSettleStorageTicket SST
		ON SST.intSettleStorageId = R.intSettleStorageId
	INNER JOIN tblGRCustomerStorage CS
		ON CS.intCustomerStorageId = SST.intCustomerStorageId
	INNER JOIN tblQMTicketDiscount TD
		ON TD.intTicketFileId = CS.intCustomerStorageId
			AND TD.strSourceType = 'Storage'
			AND TD.strDiscountChargeType = 'Percent'
	INNER JOIN tblICInventoryReceiptCharge IRC
		ON IRC.intInventoryReceiptChargeId = R.intInventoryReceiptChargeId
	WHERE IRC.intInventoryReceiptChargeId = @intInventoryReceiptChargeId

	RETURN;
END