CREATE VIEW [dbo].[vyuARSearchPOS]
AS 
SELECT intPOSId					= POS.intPOSId
	 , intEntityCustomerId		= POS.intEntityCustomerId
	 , intBillToId				= CUSTOMER.intBillToId
	 , intShipToId				= CUSTOMER.intShipToId
	 , intDocumentMaintenanceId	= POS.intDocumentMaintenanceId	 
	 , dtmDate					= POS.dtmDate
	 , strReceiptNumber			= POS.strReceiptNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strUserName				= USERNAME.strName
	 , strPONumber				= POS.strPONumber
	 , strBillToLocationName	= CUSTOMER.strBillToLocationName
	 , strBillToAddress			= CUSTOMER.strBillToAddress
	 , strBillToCity			= CUSTOMER.strBillToCity
	 , strBillToCountry			= CUSTOMER.strBillToCountry
	 , strBillToState			= CUSTOMER.strBillToState
	 , strBillToZipCode			= CUSTOMER.strBillToZipCode
	 , dblTotal					= POS.dblTotal
	 , dblCreditLimit			= CUSTOMER.dblCreditLimit
	 , dblARBalance				= CUSTOMER.dblARBalance
	 , ysnHold					= POS.ysnHold
	 , ysnReturn				= POS.ysnReturn
	 , ysnPaid					= CASE WHEN POS.intInvoiceId IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
		 , intBillToId
		 , intShipToId
		 , dblCreditLimit
		 , dblARBalance
		 , strName
		 , strBillToLocationName
		 , strBillToAddress
		 , strBillToCity
		 , strBillToCountry
		 , strBillToState
		 , strBillToZipCode
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON POS.intEntityCustomerId = CUSTOMER.intEntityCustomerId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERNAME ON POS.intEntityUserId = USERNAME.intEntityId