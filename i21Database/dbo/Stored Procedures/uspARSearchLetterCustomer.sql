CREATE PROCEDURE [dbo].[uspARSearchLetterCustomer]
(
	@intLetterId	INT,
	@ysnEmailOnly	BIT = 0
)
AS
DECLARE @strLetterName			NVARCHAR(MAX),
		@ysnSystemDefined		BIT,
	    @intCompanyLocationId	INT,
		@strCompanyName			NVARCHAR(100),
		@strCompanyAddress		NVARCHAR(100),
		@strCompanyPhone		NVARCHAR(50)

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

SELECT @strLetterName		= strName
	 , @ysnSystemDefined	= ysnSystemDefined 
FROM dbo.tblSMLetter WITH (NOLOCK)
WHERE intLetterId = CAST(@intLetterId AS NVARCHAR(10))
SET NOCOUNT OFF;

SET NOCOUNT ON;
SELECT TOP 1 
	@intCompanyLocationId	= intCompanySetupID,
	@strCompanyName			= strCompanyName,
	@strCompanyAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL),
	@strCompanyPhone		= strPhone
FROM dbo.tblSMCompanySetup WITH (NOLOCK)
SET NOCOUNT OFF;

DECLARE @temp_availablecustomer_table TABLE(
	 [intEntityCustomerId]		INT
	,[strCustomerName]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
)

DECLARE @temp_return_table TABLE(
	 [intEntityCustomerId]		INT
	,[strCustomerName]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
	,[ysnHasEmailSetup]			BIT
)

IF @strLetterName NOT IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review', 'Service Charge Invoices Letter') AND ISNULL(@ysnSystemDefined, 1) = 1
BEGIN
	TRUNCATE TABLE tblARCustomerAgingStagingTable
	INSERT INTO tblARCustomerAgingStagingTable (
		   strCustomerName
		, strCustomerNumber
		, strInvoiceNumber
		, strRecordNumber
		, intInvoiceId
		, strBOLNumber
		, intEntityCustomerId
		, dblCreditLimit
		, dblTotalAR
		, dblFuture
		, dbl0Days
		, dbl10Days
		, dbl30Days
		, dbl60Days
		, dbl90Days
		, dbl120Days
		, dbl121Days
		, dblTotalDue
		, dblAmountPaid
		, dblInvoiceTotal
		, dblCredits
		, dblPrepayments
		, dblPrepaids
		, dtmDate
		, dtmDueDate
		, dtmAsOfDate
		, strSalespersonName
		, intCompanyLocationId
		, strSourceTransaction
		, strType
		, strCompanyName
		, strCompanyAddress
	)
	EXEC dbo.uspARCustomerAgingDetailAsOfDateReport @ysnInclude120Days = 1

	DELETE FROM tblARCustomerAgingStagingTable WHERE strType = 'CF Tran'

	DELETE FROM tblARCollectionOverdueDetail
	INSERT INTO tblARCollectionOverdueDetail
	(
		intCompanyLocationId		 
		,strCompanyName				 
		,strCompanyAddress			 
		,strCompanyPhone			 
		,intEntityCustomerId		 
		,strCustomerNumber			 
		,strCustomerName			 
		,strCustomerAddress			 
		,strCustomerPhone			 
		,strAccountNumber			 
		,intInvoiceId				 
		,strInvoiceNumber			 
		,strBOLNumber				 
		,dblCreditLimit				 
		,intTermId					 
		,strTerm					 
		,dblTotalAR					 
		,dblFuture					 
		,dbl0Days					 
		,dbl10Days					 
		,dbl30Days					 
		,dbl60Days					 
		,dbl90Days					 
		,dbl120Days					 
		,dbl121Days					 
		,dblTotalDue				 
		,dblAmountPaid				 
		,dblInvoiceTotal			 		 
		,dblCredits					 	
		,dblPrepaids				 	
		,dtmDate					 
		,dtmDueDate					 
	)
	SELECT intCompanyLocationId		=	@intCompanyLocationId
		, strCompanyName			=	@strCompanyName
		, strCompanyAddress			=	@strCompanyAddress
		, strCompanyPhone			=	@strCompanyPhone
		, intEntityCustomerId		=	AGING.intEntityCustomerId
		, strCustomerNumber			=	AGING.strCustomerName
 		, strCustomerName			=	CUSTOMER.strName
		, strCustomerAddress		=	[dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, CUSTOMER.strBillToAddress, CUSTOMER.strBillToCity, CUSTOMER.strBillToState, CUSTOMER.strBillToZipCode, CUSTOMER.strBillToCountry, CUSTOMER.strName, NULL)
		, strCustomerPhone			=	CUSTOMER.strPhone
		, strAccountNumber			=	CUSTOMER.strAccountNumber
		, intInvoiceId				=	AGING.intInvoiceId	
		, strInvoiceNumber			=	AGING.strInvoiceNumber		 
		, strBOLNumber				=	AGING.strBOLNumber
		, dblCreditLimit			=	AGING.dblCreditLimit				 
		, intTermId					=	CUSTOMER.intTermsId			 
		, strTerm					=	''--CUSTOMER.strTerm
		, dblTotalAR				=	AGING.dblTotalAR	 
		, dblFuture					=	AGING.dblFuture	 					 
		, dbl0Days					=	AGING.dbl0Days	 					 
		, dbl10Days					=	AGING.dbl10Days	 					 
		, dbl30Days					=	AGING.dbl30Days	 					 
		, dbl60Days					=	AGING.dbl60Days	 					 
		, dbl90Days					=	AGING.dbl90Days	 				 
		, dbl120Days				=	AGING.dbl120Days	 					 
		, dbl121Days				=	AGING.dbl121Days	 					 
		, dblTotalDue				=	AGING.dblTotalDue	 			 
		, dblAmountPaid				=	AGING.dblAmountPaid				 
		, dblInvoiceTotal			=	AGING.dblInvoiceTotal		 
		, dblCredits				=	AGING.dblCredits						 	
		, dblPrepaids				=	AGING.dblPrepaids					 	
		, dtmDate					=	AGING.dtmDate						 
		, dtmDueDate				=	AGING.dtmDueDate		 
	FROM tblARCustomerAgingStagingTable AGING
	INNER JOIN (SELECT intEntityId
					 , intTermsId
					 , strName
					 , strBillToAddress
					 , strBillToCity
					 , strBillToState
					 , strBillToZipCode
					 , strBillToCountry
					 , strPhone
					 , strAccountNumber
				FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
	) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityId
	WHERE AGING.intInvoiceId NOT IN (SELECT intInvoiceId 
									 FROM dbo.tblARInvoice WITH (NOLOCK)
									 WHERE strTransactionType IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') AND ysnPaid = 1)
			
	DELETE FROM tblARCollectionOverdue				
	INSERT INTO tblARCollectionOverdue
	(
		intEntityCustomerId 				 
		,dblCreditLimitSum	  				 
		,dblTotalARSum 						 
		,dblFutureSum 				 
		,dbl0DaysSum 						 
		,dbl10DaysSum 					 
		,dbl30DaysSum  						 
		,dbl60DaysSum 					 
		,dbl90DaysSum 						 
		,dbl120DaysSum  						 
		,dbl121DaysSum 						 
		,dblTotalDueSum 				 
		,dblAmountPaidSum  					 
		,dblInvoiceTotalSum	 			 		 
		,dblCreditsSum 					 	
		,dblPrepaidsSum  	
	)
	SELECT 			 
		intEntityCustomerId 				 
		,dblCreditLimitSum		= SUM(dblCreditLimit) 				 
		,dblTotalARSum			= SUM(dblTotalAR) 						 
		,dblFutureSum			= SUM(dblFuture) 						 
		,dbl0DaysSum			= SUM(dbl0Days) 						 
		,dbl10DaysSum			= SUM(dbl10Days) 						 
		,dbl30DaysSum			= SUM(dbl30Days) 						 
		,dbl60DaysSum			= SUM(dbl60Days) 						 
		,dbl90DaysSum			= SUM(dbl90Days) 						 
		,dbl120DaysSum			= SUM(dbl120Days) 						 
		,dbl121DaysSum			= SUM(dbl121Days) 						 
		,dblTotalDueSum			= SUM(dblTotalDue) 					 
		,dblAmountPaidSum		= SUM(dblAmountPaid) 					 
		,dblInvoiceTotalSum		= SUM(dblInvoiceTotal) 				 		 
		,dblCreditsSum			= SUM(dblCredits) 						 	
		,dblPrepaidsSum			= SUM(dblPrepaids) 					 	
	FROM tblARCustomerAgingStagingTable
	GROUP BY intEntityCustomerId
END
	
IF @strLetterName = 'Recent Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT ARCO.intEntityCustomerId
		 , ENTITY.strName
		 , ENTITY.strCustomerNumber
	FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId 
					 , strName
					 , strCustomerNumber
				FROM dbo.vyuARCustomer WITH (NOLOCK) 
				WHERE ysnActive = 1
	) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
	WHERE (ISNULL(dbl10DaysSum,0) <> 0 OR ISNULL(dbl30DaysSum,0) <> 0 OR ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
END

ELSE IF @strLetterName = '30 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT ARCO.intEntityCustomerId
		 , ENTITY.strName
		 , ENTITY.strCustomerNumber
	FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId 
					 , strName
					 , strCustomerNumber
				FROM dbo.vyuARCustomer WITH (NOLOCK) 
				WHERE ysnActive = 1
	) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
	WHERE (ISNULL(dbl60DaysSum,0) <> 0 OR  ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
END

ELSE IF @strLetterName = '60 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT ARCO.intEntityCustomerId
		 , ENTITY.strName
		 , ENTITY.strCustomerNumber
	FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId 
					 , strName
					 , strCustomerNumber
				FROM dbo.vyuARCustomer WITH (NOLOCK) 
				WHERE ysnActive = 1
	) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
	WHERE (ISNULL(dbl90DaysSum,0) <> 0 OR  ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
END

ELSE IF @strLetterName = '90 Day Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT ARCO.intEntityCustomerId
		 , ENTITY.strName
		 , ENTITY.strCustomerNumber
	FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId 
					 , strName
					 , strCustomerNumber
				FROM dbo.vyuARCustomer WITH (NOLOCK) 
				WHERE ysnActive = 1
	) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
	WHERE (ISNULL(dbl120DaysSum,0) <> 0 OR  ISNULL(dbl121DaysSum,0) <> 0)
END

ELSE IF @strLetterName = 'Final Overdue Collection Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT ARCO.intEntityCustomerId
		 , ENTITY.strName
		 , ENTITY.strCustomerNumber
	FROM dbo.tblARCollectionOverdue ARCO WITH (NOLOCK)
	INNER JOIN (SELECT intEntityId 
					 , strName
					 , strCustomerNumber
				FROM dbo.vyuARCustomer WITH (NOLOCK) 
				WHERE ysnActive = 1
	) ENTITY ON ARCO.intEntityCustomerId = ENTITY.intEntityId
	WHERE (ISNULL(dbl121DaysSum,0) <> 0)
END

ELSE IF @strLetterName = 'Credit Suspension'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK) 
	WHERE ysnActive = 1
	  AND dblCreditLimit = 0
END

ELSE IF @strLetterName = 'Expired Credit Card'  
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK) 
	WHERE ysnActive = 1
	  AND dblCreditLimit = 0
END

ELSE IF @strLetterName = 'Credit Review'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK) 
	WHERE ysnActive = 1
	  AND dblCreditLimit > 0
END

ELSE IF @strLetterName = 'Service Charge Invoices Letter'
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT DISTINCT 
		   intEntityCustomerId
		 , strCustomerNumber
		 , strCustomerName
	FROM vyuARServiceChargeInvoiceReport	
END

ELSE
BEGIN
	INSERT INTO @temp_availablecustomer_table
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK) 
	WHERE ysnActive = 1
END

IF ISNULL(@strLetterName, '') <> ''
	BEGIN
		INSERT INTO @temp_return_table
		SELECT intEntityCustomerId
			 , strCustomerName
			 , strCustomerNumber
			 , CASE WHEN ISNULL(EMAILSETUP.intEmailSetupCount, 0) > 0 THEN CONVERT(BIT, 1) ELSE CONVERT(BIT, 0) END
		FROM @temp_availablecustomer_table C
		OUTER APPLY (
			SELECT intEmailSetupCount = COUNT(*) 
			FROM dbo.vyuARCustomerContacts CC WITH (NOLOCK)
			WHERE CC.intCustomerEntityId = C.intEntityCustomerId 
			  AND ISNULL(CC.strEmail, '') <> '' 
			  AND CC.strEmailDistributionOption LIKE '%Letter%'
		) EMAILSETUP

		IF @ysnEmailOnly = 1
			DELETE FROM @temp_return_table WHERE ysnHasEmailSetup = 0
		ELSE
			DELETE FROM @temp_return_table WHERE ysnHasEmailSetup = 1

		IF @strLetterName NOT IN ('Credit Suspension', 'Expired Credit Card', 'Credit Review', 'Service Charge Invoices Letter')
			BEGIN
				DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_return_table)
				DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_return_table)
			END

		SET NOCOUNT ON;
		SELECT * FROM @temp_return_table ORDER BY strCustomerName
		SET NOCOUNT OFF;
	END
