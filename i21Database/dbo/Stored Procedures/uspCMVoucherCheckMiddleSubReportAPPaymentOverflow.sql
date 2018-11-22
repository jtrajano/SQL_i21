﻿/*  
 This stored procedure is used as data source in the Voucher Check Middle AP Sub Report Overflow 
*/  
CREATE PROCEDURE [dbo].[uspCMVoucherCheckMiddleSubReportAPPaymentOverflow]
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
  
WITH Invoices as(

		SELECT 
				intTransactionId = F.intTransactionId
				,strBillId = BILL.strBillId
				,strInvoice = BILL.strVendorOrderNumber
				,dtmDate = BILL.dtmBillDate
				,dtmDueDate = BILL.dtmDueDate
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
				,strPaymentRecordNum  = PYMT.strPaymentRecordNum
				,dblTotalAmount = F.dblAmount
				,dtmCheckDate = F.dtmDate
				,strCheckNumber = F.strReferenceNo
				,PYMTDetail.intPaymentDetailId
				,F.intCurrencyId
		FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
					ON F.strTransactionId = PYMT.strPaymentRecordNum
				INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
					ON PYMT.intPaymentId = PYMTDetail.intPaymentId
				INNER JOIN [dbo].[tblAPBill] BILL
					ON PYMTDetail.intBillId = BILL.intBillId	
		WHERE	F.intTransactionId =ISNULL(@intTransactionIdFrom, F.intTransactionId)
				AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)

		UNION ALL SELECT
			intTransactionId = F.intTransactionId
			,strBillId = preBILL.strBillId
			,strInvoice = preBILL.strVendorOrderNumber
			,dtmDate = preBILL.dtmBillDate
			,dtmDueDate = preBILL.dtmDueDate
			,intTermsId = preBILL.intTermsId
			,strComment = SUBSTRING(preBILL.strComment,1,25)
			,dblAmount = CASE WHEN preBILL.intTransactionType = 3
						THEN preBILL.dblTotal * -1
						ELSE preBILL.dblTotal
						END
			,dblDiscount = preBILL.dblDiscount
			,dblNet = preBILL.dblTotal * -1
			,strPaymentRecordNum  = PYMT.strPaymentRecordNum
			,dblTotalAmount = F.dblAmount
			,dtmCheckDate = F.dtmDate
			,strCheckNumber = F.strReferenceNo
			,PYMTDetail.intPaymentDetailId
			,F.intCurrencyId
		FROM	[dbo].[tblCMBankTransaction] F
			INNER JOIN [dbo].[tblAPPayment] PYMT
				ON PYMT.strPaymentRecordNum = F.strTransactionId
			INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
				ON PYMTDetail.intPaymentId = PYMT.intPaymentId
			INNER JOIN [dbo].[tblAPBill] BILL
				ON BILL.intBillId = PYMTDetail.intBillId
			INNER JOIN [dbo].[tblAPAppliedPrepaidAndDebit] PreAndDeb 
				ON PreAndDeb.intBillId = BILL.intBillId
			INNER JOIN [dbo].[tblAPBill] preBILL
					ON preBILL.intBillId = PreAndDeb.intTransactionId
			WHERE  PreAndDeb.ysnApplied = 1 AND 
					F.intTransactionId = ISNULL(@intTransactionIdFrom, F.intTransactionId)

		UNION ALL SELECT 
				intTransactionId = F.intTransactionId
				,strBillId = INV.strInvoiceNumber
				,strInvoice = ''
				,dtmDate = INV.dtmDate
				,dtmDueDate = INV.dtmDueDate
				,intTermsId = INV.intTermId
				,strComment = SUBSTRING(INV.strComments,1,25)
				,dblAmount = INV.dblInvoiceTotal
				,dblDiscount = CASE WHEN PYMTDetail.dblDiscount <> 0 
						THEN PYMTDetail.dblDiscount 
						ELSE  PYMTDetail.dblInterest 
						END
				,dblNet =  PYMTDetail.dblPayment
				,strPaymentRecordNum  = PYMT.strPaymentRecordNum
				,dblTotalAmount = F.dblAmount
				,dtmCheckDate = F.dtmDate
				,strCheckNumber = F.strReferenceNo
				,PYMTDetail.intPaymentDetailId
				,F.intCurrencyId
		FROM	[dbo].[tblCMBankTransaction] F INNER JOIN [dbo].[tblAPPayment] PYMT
					ON F.strTransactionId = PYMT.strPaymentRecordNum
				INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
					ON PYMT.intPaymentId = PYMTDetail.intPaymentId
				INNER JOIN [dbo].[tblARInvoice] INV
					ON PYMTDetail.intInvoiceId = INV.intInvoiceId	
		WHERE	F.intTransactionId =ISNULL(@intTransactionIdFrom, F.intTransactionId)
				AND F.intBankTransactionTypeId IN (@AP_PAYMENT, @AP_ECHECK)

),
_Order AS
(
	SELECT 
			a.*
			,b.strTerm
			,c.strCurrency
			,ROW_NUMBER() OVER (ORDER BY intPaymentDetailId ASC) AS [row_number]

	 FROM Invoices a
	 LEFT JOIN tblSMTerm b ON a.intTermsId = b.intTermID
	 LEFT JOIN tblSMCurrency c ON a.intCurrencyId = c.intCurrencyID
)
SELECT * FROM _Order
 
WHERE [row_number] > 10