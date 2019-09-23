/*  
 This stored procedure is used to check if there are overflow on checks
*/ 
CREATE PROCEDURE uspCMCheckPrint_GetCheckOverflow
	@intBankAccountId INT = NULL,
	@strTransactionIds NVARCHAR(MAX) = NULL,
	@ysnCheckOverflow INT = NULL OUTPUT 
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @BANK_DEPOSIT INT = 1
		,@BANK_WITHDRAWAL INT = 2
		,@MISC_CHECKS INT = 3
		,@BANK_TRANSFER INT = 4
		,@BANK_TRANSACTION INT = 5
		,@CREDIT_CARD_CHARGE INT = 6
		,@CREDIT_CARD_RETURNS INT = 7
		,@CREDIT_CARD_PAYMENTS INT = 8
		,@BANK_TRANSFER_WD INT = 9
		,@BANK_TRANSFER_DEP INT = 10
		,@ORIGIN_DEPOSIT AS INT = 11
		,@ORIGIN_CHECKS AS INT = 12
		,@ORIGIN_EFT AS INT = 13
		,@ORIGIN_WITHDRAWAL AS INT = 14
		,@ORIGIN_WIRE AS INT = 15
		,@AP_PAYMENT AS INT = 16
		,@BANK_STMT_IMPORT AS INT = 17
		,@AR_PAYMENT AS INT = 18
		,@VOID_CHECK AS INT = 19
		,@AP_ECHECK AS INT = 20
		,@PAYCHECK AS INT = 21
		,@ACH AS INT = 22
		,@DIRECT_DEPOSIT AS INT = 23

--Check if there are any check overflow
;WITH QUERY AS(
SELECT TOP 1 1 ysnCheckOverflow
FROM	dbo.tblCMBankTransaction CHK
		INNER JOIN tblAPPayment PYMT
			ON CHK.strTransactionId = PYMT.strPaymentRecordNum			
WHERE	CHK.intBankAccountId = @intBankAccountId
		AND CHK.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		--AND PRINTSPOOL.strBatchId =  PRINTSPOOL.strBatchId
		AND (SELECT COUNT(intPaymentId) FROM tblAPPaymentDetail WHERE intPaymentId = PYMT.intPaymentId) > 10
UNION		
SELECT TOP 1 1
FROM	[dbo].[tblCMBankTransaction] CM 
INNER JOIN [dbo].[tblAPPayment] PYMT ON CM.strTransactionId = PYMT.strPaymentRecordNum
INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail ON PYMT.intPaymentId = PYMTDetail.intPaymentId
INNER JOIN [dbo].[tblAPBill] A ON PYMTDetail.intBillId = A.intBillId
INNER JOIN tblAPBillDetail B ON A.intBillId = B.intBillId
INNER JOIN tblSCTicket C ON B.intScaleTicketId = C.intTicketId
INNER JOIN tblCTContractHeader D ON B.intContractHeaderId = D.intContractHeaderId
INNER JOIN (tblICInventoryReceipt E INNER JOIN tblICInventoryReceiptItem F ON E.intInventoryReceiptId = F.intInventoryReceiptId)
ON C.intTicketId = F.intSourceId AND E.intSourceType = 1
WHERE CM.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
UNION
SELECT TOP 1 1 
FROM	[dbo].[tblCMBankTransaction] CM INNER JOIN [dbo].[tblAPPayment] PYMT
				ON CM.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblAPBill] BILL
				ON PYMTDetail.intBillId = BILL.intBillId
			INNER JOIN [dbo].[tblAPBillDetail] BILLDETAIL
				ON BILL.intBillId = BILLDETAIL.intBillId
			INNER JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
				ON BILLDETAIL.intContractHeaderId = CONTRACTHEADER.intContractHeaderId
			LEFT JOIN [dbo].tblICItem ITEM
				ON BILLDETAIL.intItemId = ITEM.intItemId
	WHERE CM.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
			AND CM.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK, @ACH, @DIRECT_DEPOSIT)
UNION SELECT TOP 1 1
FROM	[dbo].[tblCMBankTransaction] CM INNER JOIN [dbo].[tblAPPayment] PYMT
				ON CM.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblARInvoice] INV
				ON PYMTDetail.intInvoiceId = INV.intInvoiceId
			INNER JOIN [dbo].[tblARInvoiceDetail] INVDETAIL
				ON INV.intInvoiceId = INVDETAIL.intInvoiceId
			INNER JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
				ON INVDETAIL.intContractHeaderId = CONTRACTHEADER.intContractHeaderId
			LEFT JOIN [dbo].tblICItem ITEM
				ON INVDETAIL.intItemId = ITEM.intItemId
WHERE CM.strTransactionId IN (SELECT strValues COLLATE Latin1_General_CI_AS FROM dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
AND CM.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK, @ACH, @DIRECT_DEPOSIT)
)
SELECT @ysnCheckOverflow = 1 FROM QUERY

SELECT @ysnCheckOverflow = ISNULL(@ysnCheckOverflow, 0)