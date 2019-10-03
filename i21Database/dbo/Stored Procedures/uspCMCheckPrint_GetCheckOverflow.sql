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


DECLARE @BANK_DEPOSIT         INT = 1,
        @BANK_WITHDRAWAL      INT = 2,
        @MISC_CHECKS          INT = 3,
        @BANK_TRANSFER        INT = 4,
        @BANK_TRANSACTION     INT = 5,
        @CREDIT_CARD_CHARGE   INT = 6,
        @CREDIT_CARD_RETURNS  INT = 7,
        @CREDIT_CARD_PAYMENTS INT = 8,
        @BANK_TRANSFER_WD     INT = 9,
        @BANK_TRANSFER_DEP    INT = 10,
        @ORIGIN_DEPOSIT       AS INT = 11,
        @ORIGIN_CHECKS        AS INT = 12,
        @ORIGIN_EFT           AS INT = 13,
        @ORIGIN_WITHDRAWAL    AS INT = 14,
        @ORIGIN_WIRE          AS INT = 15,
        @AP_PAYMENT           AS INT = 16,
        @BANK_STMT_IMPORT     AS INT = 17,
        @AR_PAYMENT           AS INT = 18,
        @VOID_CHECK           AS INT = 19,
        @AP_ECHECK            AS INT = 20,
        @PAYCHECK             AS INT = 21,
        @ACH                  AS INT = 22,
        @DIRECT_DEPOSIT       AS INT = 23

DECLARE @cnt INT = 0
DECLARE @tbl TABLE
  (
     strVendorOrderNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS
  )


;WITH CM AS
(
	SELECT strTransactionId, intBankTransactionTypeId FROM tblCMBankTransaction F WHERE
	F.intBankAccountId = @intBankAccountId
	AND F.strTransactionId IN
           (SELECT strValues COLLATE Latin1_General_CI_AS
            FROM   dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
),
PD AS(
SELECT BILL.strVendorOrderNumber
FROM   CM F
       INNER JOIN [dbo].[tblAPPayment] PYMT
               ON F.strTransactionId = PYMT.strPaymentRecordNum
       INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
               ON PYMT.intPaymentId = PYMTDetail.intPaymentId
       INNER JOIN [dbo].[tblAPBill] BILL
               ON ISNULL(PYMTDetail.intBillId, PYMTDetail.intOrigBillId) =
                  BILL.intBillId
WHERE  F.intBankTransactionTypeId IN ( @AP_PAYMENT, @AP_ECHECK )
UNION
SELECT preBILL.strVendorOrderNumber
FROM   CM F
       INNER JOIN [dbo].[tblAPPayment] PYMT
               ON PYMT.strPaymentRecordNum = F.strTransactionId
       INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
               ON PYMTDetail.intPaymentId = PYMT.intPaymentId
       INNER JOIN [dbo].[tblAPBill] BILL
               ON ISNULL(PYMTDetail.intBillId, PYMTDetail.intOrigBillId) =
                  BILL.intBillId
       INNER JOIN [dbo].[tblAPAppliedPrepaidAndDebit] PreAndDeb
               ON PreAndDeb.intBillId = BILL.intBillId
       INNER JOIN [dbo].[tblAPBill] preBILL
               ON preBILL.intBillId = PreAndDeb.intTransactionId
WHERE  PreAndDeb.ysnApplied = 1

UNION
SELECT INV.strInvoiceNumber strVendorOrderNumber
FROM   CM F
       INNER JOIN [dbo].[tblAPPayment] PYMT
               ON F.strTransactionId = PYMT.strPaymentRecordNum
       INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
               ON PYMT.intPaymentId = PYMTDetail.intPaymentId
       INNER JOIN [dbo].[tblARInvoice] INV
               ON PYMTDetail.intInvoiceId = INV.intInvoiceId
WHERE  F.intBankTransactionTypeId IN ( @AP_PAYMENT, @AP_ECHECK )
)
INSERT INTO @tbl (strVendorOrderNumber)
SELECT  strVendorOrderNumber FROM PD
select * from @tbl
SELECT @cnt = Count(1)
FROM   @tbl

IF @cnt < 10
  BEGIN
      DECLARE @tbl1 TABLE
        (
           strVendorOrderNumber NVARCHAR(30) COLLATE Latin1_General_CI_AS
        )
		;WITH CM AS
		(
			SELECT strTransactionId, intBankTransactionTypeId FROM tblCMBankTransaction F WHERE
			F.intBankAccountId = @intBankAccountId
			AND F.strTransactionId IN
				   (SELECT strValues COLLATE Latin1_General_CI_AS
					FROM   dbo.fnARGetRowsFromDelimitedValues(@strTransactionIds))
		),

       BP
           AS (SELECT A.strVendorOrderNumber strVendorOrderNumber
               FROM   CM
                      INNER JOIN [dbo].[tblAPPayment] PYMT
                              ON CM.strTransactionId = PYMT.strPaymentRecordNum
                      INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
                              ON PYMT.intPaymentId = PYMTDetail.intPaymentId
                      INNER JOIN [dbo].[tblAPBill] A
                              ON PYMTDetail.intBillId = A.intBillId
                      INNER JOIN tblAPBillDetail B
                              ON A.intBillId = B.intBillId
                      INNER JOIN tblSCTicket C
                              ON B.intScaleTicketId = C.intTicketId
                      INNER JOIN tblCTContractHeader D
                              ON B.intContractHeaderId = D.intContractHeaderId
                      INNER JOIN (tblICInventoryReceipt E
                                  INNER JOIN tblICInventoryReceiptItem F
                                          ON E.intInventoryReceiptId =
                                 F.intInventoryReceiptId)
                              ON C.intTicketId = F.intSourceId
                                 AND E.intSourceType = 1

               UNION
               SELECT BILL.strVendorOrderNumber strVendorOrderNumber
               FROM   CM
                      INNER JOIN [dbo].[tblAPPayment] PYMT
                              ON CM.strTransactionId = PYMT.strPaymentRecordNum
                      INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
                              ON PYMT.intPaymentId = PYMTDetail.intPaymentId
                      INNER JOIN [dbo].[tblAPBill] BILL
                              ON PYMTDetail.intBillId = BILL.intBillId
                      INNER JOIN [dbo].[tblAPBillDetail] BILLDETAIL
                              ON BILL.intBillId = BILLDETAIL.intBillId
                      INNER JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
                              ON BILLDETAIL.intContractHeaderId =
                                 CONTRACTHEADER.intContractHeaderId
               WHERE  CM.intBankTransactionTypeId IN (
                          @AP_PAYMENT, @AP_ECHECK, @ACH, @DIRECT_DEPOSIT
                                                         )
               UNION
               SELECT INV.strInvoiceNumber strVendorOrderNumber
               FROM   CM
                      INNER JOIN [dbo].[tblAPPayment] PYMT
                              ON CM.strTransactionId = PYMT.strPaymentRecordNum
                      INNER JOIN [dbo].[tblAPPaymentDetail] PYMTDetail
                              ON PYMT.intPaymentId = PYMTDetail.intPaymentId
                      INNER JOIN [dbo].[tblARInvoice] INV
                              ON PYMTDetail.intInvoiceId = INV.intInvoiceId
                      INNER JOIN [dbo].[tblARInvoiceDetail] INVDETAIL
                              ON INV.intInvoiceId = INVDETAIL.intInvoiceId
                      INNER JOIN [dbo].[tblCTContractHeader] CONTRACTHEADER
                              ON INVDETAIL.intContractHeaderId =
                                 CONTRACTHEADER.intContractHeaderId
               WHERE  CM.intBankTransactionTypeId IN ( @AP_PAYMENT, @AP_ECHECK, @ACH, @DIRECT_DEPOSIT ))

	  INSERT INTO @tbl1
      SELECT A.strVendorOrderNumber
      FROM   BP A
             LEFT JOIN @tbl T
                    ON T.strVendorOrderNumber = A.strVendorOrderNumber
      WHERE  T.strVendorOrderNumber IS NULL

      SELECT TOP 1 @ysnCheckOverflow = 1
      FROM   @tbl1
  END
ELSE
  BEGIN
      SELECT @ysnCheckOverflow = 1
  END

SELECT @ysnCheckOverflow = ISNULL(@ysnCheckOverflow, 0)