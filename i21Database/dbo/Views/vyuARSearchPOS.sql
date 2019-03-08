CREATE VIEW [dbo].[vyuARSearchPOS]
AS 
SELECT intPOSId					= POS.intPOSId
	 , intEntityCustomerId		= POS.intEntityCustomerId
	 , intBillToId				= CUSTOMER.intBillToId
	 , intShipToId				= CUSTOMER.intShipToId
	 , intCompanyLocationId		= POS.intCompanyLocationId
	 , dtmDate					= POS.dtmDate
	 , strCreditCode			= CUSTOMER.strCreditCode
	 , strReceiptNumber			= POS.strReceiptNumber
	 , strCustomerName			= CUSTOMER.strName
	 , strUserName				= USERNAME.strName
	 , strPONumber				= POS.strPONumber
	 , strComment				= POS.strComment
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
	 , ysnPaid					= ISNULL(INV.ysnPaid, 0)
	 , ysnTaxExempt				= ISNULL(POS.ysnTaxExempt,0)
FROM dbo.tblARPOS POS WITH (NOLOCK)
INNER JOIN (
	SELECT intEntityCustomerId
		 , intBillToId
		 , intShipToId
		 , dblCreditLimit
		 , dblARBalance
		 , strCreditCode
		 , strName
		 , strBillToLocationName
		 , strBillToAddress
		 , strBillToCity
		 , strBillToCountry
		 , strBillToState
		 , strBillToZipCode
	FROM dbo.vyuARCustomerSearch WITH (NOLOCK)
) CUSTOMER ON POS.intEntityCustomerId = CUSTOMER.intEntityCustomerId
LEFT JOIN (
	SELECT intInvoiceId
	     , ysnPaid
	FROM dbo.tblARInvoice
) INV ON INV.intInvoiceId = POS.intInvoiceId
INNER JOIN (
	SELECT intEntityId
		 , strName
	FROM dbo.tblEMEntity WITH (NOLOCK)
) USERNAME ON POS.intEntityUserId = USERNAME.intEntityId