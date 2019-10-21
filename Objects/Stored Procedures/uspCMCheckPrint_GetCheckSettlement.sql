﻿/*  
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


--SELECT TOP 1
--@ysnCheckSettlement = 1	
--FROM	dbo.tblCMBankTransaction CHK 
--		--INNER JOIN dbo.tblCMCheckPrintJobSpool PRINTSPOOL ON CHK.strTransactionId = PRINTSPOOL.strTransactionId
--		--	AND CHK.intBankAccountId = PRINTSPOOL.intBankAccountId
--		INNER JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
--		INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
--		INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
--		INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
--		INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
--		INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
--		INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
--		--INNER JOIN tblSCTicket TICKET ON INVRCPTITEM.intSourceId = TICKET.intTicketId			
--WHERE	CHK.intBankAccountId = @intBankAccountId
--		AND CHK.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
--		AND INVRCPTITEM.intSourceId IS NOT NULL

IF EXISTS( 
				SELECT TOP 1 1
    FROM dbo.tblCMBankTransaction CHK 
      INNER JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
      INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
      INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
      INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
      INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
      INNER JOIN tblICInventoryReceiptItem INVRCPTITEM ON BillDtl.intInventoryReceiptItemId = INVRCPTITEM.intInventoryReceiptItemId
      INNER JOIN tblICInventoryReceipt INVRCPT ON INVRCPTITEM.intInventoryReceiptId = INVRCPT.intInventoryReceiptId
    WHERE  CHK.strTransactionId = CHK.strTransactionId
      AND INVRCPTITEM.intSourceId IS NOT NULL 
      AND PYMT.strPaymentRecordNum IN  (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds)) --('PAY-153')
      AND PYMT.intEntityVendorId = INVRCPT.intEntityVendorId
	  AND INVRCPT.intSourceType = 1 -- originated from scale

				UNION ALL
				SELECT TOP 1 1 
				FROM dbo.tblCMBankTransaction CHK 
				  INNER JOIN tblAPPayment PYMT ON CHK.strTransactionId = PYMT.strPaymentRecordNum
				  INNER JOIN tblAPPaymentDetail PYMTDTL ON PYMT.intPaymentId = PYMTDTL.intPaymentId
				  INNER JOIN tblAPBill Bill ON PYMTDTL.intBillId = Bill.intBillId
				  INNER JOIN tblAPBillDetail BillDtl ON Bill.intBillId = BillDtl.intBillId
				  INNER JOIN tblICItem Item ON BillDtl.intItemId = Item.intItemId
				  INNER JOIN tblGRStorageHistory StrgHstry ON Bill.intBillId = StrgHstry.intBillId
				  WHERE CHK.strTransactionId = CHK.strTransactionId AND PYMT.strPaymentRecordNum IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
			)
	BEGIN
		SET @ysnCheckSettlement = 1
	END

SET @ysnCheckSettlement = ISNULL(@ysnCheckSettlement, 0)