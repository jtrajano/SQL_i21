CREATE PROCEDURE uspARGetScheduledPayments
AS
BEGIN TRY
	BEGIN TRANSACTION

	IF OBJECT_ID('tempdb..#PAYMENTSTOPROCESS') IS NOT NULL DROP TABLE #PAYMENTSTOPROCESS	

	DECLARE @strVersion NVARCHAR(100)

	SELECT TOP 1 @strVersion = strVersionNo
	FROM tblSMBuildNumber
	ORDER BY intVersionID DESC

	SELECT intPaymentId			= P.intPaymentId
		 , intEntityCardInfoId	= P.intEntityCardInfoId
		 , intEntityCustomerId	= P.intEntityCustomerId		 
		 , intBankAccountId		= P.intBankAccountId
		 , intDayOfMonth		= CI.intDayOfMonth
         , intEntityUserId      = P.intEntityId
		 , intCompanyLocationId	= P.intLocationId
		 , dtmDatePaid			= P.dtmDatePaid
		 , dtmScheduledPayment	= P.dtmScheduledPayment
		 , dblAmountPaid		= P.dblAmountPaid
		 , strRecordNumber		= P.strRecordNumber
		 , strCustomerNumber	= C.strCustomerNumber
		 , strInvoices			= INVOICE.strInvoiceNumbers
		 , ysnValidated			= CAST(0 AS BIT)
		 , ysnValid				= CAST(0 AS BIT)
		 , strError				= CAST('' AS NVARCHAR(500))
		 , strVersion			= @strVersion
		 , strUserName			= EC.strUserName
	INTO #PAYMENTSTOPROCESS
	FROM tblARPayment P
	INNER JOIN tblARCustomer C ON P.intEntityCustomerId = C.intEntityId
	INNER JOIN tblEMEntityCardInformation CI ON P.intEntityCardInfoId = CI.intEntityCardInfoId
	INNER JOIN tblEMEntityCredential EC ON P.intEntityId = EC.intEntityId
	CROSS APPLY (
		SELECT strInvoiceNumbers = LEFT(strTransactionNumber, LEN(strTransactionNumber) - 1) COLLATE Latin1_General_CI_AS
		FROM (
			SELECT CAST(PD.strTransactionNumber AS VARCHAR(200))  + ', '
			FROM tblARPaymentDetail PD WITH(NOLOCK)			
			WHERE PD.intPaymentId = P.intPaymentId
			  AND PD.dblPayment != 0
			FOR XML PATH ('')
		) INV (strTransactionNumber)
	) INVOICE
	WHERE P.intPaymentMethodId = 11
	  AND P.ysnScheduledPayment = 1
	  AND CI.ysnAutoPay = 1
	  AND P.ysnProcessCreditCard = 0
	  AND P.ysnPosted = 0
	  AND CAST(P.dtmScheduledPayment AS DATE) >= P.dtmDatePaid
	  AND CAST(P.dtmScheduledPayment AS DATE) = CAST(GETDATE() AS DATE)
	  AND (DAY(GETDATE()) = CI.intDayOfMonth) --OR (CI.intDayOfMonth < DAY(DATEADD(d, -1, DATEADD(M, DATEDIFF(M, 0, GETDATE()) + 1, 0)))           ) )
	
	WHILE EXISTS (SELECT TOP 1 NULL FROM #PAYMENTSTOPROCESS WHERE ysnValidated = 0)
		BEGIN
			DECLARE @intPaymentId		INT = NULL
				  , @intBankAccountId	INT = NULL
				  , @dtmPostDate		DATETIME = NULL
				  , @strError			NVARCHAR(500) = NULL
			
			SELECT TOP 1 @intPaymentId	 = intPaymentId
				       , @intBankAccountId	= intBankAccountId
					   , @dtmPostDate		= dtmDatePaid
			FROM #PAYMENTSTOPROCESS 
			WHERE ysnValidated = 0
			
			EXEC uspARValidatePaymentPosting @PaymentId     = @intPaymentId
										   , @Post          = 1
										   , @UserId        = 1
										   , @BankAccountId = @intBankAccountId
										   , @BatchId       = NULL
										   , @PostDate      = @dtmPostDate
										   , @Error         = @strError OUT

			UPDATE #PAYMENTSTOPROCESS 
			SET ysnValidated	= 1
			  , ysnValid		= CASE WHEN ISNULL(@strError, '') <> '' THEN 0 ELSE 1 END
			  , strError		= NULLIF(@strError, '')
			WHERE intPaymentId = @intPaymentId
		END

	SELECT * FROM #PAYMENTSTOPROCESS WHERE ysnValid = 1

	COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()
	ROLLBACK TRANSACTION 

	RAISERROR(@strErrorMsg, 11, 1) 
END CATCH

