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
	INNER JOIN tblICItem item 
		ON item.intItemId = R.intItemId
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
	INNER JOIN tblGRDiscountScheduleCode DSC
		ON DSC.intDiscountScheduleCodeId = TD.intDiscountScheduleCodeId
			AND DSC.intItemId = item.intItemId
	INNER JOIN tblICInventoryReceiptCharge IRC
		ON IRC.intInventoryReceiptChargeId = R.intInventoryReceiptChargeId
	OUTER APPLY (
		SELECT TOP 1 IL.intItemLocationId
		FROM tblAPBillDetail A
		INNER JOIN tblICItem IC
			ON IC.intItemId = A.intItemId
				AND IC.strType = 'Inventory'
		INNER JOIN tblICItemLocation IL
			ON IL.intItemId = IC.intItemId
				AND IL.intLocationId = A.intLocationId
		WHERE intBillId = R.intBillId			
	) ITEM
	OUTER APPLY (
		SELECT TOP 1 stockUnit.*
		FROM tblICItemUOM stockUnit 
		WHERE 
			item.intItemId = stockUnit.intItemId 
		AND stockUnit.ysnStockUnit = 1
	) itemUOM
	WHERE IRC.intInventoryReceiptChargeId = @intInventoryReceiptChargeId

	RETURN;
END