/*  
 This stored procedure is used as data source for "Check Voucher Middle Sub Report AP Payment"
*/  
CREATE  PROCEDURE [dbo].[uspCMVoucherCheckMiddleSubReportAPPayment]  
	@intTransactionIdFrom INT = 0   
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
  ,@PAYCHECK AS INT = 21;
WITH InvoiceType As(
	select 0 intTransactionType, 'Invoice', strTransactionType UNION ALL
	select 1 intTransactionType , 'Voucher' strTransactionType UNION ALL
	select 2 intTransactionType , 'Prepayment' strTransactionType UNION ALL
	select 3 intTransactionType , 'Debit Memo' strTransactionType UNION ALL
	select 9 intTransactionType , '1099 Adjustment' strTransactionType UNION ALL
	select 11 intTransactionType , 'Claim' strTransactionType UNION ALL
	select 12 intTransactionType , 'Prepayment Reversal' strTransactionType UNION ALL
	select 13 intTransactionType , 'Basis Advance' strTransactionType UNION ALL
	select 14 intTransactionType , 'Deferred Interest' strTransactionType
),
Invoices AS(
	SELECT  
			intTransactionId = F.intTransactionId
			,strBillId = BILL.strBillId
			,strInvoice = BILL.strVendorOrderNumber
			,dtmDueDate = BILL.dtmDueDate
			,dtmDate = BILL.dtmBillDate
			,intTermsId = BILL.intTermsId
			,strComment = SUBSTRING(BILL.strComment,1,25)
			,dblAmount = CASE WHEN BILL.intTransactionType = 3
						THEN BILL.dblTotal * -1
						ELSE BILL.dblTotal
						END
			,dblDiscount = CASE WHEN PYMTDetail.dblDiscount <> 0 
						THEN PYMTDetail.dblDiscount 
						ELSE  PYMTDetail.dblInterest 
						END
			,dblNet = CASE WHEN BILL.intTransactionType = 3
						THEN PYMTDetail.dblPayment * -1
						ELSE PYMTDetail.dblPayment
						END
			,BILL.intTransactionType
			,PYMTDetail.intPaymentDetailId
			,F.intCurrencyId
			,F.strReferenceNo strCheckNumber
			,F.dblAmount dblTotalAmount
			,F.dtmDate dtmCheckDate
	FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
				ON F.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblAPBill] BILL
				ON ISNULL(PYMTDetail.intBillId,PYMTDetail.intOrigBillId) = BILL.intBillId
	WHERE	F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)
			AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)

	--Include Prepaid and Debit
	UNION ALL SELECT  
			intTransactionId = F.intTransactionId
			,strBillId = preBILL.strBillId
			,strInvoice = preBILL.strVendorOrderNumber
			,dtmDueDate = preBILL.dtmDueDate
			,dtmDate = preBILL.dtmBillDate
			,intTermsId = preBILL.intTermsId
			,strComment = SUBSTRING(preBILL.strComment,1,25)
			,dblAmount = CASE WHEN preBILL.intTransactionType = 3
						THEN preBILL.dblTotal * -1
						ELSE preBILL.dblTotal
						END
			,dblDiscount = preBILL.dblDiscount
			,dblNet = preBILL.dblTotal * -1
			,preBILL.intTransactionType
			,PYMTDetail.intPaymentDetailId
			,F.intCurrencyId
			,F.strReferenceNo strCheckNumber
			,F.dblAmount dblTotalAmount
			,F.dtmDate dtmCheckDate
	FROM	[dbo].[tblCMBankTransaction] F
		INNER JOIN [dbo].[tblAPPayment] PYMT
			ON PYMT.strPaymentRecordNum = F.strTransactionId
		INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
			ON PYMTDetail.intPaymentId = PYMT.intPaymentId
		INNER JOIN [dbo].[tblAPBill] BILL
			ON ISNULL(PYMTDetail.intBillId,PYMTDetail.intOrigBillId) = BILL.intBillId
		INNER JOIN [dbo].[tblAPAppliedPrepaidAndDebit] PreAndDeb 
			ON PreAndDeb.intBillId = BILL.intBillId
		INNER JOIN [dbo].[tblAPBill] preBILL
				ON preBILL.intBillId = PreAndDeb.intTransactionId
		WHERE  PreAndDeb.ysnApplied = 1 AND 
				F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)

	--Include Invoice
	UNION ALL SELECT
			intTransactionId = F.intTransactionId
			,strBillId = ''
			,strInvoice = INV.strInvoiceNumber
			,dtmDueDate = INV.dtmDueDate
			,dtmDate = INV.dtmDate
			,intTermsId = INV.intTermId
			,strComment = INV.strComments
			,dblAmount = INV.dblInvoiceTotal
			,dblDiscount = CASE WHEN PYMTDetail.dblDiscount <> 0 
						THEN PYMTDetail.dblDiscount 
						ELSE  PYMTDetail.dblInterest 
						END
			,dblNet = PYMTDetail.dblPayment
			,0 AS intTransactionType
			,PYMTDetail.intPaymentDetailId
			,F.intCurrencyId
			,F.strReferenceNo strCheckNumber
			,F.dblAmount dblTotalAmount
			,F.dtmDate dtmCheckDate
	FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
				ON F.strTransactionId = PYMT.strPaymentRecordNum
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMT.intPaymentId = PYMTDetail.intPaymentId
			INNER JOIN [dbo].[tblARInvoice] INV
				ON PYMTDetail.intInvoiceId = INV.intInvoiceId
	WHERE	F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)
			AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)
) 
SELECT
Invoice.*
,InvoiceType.strTransactionType
,Term.strTermCode
,Curr.strCurrency
FROM Invoices Invoice
LEFT JOIN tblSMTerm Term on Invoice.intTermsId = Term.intTermID
LEFT JOIN tblSMCurrency Curr ON Invoice.intCurrencyId = Curr.intCurrencyID
LEFT JOIN InvoiceType ON InvoiceType.intTransactionType = Invoice.intTransactionType
order by strInvoice, intPaymentDetailId