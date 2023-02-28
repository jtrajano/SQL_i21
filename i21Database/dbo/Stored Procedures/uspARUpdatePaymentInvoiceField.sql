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

UPDATE P
SET strTicketNumbers 		= SCALETICKETS.strTicketNumbers
  , intCurrentStatus		= 5
FROM tblARPayment P
INNER JOIN @FinalPaymentId FP ON P.intPaymentId = FP.intId
CROSS APPLY (
	SELECT strTicketNumbers = LEFT(strTicketNumber, LEN(strTicketNumber) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(I.strTicketNumbers AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD WITH(NOLOCK)
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE PD.intPaymentId = P.intPaymentId
		  AND I.strTicketNumbers IS NOT NULL
		FOR XML PATH ('')
	) INV (strTicketNumber)
) SCALETICKETS

UPDATE P
SET strTicketNumbers 		= CUSTOMERREFERENCES.strCustomerReferences
  , intCurrentStatus		= 5
FROM tblARPayment P
INNER JOIN @FinalPaymentId FP ON P.intPaymentId = FP.intId
CROSS APPLY (
	SELECT strCustomerReferences = LEFT(strCustomerReference, LEN(strCustomerReference) - 1) COLLATE Latin1_General_CI_AS
	FROM (
		SELECT CAST(I.strCustomerReferences AS VARCHAR(200))  + ', '
		FROM tblARPaymentDetail PD WITH(NOLOCK)
		INNER JOIN tblARInvoice I ON PD.intInvoiceId = I.intInvoiceId
		WHERE PD.intPaymentId = P.intPaymentId
		  AND I.strCustomerReferences IS NOT NULL
		FOR XML PATH ('')
	) INV (strCustomerReference)
) CUSTOMERREFERENCES

IF ISNULL(@ysnRebuild, 0) = 1
	BEGIN
		INSERT INTO tblARPaymentBankAccount (
			intBankAccountId
			, strBankAccountNo
			, intConcurrencyId
		)
		SELECT intBankAccountId	= B.intBankAccountId
			, strBankAccountNo	= dbo.fnAESDecryptASym(B.strBankAccountNo)
			, intConcurrencyId	= 1
		FROM tblCMBankAccount B
		LEFT JOIN tblARPaymentBankAccount PBA ON B.intBankAccountId = PBA.intBankAccountId
		WHERE PBA.intPaymentBankAccount IS NULL
	END