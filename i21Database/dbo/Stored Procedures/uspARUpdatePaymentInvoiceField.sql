CREATE PROCEDURE dbo.uspARUpdatePaymentInvoiceField
	  @PaymentIds	Id	READONLY
	, @ysnRebuild	BIT = 0
AS

DECLARE @FinalPaymentId Id 

IF @ysnRebuild = 1
	BEGIN
	    INSERT INTO @FinalPaymentId (intId)
	    SELECT DISTINCT P.intPaymentId 
	    FROM tblARPayment P
        INNER JOIN tblARPaymentDetail PD ON P.intPaymentId= PD.intPaymentId
        WHERE PD.strTransactionNumber IS NOT NULL
		AND PD.intInvoiceId IS NOT NULL
	END
ELSE
	BEGIN
		INSERT INTO @FinalPaymentId (intId)
		SELECT DISTINCT intId 
		FROM @PaymentIds
	END

ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentDelete
ALTER TABLE tblARPayment DISABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail DISABLE TRIGGER trg_tblARPaymentDetailUpdate

UPDATE P

SET strInvoices = TRANSACTIONS.strTransactionId

FROM tblARPayment P
INNER JOIN  @FinalPaymentId FP ON P.intPaymentId=FP.intId
OUTER APPLY (
	SELECT strTransactionId = LEFT(strTransactionId, LEN(strTransactionId) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(T.strTransactionId AS VARCHAR(200))  + ', '
		FROM (
			SELECT strTransactionId = strInvoiceNumber
			FROM dbo.tblARInvoice I WITH(NOLOCK)
			INNER JOIN (
				SELECT intInvoiceId
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				WHERE intPaymentId = P.intPaymentId
				  AND intInvoiceId IS NOT NULL
			) ARDETAILS ON I.intInvoiceId = ARDETAILS.intInvoiceId

			UNION ALL

			SELECT strTransactionId = strBillId
			FROM dbo.tblAPBill BILL WITH(NOLOCK)
			INNER JOIN (
				SELECT intBillId
				FROM dbo.tblARPaymentDetail WITH (NOLOCK)
				WHERE intPaymentId = P.intPaymentId
				  AND intBillId IS NOT NULL
			) BILLDETAILS ON BILL.intBillId = BILLDETAILS.intBillId
		) T		
		FOR XML PATH ('')
	) TRANS (strTransactionId)
) TRANSACTIONS

ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentDelete
ALTER TABLE tblARPayment ENABLE TRIGGER trg_tblARPaymentUpdate
ALTER TABLE tblARPaymentDetail ENABLE TRIGGER trg_tblARPaymentDetailUpdate