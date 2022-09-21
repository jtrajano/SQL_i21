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

UPDATE P
SET strInvoices 		= TRANSACTIONS.strTransactionNumber
  , intCurrentStatus	= 5
FROM tblARPayment P
INNER JOIN  @FinalPaymentId FP ON P.intPaymentId = FP.intId
CROSS APPLY (
	SELECT strTransactionNumber = LEFT(strTransactionNumber, LEN(strTransactionNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(PD.strTransactionNumber AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD
		WHERE FP.intId = PD.intPaymentId
		FOR XML PATH ('')
	) TRANS (strTransactionNumber)
) TRANSACTIONS