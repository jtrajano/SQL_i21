/*  
 This stored procedure is used to check if there are overflow on checks
*/ 
CREATE PROCEDURE uspCMCheckPrint_GetCheckSettlement
	@intBankAccountId INT = NULL,
	@ysnCheckSettlement INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


--Check if there are any check overflow
IF EXISTS (
SELECT TOP 1
1 
FROM	dbo.tblCMBankTransaction CHK 
		INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
			AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
		INNER JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
		INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
		INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
		INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
		INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
		INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
		--INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId			
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId = CHK.strTransactionId
		AND INVRCPTITEM.intSourceId IS NOT NULL

UNION ALL
SELECT TOP 1
1 
FROM	dbo.tblCMBankTransaction CHK 
		INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
			AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
		INNER JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
		INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
		INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
		INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
		INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
		INNER JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
		WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId = CHK.strTransactionId
)
BEGIN
SET @ysnCheckSettlement = 1
END
ELSE
BEGIN
SET @ysnCheckSettlement = 0
END
SET @ysnCheckSettlement = ISNULL(@ysnCheckSettlement, 0)



