CREATE VIEW [dbo].[vyuARInvoiceAgingReport]
AS

SELECT * FROM (
	SELECT  strInvoiceNumber							= STAGING.strInvoiceNumber
		  , intInvoiceId								= STAGING.intInvoiceId
		  , strBOLNumber								= STAGING.strBOLNumber
		  , intEntityCustomerId							= STAGING.intEntityCustomerId
		  , dblTotalAR									= SUM(STAGING.dblTotalAR)
		  , dblFuture									= SUM(STAGING.dblFuture)
		  , dbl0Days									= SUM(STAGING.dbl0Days)
		  , dbl10Days									= SUM(STAGING.dbl10Days)
		  , dbl30Days									= SUM(STAGING.dbl30Days)
		  , dbl60Days									= SUM(STAGING.dbl60Days)
		  , dbl90Days									= SUM(STAGING.dbl90Days)
		  , dbl91Days									= SUM(STAGING.dbl120Days +  STAGING.dbl121Days) 
		  , dblTotalDue									= SUM(STAGING.dblTotalDue)
		  , dblAmountPaid								= SUM(STAGING.dblAmountPaid)
		  , dblInvoiceTotal								= STAGING.dblInvoiceTotal
		  , dblCredits									= STAGING.dblCredits
		  , dblPrepayments								= STAGING.dblPrepayments
		  , dblPrepaids									= STAGING.dblPrepaids
		  , dtmDate										= INVOICE.dtmDate
		  , dtmDueDate									= STAGING.dtmDueDate
		  , intCompanyLocationId						= STAGING.intCompanyLocationId
		  , strTransactionType							= STAGING.strTransactionType
		  , dblCreditLimit								= STAGING.dblCreditLimit
		  , strCustomerName								= STAGING.strCustomerName
		  , strCustomerNumber							= STAGING.strCustomerNumber
		  , intEntityUserId								= STAGING.intEntityUserId
		  , intCurrencyId								= INVOICE.intCurrencyId
		  , intAccountId								= INVOICE.intAccountId
		  , strAccountingPeriod							= AccPeriod.strAccountingPeriod
		  , strShipToLocation							= SHIPTOLOCATION.strAddress
		  , strBillToLocation							= BILLTOLOCATION.strAddress
		  , strDefaultLocation							= DEFAULTLOCATION.strAddress
		  , strDefaultShipTo							= CUSTOMER.strDefaultShipTo
		  , strDefaultBillTo							= CUSTOMER.strDefaultBillTo
		  , strCurrency									= CUR.strCurrency
		  , strCurrencyDescription						= CUR.strDescription
		  , strLocationName								= COMPANYLOCATION.strLocationName
	FROM tblARCustomerAgingStagingTable STAGING
	INNER JOIN ( 
		SELECT     intInvoiceId
				 , intAccountId
				 , intCurrencyId
				 , intShipToLocationId
				 , intBillToLocationId
				 , dtmDate
		 FROM tblARInvoice WITH (NOLOCK) 
	) INVOICE  
	ON STAGING.intInvoiceId = INVOICE.intInvoiceId
	OUTER APPLY ( 
	    SELECT TOP 1 strAccountingPeriod = P.strPeriod 
	    FROM tblGLFiscalYearPeriod P
	    WHERE P.intGLFiscalYearPeriodId = STAGING.intInvoiceId
	) AccPeriod
	LEFT JOIN (
		SELECT intCurrencyID
			 , strCurrency
			 , strDescription
		FROM dbo.tblSMCurrency
	) CUR 
	ON CUR.intCurrencyID = INVOICE.intCurrencyId
	LEFT JOIN ( 
		SELECT intEntityId
			 , intEntityLocationId
			 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
		WHERE ysnDefaultLocation = 1
	) SHIPTOLOCATION 
	ON SHIPTOLOCATION.intEntityLocationId  = INVOICE.intShipToLocationId AND 
	   SHIPTOLOCATION.intEntityId = STAGING.intEntityCustomerId 
	LEFT JOIN (
		SELECT intEntityId
			 , intEntityLocationId
			 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
		WHERE ysnDefaultLocation = 1
	) BILLTOLOCATION 
	ON BILLTOLOCATION.intEntityLocationId = INVOICE.intBillToLocationId AND 
	   BILLTOLOCATION.intEntityId = STAGING.intEntityCustomerId 
    LEFT JOIN (
		SELECT intEntityId
			 , intEntityLocationId
			 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
		FROM dbo.tblEMEntityLocation WITH (NOLOCK)
		WHERE ysnDefaultLocation = 1
	) DEFAULTLOCATION 
	ON DEFAULTLOCATION.intEntityId = STAGING.intEntityCustomerId 
	INNER JOIN (
				SELECT C.intEntityId
					 , strDefaultShipTo = DEFAULTSHIPTO.strAddress
					 , strDefaultBillTo = DEFAULTBILLTO.strAddress
				FROM tblARCustomer C WITH (NOLOCK)
				LEFT JOIN (
					SELECT intEntityId
						 , intEntityLocationId
						 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
					FROM dbo.tblEMEntityLocation WITH (NOLOCK)
				) DEFAULTSHIPTO ON DEFAULTSHIPTO.intEntityLocationId = C.intShipToId
							   AND DEFAULTSHIPTO.intEntityId = C.intEntityId
				LEFT JOIN (
					SELECT intEntityId
						 , intEntityLocationId
						 , strAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, strLocationName, strAddress, strCity, strState, strZipCode, strCountry, NULL, 0) COLLATE Latin1_General_CI_AS
					FROM dbo.tblEMEntityLocation WITH (NOLOCK)
				) DEFAULTBILLTO ON DEFAULTBILLTO.intEntityLocationId = C.intBillToId
							   AND DEFAULTSHIPTO.intEntityId = C.intEntityId
	) CUSTOMER 
	ON  CUSTOMER.intEntityId = STAGING.intEntityCustomerId
	LEFT JOIN (
		SELECT intCompanyLocationId
			 , strLocationName
		FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
	) COMPANYLOCATION 
	ON COMPANYLOCATION.intCompanyLocationId = STAGING.intCompanyLocationId
	WHERE strAgingType = 'Detail'
	GROUP BY
	 STAGING.strInvoiceNumber
	,STAGING.intInvoiceId
	,STAGING.strBOLNumber
	,STAGING.intEntityCustomerId
	,STAGING.dblInvoiceTotal
	,STAGING.dblCredits
	,STAGING.dblPrepayments
	,STAGING.dblPrepaids
	,INVOICE.dtmDate
	,STAGING.dtmDueDate
	,STAGING.intCompanyLocationId
	,STAGING.strTransactionType
	,STAGING.dblCreditLimit
	,STAGING.strCustomerName
	,STAGING.strCustomerNumber
	,STAGING.intEntityUserId
	,INVOICE.intCurrencyId
	,INVOICE.intAccountId
	,AccPeriod.strAccountingPeriod
	,SHIPTOLOCATION.strAddress
	,BILLTOLOCATION.strAddress
	,DEFAULTLOCATION.strAddress
	,CUSTOMER.strDefaultShipTo
	,CUSTOMER.strDefaultBillTo
	,CUR.strCurrency
	,CUR.strDescription
	,COMPANYLOCATION.strLocationName
	)AGING
GO