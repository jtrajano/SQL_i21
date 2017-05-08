CREATE VIEW [dbo].[vyuARServiceChargeInvoiceReport]
AS
SELECT 
	ARI.intInvoiceId
	, ARID.intInvoiceDetailId	
	, ARI.strInvoiceNumber
	, ARI.dtmDate
	, ARI.dtmDueDate
	, ARI.intTermId
	, SMT.strTerm
	, dblInvoiceTotal			= Summary.dblTotal
	, dblBaseInvoiceTotal		= Summary.dblBaseTotal
	, dblTotalDue				= ARID.dblTotal
	, dblBaseTotalDue			= ARID.dblBaseTotal
	, ARI.intEntityCustomerId
	, ARC.strCustomerNumber
	, strCustomerName			= EME.strName
	, ARC.strAccountNumber
	, strCustomerAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, EME.strName, EMELoc.strBillToAddress, EMELoc.strBillToCity, EMELoc.strBillToState, EMELoc.strBillToZipCode, EMELoc.strBillToCountry, NULL, NULL)
	, intCompanyLocationId		= SMCS.intCompanyLocationId
	, strCompanyName			= SMCS.strCompanyName
	, strCompanyPhone			= SMCS.strCompanyPhone
	, strCompanyFax				= SMCS.strCompanyFax
	, strCompanyEmail			= SMCS.strCompanyEmail
	, dtmLetterDate					= GETDATE()
FROM 
	(SELECT intInvoiceId
		, intEntityCustomerId
		, strInvoiceNumber
		, dtmDate
		, dtmDueDate
		, intTermId
		, dblInvoiceTotal
		, dblBaseInvoiceTotal		
	 FROM 
		tblARInvoice WITH (NOLOCK)
	 WHERE 
		strType = 'Service Charge') ARI 
INNER JOIN 
	(
		SELECT 
			intInvoiceId
			, intInvoiceDetailId
			, dblTotal
			, dblBaseTotal
		FROM	
			tblARInvoiceDetail
	) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
INNER JOIN
	(SELECT 
		intTermID
		, strTerm 
	 FROM 
		tblSMTerm WITH (NOLOCK)) SMT ON ARI.intTermId = SMT.intTermID
INNER JOIN (SELECT intEntityId
				, strCustomerNumber
				, strAccountNumber
				, intBillToId 
		    FROM 
				tblARCustomer WITH(NOLOCK)) ARC ON ARI.intEntityCustomerId = ARC.intEntityId
INNER JOIN (SELECT intEntityId
				, strName 
			FROM 
				tblEMEntity WITH(NOLOCK)) EME ON ARC.intEntityId = EME.intEntityId
INNER JOIN (SELECT intEntityId
				, intEntityLocationId
				, strBillToAddress		= strAddress
				, strBillToCity			= strCity
				, strBillToLocationName	= strLocationName
				, strBillToCountry		= strCountry
				, strBillToState		= strState
				, strBillToZipCode		= strZipCode
			FROM 
				tblEMEntityLocation WITH(NOLOCK)
			) EMELoc ON ARC.intEntityId = EMELoc.intEntityId AND ARC.intBillToId = EMELoc.intEntityLocationId
INNER JOIN 	
	(
		SELECT intEntityCustomerId
			, dblTotal				= SUM(dblTotal)
			, dblBaseTotal			= SUM(dblBaseTotal)
		FROM 
			(
				SELECT 
					ARI.intEntityCustomerId  
					, ARID.dblTotal
					, ARID.dblBaseTotal
				FROM 
					tblARInvoice ARI WITH (NOLOCK) 
				INNER JOIN 
					(SELECT 
						intInvoiceId
						, dblTotal
						, dblBaseTotal
					 FROM 
						tblARInvoiceDetail WITH (NOLOCK)) ARID ON ARI.intInvoiceId = ARID.intInvoiceId
				WHERE 
					ARI.strType = 'Service Charge'
			)  Totals
		GROUP BY intEntityCustomerId
	) Summary ON ARC.intEntityId = Summary.intEntityCustomerId
 CROSS JOIN (SELECT intCompanyLocationId	= intCompanySetupID
					, strCompanyName		= strCompanyName
					, strCompanyAddress		= [dbo].fnARFormatCustomerAddress(NULL, NULL, NULL, strAddress, strCity, strState, strZip, strCountry, NULL, NULL)
					, strCompanyPhone		= strPhone
					, strCompanyFax			= strFax
					, strCompanyEmail		= strEmail
			 FROM	
				tblSMCompanySetup WITH(NOLOCK)) SMCS