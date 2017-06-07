CREATE PROCEDURE [dbo].[uspARSearchLetterCustomer]
(
	@intLetterId INT
)
AS
DECLARE @strLetterName			NVARCHAR(MAX),
	    @intCompanyLocationId	INT,
		@strCompanyName			NVARCHAR(100),
		@strCompanyAddress		NVARCHAR(100),
		@strCompanyPhone		NVARCHAR(50)

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

SELECT @strLetterName = strName 
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

DECLARE @temp_aging_table TABLE(
	 [strCustomerName]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(15)	COLLATE Latin1_General_CI_AS
	,[strInvoiceNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[strRecordNumber]			NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intInvoiceId]				INT	
	,[strBOLNumber]				NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intEntityCustomerId]		INT				
	,[dblCreditLimit]			NUMERIC(18,6)
	,[dblTotalAR]				NUMERIC(18,6)
	,[dblFuture]				NUMERIC(18,6)
	,[dbl0Days]					NUMERIC(18,6)
	,[dbl10Days]				NUMERIC(18,6)
	,[dbl30Days]				NUMERIC(18,6)
	,[dbl60Days]				NUMERIC(18,6)
	,[dbl90Days]				NUMERIC(18,6)
	,[dbl120Days]				NUMERIC(18,6) 
	,[dbl121Days]				NUMERIC(18,6) 
	,[dblTotalDue]				NUMERIC(18,6)
	,[dblAmountPaid]			NUMERIC(18,6)
	,[dblInvoiceTotal]			NUMERIC(18,6)
	,[dblCredits]				NUMERIC(18,6)
	,[dblPrepaids]				NUMERIC(18,6)
	,[dtmDate]					DATETIME
	,[dtmDueDate]				DATETIME
	,[dtmAsOfDate]				DATETIME
	,[strSalespersonName]		NVARCHAR(100)	COLLATE Latin1_General_CI_AS
	,[intCompanyLocationId]		INT
)

DECLARE @temp_availablecustomer_table TABLE(
	 [intEntityCustomerId]		INT
	,[strCustomerName]			NVARCHAR(200)	COLLATE Latin1_General_CI_AS
	,[strCustomerNumber]		NVARCHAR(50)	COLLATE Latin1_General_CI_AS
)

IF @strLetterName <> 'Service Charge Invoices Letter'
BEGIN
	INSERT INTO @temp_aging_table
	EXEC uspARCollectionOverdueDetailReport NULL, NULL  

	DELETE FROM @temp_aging_table
	WHERE [strInvoiceNumber] IN (SELECT [strInvoiceNumber] FROM tblARInvoice WITH (NOLOCK) WHERE strType IN ('CF Tran'))

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
	FROM @temp_aging_table AGING
	INNER JOIN (SELECT intEntityCustomerId
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
	) CUSTOMER ON AGING.intEntityCustomerId = CUSTOMER.intEntityCustomerId
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
	FROM 
		@temp_aging_table
	GROUP BY 
		intEntityCustomerId
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

	DELETE 
	FROM dbo.tblARCollectionOverdueDetail 
	WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE 
	FROM dbo.tblARCollectionOverdue 
	WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF @strLetterName = 'Expired Credit Card'  
BEGIN
	GetActiveCustomers:
	INSERT INTO @temp_availablecustomer_table
	SELECT intEntityId
		 , strName
		 , strCustomerNumber
	FROM dbo.vyuARCustomer WITH (NOLOCK) 
	WHERE ysnActive = 1
	  AND dblCreditLimit = 0
			
	DELETE FROM dbo.tblARCollectionOverdueDetail 
	WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ARC ORDER BY strCustomerName	
	SET NOCOUNT OFF;
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

	DELETE FROM dbo.tblARCollectionOverdueDetail WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	DELETE FROM dbo.tblARCollectionOverdue WHERE intEntityCustomerId NOT IN (SELECT intEntityCustomerId FROM @temp_availablecustomer_table)

	SET NOCOUNT ON;
	SELECT * FROM @temp_availablecustomer_table ORDER BY strCustomerName
	SET NOCOUNT OFF;
END

ELSE IF  @strLetterName = 'Service Charge Invoices Letter'
BEGIN
	SET NOCOUNT ON;
	SELECT I.intEntityCustomerId
		 , CUST.strCustomerNumber
		 , CUST.strCustomerName
	FROM dbo.tblARInvoice I WITH (NOLOCK)
	INNER JOIN (SELECT intEntityCustomerId
					 , strCustomerNumber
					 , strCustomerName  = strName
				FROM dbo.vyuARCustomer WITH (NOLOCK)
				WHERE ysnActive = 1
	) CUST ON I.intEntityCustomerId = CUST.intEntityCustomerId	 
	WHERE I.strType = 'Service Charge'
	GROUP BY I.intEntityCustomerId
		   , CUST.strCustomerNumber
		   , CUST.strCustomerName
	ORDER BY CUST.strCustomerName
	SET NOCOUNT OFF;	
END

ELSE
BEGIN
	GOTO GetActiveCustomers
END