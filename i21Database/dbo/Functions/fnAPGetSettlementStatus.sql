CREATE FUNCTION [dbo].[fnAPGetSettlementStatus]
(
	@strTransactionId NVARCHAR(100) = NULL
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @hasSettlement BIT = 0;

	IF EXISTS( 
				SELECT TOP 1 1
				FROM tblAPPayment PYMT
				  INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				  INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
				  INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
				  INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
				  INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
				  INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
				WHERE  INVRCPTITEM.intSourceId IS NOT NULL
					AND PYMT.intEntityVendorId = INVRCPT.intEntityVendorId 
				  AND PYMT.strPaymentRecordNum = @strTransactionId
				UNION ALL --DIRECT IN
				SELECT TOP 1 1
				FROM tblAPPayment PYMT
					INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
					INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
					INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
					INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
					INNER JOIN tblSCTicket TKT ON BillDtl.intScaleTicketId = TKT.intTicketId
				WHERE  PYMT.intEntityVendorId = TKT.intEntityId 
					AND PYMT.strPaymentRecordNum = @strTransactionId
				UNION ALL
				SELECT TOP 1 1 
				FROM tblAPPayment PYMT 
				  INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				  INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
				  INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
				  INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
				  --INNER JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
				  INNER JOIN tblGRSettleStorageBillDetail SSBD ON SSBD.intBillId = Bill.intBillId
				  WHERE PYMT.strPaymentRecordNum = @strTransactionId
			)
	BEGIN
		SET @hasSettlement = 1
	END

	RETURN @hasSettlement;

END

GO