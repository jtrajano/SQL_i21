/*  
 This stored procedure is used to check if there are overflow on checks
*/ 
CREATE PROCEDURE uspCMCheckPrint_GetCheckSettlement
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@ysnCheckSettlement INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF EXISTS( 
		SELECT TOP 1 1
    	FROM dbo.tblCMBankTransaction CHK 
			JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
			JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
    	WHERE INVRCPTITEM.intSourceId IS NOT NULL 
			AND PYMT.strPaymentRecordNum IN  (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds)) --('PAY-153')
			AND PYMT.intEntityVendorId = INVRCPT.intEntityVendorId
			AND INVRCPT.intSourceType = 1 -- originated from scale

	UNION ALL
		SELECT TOP 1 1 
		FROM dbo.tblCMBankTransaction CHK 
			JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
		WHERE PYMT.strPaymentRecordNum IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
	UNION ALL
		SELECT TOP 1 1
		FROM dbo.tblCMBankTransaction CHK 
			JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
			JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
			JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
			JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
			JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
			JOIN tblSCTicket TKT ON BillDtl.intScaleTicketId = TKT.intTicketId
		WHERE  PYMT.intEntityVendorId = TKT.intEntityId 
			AND PYMT.strPaymentRecordNum IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		)
	BEGIN
		SET @ysnCheckSettlement = 1
	END

SET @ysnCheckSettlement = ISNULL(@ysnCheckSettlement, 0)